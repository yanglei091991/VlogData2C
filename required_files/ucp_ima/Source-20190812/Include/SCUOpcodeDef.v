`ifndef   SCU_DEFINE_H

`define  SCU_DEFINE_H

`define SCU_ADD               5'b00001
`define SCU_SUB               5'b00010
`define SCU_MUL               5'b00011
`define SCU_2_SFLOAT          5'b00100
`define SCU_2_DFLOAT          5'b00101
`define SCU_2_FIX             5'b00110
`define SCU_2_FIX_UN          5'b00111
`define SCU_ABS               5'b01000
`define SCU_RECIP             5'b01001
`define SCU_RSQRT             5'b01010
                  
`define SCU_AND            5'b10100
`define SCU_OR             5'b10101
`define SCU_NOR            5'b10111
`define SCU_NOT            5'b10110
                  
`define SCU_EQUAL            5'b11000
`define SCU_NOT_EQUAL         5'b11001
`define SCU_BIG              5'b11010
`define SCU_NOT_SMALL         5'b11011
`define SCU_SMALL            5'b11100
`define SCU_NOT_BIG           5'b11101
                  
`define SCU_LEFT_SHIFT         5'b10000
`define SCU_RIGHT_SHIFT        5'b10001

`define SCU_ADD_WITH_CARRY    5'b10010
`define SCU_SUB_WITH_CARRY    5'b10011

`endif