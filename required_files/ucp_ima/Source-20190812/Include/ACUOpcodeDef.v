//`timescale 1ns/1ns

//ACU_FLOAT_ALU_DEFINE_H
`ifndef   ACU_FLOAT_ALU_DEFINE_H
`define   ACU_FLOAT_ALU_DEFINE_H

`define ACU_FLOAT_ADD             5'b00001
`define ACU_FLOAT_SUB             5'b00010
`define ACU_FLOAT_MAX             5'b00011
`define ACU_FLOAT_MIN             5'b00100
`define ACU_FLOAT_ABS             5'b00101
`define ACU_FLOAT_ADD_AND_SUB     5'b00110
                                  
`define ACU_FLOAT_EQUAL           5'b01000
`define ACU_FLOAT_NOT_EQUAL       5'b01001
`define ACU_FLOAT_BIG             5'b01010
`define ACU_FLOAT_NOT_SMALL       5'b01011
`define ACU_FLOAT_SMALL           5'b01100
`define ACU_FLOAT_NOT_BIG         5'b01101
        
`define ACU_FLOAT_2_SFLOAT        5'b10000
`define ACU_FLOAT_2_DFLOAT        5'b10001
`define ACU_FLOAT_2_FIX           5'b10010
`define ACU_FLOAT_2_FIX_UN        5'b10011
        
`define ACU_FLOAT_RECIP           5'b11000
`define ACU_FLOAT_RSQRT           5'b11001
`endif

//ACC_FLOAT_MAC_DEFINE_H
`ifndef   ACC_FLOAT_MAC_DEFINE_H
`define   ACC_FLOAT_MAC_DEFINE_H

`define ACC_FLOAT_MAC_MUL    3'b001
`define ACC_FLOAT_MAC_MADD   3'b010
`define ACC_FLOAT_MAC_MAC    3'b011
`define ACC_FLOAT_MAC_READMR 3'b100
`endif

//ACU_FIX_ALU_DEFINE_H
`ifndef   ACU_FIX_ALU_DEFINE_H
`define   ACU_FIX_ALU_DEFINE_H
`define ACC_FIX_ALU_ADD        5'b00001
`define ACC_FIX_ALU_SUB        5'b00010
`define ACC_FIX_ALU_MAX        5'b00011
`define ACC_FIX_ALU_MIN        5'b00100
`define ACC_FIX_ALU_ABS        5'b00101
`define ACC_FIX_ALU_MERGE      5'b00110
`define ACC_FIX_ALU_AND        5'b01000
`define ACC_FIX_ALU_OR         5'b01001
`define ACC_FIX_ALU_XOR        5'b01010
`define ACC_FIX_ALU_NOT        5'b01011
`define ACC_FIX_ALU_LSHIFT     5'b01100
`define ACC_FIX_ALU_RSHIFT     5'b01101
`define ACC_FIX_ALU_COMPRESS   5'b01110
`define ACC_FIX_ALU_DECOMPRESS 5'b01111
`define ACC_FIX_ALU_BEQ        5'b10000
`define ACC_FIX_ALU_NBEQ       5'b10001
`define ACC_FIX_ALU_BIG        5'b10010
`define ACC_FIX_ALU_BIGORE     5'b10011
`define ACC_FIX_ALU_SMALL      5'b10100
`define ACC_FIX_ALU_SMALLORE   5'b10101
`define ACC_FIX_ALU_RMAX       5'b10110
`define ACC_FIX_ALU_RMIN       5'b10111
`define ACC_FIX_ALU_DIVS       5'b11000
`define ACC_FIX_ALU_DIVQ       5'b11001
`define ACC_FIX_ALU_MDIVR      5'b11010
`define ACC_FIX_ALU_MDIVQ      5'b11011
`define ACC_FIX_ALU_RDIV      5'b11100


`define ACC_FIX_ALU_FBS_WORD       2'b00
`define ACC_FIX_ALU_FBS_BIT        2'b10
`define ACC_FIX_ALU_FBS_SHORTWORD  2'b01
`endif

//ACC_FIX_MAC_DEFINE_H
`ifndef   ACC_FIX_MAC_DEFINE_H
`define   ACC_FIX_MAC_DEFINE_H
`define opcode_rMul_T 4'b0001
`define opcode_rMul_W 4'b0010
`define opcode_cMac 4'b0011
`define opcode_rMac_Set 4'b1000
`define opcode_rMac_Mr 4'b1001
`define opcode_ReadMr 4'b0000  //
`define opcode_rMac_Mr_Tran 4'b1010
`define opcode_rAcc 4'b1011
`define opcode_rAcc_Tran 4'b1100
`endif