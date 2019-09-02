/*
 * ===================================================================
 *
 *        Filename:  CovSampleIF.sv
 *
 *         Created:  2017-09-07 10:53:07 AM
 *   Last Modified:  2017-09-07 11:00:33 AM
 *          Author:  Lipeng YANG , lipeng.yang@ia.ac.cn
 *    Organization:  National ASIC Design Engineering Center, IACAS
 *
 *     Description:  Interface for Coverage Sample
 *
 *
 * ===================================================================
 */
interface CovSampleIF (input iSoCClk, input CClk);

  clocking  SoCCB @(negedge iSoCClk); endclocking
  clocking  APECB @(negedge CClk); endclocking

endinterface

