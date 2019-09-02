#include "VlogData2C.h"
#include <cstring>
#define SAVE_BYTE_TOKEN                       \
  yylval->str = new char[2];                \
  yylval->str[0] = tolower(*ts);            \
  yylval->str[1] = tolower(*(ts + 1));

#define SAVE_ADDR_TOKEN                       \
  yylval->str = new char[64]();                \
  memcpy(yylval->str, ts + 1, te - ts - 1)

%%{
  machine vlog_lexer;
  write data;
}%%

%%{
  main := |*
"@"xdigit+            {param->position.start = te; SAVE_ADDR_TOKEN; return ADDR;};
[ \t\n\r]             {;};
'//'print+						{;};
xdigit{2}               {param->position.start = te; SAVE_BYTE_TOKEN; return VALUE;};
*|;
}%%

int vloglex(YYSTYPE * yylval, struct vlog_param_strt *param) {
  const char *p  = param->position.start; 	// start point for ragel lexing.
  const char *pe = param->position.end;   	// lexing end.

  // vars for ragel scanners
  int cs; // init state
  const char *ts, *te;
  int act;
  const char *eof = 0;

  // variables accessed within ragel blocks
  int token = -1;

  // this is where ragel-lexer works.
  %%{
    # Initialize and execute.
    write init;
    write exec;
  }%%

  return token;
}
