#include <iostream>
#include <string>
#include "VlogData2C.h"

using namespace std;

unsigned dm_num; // indentifier dm0/dm1/dm2 for further address generation

unsigned int getFileCharCount(const string& VlogFilename);
void setVlogFileBuf(char* vlog_buf, const unsigned len, const string& VlogFilename);

#include "vlog_parser.h"
#include "vlog_lexer.ragel"
#include "vlog_parser.bison"


int parseVlogData(const string& VlogFilename) {
  // check if the file has .dat postfix
  if(!ends_with(VlogFilename, ".dat")) {
    cout<<VlogFilename<<" is not a vlog dat file"<<endl;
    return -1;
  }
  if(VlogFilename.find("DM0.dat") != string::npos ||
     VlogFilename.find("dm0.dat") != string::npos) {
    cout<<"Load vlog dat file: "<<VlogFilename<<endl;
    dm_num = 0;
  }
  else if(VlogFilename.find("DM1.dat") != string::npos ||
          VlogFilename.find("dm1.dat") != string::npos) {
    cout<<"Load vlog dat file: "<<VlogFilename<<endl;
    dm_num = 1;
  }
  else if(VlogFilename.find("DM2.dat") != string::npos ||
          VlogFilename.find("dm2.dat") != string::npos) {
    cout<<"Load vlog dat file: "<<VlogFilename<<endl;
    dm_num = 2;
  }
  else if(VlogFilename.find("DM3.dat") != string::npos ||
          VlogFilename.find("dm3.dat") != string::npos) {
    cout<<"Load vlog dat file: "<<VlogFilename<<endl;
    dm_num = 3;
  }
  else {
    return -1;
  }

  
  //yydebug = 1;
  unsigned len = getFileCharCount(VlogFilename);
  if(len == 0) {
    cout<<"empty vlog file!"<<endl;
    return -1;
  }
  else
    cout<<"vlog file count: "<<len<<endl;

  struct vlog_param_strt *param = new vlog_param_strt();
  char* vlogbuf = new char[len + 1]();
  setVlogFileBuf(vlogbuf, len, VlogFilename);

  param->position.start = vlogbuf;
  param->position.end = vlogbuf + len;
  
  int err = vlogparse(param);
  if (err) {
    cout<<"parse has error!"<<endl;
  }
  else
    cout<<"vlog parse is done"<<endl;

  delete param;
  // write stack bottom-related data into data record
  if(!set_stack_record) {
    static struct dm_data_record *stack_record = NULL;
    stack_record = new struct dm_data_record;

    char *byte_str = new char[11]();
    byte_str[0] = '0'; byte_str[1] = 'x';
    byte_str[2] = '0'; byte_str[3] = '0';
    byte_str[4] = '0'; byte_str[5] = '2';
    byte_str[6] = 'f'; byte_str[7] = 'f';
    byte_str[8] = 'f'; byte_str[9] = '0';
    stack_record->byte_nums.push_back(byte_str);

    const unsigned MAX_ADDR_LEN = 80;
    char *addr_str = new char[MAX_ADDR_LEN]();
    char stack_addr_str[] = "3fffc";
    strcpy(addr_str, stack_addr_str);
    stack_record->dm_addr = addr_str;
    dm_data_records.push_back(stack_record);
    cout<<"stack bottom configuration data is generated"<<endl;
    set_stack_record = true;
  }

  return 0;
}

#include <fstream>

unsigned int getFileCharCount(const string& VlogFilename) {
  unsigned int count = 0;
  fstream fin(VlogFilename, fstream::in);
  if(!fin.is_open()) {
    cout<<"Unable to open file "<<VlogFilename<<endl;
    return 0;
  }
  char ch;

  while(fin >> noskipws >> ch) {
    count++;
  }
  fin.close();

  return count;
}

void setVlogFileBuf(char* vlog_buf, const unsigned len, const string& VlogFilename) {
  fstream fin(VlogFilename, fstream::in);
  unsigned i = 0;
  char ch;
  while(fin >> noskipws >> ch) {
    vlog_buf[i++] = ch;
  }
  fin.close();
}

//convert int to hex
string int_to_hex(unsigned w)
{
  unsigned hex_len = sizeof(unsigned) << 1;
  static const char* digits = "0123456789abcdef";
  std::string rc(hex_len,'0');
  for (unsigned i=0, j=(hex_len-1)*4 ; i<hex_len; ++i,j-=4)
    rc[i] = digits[(w>>j) & 0x0f];
  return rc;
}
