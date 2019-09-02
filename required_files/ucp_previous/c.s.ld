/*File Name: 		MaPU_C.s.ld
 *Creating Date: 	2013-1-10
 *Creating Author: 	shaolin.xie@ia.ac.cn
 *Description: 		The default link script for UCPS C files.
*/

/************************************************************************
 *  Here is an example asm file to use diffent sections.
 *  Please refer to http://192.168.3.9/Docs/using%20as.pdf
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

/****************************************************************/
/* The Default Stack Point, points to the END of the IM       */
ENTRY( __ucps_init ) ;
PROVIDE(__ucps_stack_top = 0x40000) ;
 

MEMORY {
  IM        : ORIGIN = 0x000000	, LENGTH = 0x40000
  DM0       : ORIGIN = 0x100000	, LENGTH = 0x40000
  DM1       : ORIGIN = 0x200000	, LENGTH = 0x40000
  DM2       : ORIGIN = 0x300000	, LENGTH = 0x40000
}

/****************************************************************
 * The segments definition, which affect the load address of the
 * elf.
 */

/* All text code & data are in IM */
SECTIONS {
  /* All .text & .data & .bss are located in IM */
  .text 	  :	{   *(.text)   } >IM = 0x00000080
  .rodata 	:	{   *(.rodata*)} >IM
  .sbss     : {   *(.sbss*)  } >DM0
  .bss     	:	{   *(.bss)    } >DM0
  .data	 	  :	{   *(.data*)  } >IM

  /* tag start point for heap */
	__ucps_heap_start = ALIGN(0x8);

  /********************************************/
  .DM0 : { *( .DM0 ) } > DM0
  .DM1 : { *( .DM1 ) } > DM1
  .DM2 : { *( .DM2 ) } > DM2
}

