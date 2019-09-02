/*
 * fifo-server.c
 *
 *  Created on: Apr 19, 2012
 *      Author: yangyy
 */


#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <bits/time.h>
#include <string.h>
#include <errno.h>
#include <assert.h>

#include <svdpi.h>
#include <vcsuser.h>
#ifdef __cplusplus
extern "C" {
#endif

#define FIFO_OPEN_TIMEOUT 100000 // micro second
#define FIFO_OPEN_REPEAT  36000	 // wait 60 minutes

enum _fifo_flag_
{
	SERVER_SIDE = 0, CLIENT_SIDE = 1, READ_PORT = 0, WRITE_PORT = 2
};

static char mapu_dir[64];
static const char* fifo_name[2] = {"TEMPORARY-FIFO-0", "TEMPORARY-FIFO-1"};
// server read  <--- fifo0 <---- client write
// server write  ---> fifo1 ----> client read

// fifo_path = mapu_dir + fifo_name
static char fifo_path[2][128];

static int fd_for_read = -1;
static int fd_for_write = -1;

static int
set_mapu_dir(void)
{
	char*home = getenv("HOME");
	int res, i;
	struct stat st;

	strcpy(mapu_dir, home);
	strcat(mapu_dir, "/.mapu.d/");

	res = stat(mapu_dir, &st);
	if(res == 0)    // dir already exists
	assert(S_ISDIR(st.st_mode));
	else {
		res = mkdir(mapu_dir, S_IRWXU | S_IRWXG | S_IRWXO);    // a dir MUST be X mode to create a file into it.
		if(res!=0)	{
			fprintf(stdout, "try to create ~/.mapu.d but failed\n");
			exit(-1);
		}
		res = chmod(mapu_dir, S_IRWXU | S_IRWXG | S_IRWXO);
	}

	for(i = 0; i < 2; i++) {
		strcpy(fifo_path[i], mapu_dir);
		strcat(fifo_path[i], fifo_name[i]);

		res = stat(fifo_path[i], &st);
		if(res == 0) { // file already exists
			if( !S_ISFIFO(st.st_mode) )
				res = remove(fifo_path[i]);
			else  {
				res = chmod(fifo_path[i], S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH);
				continue;
			}
		}
		res = mkfifo(fifo_path[i], S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH);
		if(res!=0) {
			fprintf(stdout, "try to create fifo but failed\n");
			exit(-1);
		}
		res = chmod(fifo_path[i], S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH);
	}
	return 0;
}

static int
open_fifo(int flags/*, int timeout*/)
{
	char op0[] = "read", op1[] = "write";
	char obj0[] = "simulator", obj1[] = "openocd";

	int ret, mode;
	char * path, *op, *obj;

	switch(flags & 0x3) {
		case (SERVER_SIDE | READ_PORT):
			mode = (O_RDONLY | O_NONBLOCK);
			path = fifo_path[0];
			op = op0;
			obj = obj0;
			break;
		case (CLIENT_SIDE | WRITE_PORT):
			mode = (O_WRONLY | O_NONBLOCK);
			path = fifo_path[0];
			op = op1;
			obj = obj1;
			break;
		case (SERVER_SIDE | WRITE_PORT):
			mode = (O_WRONLY | O_NONBLOCK);
			path = fifo_path[1];
			op = op1;
			obj = obj0;
			break;
		case (CLIENT_SIDE | READ_PORT):
			mode = (O_RDONLY | O_NONBLOCK);
			path = fifo_path[1];
			op = op0;
			obj = obj1;
			break;
		default:
			break;
	}
	int repeat = 0;
	do {
		ret = open(path, mode);
		if(ret < 0) {
			repeat++;
			if(repeat % 100 == 0) fprintf(stdout, "%d seconds has elapsed when %s tries to open fifo's %s port...\n",
											FIFO_OPEN_TIMEOUT * 100 / 1000000, obj, op);

			usleep(FIFO_OPEN_TIMEOUT);
		}
		else break;
	} while(repeat < FIFO_OPEN_REPEAT);

	return ret;
}

int
write_fifo(const char *buf, int size)
{
	int ret = write(fd_for_write, buf, size);
	int res;
	if(ret != size) fprintf(stdout, "write to fifo error, expect to write %d bytes other than %d bytes\n", size, ret);
	/*else {
		LOG_DEBUG("write %d bytes (expected %d bytes) to fifo: ", ret, size);
		for(res = 0; res < ret; res++) {
			LOG_DEBUG("(%02d)%02X", res + 1, (unsigned char) buf[res]);
			if((res + 1) % 10 == 0)
			 LOG_DEBUG("\n");
		}
		LOG_DEBUG("\n");
	}*/

	return ret;
}

int
init_fifo_server(void)
{
	set_mapu_dir();

	int res;
	char lock[128];
	const char suffix[] = ".server.lock";
	struct stat st;

	strcpy(lock, fifo_path[0]);
	strcat(lock, suffix);
	res = stat(lock, &st);

//	if(res != 0) { // usually lock does not exist
//	//	res = mkfifo(lock, S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH);
		fd_for_read = open_fifo(SERVER_SIDE | READ_PORT);
//	}
//	else {
//		fprintf(stdout, "----!!!! fifo is in use by other simulator process, please check !!!!----\n");
//		exit(-1);
//	}

	if(fd_for_read >= 0) {
		fprintf(stdout, "---- simulator opened fifo's read port successfully.\n");

		strcpy(lock, fifo_path[1]);
		strcat(lock, suffix);
		res = stat(lock, &st);

		if(res != 0) { // usually lock does not exist
		//	res = mkfifo(lock, S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH);
			fd_for_write = open_fifo(SERVER_SIDE | WRITE_PORT);
		}
		else {
			fprintf(stdout, "----!!!! fifo is in use by other simulator process, please check !!!!----\n");
			exit(-1);
		}

		if(fd_for_write >= 0) {
			char str[] = "---- simulator opened fifo's write port successfully.\n"
						 "---- simulator accepted connection from openocd.\n";
			fprintf(stdout, str);
			return 0;
		}
		else {
			fprintf(stdout, "---- simulator failed to open fifo's write port.\n");
			return -1;
		}
	}
	else {
		fprintf(stdout, "---- simulator failed to open fifo's read port.\n");
		return -1;
	}
}

int
deinit_fifo_server(void) {
	int res;
	char lock[128];
	const char suffix[] = ".server.lock";
	struct stat st;
	int i;
	for(i = 0; i < 2; i++) {
		strcpy(lock, fifo_path[i]);
		strcat(lock, suffix);

		res = stat(lock, &st);

		// usually lock does exist
		if(res == 0) res = remove(lock);
	}

	return 0;
}

void scanjtag(const char ojtag[9], char* ijtag)
{
	if (fd_for_read == -1) return;
        if(read(fd_for_read, ijtag, 9)>0)
	{
		write_fifo(ojtag, 9);
	}
}

#ifdef __cplusplus
}
#endif
