/*File Name: 		UCP_ASM.m.ld
 *Creating Date: 	2018-10-15
 *Creating Author: 	chunxia.du@ia.ac.cn
 *Description: 		The default link script for UCPM assembler files.
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
 *  The memory block definition  of UCPM                               
 *  Which seems only affects the section address, not the segments.
 */
MEMORY {
  MIM       : ORIGIN = 0x000000	, LENGTH = 0x20000
}

/****************************************************************
 * The segments definition, which affect the load address of the
 * elf.
 */

/* All text code & data are in MIM */
SECTIONS {
  /* All .text & .data & .bss are located in MIM */
  .text : { 
    *(.text) 
  } >MIM
  .data : {
    *(.data) 
  } >MIM
  .bss : {
    *(.bss) 
  } >MIM
}


