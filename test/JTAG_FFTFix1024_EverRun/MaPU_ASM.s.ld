/*File Name: 		MaPU_ASM.s.ld
 *Creating Date: 	2013-1-10
 *Creating Author: 	shaolin.xie@ia.ac.cn
 *Description: 		The default link script for MSPU assembler files.
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
 *  The memory block definition  of MSPU                               
 *  Which seems only affects the section address, not the segments.
 */
MEMORY {
  IM        : ORIGIN = 0x000000	, LENGTH = 0x20000

  /* The SM start address refer to the mail send by duxl@zklc.com */
  SM        : ORIGIN = 0x40200000 	, LENGTH = 0x20000
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
  } >IM
  .data : {
    *(.data) 
  } >IM

  .SM       : { *( .SM       ) } > SM
}


