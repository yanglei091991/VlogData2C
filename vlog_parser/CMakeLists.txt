include_directories(${CMAKE_CURRENT_BINARY_DIR})
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

include(Bison)
set(LLVM_TARGET_PARSER vlog_parser.y)
bison(VlogCompiler vlog_parser.bison)
add_public_bison_target(VlogParser)

include(Ragel)
set(LLVM_TARGET_LEXER vlog_lexer.rl)
ragel(VlogCompiler vlog_lexer.ragel)
add_public_ragel_target(VlogLexer)

add_library(vlog_parser
  vlog_parser.cpp
  )

add_dependencies(vlog_parser
  VlogLexer
  VlogParser
  )
