%{
#include <VlogData2C.h>
#include <cstdio>
#include <iostream>
#include <cstring>

/* error handling for bison generated yyparse() */
int vlogerror(struct vlog_param_strt *param, const char *s) {
  printf("ERROR: %s, pos: %s\n", s, param->position.start);
  return 0;
}

static struct dm_data_record *current_record = NULL;
%}
%defines 	"vlog_parser.h"
%define api.pure
%name-prefix="vlog"
%param { struct vlog_param_strt *param }

%union {
  unsigned int addr;
  char *str;
}
%token <str> VALUE
%token <str> ADDR

%type <addr> loads confs conf_wo_addr conf data byte_data

%start loads

%code provides {
extern int vloglex(YYSTYPE * yylval, struct vlog_param_strt *param);
}

%%
loads : confs | conf_wo_addr | { $$ = 0; };
confs: conf | confs conf ;
conf: ADDR data {
  if(!current_record){ 
    std::cout<<"error: no current data found!"<<endl;
    YYABORT;
  }
  const unsigned MAX_ADDR_LEN = 80;
  char *addr_str = new char[MAX_ADDR_LEN]();
  unsigned addr_num = strtoul($1, 0, 16);
  delete $1;
  /*if(addr_num > 0x40000)*/
    /*cout<<"Error: ADDR is larger then 0x40000"<<endl;*/

  if(dm_num == 0)
    addr_num += 0x200000;
  else if(dm_num == 1)
    addr_num += 0x280000;
  else if(dm_num == 2)
    addr_num += 0x300000;
  else if(dm_num == 3)
    addr_num += 0x380000;
  else
    cout<<"Error: DM number is not 0/1/2/3!"<<endl;

  string add_str_hex = int_to_hex(addr_num);

  strcpy(addr_str, add_str_hex.c_str());
  current_record->dm_addr = addr_str;
  cout<<"ADDR data found: "<<addr_str<<endl;

  dm_data_records.push_back(current_record);

  current_record = NULL;
};
conf_wo_addr: data {
  if(!current_record){ 
    std::cout<<"error: no current data found!"<<endl;
    YYABORT;
  }
  const unsigned MAX_ADDR_LEN = 80;
  char *addr_str = new char[MAX_ADDR_LEN]();
  unsigned addr_num = 0; 

  /*if(addr_num > 0x40000)*/
    /*cout<<"Error: ADDR is larger then 0x40000"<<endl;*/

  if(dm_num == 0)
    addr_num += 0x200000;
  else if(dm_num == 1)
    addr_num += 0x280000;
  else if(dm_num == 2)
    addr_num += 0x300000;
  else if(dm_num == 3)
    addr_num += 0x380000;
  else
    cout<<"Error: DM number is not 0/1/2/3!"<<endl;

  string add_str_hex = int_to_hex(addr_num);

  strcpy(addr_str, add_str_hex.c_str());
  current_record->dm_addr = addr_str;
  cout<<"ADDR data is generated to be 0x0: "<<addr_str<<endl;

  dm_data_records.push_back(current_record);

  current_record = NULL;
};
data
  : data byte_data
  | byte_data
  ;
byte_data
  : VALUE VALUE VALUE VALUE {
      char *byte_str = new char[11]();
      byte_str[0] = '0'; byte_str[1] = 'x';
      byte_str[2] = $4[0]; byte_str[3] = $4[1];
      byte_str[4] = $3[0]; byte_str[5] = $3[1];
      byte_str[6] = $2[0]; byte_str[7] = $2[1];
      byte_str[8] = $1[0]; byte_str[9] = $1[1];

      if(!current_record)
        current_record = new struct dm_data_record;

      current_record->byte_nums.push_back(byte_str);

      delete $4;
      delete $3;
      delete $2;
      delete $1;
    }
  ;

%%
