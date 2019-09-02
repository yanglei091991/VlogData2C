/*
 * ===================================================================
 *
 *        Filename:  app.s.asm
 *
 *         Created:  2018-08-22 
 *   Last Modified:  2018-11-02
 *          Author:  lirui&lih
 *    Organization:  Beijing SmartLogic Technology Ltd.
 *
 *     Description:  PN SPU Code
 *
 *
 * ===================================================================
 */

  .text
  .global _start

_start:
m.s  NOP;;
m.s  NOP;;
m.s  R1 = CallM MPU(B);;
m.s  R1 = Stat (B);; 
m.s  NOP;;
m.s  NOP;;
m.s  NOP;;
m.s  NOP;;
m.s  Readcond[R1] ;; 
m.s  NOP;;
m.s  NOP;;
m.s  SPU.Stop;;

