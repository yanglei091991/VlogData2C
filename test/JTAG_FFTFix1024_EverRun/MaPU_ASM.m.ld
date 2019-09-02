/*File Name: 		MaPU_ASM.m.ld
 *Creating Date: 	2013-1-10
 *Creating Author: 	shaolin.xie@ia.ac.cn
 *Description: 		The default link script for MMPU assembler files.
 */
/************************************************************************
 *  Here is an example asm file to use diffent sections.
 *  Please refer to http://192.168.3.91/Docs/using%20as.pdf
 *
	.text 
	.int 0x1
	.data 
	.int 0x2
	.section .SDA0.DM0, "aw"
	.int 0x3
	.section .SDA0.DM1, "aw"
	.int 0x4
	.section .SDA1.DM0, "aw"
	.int 0x5
	.section .SDA1.DM1, "aw"
	.int 0x6
	.section .SDA2.DM0, "aw"
	.int 0x7
	.section .SDA2.DM1, "aw"
	.int 0x8
*/
/***********************************************************************
 *  The memory block definition  of MMPU                               
 *  Which seems only affects the section address, not the segments.
 */
MEMORY {
  MIM       : ORIGIN = 0x000000	, LENGTH = 82K

  SDA0.DM0.0  : ORIGIN = 0x400000	, LENGTH = 0x04000
  SDA0.DM0.1  : ORIGIN = 0x404000	, LENGTH = 0x04000
  SDA0.DM0.2  : ORIGIN = 0x408000	, LENGTH = 0x04000
  SDA0.DM0.3  : ORIGIN = 0x40c000	, LENGTH = 0x04000
  SDA0.DM0.4  : ORIGIN = 0x410000	, LENGTH = 0x04000
  SDA0.DM0.5  : ORIGIN = 0x414000	, LENGTH = 0x04000
  SDA0.DM0.6  : ORIGIN = 0x418000	, LENGTH = 0x04000
  SDA0.DM0.7  : ORIGIN = 0x41c000	, LENGTH = 0x04000
  SDA0.DM0.8  : ORIGIN = 0x420000	, LENGTH = 0x04000
  SDA0.DM0.9  : ORIGIN = 0x424000	, LENGTH = 0x04000
  SDA0.DM0.a  : ORIGIN = 0x428000	, LENGTH = 0x04000
  SDA0.DM0.b  : ORIGIN = 0x42c000	, LENGTH = 0x04000
  SDA0.DM0.c  : ORIGIN = 0x430000	, LENGTH = 0x04000
  SDA0.DM0.d  : ORIGIN = 0x434000	, LENGTH = 0x04000
  SDA0.DM0.e  : ORIGIN = 0x438000	, LENGTH = 0x04000
  SDA0.DM0.f  : ORIGIN = 0x43c000	, LENGTH = 0x04000

  SDA0.DM1  : ORIGIN = 0x600000	, LENGTH = 0x40000
  SDA1.DM0  : ORIGIN = 0x800000	, LENGTH = 0x40000
  SDA1.DM1  : ORIGIN = 0xA00000	, LENGTH = 0x40000
  SDA2.DM0  : ORIGIN = 0xC00000	, LENGTH = 0x40000
  SDA2.DM1  : ORIGIN = 0xE00000	, LENGTH = 0x40000
}

/****************************************************************
 * The segments definition, which affect the load address of the
 * elf.
 */

/* All text code & data are in IM */
SECTIONS {
  /* All .text & .data & .bss are located in IM */
  .text : { 
    *(.text) 
  } >MIM
  .data : {
    *(.data) 
  } >MIM

  /********************************************/
  .SDA0.DM0.0 : { *( .SDA0.DM0.0 ) } > SDA0.DM0.0
  .SDA0.DM0.1 : { *( .SDA0.DM0.1 ) } > SDA0.DM0.1
  .SDA0.DM0.2 : { *( .SDA0.DM0.2 ) } > SDA0.DM0.2
  .SDA0.DM0.3 : { *( .SDA0.DM0.3 ) } > SDA0.DM0.3
  .SDA0.DM0.4 : { *( .SDA0.DM0.4 ) } > SDA0.DM0.4
  .SDA0.DM0.5 : { *( .SDA0.DM0.5 ) } > SDA0.DM0.5
  .SDA0.DM0.6 : { *( .SDA0.DM0.6 ) } > SDA0.DM0.6
  .SDA0.DM0.7 : { *( .SDA0.DM0.7 ) } > SDA0.DM0.7
  .SDA0.DM0.8 : { *( .SDA0.DM0.8 ) } > SDA0.DM0.8
  .SDA0.DM0.9 : { *( .SDA0.DM0.9 ) } > SDA0.DM0.9
  .SDA0.DM0.a : { *( .SDA0.DM0.a ) } > SDA0.DM0.a
  .SDA0.DM0.b : { *( .SDA0.DM0.b ) } > SDA0.DM0.b
  .SDA0.DM0.c : { *( .SDA0.DM0.c ) } > SDA0.DM0.c
  .SDA0.DM0.d : { *( .SDA0.DM0.d ) } > SDA0.DM0.d
  .SDA0.DM0.e : { *( .SDA0.DM0.e ) } > SDA0.DM0.e
  .SDA0.DM0.f : { *( .SDA0.DM0.f ) } > SDA0.DM0.f
  
  .SDA0.DM1 : { *( .SDA0.DM1 ) } > SDA0.DM1
  .SDA1.DM0 : { *( .SDA1.DM0 ) } > SDA1.DM0
  .SDA1.DM1 : { *( .SDA1.DM1 ) } > SDA1.DM1
  .SDA2.DM0 : { *( .SDA2.DM0 ) } > SDA2.DM0
  .SDA2.DM1 : { *( .SDA2.DM1 ) } > SDA2.DM1
}


