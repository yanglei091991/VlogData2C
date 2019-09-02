#ifndef DATA_2_SOURCE_H_
#define DATA_2_SOURCE_H_

#include <cstdint> // for uint32_t in C++ 11
#include <list>
#include <string>

struct pos_strt {
  const char *start;
  const char *end;
};

struct vlog_param_strt {
  struct pos_strt position;
  uint32_t dst;
  uint32_t src;
};

struct dm_data_record {
  char* dm_addr;
  std::list<char*> byte_nums;
};

extern bool set_stack_record;

extern std::list<struct dm_data_record*> dm_data_records;

int parseVlogData(const std::string& VlogFilename);

void dumpVlogRecord(std::list<struct dm_data_record*> &records); 
void clearVlogRecord(std::list<struct dm_data_record*> &records); 

int writeVlogDataToCFile(const std::string &CFilename);

int writeVlogDataToAsmFile(const std::string &CFilename);

int writeSectionInfoToLdScript(const std::string &LdFilename);

bool ends_with(std::string const & value, std::string const & ending);

int findClosingParen(const std::string &text, int open_pos);

std::string int_to_hex(unsigned i);

#endif
