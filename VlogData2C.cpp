#include <iostream>
#include "VlogData2C.h"
#include <cstring>
#include <fstream>

using namespace std;

bool set_stack_record = false;

list<struct dm_data_record*> dm_data_records;

int main(int argc, char **argv)
{
  if(argc < 2
    || strcmp(argv[1], "-h") == 0
    || strcmp(argv[1], "--help") == 0) {
    cout<<"Usage: vlogdata2c [-c/-asm] [dest C/ASM file] [dest ld script] [vlog data file1, vlog datafile2 ...]"<<endl;
    return -1;
  }

  for(int vlog_file_num = argc - 4, i = 0; i < vlog_file_num; i++) {
    const string VlogFilename(argv[4 + i]);
    parseVlogData(VlogFilename); // this function build dm_data_records
  }

  //dumpVlogRecord(dm_data_records);

  if(strcmp(argv[1], "-c") == 0) {
    const string CFilename(argv[2]);
    writeVlogDataToCFile(CFilename);
  }
  else if(strcmp(argv[1], "-asm") == 0) {
    const string AsmFilename(argv[2]);
    writeVlogDataToAsmFile(AsmFilename);
  }
  else {
    cout<<"Error: c/asm file type not specified!"<<endl;
    return -1;
  }

  const string LdFilename(argv[3]);
  writeSectionInfoToLdScript(LdFilename);

  clearVlogRecord(dm_data_records);

  return 0;
}


void dumpVlogRecord(list<struct dm_data_record*> &records) {
  list<struct dm_data_record*>::iterator itr, itr_end;
  for(itr = records.begin(), itr_end = records.end(); itr != itr_end; itr++) {
    cout<<"addr: @"<<(*itr)->dm_addr<<endl;

    list<char*>::iterator itr_char, itr_char_end;
    int i = 0;

    for(itr_char = (*itr)->byte_nums.begin(), itr_char_end = (*itr)->byte_nums.end(); 
        itr_char != itr_char_end; i++, itr_char++) {
      cout<<" "<<*itr_char;
      if(i != 0 && i % 16 == 15)
        cout<<endl;
    }
  }
}
void clearVlogRecord(list<struct dm_data_record*> &records) {
  list<struct dm_data_record*>::iterator itr, itr_end;
  for(itr = records.begin(), itr_end = records.end(); itr != itr_end; itr++) {
    delete (*itr)->dm_addr;

    list<char*>::iterator itr_char, itr_char_end;

    for(itr_char = (*itr)->byte_nums.begin(), itr_char_end = (*itr)->byte_nums.end(); 
        itr_char != itr_char_end; itr_char++) {
      delete *itr_char;
    }
  }
}
// find if file name end with certain postfix
bool ends_with(std::string const & value, std::string const & ending)
{
    if (ending.size() > value.size()) return false;
    return std::equal(ending.rbegin(), ending.rend(), value.rbegin());
}

int writeVlogDataToCFile(const string &CFilename) {
  // check if it's a c file
  if(!ends_with(CFilename, ".c")) {
    cout<<"Error: "<<CFilename<<" is not a c source file!"<<endl;
    return -1;
  }
  // check the file exists
  ifstream fin;
  fin.open(CFilename, ios::in);
  if(!fin.is_open()) {
    cout<<"Error: "<<CFilename<<" not exists!"<<endl;
    return -1;
  }
  
  ofstream fout;
  string OutCFile;
  
  unsigned last_index = CFilename.find_last_of(".");
  OutCFile = CFilename.substr(0,last_index); // remove post fix: ".c"
  OutCFile += ".vlogdata.c";

  fout.open(OutCFile, ios::out);
  if(!fout.is_open()) {
    cout<<"Could not open file "<<OutCFile<<endl;
    return -1;
  }
  // first, copy fin to fout
  const unsigned MAX_LINE_LEN = 1000;
  char line[MAX_LINE_LEN];
  while(fin.getline(line, MAX_LINE_LEN)) {
    fout<<line<<endl;
  }

  // then, output vlog data
  list<struct dm_data_record*>::iterator itr, itr_end;
  for(itr = dm_data_records.begin(), itr_end = dm_data_records.end(); itr != itr_end; itr++) {
    fout<<endl;
    fout<<"unsigned int DM_ADDR_"<<(*itr)->dm_addr
        <<" [] "
        <<"__attribute__((section (\".DM_ADDR_"
        <<(*itr)->dm_addr<<"\"))) = {"<<endl;

    list<char*>::iterator itr_char, itr_char_end;
    int i = 0;

    for(itr_char = (*itr)->byte_nums.begin(), itr_char_end = (*itr)->byte_nums.end(); 
        itr_char != itr_char_end; i++, itr_char++) {
      fout<<*itr_char<<","<<endl;
    }
    fout<<"};"<<endl;
  }

  fin.close();
  fout.close();
  cout<<"vlog data has been written to c file "<<OutCFile<<endl;
  return 0;
}

int writeVlogDataToAsmFile(const string &AsmFilename) {
  // check if it's a asm file
  if(!ends_with(AsmFilename, ".asm") &&
     !ends_with(AsmFilename, ".s")) {
    cout<<"Error: "<<AsmFilename<<" is not a asm source file!"<<endl;
    return -1;
  }
  // check the file exists
  ifstream fin;
  fin.open(AsmFilename, ios::in);
  if(!fin.is_open()) {
    cout<<"Error: "<<AsmFilename<<" not exists!"<<endl;
    return -1;
  }
  
  ofstream fout;
  string OutAsmFile;
  
  unsigned last_index = AsmFilename.find_last_of(".");
  OutAsmFile = AsmFilename.substr(0,last_index); // remove post fix: ".asm/.c"
  OutAsmFile += ".vlogdata.asm"; // FIXME

  fout.open(OutAsmFile, ios::out);
  if(!fout.is_open()) {
    cout<<"Could not open file "<<OutAsmFile<<endl;
    return -1;
  }
  // first, copy fin to fout
  const unsigned MAX_LINE_LEN = 1000;
  char line[MAX_LINE_LEN];
  while(fin.getline(line, MAX_LINE_LEN)) {
    fout<<line<<endl;
  }

  // then, output vlog data
  list<struct dm_data_record*>::iterator itr, itr_end;
  for(itr = dm_data_records.begin(), itr_end = dm_data_records.end(); itr != itr_end; itr++) {
    fout<<endl;
    fout<<".section .DM_ADDR_"<<(*itr)->dm_addr
        <<",\"aw\""<<endl;

    list<char*>::iterator itr_char, itr_char_end;
    int i = 0;

    for(itr_char = (*itr)->byte_nums.begin(), itr_char_end = (*itr)->byte_nums.end(); 
        itr_char != itr_char_end; i++, itr_char++) {
      fout<<".int "<<*itr_char<<endl;
    }
    fout<<endl;
  }

  fin.close();
  fout.close();
  cout<<"vlog data has been written to asm file "<<OutAsmFile<<endl;
  return 0;
}

int writeSectionInfoToLdScript(const std::string &LdFilename) {
  // check if the file name has "ld" postfix
  if(!ends_with(LdFilename, ".ld")) {
    cout<<LdFilename<<" is not a ld script file"<<endl;
    return -1;
  }
  // check the file exists
  ifstream fin;
  fin.open(LdFilename, ios::in);
  if(!fin.is_open()) {
    cout<<"Error: "<<LdFilename<<" not exists!"<<endl;
    return -1;
  }

  ofstream fout;
  string OutLdFile;

  unsigned last_index = LdFilename.find_last_of(".");
  OutLdFile = LdFilename.substr(0,last_index); // remove post fix: ".ld"
  OutLdFile += ".vlogdata.ld";

  fout.open(OutLdFile, ios::out);
  if(!fout.is_open()) {
    cout<<"Could not open file "<<OutLdFile<<endl;
    return -1;
  }
  // get all file content into one string
  string LdFileStr = "";
  const unsigned MAX_LINE_LEN = 1000;
  char line[MAX_LINE_LEN];
  while(fin.getline(line, MAX_LINE_LEN)) {
    LdFileStr += line;
    LdFileStr += '\n';
  }

  // insert ld script record into MEMORY REGION

  // find the first "MEMORY {"
  const string MMYStr = "MEMORY";
  unsigned pos;
  pos = LdFileStr.find(MMYStr);
  if(pos == string::npos) {
    cout<<"no MEMORY key word found in ld script file "<<LdFilename<<endl;
    fin.close();
    fout.close();
    return -1;
  }
  while(LdFileStr[pos] != '{' &&
        pos < LdFileStr.length()) {
    ++pos;
  }
  int pos_insert = findClosingParen(LdFileStr, pos);
  int pos_increase = 0;
  --pos_insert; // insert conetent before '}'

  LdFileStr.insert(pos_insert++, "\n");
  list<struct dm_data_record*>::iterator itr, itr_end;
  for(itr = dm_data_records.begin(), itr_end = dm_data_records.end(); itr != itr_end; itr++) {
    string ld_record = "";
    string tmp_str;
    tmp_str = "  DM_ADDR_" + string((*itr)->dm_addr); pos_increase += tmp_str.length(); ld_record += tmp_str;
    tmp_str = " : ORIGIN = 0x"; pos_increase += tmp_str.length(); ld_record += tmp_str;
    tmp_str = (*itr)->dm_addr; pos_increase += tmp_str.length(); ld_record += tmp_str;
    tmp_str = " , LENGTH = "; pos_increase += tmp_str.length(); ld_record += tmp_str;

    unsigned sec_size = (*itr)->byte_nums.size() * 4; // byte number in this section
    tmp_str = to_string(sec_size); pos_increase += tmp_str.length(); ld_record += tmp_str;

    ld_record += '\n'; ++pos_increase;
    LdFileStr.insert(pos_insert, ld_record);
  }
  pos_insert += pos_increase; // now LdFileStr[pos_insert + 1] = '}'
  LdFileStr.insert(pos_insert, "\n");

  // insert ld script record into SECTIONS REGION

  // find the first "SECTIONS {"
  const string SECTStr = "SECTIONS";
  pos = LdFileStr.find(SECTStr);
  if(pos == string::npos) {
    cout<<"no SECTIONS key word found in ld script file "<<LdFilename<<endl;
    fin.close();
    fout.close();
    return -1;
  }
  while(LdFileStr[pos] != '{' &&
        pos < LdFileStr.length()) {
    ++pos;
  }
  pos_insert = findClosingParen(LdFileStr, pos);
  pos_increase = 0;
  --pos_insert; // insert conetent before '}'

  //LdFileStr.insert(pos_insert++, "\n");

  for(itr = dm_data_records.begin(), itr_end = dm_data_records.end(); itr != itr_end; itr++) {
    string ld_record = "";
    string tmp_str;
    tmp_str = "  .DM_ADDR_" + string((*itr)->dm_addr); pos_increase += tmp_str.length(); ld_record += tmp_str;
    tmp_str = " : { *( .DM_ADDR_" + string((*itr)->dm_addr); pos_increase += tmp_str.length(); ld_record += tmp_str;
    tmp_str = " ) } > "; pos_increase += tmp_str.length(); ld_record += tmp_str;
    tmp_str = "DM_ADDR_" + string((*itr)->dm_addr); pos_increase += tmp_str.length(); ld_record += tmp_str;
    ld_record += '\n'; ++pos_increase;

    LdFileStr.insert(pos_insert, ld_record);
  }
  pos_insert += pos_increase; // now LdFileStr[pos_insert + 1] = '}'
  //LdFileStr.insert(pos_insert, "\n");

  fout<<LdFileStr;

  cout<<"vlog data section info has been written to ld script file "<<OutLdFile<<endl;
  fin.close();
  fout.close();
  return 0;
}

// find matc:hed bracket
int findClosingParen(const string &text, int open_pos) {
  int close_pos = open_pos;
  int counter = 1;
  while (counter > 0) {
      char c = text[++close_pos];
      if (c == '{') {
          counter++;
      }
      else if (c == '}') {
          counter--;
      }
  }
  return close_pos;
}
