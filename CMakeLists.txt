cmake_minimum_required(VERSION 3.4.3)
project(VLOGDATA2C LANGUAGES CXX)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake_modules")
set (CMAKE_CXX_STANDARD 11)
set (CMAKE_BUILD_TYPE Debug)

include_directories(
  ${CMAKE_CURRENT_SOURCE_DIR}/include
  ${CMAKE_CURRENT_BINARY_DIR}/vlog_parser
  )

add_executable(vlogdata2c
  VlogData2C.cpp
  )

add_subdirectory(vlog_parser)

target_link_libraries(vlogdata2c vlog_parser)
