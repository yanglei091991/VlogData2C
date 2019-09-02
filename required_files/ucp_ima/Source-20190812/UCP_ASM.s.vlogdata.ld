/*File Name: 		UCP_ASM.s.ld
 *Creating Date: 	2018-10-15
 *Creating Author: 	chunxia.du@ia.ac.cn
 *Description: 		The default link script for UCPS assembler files.
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
 *  The memory block definition  of UCPS                               
 *  Which seems only affects the section address, not the segments.
 */
MEMORY {
  IM        : ORIGIN = 0x000000	, LENGTH = 0x40000
  DM_ADDR_002bffc0 : ORIGIN = 0x002bffc0 , LENGTH = 64
  DM_ADDR_00284000 : ORIGIN = 0x00284000 , LENGTH = 16384
  DM_ADDR_00280000 : ORIGIN = 0x00280000 , LENGTH = 320
  DM_ADDR_3fffc : ORIGIN = 0x3fffc , LENGTH = 4
  DM_ADDR_00200000 : ORIGIN = 0x00200000 , LENGTH = 1280


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
  .bss : {
    *(.bss) 
  } >IM  .DM_ADDR_002bffc0 : { *( .DM_ADDR_002bffc0 ) } > DM_ADDR_002bffc0
  .DM_ADDR_00284000 : { *( .DM_ADDR_00284000 ) } > DM_ADDR_00284000
  .DM_ADDR_00280000 : { *( .DM_ADDR_00280000 ) } > DM_ADDR_00280000
  .DM_ADDR_3fffc : { *( .DM_ADDR_3fffc ) } > DM_ADDR_3fffc
  .DM_ADDR_00200000 : { *( .DM_ADDR_00200000 ) } > DM_ADDR_00200000

}

/* The Stack Pointer  */
STACK_POINTER = 0x40000;


