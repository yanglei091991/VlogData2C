//File Name: TestLib.sv
//Creating Date: 2012-4.12
//Creating Author: shaolin.xie@ia.ac.cn
//Description: The Class definition for Testing.
//Last Commit: $Id$
/*
  #  Common Used tasks
  #  APEInitInstrMem()   : Initiate the IM and MIM
  #  APEInitDataMem()    : Initiate the SDA0DM0 ~ SDA2DM1
  #  ResetAll()           : Reset the whole design.
  #  ResetAndStartSPU()   : Reset the whole design and Sent start signal to VPU
  #  WaitSPUCycles()      : Wait SPU Cycles.
  #  WaitSoCCycles()      : Wait SoC Cycles.
  #  WaitMPUCycles()      : Wait MPU Cycles.
  
  # class Monitor         : The Monitor Componet for testbench
  #      .R_Read()        : Read the R register.
  #      .R_Write()       : Write the R register
  #      .M_Read()        : Read  M register
  #      .M_Write()       : Write M register 
  #      .MACFlag_Read()  : Read Flag of MAC
  #      .ALUFlag_Read()  : Read Flag of ALU
  #      .MR_Read()       : Read MR register
  #      .TBReg_Read()    : Read TBReg
  #      .MRegLatch_Read(): Read MRegLatch
  #      .ErasedBit_Read(): Read ErasedBit
  #      .MC_Read()		  : Read MC of MReg
  #      .DM.ReadBytes()  : Read  $length(Data) Bytes from DM, address starts from 0
  #      .DM.WriteBytes() : Write $length(Data) Bytes to   DM, address starts from 0
  #      .T_Read()        : Read  T register
  #      .display_256()   : Display the 256bit variable
  #      .display_512()   : Display the 512bit variable

  # class ARM             : The ARM module.
         .Write()         : Write the CSU
         .Read()          : Read  the CSU 
         .DMA()           : Initial an DMA request.
         .WaitDMA()       : Wait an DMA group  to finish.

  # class DDR             :The DDR module.
         .ReadBytes() 
         .WriteBytes()
         .ReadWords() 
         .WriteWords()
         .ReadWord()
         .WriteWord()

  # class ShareMem    :The ShareMemory module.
*/
`include "SPUDef.v"
`include "MPUDef.v"
`include "TestDef.v"

`timescale 1ns/1ps


//--Class Environment--//
class Environment;
  Coverage     cCov;	
  extern task  run();
  extern task  wrap_up();
endclass
task Environment::run();
  cCov = new();
  cCov.run();
endtask
task Environment::wrap_up();
  $display("***************************************");
  $display("  the function coverage is %f%%",$get_coverage());
  $display("***************************************");
endtask

//////////////////////////////////////////////////////////////

//Task to Initialize the RFM 
task  APEInitInstrMem();
  // IM Instruction Code
`ifdef PLATFORM_FPGA
  TestTop.FPGA_Top_inst.uRFM.uIM.IMInit("./IM.data");
  
  // MIM Cluster Instruction Code
  TestTop.FPGA_Top_inst.uRFM.uMIM.MIMInit("./MIM.data");
`else
  TestTop.uRFM.uIM.IMInit("./IM.data");

  // MIM Cluster Instruction Code
  //TestTop.uRFM.uMIM.MIMInit("./MIM.data");
  
`endif
endtask

//task APEInitDataMem(input bit [2:0] Gran, input bit [3:0] Size);  
//  byte Data[];
//  Data = new[1<<19];
//
//  TestTop.uRFM.uDM0.DMInit(Gran, Size, "./DM0.dat");
//  TestTop.uRFM.uDM1.DMInit(Gran, Size, "./DM1.dat");
//  TestTop.uRFM.uDM2.DMInit(Gran, Size, "./DM2.dat"); 
//  TestTop.uRFM.uDM3.DMInit(Gran, Size, "./DM3.dat"); 
//
//  Data.delete();
//endtask

//task APEInitDataMem_new(input bit [2:0] Gran, input bit [3:0] Size, input int XNum);  
//  byte Data[];
//  Data = new[1<<19];
//
//  TestTop.uRFM.uDM0.DMInit_new(Gran, Size, XNum, "./DM0.dat");
//  TestTop.uRFM.uDM1.DMInit_new(Gran, Size, XNum, "./DM1.dat");
//  TestTop.uRFM.uDM2.DMInit_new(Gran, Size, XNum, "./DM2.dat"); 
//  TestTop.uRFM.uDM3.DMInit_new(Gran, Size, XNum, "./DM3.dat"); 
//
//  Data.delete();
//endtask

//////////////////////////////////////////////////////////////
//Task to reset the whole design. 
task  ResetAll();
    iExtToCSU.oCB.AWVALID <=  0;
    iExtToCSU.oCB.WVALID  <=  0;
    iExtToCSU.oCB.ARVALID <=  0;
    iExtToCSU.oCB.RREADY  <=  1;
    iExtToCSU.oCB.BREADY  <=  1;
    
    iCSUToExt.iCB.AWREADY <=  1;
    iCSUToExt.iCB.WREADY  <=  1;
    iCSUToExt.iCB.ARREADY <=  1;
    iCSUToExt.iCB.BVALID  <=  0;
    iCSUToExt.iCB.RVALID  <=  0;

    iSMBus.iCB.AWREADY <=  1;
    iSMBus.iCB.WREADY  <=  1;
    iSMBus.iCB.ARREADY <=  1;
    iSMBus.iCB.BVALID  <=  0;
    iSMBus.iCB.RVALID  <=  0;
    
    @TestTop.iSoCClk begin
      TestTop.Rst_n <= 0;
      TestTop.iSoCRst_n <= 0;
    end
    repeat(2) @(posedge  TestTop.iSoCClk);
    TestTop.Rst_n  <= 1;
    TestTop.iSoCRst_n  <= 1;
    $display("@%0t : System Reseted.", $realtime);
endtask 

//////////////////////////////////////////////////////////////
//Task to Wait SPU Cycles.
//task automatic WaitSPUCycles(int C);
//  int i=0;
//  while(i<C) begin
//   `ifdef PLATFORM_FPGA
//	@(posedge TestTop.FPGA_Top_inst.uRFM.uSPU.CClk);
//    `else
//	@(posedge TestTop.uRFM.uSPU.CClk); 
//   `endif
//        `TD;
//        i= i+1;
//  end
//endtask

task automatic WaitSPUCycles(int C);
   int i=0;
   while(i<C) begin
      `ifdef PLATFORM_FPGA
          @(negedge $root.TestTop.FPGA_Top_inst.uRFM.uSPU.CClk);
          if($root.TestTop.FPGA_Top_inst.uRFM.uSPU.uSPUPipeCtrl.oExeStall == 0) 
            i=i+1;
      `else
          @(negedge $root.TestTop.uRFM.uSPU.CClk);
          if($root.TestTop.uRFM.uSPU.uSPUPipeCtrl.oExeStall == 0) 
            i=i+1;
      `endif
   end
endtask

task automatic WaitSPUCycles_NStall(int C);
   int i=0;
   while(i<C) begin
      `ifdef PLATFORM_FPGA
          @(negedge $root.TestTop.FPGA_Top_inst.uRFM.uSPU.CClk);
            i=i+1;
      `else
          @(negedge $root.TestTop.uRFM.uSPU.CClk);
            i=i+1;
      `endif
   end
endtask

task automatic WaitSPUSYNStalledCycles(int C);
  int i=0;
  while(i<C) begin
      `ifdef PLATFORM_FPGA
	@(negedge TestTop.FPGA_Top_inst.uRFM.uSPU.CClk);
	if( TestTop.FPGA_Top_inst.uRFM.uSPU.uSYN.nEx0Stall == 0) i=i+1;
        //  $display("@time=%0t; i=%h; StallEn=%b", $realtime,i,TestTop.FPGA_Top_inst.uRFM.uSPU.uSYN.nEx0Stall); 
      `else
	@(negedge TestTop.uRFM.uSPU.CClk); begin
	if( TestTop.uRFM.uSPU.uSYN.nEx0Stall == 0)  begin i=i+1;
         // $display("@time=%0t; i=%h; StallEn=%b", $realtime,i,TestTop.uRFM.uSPU.uSYN.nEx0Stall); 
          end
        end
      `endif
       
  end
endtask

task automatic WaitSPUWrFIFOEnCycles();
  while(1) begin
   `ifdef PLATFORM_FPGA
	@(negedge TestTop.FPGA_Top_inst.uRFM.uSPU.CClk);
        if(TestTop.FPGA_Top_inst.uRFM.uSPU.uSYN.nEx0Stall == 1'b0) break;
    `else
	@(negedge TestTop.uRFM.uSPU.CClk); 
        if(TestTop.uRFM.uSPU.uSYN.nEx0Stall == 1'b0) break;
   `endif
        //`TD;
  end
endtask

task automatic WaitSPUSYNDPStalledCycles();
  int i=0;
  while(1) begin
      `ifdef PLATFORM_FPGA
	@(negedge TestTop.FPGA_Top_inst.uRFM.uSPU.CClk);
	if(TestTop.FPGA_Top_inst.uRFM.uSPU.uSYN.iDPStall == 0) 
          break;
        //  $display("@time=%0t; i=%h; StallEn=%b", $realtime,i,TestTop.FPGA_Top_inst.uRFM.uSPU.uSYN.nEx0Stall); 
        
      `else
	@(negedge TestTop.uRFM.uSPU.CClk); 
	if(TestTop.uRFM.uSPU.uSYN.iDPStall == 0)  
          break;
         // $display("@time=%0t; i=%h; StallEn=%b", $realtime,i,TestTop.uRFM.uSPU.uSYN.nEx0Stall); 
         
       
      `endif
       
  end
endtask

// Reg of MFetch
//task automatic WaitMPUCyclesMFetch(int C);
//   int i = 0;
//   bit MicroValid;
//   while(i<C)begin
//      `ifdef PLATFORM_FPGA
//         @(negedge TestTop.FPGA_Top_inst.uRFM.uMPU.CClk);
//         MicroValid = $root.TestTop.FPGA_Top_inst.uRFM.uMPU.uMFetch.nCurrentMicroValid; 
//      `else
//         @(negedge TestTop.uRFM.uMPU.CClk);
//         MicroValid = $root.TestTop.uRFM.uMPU.uMFetch.nCurrentMicroValid;
//      `endif
//      if(MicroValid) begin
//         i = i + 1; 
//      end           
//   end
//endtask
//
//// Reg exclude of MFetch
//task automatic WaitMPUCycles(int C);
//   int i = 0;
//   bit MicroValid;
//   while(i<C)begin
//      `ifdef PLATFORM_FPGA
//         @(negedge TestTop.FPGA_Top_inst.uRFM.uMPU.CClk);
//         MicroValid = $root.TestTop.FPGA_Top_inst.uRFM.uMPU.gen_dpath[3].uDPath.gen_IMA[3].uIMA.rEUStallEn[0]; 
//      `else
//         @(negedge TestTop.uRFM.uMPU.CClk);
//         MicroValid = $root.TestTop.uRFM.uMPU.gen_dpath[3].uDPath.gen_IMA[3].uIMA.rEUStallEn[0];
//      `endif
//      if(!MicroValid) begin
//         i = i + 1; 
//      end           
//   end
//endtask

//Task to Wait SoC Cycles.
task automatic WaitSoCCycles(int C);
  repeat (C)  @(posedge TestTop.iSoCClk);
endtask

//////////////////////////////////////////////////////////////
`define MR_WIDTH     1664
//--Class Monitor
class  Monitor;
  extern task automatic R_Read(input bit[4:0] Index, output logic[31:0]  Data) ;
  extern task SVR_Read(input bit[1:0] Index, output logic[511:0] Data);

  extern task display_256(input bit[255:0]  Data);
  extern task display_512(input logic[511:0]  Data);
endclass

//////////////////////////////////////////////////////////////
//Function read/write the Regsiter
`ifdef PLATFORM_FPGA
`define SPU_PATH  $root.TestTop.FPGA_Top_inst.uRFM.uSPU
`else
`define SPU_PATH  $root.TestTop.uRFM.uSPU
`endif
task automatic Monitor::R_Read(input bit[4:0] Index, output logic[31:0] Data);
  `TD;
  Data = `SPU_PATH.uDecode.uRRegFile.rRReg[Index];
endtask

task automatic Monitor::SVR_Read(input bit[1:0] Index, output logic[511:0] Data);
  `TD;
  Data = `SPU_PATH.uDecode.rSVRReg[Index];
endtask

task Monitor::display_256(input bit[255:0]  Data);
  $display("Data=%h_%h_%h_%h_%h_%h_%h_%h", 
      Data[255:224],Data[223:192],Data[191:160],Data[159:128],Data[127:96],Data[95:64],Data[63:32],Data[31:0] );
endtask

task Monitor::display_512(input logic[511:0]  Data);
  $display("Data=%h_%h_%h_%h_%h_%h_%h_%h_%h_%h_%h_%h_%h_%h_%h_%h,", 
      Data[511:480],Data[479:448],Data[447:416],Data[415:384],Data[383:352],Data[351:320],Data[319:288],Data[287:256], 
      Data[255:224],Data[223:192],Data[191:160],Data[159:128],Data[127:96],Data[95:64],Data[63:32],Data[31:0] );
endtask

`undef SPU_PATH  


//////////////////////////////////////////////////////////////
// Check
/****************************** SPU *******************************
*  task automatic CheckSCUFlag(int SPUSTARTPC, input int InstrCycle, input logic[1:0] ExpValue);
*  task automatic CheckSCUCFlag(int SPUSTARTPC, input int InstrCycle, input logic[1:0] ExpValue);
*  task automatic CheckRValue(input int SPUSTARTPC, input int InstrCycle, input bit[4:0] RID, input logic[31:0] ExpValue); 
*  task automatic CheckRValueUnsignedBit(input int SPUSTARTPC, input int InstrCycle, input bit[4:0] RID, input logic[31:0] ExpValue);
*  task automatic CheckRValue_Jump(input int SPUSTARTPC, input int InstrCycle, input bit[4:0] RID, input logic[31:0] ExpValue); 
*  task automatic CheckJUMP_SPU(input int SPUSTARTPC,input int InstrCycle, input int NextSPUSTARTPC);
*  task automatic CheckRValueShort(input int SPUSTARTPC, input int InstrCycle, input bit[4:0] RID, input logic[15:0] ExpValue); 
*  task automatic CheckRValueAGU(input int SPUSTARTPC, input int InstrCycle, input bit[4:0] RID, input logic[31:0] ExpValue); 
*  task automatic CheckRValueSYN(input int SPUSTARTPC, input int InstrCycle, input bit[4:0] RID, input logic[31:0] ExpValue); 
*  task automatic CheckRValueSCU(input int SPUSTARTPC, input int InstrCycle, input bit[4:0] RID, input logic[31:0] ExpValue); 
*  task automatic Check2RValue(input int SPUSTARTPC, input int InstrCycle, input bit[4:0] RID, input logic[31:0] ExpValue); 
*  task automatic CheckRExpValue(input int SPUSTARTPC, input int InstrCycle, input bit[4:0] RID, input logic[31:0] ExpValue); 
*  task automatic CheckRSignExpValue(input int SPUSTARTPC, input int InstrCycle, input bit[4:0] RID, input logic[31:0] ExpValue); 
*  task automatic CheckRIsNAN(input int SPUSTARTPC, input int InstrCycle, input bit[4:0] RID); 
*  task automatic CheckRHValue(input int SPUSTARTPC, input int InstrCycle, input bit[4:0] RID, input logic[31:0] ExpValue); 
*  task automatic CheckSVRValue(input int SPUSTARTPC, input int InstrCycle, input bit[1:0] SVRID, input logic[511:0] ExpValue); 
*  task automatic CheckFIFOValue(input int SPUSTARTPC, input int InstrCycle, input bit[1:0] FIFOID, input logic[31:0] ExpValue); 
*  task automatic CheckSEQIntEn(int SPUSTARTPC, input int InstrCycle, input logic ExpValue); 
*/

`define SPU_STARTDC_PC  $root.TestTop.uRFM.uSPU.uFetch.rDispatchPC
`define SPU_STARTEX0_PC $root.TestTop.uRFM.uSPU.uFetch.rRRPC
`define DPStall         $root.TestTop.uRFM.uSPU.uDecode.oDPStall
`define ExeStall        $root.TestTop.uRFM.uSPU.uSPUPipeCtrl.oExeStall
`define IntStall        $root.TestTop.uRFM.uSPU.uSPUPipeCtrl.oIntStall
`define SYNStall        $root.TestTop.uRFM.uSPU.uSYN.oSYNStall
`define CALLEN          $root.TestTop.uRFM.uSPU.uSYN.oWrCallMAddrEn
`define CALL_ADDR       $root.TestTop.uRFM.uSPU.uSYN.oWrCallMAddrValue

`define TIME_OUT_CYCLE        100000
`define SPU_DELAY_CYCLE       1

// SPU
   task automatic CheckLoopSPU(input int StartSPC, input int EndSPC, input int LpNum);
      int PCHitNum_Loop = 0;
      while(1)begin
         @(iCvSmpIF.APECB)
         if((`SPU_STARTDC_PC === StartSPC) && !`ExeStall) 
	         PCHitNum_Loop = PCHitNum_Loop + 1;
         if((`SPU_STARTDC_PC === EndSPC) && !`ExeStall)
            break;
      end
      if(PCHitNum_Loop == LpNum)
         $display("SPU Loop Passed @SPU_STARTDC_PC = %h, ActualLpNum = %h",StartSPC, PCHitNum_Loop);
      else
         $display("***Loop Error*** @SPU_STARTDC_PC = %h, ExpectedLpNum = %h, ActualLpNum = %h", StartSPC, LpNum, PCHitNum_Loop);
   endtask

   // check C and V flags
   task automatic CheckSCUFlag(int SPUSTARTPC, input int InstrCycle, input logic[1:0] ExpValue);
      logic[1:0] FlagValue;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);

      FlagValue = $root.TestTop.uRFM.uSPU.uSCU.uEx0Unit.oFlag;

      if(FlagValue == ExpValue)
         $display("%0t Read SCU Flag OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result of SCU Flag are :%h ,%h\n", $realtime, SPUSTARTPC, ExpValue, FlagValue);
   endtask

   // check C flag
   task automatic CheckSCUCFlag(int SPUSTARTPC, input int InstrCycle, input logic ExpValue);
      logic FlagValue;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);

	   FlagValue = $root.TestTop.uRFM.uSPU.uSCU.uEx0Unit.oFlag[1];

      if(FlagValue === ExpValue)
         $display("%0t Read SCU C Flag OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result of SCU C Flag are :%h ,%h\n", $realtime, SPUSTARTPC, ExpValue, FlagValue);
   endtask

   task automatic CheckRValue_NStall(input int SPUSTARTPC, input int InstrCycle, input bit[4:0] RID, input logic[31:0] ExpValue); 
      logic[31:0]   RValue;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC)
            break;
      end
      WaitSPUCycles_NStall(InstrCycle);
      Mon.R_Read(RID, RValue);
      if(RValue === ExpValue)
         $display("%0t Read R[%0d] OK @SPU_STARTEX0_PC = %h!!", $realtime, RID, SPUSTARTPC);
      else
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result 0f R[%0d] are :%h ,%h\n", $realtime, SPUSTARTPC, RID, ExpValue, RValue);
   endtask

   task automatic CheckRValue(input int SPUSTARTPC, input int InstrCycle, input bit[4:0] RID, input logic[31:0] ExpValue); 
      logic[31:0]   RValue;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);
      Mon.R_Read(RID, RValue);
      if(RValue === ExpValue)
         $display("%0t Read R[%0d] OK @SPU_STARTEX0_PC = %h!!", $realtime, RID, SPUSTARTPC);
      else
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result 0f R[%0d] are :%h ,%h\n", $realtime, SPUSTARTPC, RID, ExpValue, RValue);
   endtask

   task automatic CheckRValueUnsignedBit(input int SPUSTARTPC, input int InstrCycle, input bit[4:0] RID, input logic[31:0] ExpValue); 
      logic[31:0]   RValue;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);
      Mon.R_Read(RID, RValue);
      if(RValue[30:0] === ExpValue[30:0])
         $display("%0t Read R[%0d] OK @SPU_STARTEX0_PC = %h!!", $realtime, RID, SPUSTARTPC);
      else
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result 0f R[%0d] are :%h ,%h\n", $realtime, SPUSTARTPC, RID, ExpValue, RValue);
   endtask


   task automatic CheckRValue_Jump(input int SPUSTARTPC, input int InstrCycle, input bit[4:0] RID, input logic[31:0] ExpValue); 
      logic[31:0]   RValue;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTDC_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle+`SPU_DELAY_CYCLE);
      Mon.R_Read(RID, RValue);
      if(RValue === ExpValue)
         $display("%0t Read R[%0d] OK @SPU_STARTEX0_PC = %h!!", $realtime, RID, SPUSTARTPC);
      else
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result 0f R[%0d] are :%h ,%h\n", $realtime, SPUSTARTPC, RID, ExpValue, RValue);
   endtask

   task automatic CheckRValueShort(input int SPUSTARTPC, input int InstrCycle, input bit[4:0] RID, input logic[15:0] ExpValue); 
      logic[15:0]   RValue;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC)
            break;
      end
      WaitSPUCycles(InstrCycle);
      //#0.5; 
      Mon.R_Read(RID, RValue);
      if(RValue === ExpValue)
         $display("%0t Read R[%0d] OK @SPU_STARTEX0_PC = %h!!", $realtime, RID, SPUSTARTPC);
      else
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result 0f R[%0d] are :%h ,%h\n", $realtime, SPUSTARTPC, RID, ExpValue, RValue);
  endtask

  task automatic CheckJUMP_SPU(input int SPUSTARTPC,input int InstrCycle, input int NextSPUSTARTPC);
      while(1) begin
         @(iCvSmpIF.APECB)
         if((`SPU_STARTDC_PC === SPUSTARTPC) && !`DPStall)
            break;
      end
      
       WaitSPUCycles(InstrCycle); 

      if(`SPU_STARTDC_PC != NextSPUSTARTPC)
         $display( "%0t Error @SPU_STARTDC_PC = %h, ExpectedNextSTARTPC = %h , RealNextSTARTPC = %h", $realtime, SPUSTARTPC, NextSPUSTARTPC, `SPU_STARTDC_PC);
      else
         $display( "%0t JUMP addr %h OK  @SPU_STARTDC_PC = %h!!", $realtime, NextSPUSTARTPC, SPUSTARTPC);
   endtask

   task automatic CheckRValueAGU(input int SPUSTARTPC, input int InstrCycle, input bit[4:0] RID, input logic[31:0] ExpValue); 
      logic[31:0]   RValue;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC)
            break;
      end
      WaitSPUCycles(InstrCycle);
      //#0.5; 
      Mon.R_Read(RID, RValue);
      if(RValue === ExpValue)
         $display("%0t Read R[%0d] OK @SPU_STARTEX0_PC = %h!!", $realtime, RID, SPUSTARTPC);
      else
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result 0f R[%0d] are :%h ,%h\n", $realtime, SPUSTARTPC, RID, ExpValue, RValue);
   endtask

   task automatic CheckRValueSYN(input int SPUSTARTPC, input int InstrCycle, input bit[4:0] RID, input logic[31:0] ExpValue); 
      logic[31:0]   RValue;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUSYNStalledCycles(InstrCycle);
      
      Mon.R_Read(RID, RValue);
      if(RValue === ExpValue)
         $display("%0t Read R[%0d] OK @SPU_STARTEX0_PC = %h!!", $realtime, RID, SPUSTARTPC);
      else
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :%h ,%h\n", $realtime, SPUSTARTPC, ExpValue, RValue);
   endtask

 task automatic CheckRValueSYN2(input int SPUSTARTPC, input int InstrCycle, input bit[4:0] RID, input logic[31:0] ExpValue); 
      logic[31:0]   RValue;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUSYNStalledCycles(InstrCycle);
      
      if(RID != 5'h00) begin
        Mon.R_Read(RID, RValue);
      end
      else begin
        RValue = 32'h0;
      end

      if(RValue === ExpValue) $display("%0t Read R  OK @SPU_STARTEX0_PC = %h!!", $time,SPUSTARTPC);
      else   $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :%h ,%h\n", $time,SPUSTARTPC , ExpValue, RValue);
  endtask  

   task automatic CheckRValueSCU(input int SPUSTARTPC, input int InstrCycle, input bit[4:0] RID, input logic[31:0] ExpValue); 
      logic[31:0]   RValue;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);
      
      Mon.R_Read(RID, RValue);
      if(RValue === ExpValue)
         $display("%0t Read R  OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :%h ,%h\n", $realtime, SPUSTARTPC, ExpValue, RValue);
   endtask
 
   task automatic CheckRValue2(input int SPUSTARTPC, input int InstrCycle, input bit[4:0] RID, input logic[31:0] ExpValue); 
      logic[31:0]   RValue;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTDC_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTDC_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle+`SPU_DELAY_CYCLE);
      
      Mon.R_Read(RID, RValue);
      if(RValue === ExpValue)
         $display("%0t Read R OK @SPUJUMPDC_PC = %h!!", $realtime, SPUSTARTPC);
      else
         $display("%0t Error @SPUJUMPDC_PC = %h, Expected Value and Real Result are :%h ,%h\n", $realtime, SPUSTARTPC, ExpValue, RValue);

   endtask

   task automatic CheckRExpValue(input int SPUSTARTPC, input int InstrCycle, input bit[4:0] RID, input logic[31:0] ExpValue); 
      logic[31:0]   RValue;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);
      
      Mon.R_Read(RID, RValue);
      if(RValue[30:23] === ExpValue[30:23])
         $display("%0t Read R[%0d][30:23] OK @SPU_STARTEX0_PC = %h!!", $realtime, RID, SPUSTARTPC);
      else
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result of R[%0d][30:23] are :%h ,%h\n", $realtime, SPUSTARTPC, RID, ExpValue[30:23], RValue[30:23]);
   endtask

   task automatic CheckRSignExpValue(input int SPUSTARTPC, input int InstrCycle, input bit[4:0] RID, input logic[31:0] ExpValue); 
      logic[31:0]   RValue;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);
      
      Mon.R_Read(RID, RValue);
      if(RValue[31:23] === ExpValue[31:23])
         $display("%0t Read R[%0d][31:23] OK @SPU_STARTEX0_PC = %h!!", $realtime, RID, SPUSTARTPC);
      else
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result of R[%0d][31:23] are :%h ,%h\n", $realtime, SPUSTARTPC, RID, ExpValue[31:23], RValue[31:23]);
   endtask
  
   task automatic CheckRIsNAN(input int SPUSTARTPC, input int InstrCycle, input bit[4:0] RID); 
      logic[31:0]   RValue;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);

      Mon.R_Read(RID, RValue);
      if((RValue[30:23] === 8'hff) && (RValue[22:0] != 23'd0))
         $display("%0t Check R[%0d] is NaN OK @SPU_STARTEX0_PC = %h!!", $realtime, RID, SPUSTARTPC);
      else
         $display("%0t Error @SPU_STARTEX0_PC = %h, R[%0d] is not NaN. Its value is %h\n", $realtime, SPUSTARTPC, RID, RValue);
   endtask


   task automatic CheckIMValueWord_NStall(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
      byte   IMValue[];
      IMValue = new[4];

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC)
            break;
      end
      WaitSPUCycles_NStall(InstrCycle);

      $root.TestTop.uRFM.uIM.IMReadBytes(Addr, IMValue);

      if({IMValue[3],IMValue[2],IMValue[1],IMValue[0]} === ExpValue)
         $display("%0t Read IM OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else
         $display("%0t IM Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :%h ,%h%h%h%h\n", $realtime, SPUSTARTPC, ExpValue, IMValue[3], IMValue[2], IMValue[1], IMValue[0]);
   endtask: CheckIMValueWord_NStall

   task automatic CheckIMValueWord(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
      byte   IMValue[];
      IMValue = new[4];

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);

      $root.TestTop.uRFM.uIM.IMReadBytes(Addr, IMValue);

      if({IMValue[3],IMValue[2],IMValue[1],IMValue[0]} === ExpValue)
         $display("%0t Read IM OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else
         $display("%0t IM Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :%h ,%h%h%h%h\n", $realtime, SPUSTARTPC, ExpValue, IMValue[3], IMValue[2], IMValue[1], IMValue[0]);
   endtask: CheckIMValueWord
   
   task automatic CheckIMValueShort(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
      byte   IMValue[];
      IMValue = new[2];

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);

      $root.TestTop.uRFM.uIM.IMReadBytes(Addr, IMValue);

      if({IMValue[1],IMValue[0]} === ExpValue)
         $display("%0t Read IM OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else
         $display("%0t IM Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :%h ,%h%h%h%h\n", $realtime, SPUSTARTPC, ExpValue, IMValue[3], IMValue[2], IMValue[1], IMValue[0]);
   endtask: CheckIMValueShort

   task automatic CheckIMValueByte(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
      byte   IMValue[];
      IMValue = new[1];

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);
      $root.TestTop.uRFM.uIM.IMReadBytes(Addr, IMValue);
      if({IMValue[0]} === ExpValue) $display("%0t Read IM OK @SPU_STARTEX0_PC = %h!!", $time, SPUSTARTPC);
      else   $display("%0t IM Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :%h ,%h\n", $time, SPUSTARTPC, ExpValue, IMValue[0]);
      IMValue.delete();
   endtask: CheckIMValueByte

   task automatic CheckSVRValue(input int SPUSTARTPC, input int InstrCycle, input bit[1:0] SVRID, input logic[511:0] ExpValue); 
      logic[511:0]   RValue;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);
      
      Mon.SVR_Read(SVRID, RValue);
      if(RValue === ExpValue)
         $display("%0t Read SVR[%0d] OK @SPU_STARTEX0_PC = %h!!", $realtime, SVRID, SPUSTARTPC);
      else begin
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         Mon.display_512(ExpValue);
         Mon.display_512(RValue);
         $display(" ");
      end
   endtask

   //task automatic CheckFIFOValue(input int SPUSTARTPC, input int InstrCycle, input bit[1:0] FIFOID, input logic[31:0] ExpValue); 
   //   logic[31:0]   FIFOValue;

   //   while(1) begin
   //      @(iCvSmpIF.APECB)
   //      if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
   //         break;
   //   end
   //  // WaitSPUWrFIFOEnCycles();
   //   WaitSPUCycles(InstrCycle); 
   //   `TD
   //   FIFOValue = $root.TestTop.uRFM.uMPU.uMFetch.RFIFO[FIFOID];
   //   if(FIFOValue === ExpValue)
   //      $display("%0t Read FIFO[%0d] OK @SPU_STARTEX0_PC = %h!!", $realtime, FIFOID, SPUSTARTPC);
   //   else   
   //      begin
   //         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are : %h, %h\n", $realtime, SPUSTARTPC, ExpValue, FIFOValue);
   //         $display(" ");
   //      end
   //endtask

   task automatic CheckSEQIntEn(int SPUSTARTPC, input int InstrCycle, input logic ExpValue); 
      logic SEQIntEn;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTDC_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);
      
      SEQIntEn = $root.TestTop.uRFM.uSPU.uSEQ.rIntEn;

      if(SEQIntEn === ExpValue)
         $display("%0t Read SEQ IntEn OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :%h ,%h\n", $realtime, SPUSTARTPC, ExpValue, SEQIntEn);
   endtask

   task automatic CheckSYNFlag(int SPUSTARTPC, input int InstrCycle, input logic[1:0] ExpValue);
      logic[1:0] FlagValue;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);

      FlagValue = $root.TestTop.uRFM.uSPU.uSYN.rFlag;

      if(FlagValue == ExpValue)
         $display("%0t Read SYN Flag OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :%h ,%h\n", $realtime, SPUSTARTPC, ExpValue, FlagValue);
   endtask

   task automatic CheckSYNCFlag(int SPUSTARTPC, input int InstrCycle, input logic[1:0] ExpValue);
      logic[1:0] FlagValue;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);

      FlagValue = $root.TestTop.uRFM.uSPU.uSYN.rFlag;

      if(FlagValue[1] === ExpValue[1])
         $display("%0t Read SYN Flag OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :%h ,%h\n", $realtime, SPUSTARTPC, ExpValue, FlagValue);
   endtask

`undef SPU_STARTDC_PC
`undef SPU_STARTEX0_PC
`undef DPStall
`undef ExeStall
`undef IntStall
`undef SYNStall
`undef CALLEN 
`undef CALL_ADDR


//////////////////////////////////////////////////////////////
//Class to Emulate AXI transaction.
class AXIAWTran #(int ID_BITS=7,int A_BITS=32);
      bit[ID_BITS-1:0]          AWID    ; bit[A_BITS-1:0]           AWADDR  ; bit[2:0]                  AWSIZE  ;
      bit[3:0]                  AWLEN   ; bit[1:0]                  AWBURST ; bit[1:0]                  AWLOCK  ;
      bit                       AWVALID ;
      bit                       AWREADY ;
endclass

class AXIWTran #(int ID_BITS=7, int D_BITS=128);
      bit[ID_BITS-1:0]          WID     ; bit[D_BITS-1:0]           WDATA   ; bit[D_BITS/8-1:0]         WSTRB   ;
      bit                       WLAST   ; bit                       WVALID  ; bit                       WREADY  ;
endclass

class AXIBTran #(int ID_BITS=7);
      bit[ID_BITS-1:0]          BID     ; bit[1:0]                  BRESP   ; bit                       BVALID  ;
      bit                       BREADY  ;
endclass

class AXIARTran #(int ID_BITS=7,int A_BITS=32);
      bit[ID_BITS-1:0]         ARID    ; bit[A_BITS-1:0]          ARADDR  ; bit[2:0]                 ARSIZE  ;
      bit[3:0]                 ARLEN   ; bit[1:0]                 ARBURST ; bit[1:0]                 ARLOCK  ;
      bit                      ARVALID ; bit                      ARREADY ;
endclass

class AXIRTran #( int ID_BITS=7,int D_BITS=128);
      bit[ID_BITS-1:0]          RID     ; bit[D_BITS-1:0]           RDATA   ; bit[1:0]                  RRESP   ;
      bit                       RLAST   ; bit                       RVALID  ; bit                       RREADY  ;
endclass

//////////////////////////////////////////////////////////////
//Class to Emulate the ARM.
class ARM #(int AXI_WIDTH=32);
  extern task Write(input int Addr, input int Data); 
  extern task Read(input int Addr, output int Data);
  extern task BurstWrite(input int Addr,input int Size,input int Len,ref byte Data[],input int Delay); 
  extern task BurstRead(input int Addr,input int Size,input int Len,ref byte Data[],input int Delay);
  extern task DMA( input int DMACmd, input int GroupNum,
                                     input int lAddr, input int lXNum,  input int lYStep=0, input int lYNum=1, input int lZStep=0,input int lYAllNum,
                                     input int gAddr, input int gXNum,  input int gYStep=0, input int gYNum=1, input int gZStep=0,input int gYAllNum);
  extern task WaitDMA(input int GroupNum, input int Update= 0, input int WaitCycles = 10000);
endclass

//////////////////////////////////////////////////////////////
//Class to Emulate the AXISlave
class AXISlave #(MAIL_SIZE=8);
  extern function new(input int Size); 
  extern task Init(string FileName); 
  extern task ReadBytes(input int Addr, ref byte D[] );  
  extern task WriteBytes(input int Addr, const ref byte D[]);
  extern task ReadWords(input int Addr, ref int D[] );  
  extern task WriteWords(input int Addr, const ref int D[]);
  extern task ReadWord(input int Addr, output int D );  
  extern task WriteWord(input int Addr, input int D );
  virtual task Run();         endtask
  virtual task AXIAWHandle(); endtask
  virtual task AXIARHandle(); endtask
  virtual task AXIWHandle(); endtask
  virtual task AXIBHandle(); endtask
  virtual task AXIRHandle(); endtask

  mailbox AWMail, ARMail, WMail;
  byte    Data[];
  typedef enum {AXI_BURST_FIXED,AXI_BURST_INCR,AXI_BURST_WRAP} AXI_BURST_TYPE;

endclass
//////////////////////////////////////////////////////////////
//Class to Emulate the DDR
class DDR #(int BASE=32'h0, int SIZE=32'h100, int AXI_WIDTH=128) extends AXISlave ;
  function new(); super.new(SIZE); endfunction
  extern virtual task Run();         
  extern virtual task AXIAWHandle(); 
  extern virtual task AXIARHandle(); 
  extern virtual task AXIWHandle();  
  extern virtual task AXIBHandle();  
  extern virtual task AXIRHandle();  
endclass
//////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////
function AXISlave::new(input int Size);
  Data = new[Size];
  AWMail = new(MAIL_SIZE);
  ARMail = new(MAIL_SIZE);
  WMail = new(MAIL_SIZE); 
endfunction

task    AXISlave::Init(string FileName);
  $readmemh( FileName,this.Data, );
endtask

task    AXISlave::ReadBytes(input int Addr, ref byte D[]);
  if( Addr + D.size() < Data.size() )  foreach( D[i] )  D[i] = this.Data[Addr + i];
  else  $display ("@%0t : Error reading bytes , address= 0x%h, length = 0x%h",$realtime, Addr, D.size() );
endtask

task    AXISlave::WriteBytes(input int Addr, const ref byte D[]);
  if( Addr + D.size() <=  Data.size() )  foreach( D[i] )   this.Data[Addr + i] = D[i];
  else  $display ("@%0t : Error writing bytes , address= 0x%h, length = 0x%h",$realtime, Addr, D.size() );
endtask

task    AXISlave::ReadWord(input int Addr, output int D);
    for (int i=0; i< 4; i++) D[ (i+1) *8 -1 -:  8 ] = Data[Addr +i] ;
endtask

task    AXISlave::WriteWord(input int Addr, input int D);
    for (int i=0; i< 4; i++)  Data[Addr +i] = D[ (i+1) *8 -1 -: 8 ] ;
endtask

task    AXISlave::ReadWords(input int Addr, ref int D[]);
  if( Addr + D.size()*4 < Data.size() )  foreach( D[i] ) begin
    for (int j=0; j< 4; j++)     D[i][ (j+1) *8 -1 -:  8 ]   =       Data[Addr + i*4 + j] ;
  end else  $display ("@%0t : Error reading words , address= 0x%h, length = 0x%h,DDR size = %h bytes",$realtime, Addr, D.size(),Data.size() );
endtask

task    AXISlave::WriteWords(input int Addr, const ref int D[]);
  if( Addr + D.size()*4 < Data.size() )  foreach( D[i] ) begin
    for (int j=0; j< 4; j++)      Data[ Addr + i*4 + j]      =       D[i][ (j+1) *8 -1 -: 8 ] ;
  end else  $display ("@%0t : Error writing words , address= 0x%h, length = 0x%h DDR size = %h bytes",$realtime, Addr, D.size(),Data.size() );
endtask
//////////////////////////////////////////////////////////////

task DDR::Run();
  fork :DDR_HANDLES
    AXIAWHandle();
    AXIARHandle();
    AXIWHandle();
    AXIBHandle();
    AXIRHandle();
  join_none
endtask

`define DDR_CB  iCSUToExt.iCB
//////////////////////////
task DDR::AXIAWHandle();
   AXIAWTran  sAW = new(); 
   AXIAWTran  MailAW;   
   `DDR_CB.AWREADY <=   1; 
    while(1) begin
      @(`DDR_CB) if ( `DDR_CB.AWVALID == 1 ) begin 
        sAW.AWID      =      `DDR_CB.AWID    ; sAW.AWADDR    =      `DDR_CB.AWADDR  ; sAW.AWSIZE    =      `DDR_CB.AWSIZE  ; 
        sAW.AWLEN     =      `DDR_CB.AWLEN   ; sAW.AWBURST   =      `DDR_CB.AWBURST ; sAW.AWLOCK    =      `DDR_CB.AWLOCK  ; 
        sAW.AWVALID   =      `DDR_CB.AWVALID ;

        MailAW = new sAW;
 
        if( AWMail.try_put(MailAW)  ==  0 ) begin
          `DDR_CB.AWREADY <=   0;
        end else begin; 
          `DDR_CB.AWREADY <=   1; 
          @(`DDR_CB) `DDR_CB.AWREADY <=  0;
        end
      end 
    end   
endtask

//////////////////////////
task DDR::AXIWHandle();
   AXIWTran sW=new();    
   AXIWTran MailW;

   `DDR_CB.WREADY <=   1; 
    while(1) begin
      @(`DDR_CB) if ( `DDR_CB.WVALID == 1 ) begin 
        sW.WID         =   `DDR_CB.WID     ; sW.WDATA       =   `DDR_CB.WDATA   ; sW.WSTRB       =   `DDR_CB.WSTRB   ; 
        sW.WLAST       =   `DDR_CB.WLAST   ; sW.WVALID      =   `DDR_CB.WVALID  ; 
      
       MailW = new sW;

        if( WMail.try_put(MailW)  ==  0 ) begin
          `DDR_CB.WREADY <=   0;
        end else begin; 
          `DDR_CB.WREADY <=   1; 
          @(`DDR_CB) `DDR_CB.WREADY <=  0;
        end
      end
    end   
endtask

//////////////////////////
task DDR::AXIARHandle();
  AXIARTran   sAR = new();    
  AXIARTran   MailAR;

  `DDR_CB.ARREADY <=   1; 
  while(1) begin
    @(`DDR_CB) if ( `DDR_CB.ARVALID == 1 ) begin 
      sAR.ARID      =   `DDR_CB.ARID   ; sAR.ARADDR    =   `DDR_CB.ARADDR ; sAR.ARSIZE    =   `DDR_CB.ARSIZE ; 
      sAR.ARLEN     =   `DDR_CB.ARLEN  ; sAR.ARBURST   =   `DDR_CB.ARBURST; sAR.ARLOCK    =   `DDR_CB.ARLOCK ; 
      sAR.ARVALID   =   `DDR_CB.ARVALID; sAR.ARREADY   =   0          ;

      MailAR = new sAR;
 
      if( ARMail.try_put(MailAR)  ==  0 ) begin
        `DDR_CB.ARREADY <=   0;
      end else begin; 
        `DDR_CB.ARREADY <=   1; 
         @(`DDR_CB) `DDR_CB.ARREADY <=  0;
      end
    end
  end   
endtask

//////////////////////////
task DDR::AXIBHandle();
    AXIAWTran  sAW ;    
    AXIWTran   sW  ;    
    int BrstCount = 0;
    int BrstSize  = 0;
    int MemAddr   = 0;
    while(1) begin
      `DDR_CB.BVALID <=  0;
      AWMail.get(sAW);    

      BrstCount = sAW.AWLEN+1; 
      BrstSize  = 1<<(sAW.AWSIZE);
      MemAddr   = (sAW.AWADDR/(AXI_WIDTH/8))*(AXI_WIDTH/8) - DDR::BASE;

      BUSRT_TYPE: assert( sAW.AWBURST ==  AXI_BURST_INCR );
      ADDR_RANGE: assert( MemAddr     <   DDR::SIZE       );

      for(int i=0; i< BrstCount; i++) begin
        WMail.get(sW);
        for( int j=0; j< AXI_WIDTH/8; j++ ) if ( sW.WSTRB[j] ) begin
          this.Data [ MemAddr+ i*BrstSize + j   ] = sW.WDATA[(j*8) +: 8];         
        end
      end

      LAST_CHECK: assert( sW.WLAST ==  1);   //the last poped data.
      
      @(`DDR_CB)
      while(1 ) begin
        `DDR_CB.BVALID <=  1;      
        `DDR_CB.BID    <=  sAW.AWID; 
        @(`DDR_CB) if( `DDR_CB.RREADY == 1) break;
      end  
     
    end
endtask

//////////////////////////
task DDR::AXIRHandle();
  AXIARTran sAR;    
  bit [AXI_WIDTH-1 : 0] ReadData;
  int BrstCount = 0;
  int BrstSize  = 0;
  int MemAddr   = 0;
  while(1) begin
    `DDR_CB.RVALID <=  0;
    `DDR_CB.RLAST  <=  0;
    ARMail.get(sAR);

    BrstCount = sAR.ARLEN+1; 
    BrstSize  = 1<<(sAR.ARSIZE);
    MemAddr   = (sAR.ARADDR/(AXI_WIDTH/8))*(AXI_WIDTH/8) - DDR::BASE;

//    BUSRT_TYPE: assert( sAR.ARBURST ==  AXI_BURST_INCR );
//    BUSRT_SIZE: assert( BrstSize  ==  AXI_WIDTH/8 );
//    ADDR_RANGE: assert( MemAddr     <   DDR::SIZE       );
    
    for(int i=0; i< BrstCount; i++) begin
      for( int j=0; j< AXI_WIDTH/8; j++ ) ReadData[ (j*8) +: 8] = this.Data[ MemAddr+ i*BrstSize + j   ]; 
      while(1 ) begin
        `DDR_CB.RID    <=  sAR.ARID;
        `DDR_CB.RRESP  <=  0;
        `DDR_CB.RVALID <=  1;
        `DDR_CB.RDATA  <=  ReadData;
        `DDR_CB.RLAST  <=  ( i== (BrstCount -1) );
        @(`DDR_CB) if( `DDR_CB.RREADY == 1) break;
      end      
    end
  end
endtask

//Class to Emulate the SM
class ShareMem #(int BASE=32'h0, int SIZE=32'h100, int AXI_WIDTH=32) extends AXISlave ;
  function new();
    super.new(SIZE);
    Data = new[SIZE];
    AWMail = new(MAIL_SIZE);
    ARMail = new(MAIL_SIZE);
    WMail = new(MAIL_SIZE);  
  endfunction
  extern virtual task Run();         
  extern virtual task AXIAWHandle(); 
  extern virtual task AXIARHandle(); 
  extern virtual task AXIWHandle();  
  extern virtual task AXIBHandle();  
  extern virtual task AXIRHandle(); 
  mailbox AWMail, ARMail, WMail; 
endclass


task ShareMem::Run();
  fork :DDR_HANDLES
    AXIAWHandle();
    AXIARHandle();
    AXIWHandle();
    AXIBHandle();
    AXIRHandle();
  join_none
endtask

`define SMem_CB  iSMBus.iCB
//////////////////////////
task ShareMem::AXIAWHandle();
  fork 
    begin
      AXIAWTran  sAW = new(); 
      AXIAWTran  MailAW;   
      `SMem_CB.AWREADY <=   1; 
      while(1) begin
        @(`SMem_CB) if ( `SMem_CB.AWVALID == 1 ) begin 
          sAW.AWID      =      `SMem_CB.AWID    ; sAW.AWADDR    =      `SMem_CB.AWADDR  ; sAW.AWSIZE    =      `SMem_CB.AWSIZE  ; 
          sAW.AWLEN     =      `SMem_CB.AWLEN   ; sAW.AWBURST   =      `SMem_CB.AWBURST ; sAW.AWLOCK    =      `SMem_CB.AWLOCK  ; 
          sAW.AWVALID   =      `SMem_CB.AWVALID ;

          MailAW = new sAW;
 
          if( AWMail.try_put(MailAW)  ==  0 ) begin
          `SMem_CB.AWREADY <=   0;
          end else begin 
            `SMem_CB.AWREADY <=   1; 
            @(`SMem_CB) `SMem_CB.AWREADY <=  0;
          end
        end 
      end
    end
  join  
endtask

//////////////////////////
task ShareMem::AXIWHandle();
  fork 
    begin
      AXIWTran #(.ID_BITS(7), .D_BITS(32)) sW=new();    
      AXIWTran #(.ID_BITS(7), .D_BITS(32)) MailW;

      `SMem_CB.WREADY <=   1; 
      while(1) begin
        @(`SMem_CB) if ( `SMem_CB.WVALID == 1 ) begin 
          sW.WID         =   `SMem_CB.WID     ; sW.WDATA       =   `SMem_CB.WDATA   ; sW.WSTRB       =   `SMem_CB.WSTRB   ; 
          sW.WLAST       =   `SMem_CB.WLAST   ; sW.WVALID      =   `SMem_CB.WVALID  ; 
      
          MailW = new sW;

          if( WMail.try_put(MailW)  ==  0 ) begin
            `SMem_CB.WREADY <=   0;
          end else begin; 
            `SMem_CB.WREADY <=   1; 
            @(`SMem_CB) `SMem_CB.WREADY <=  0;
          end
        end
      end
    end
  join   
endtask

//////////////////////////
task ShareMem::AXIARHandle();
  fork 
    begin
      AXIARTran   sAR = new();    
      AXIARTran   MailAR;

      `SMem_CB.ARREADY <=   1; 
      while(1) begin
        @(`SMem_CB) if ( `SMem_CB.ARVALID == 1 ) begin 
          sAR.ARID      =   `SMem_CB.ARID   ; sAR.ARADDR    =   `SMem_CB.ARADDR ; sAR.ARSIZE    =   `SMem_CB.ARSIZE ; 
          sAR.ARLEN     =   `SMem_CB.ARLEN  ; sAR.ARBURST   =   `SMem_CB.ARBURST; sAR.ARLOCK    =   `SMem_CB.ARLOCK ; 
          sAR.ARVALID   =   `SMem_CB.ARVALID; sAR.ARREADY   =   0          ;

          MailAR = new sAR;
 
          if( ARMail.try_put(MailAR)  ==  0 ) begin
            `SMem_CB.ARREADY <=   0;
          end else begin 
            `SMem_CB.ARREADY <=   1; 
             @(`SMem_CB) `SMem_CB.ARREADY <=  0;
          end
        end
      end
    end
  join   
endtask

//////////////////////////
task ShareMem::AXIBHandle();
    AXIAWTran  sAW ;    
    AXIWTran #(.ID_BITS(7), .D_BITS(32)) sW  ;    
    int BrstCount = 0;
    int BrstSize  = 0;
    int MemAddr   = 0;
    while(1) begin
      `SMem_CB.BVALID <=  0;
      AWMail.get(sAW); 
      
      BrstCount = sAW.AWLEN+1; 
      BrstSize  = 1<<(sAW.AWSIZE);
      MemAddr   = sAW.AWADDR - ShareMem::BASE;

      BUSRT_TYPE: assert( sAW.AWBURST ==  AXI_BURST_INCR );
      BUSRT_SIZE: assert( BrstSize ==  AXI_WIDTH/8 );
      ADDR_RANGE: assert( MemAddr     <   ShareMem::SIZE       );
      
      for(int i=0; i< BrstCount; i++) begin
        WMail.get(sW);
        for( int j=0; j< BrstSize; j++ ) if ( sW.WSTRB[j] ) begin
          this.Data [ MemAddr+ i*BrstSize + j   ] = sW.WDATA[(j*8) +: 8];
        end
      end

      LAST_CHECK: assert( sW.WLAST ==  1);   //the last poped data.
      
      @(`SMem_CB)
      while(1) begin
        `SMem_CB.BVALID <=  1;      
        `SMem_CB.BID    <=  sAW.AWID; 
        @(`SMem_CB) if( `SMem_CB.RREADY == 1) break;
      end  
       
    end
endtask

//////////////////////////
task ShareMem::AXIRHandle();
  AXIARTran sAR;    
  bit [AXI_WIDTH-1 : 0] ReadData;
  int BrstCount = 0;
  int BrstSize  = 0;
  int MemAddr   = 0;
  while(1) begin
    `SMem_CB.RVALID <=  0;
    `SMem_CB.RLAST  <=  0;
   
    ARMail.get(sAR); 
    
    BrstCount = sAR.ARLEN+1; 
    BrstSize  = 1<<(sAR.ARSIZE);
    MemAddr   = sAR.ARADDR - ShareMem::BASE;

    BUSRT_TYPE: assert( sAR.ARBURST ==  AXI_BURST_INCR );
    BUSRT_SIZE: assert( BrstSize  ==  AXI_WIDTH/8 );
    ADDR_RANGE: assert( MemAddr     <   ShareMem::SIZE       );
    
    for(int i=0; i< BrstCount; i++) begin
      for( int j=0; j< BrstSize; j++ ) ReadData[ (j*8) +: 8] = this.Data[ MemAddr+ i*BrstSize + j   ]; 
      while(1 ) begin
        `SMem_CB.RID    <=  sAR.ARID;
        `SMem_CB.RRESP  <=  0;
        `SMem_CB.RVALID <=  1;
        `SMem_CB.RDATA  <=  ReadData;
        `SMem_CB.RLAST  <=  ( i== (BrstCount -1) );
        @(`SMem_CB) if( `SMem_CB.RREADY == 1) break;
      end
    end
  end
endtask

/////////////////////////////////////////////////////////////////////////////////////////////////////
task ARM::Write(input int Addr, input int Data); 
  fork
    iExtToCSU.oCB.BREADY  <=   1;
    //Write the address
    begin :WRITE_ADDR
      @(iExtToCSU.oCB) begin
        iExtToCSU.oCB.AWID    <=   3; iExtToCSU.oCB.AWADDR  <=  Addr; iExtToCSU.oCB.AWSIZE  <=  4;
        iExtToCSU.oCB.AWLEN   <=   0; iExtToCSU.oCB.AWBURST <=  0;    iExtToCSU.oCB.AWLOCK  <=  0;
        iExtToCSU.oCB.AWVALID <=   1;
      end
      while(1) begin
        @(iExtToCSU.oCB) if (iExtToCSU.oCB.AWREADY == 1) begin 
          iExtToCSU.oCB.AWVALID <=  0;   break;
        end
      end 
    end : WRITE_ADDR
    //Write the Data
    begin:WRITE_DATA
      @(iExtToCSU.oCB)  begin
        iExtToCSU.oCB.WID     <=   3; iExtToCSU.oCB.WDATA   <=  Data; iExtToCSU.oCB.WSTRB   <=  'hF;
        iExtToCSU.oCB.WLAST   <=   1; iExtToCSU.oCB.WVALID  <=  1;
      end   
      while(1) begin
          @(iExtToCSU.oCB) if (iExtToCSU.oCB.WREADY == 1) begin
            iExtToCSU.oCB.WVALID <=  0;   
            break;
          end
      end
    end:WRITE_DATA
  join
endtask

task ARM::BurstWrite(input int Addr,input int Size,input int Len,ref byte Data[],input int Delay);
  int Counter;
  int DelayCounter;
  Counter=0;
  DelayCounter=0;
  fork
    iExtToCSU.oCB.BREADY  <=   1;
    //Write the address
    begin :WRITE_ADDR
      @(iExtToCSU.oCB) begin
        iExtToCSU.oCB.AWID    <=   3; iExtToCSU.oCB.AWADDR  <=  Addr; iExtToCSU.oCB.AWSIZE  <= Size;
        iExtToCSU.oCB.AWLEN   <=  Len; iExtToCSU.oCB.AWBURST <=  1;    iExtToCSU.oCB.AWLOCK  <=  0;
        iExtToCSU.oCB.AWVALID <=   1;
      end
      while(1) begin
        @(iExtToCSU.oCB) if (iExtToCSU.oCB.AWREADY == 1) begin 
          iExtToCSU.oCB.AWVALID <=  0;   break;
        end
      end 
    end : WRITE_ADDR
    //Write the Data
    begin:WRITE_DATA
      while(Counter<= Len) begin
        @(iExtToCSU.oCB)  begin
          iExtToCSU.oCB.WID     <=   3; iExtToCSU.oCB.WDATA   <={Data[Counter*8+3],Data[Counter*8+2],Data[Counter*8+1],Data[Counter*8]}; iExtToCSU.oCB.WSTRB   <=  'hF;
          iExtToCSU.oCB.WLAST   <=   (Counter==Len); iExtToCSU.oCB.WVALID  <=  1;
        end
        #1;
        if(iExtToCSU.oCB.WREADY) Counter=Counter+1;
        while((DelayCounter<Delay)&&(Counter<= Len)) begin
          @(iExtToCSU.oCB)  begin
            iExtToCSU.oCB.WVALID<= 1'b0;
            DelayCounter=DelayCounter+1;
          end
        end
        DelayCounter=0;
      end 
      while(1) begin
        @(iExtToCSU.oCB) if (iExtToCSU.oCB.WREADY == 1) begin
          iExtToCSU.oCB.WVALID <=  0;   
          break;
        end
      end
    end:WRITE_DATA              
    begin:WRITE_RESP
      while(1) begin
        @(iExtToCSU.oCB) if (iExtToCSU.oCB.BVALID == 1) begin 
          iExtToCSU.oCB.BREADY  <=   0;   break;
        end
      end 
    end:WRITE_RESP
  join
endtask

//////////////////////////////////////////////
task ARM::Read(input int Addr, output int Data); 
  begin:WRITE_ADDR
    @(iExtToCSU.oCB)  begin
      iExtToCSU.oCB.ARID    <=   3; iExtToCSU.oCB.ARADDR  <=  Addr; iExtToCSU.oCB.ARSIZE  <=  4;
      iExtToCSU.oCB.ARLEN   <=   0; iExtToCSU.oCB.ARBURST <=  0;    iExtToCSU.oCB.ARLOCK  <=  0;
      iExtToCSU.oCB.ARVALID <=   1;
    end   
    while(1) begin
      @(iExtToCSU.oCB) if (iExtToCSU.oCB.ARREADY == 1) begin
        iExtToCSU.oCB.ARVALID <=  0;   
        break;
      end
    end 
  end:WRITE_ADDR
  begin:READ_DATA
    iExtToCSU.oCB.RREADY  <=  1;
    @(posedge iExtToCSU.oCB.RVALID) Data  = iExtToCSU.oCB.RDATA;
    @(iExtToCSU.oCB )               iExtToCSU.oCB.RREADY  <= 0;
  end:READ_DATA
endtask

task ARM::BurstRead(input int Addr,input int Size,input int Len,ref byte Data[],input int Delay);
  int Counter,DelayCounter;
  bit BreakOut;
  BreakOut=0;
  Counter=0;
  DelayCounter=0;  
  begin:WRITE_ADDR
    @(iExtToCSU.oCB)  begin
      iExtToCSU.oCB.RREADY  <=  1;
      iExtToCSU.oCB.ARID    <=   3; iExtToCSU.oCB.ARADDR  <=  Addr; iExtToCSU.oCB.ARSIZE  <=  Size;
      iExtToCSU.oCB.ARLEN   <=   Len; iExtToCSU.oCB.ARBURST <=  1;    iExtToCSU.oCB.ARLOCK  <=  0;
      iExtToCSU.oCB.ARVALID <=   1;
    end
    BreakOut=0;   
    while(!BreakOut) begin
      @(iExtToCSU.oCB) if (iExtToCSU.oCB.ARREADY == 1) begin
        iExtToCSU.oCB.ARVALID <=  0;   
        BreakOut=1;
      end
    end 
  end:WRITE_ADDR
  begin:READ_DATA
    while(Counter<= Len) begin
      @(iExtToCSU.oCB );
      if(iExtToCSU.oCB.RVALID) begin
        if(DelayCounter==0) {Data[Counter*8+3],Data[Counter*8+2],Data[Counter*8+1],Data[Counter*8]}=iExtToCSU.oCB.RDATA;
        if((Counter==Len)||(DelayCounter!=Delay)) iExtToCSU.oCB.RREADY  <= 0;
        else                                      iExtToCSU.oCB.RREADY  <= 1;
        #1
        if((DelayCounter==Delay)||(Counter==Len)) Counter=Counter+1;
        if(DelayCounter!=Delay) DelayCounter=DelayCounter+1; 
        else                    DelayCounter=0; 
      end   
    end
    @(iExtToCSU.oCB ) iExtToCSU.oCB.RREADY  <= 0;    
  end:READ_DATA
endtask

//////////////////////////////////////////////////////////////
//Task to setup the DMA request.
task ARM::DMA( input int DMACmd, input int GroupNum,
                                 input int lAddr, input int lXNum,  input int lYStep=0, input int lYNum=1, input int lZStep=0,input int lYAllNum,
                                 input int gAddr, input int gXNum,  input int gYStep=0, input int gYNum=1, input int gZStep=0,input int gYAllNum);
    int QNum= 0; int CMDStatus=1;
    //Wait the DMA queue to be availiable
    fork
      begin: WAIT_DMAQUEUE
        while(1) begin
          this.Read(`MMIO_CMDQStatus, QNum);
          if (QNum < 4) break;
        end
      end: WAIT_DMAQUEUE

      begin:WAIT_DMAQUEUE_BEAT
        WaitSoCCycles(50);
        $display("@%0t : ARM Waiting for DMA Queue avaliable.",$realtime);
      end
    join_any

    disable WAIT_DMAQUEUE;
    //Write the DMA parameters.    
    while(1)  begin
      this.Write(`MMIO_LOCAL_ADDR,      lAddr);          this.Write(`MMIO_LOCAL_XNUM,    lXNum);
      this.Write(`MMIO_LOCAL_YSTEP,     lYStep);         this.Write(`MMIO_LOCAL_YNUM,    lYNum);
      this.Write(`MMIO_LOCAL_ZSTEP,     lZStep);         this.Write(`MMIO_LOCAL_YALLNUM,  lYAllNum);
      this.Write(`MMIO_GLOBAL_ADDR,     gAddr);          this.Write(`MMIO_GLOBAL_XNUM,   gXNum);
      this.Write(`MMIO_GLOBAL_YSTEP,    gYStep);         this.Write(`MMIO_GLOBAL_YNUM,   gYNum);
      this.Write(`MMIO_GLOBAL_ZSTEP,    gZStep);         this.Write(`MMIO_GLOBAL_YALLNUM, gYAllNum);
      this.Write(`MMIO_COMMAND_TAG,     GroupNum);       this.Write(`MMIO_DMA_CMD,       DMACmd);
      this.Read(`MMIO_CMDStatus,  CMDStatus);
      if( CMDStatus  == 0 ) begin $display("@%0t: DMA command complete",$realtime); break; end
      else                  $display("DMA command sending error , retry...");
  end
  
endtask

//////////////////////////////////////////////////////////////
//Task to Wait DMA group  complete the task
task ARM::WaitDMA(input int GroupNum, input int Update= 0, input int WaitCycles = 10000);
  int Status =0;
  this.Write(`MMIO_TAG_QUERY_MASK, 1<<GroupNum);           
  this.Write(`MMIO_TAG_QUERY_TYPE, Update);      
  fork : WAIT_DMA_STATUS
    while( ( (Status >> GroupNum)  & 32'h1 ) ==32'h0 ) begin this.Read(`MMIO_TAG_STATUS, Status); end
    begin
      WaitSoCCycles( WaitCycles);
      $display("@%0t :Error  Wait %d Cycles but DMA not complete. ", $realtime, WaitCycles);
    end
  join_any :WAIT_DMA_STATUS
  disable WAIT_DMA_STATUS ;
endtask


//////////////////////////////////////////////////////////////
//Task to reset whole design and start the VPU. 
task ResetAndStartSPU();
  int T;
  ARM  hARM;

  hARM = new();
  ResetAll();
  hARM.Write(`MMIO_APE_CONTROL, 32'h80000001); 
  fork : CHECK_START_STATUS
        begin: READ_STATUS
        `ifdef PLATFORM_FPGA
          wait( $root.TestTop.FPGA_Top_inst.uRFM.uSPU.oSPUStat[0]== 1'b1);
        `else
          wait( $root.TestTop.uRFM.uSPU.oSPUStat[0]== 1'b1);
        `endif
          $display("@%0t: SPU Started ",$realtime);
        end: READ_STATUS

        begin : TIME_OUT
          WaitSoCCycles(100);
          $display("@%0t: Error: Waited 100 Cycle But SPU Didn't Start .", $realtime);
        end   :TIME_OUT
  join_any:CHECK_START_STATUS

  disable  CHECK_START_STATUS;

endtask

task ARM_APEInitIM();
//  `define _LIB_DEBUG
  localparam DDRSize =32'h400000;
  localparam LADDR_WIDTH = 17;
  localparam LEN = 1<<LADDR_WIDTH; 
  
  ARM hARM;
  int i;
  byte Mem[];
  DDR #(.BASE(`DDR_ADDR_BASE),.SIZE(DDRSize))  hDDR;
  hARM = new();   
  hDDR = new(); 
  ResetAll();
  hDDR.Run(); 

  //Initialization the IM
  $readmemh("IM.data", hDDR.Data);
  $readmemh("IM.data", Mem);

  `ifdef  _LIB_DEBUG
    for (i = 17'h1fffc; i<18'h20000; i++)  $display("hDDR.Data = %h", hDDR.Data[i]);
  `endif

  if(Mem.size()!=0) begin
    hARM.DMA(0, 0, 0,              LEN, 0, 1, 0, 1,
                   `DDR_ADDR_BASE, LEN, 0, 1, 0, 1);
    hARM.WaitDMA(0, 0 , 100000);    
    $display("@%0t : Completing Initialize the IM",$realtime);
  end else begin
    $display("@%0t : No need to initialize the IM",$realtime);
  end
endtask

task ARM_APEInitMIM();
  localparam DDRSize =32'h400000;
  
  ARM hARM;
  int i;
  byte Mem[];
  DDR #(.BASE(`DDR_ADDR_BASE),.SIZE(DDRSize))  hDDR;
  hARM = new();   
  hDDR = new(); 
//  ResetAll();
  hDDR.Run(); 
  //Initialization the MIM  
  $readmemh("MIM.data", Mem);
  $readmemh("MIM.data", hDDR.Data);
  if(Mem.size()!=0) begin
    hARM.DMA(0, 0, 32'h40000,      32'h29          , 32'h40, hDDR.Data.size()/32'h29, 0, hDDR.Data.size()/32'h29,
                   `DDR_ADDR_BASE, hDDR.Data.size(), 0,      1,                       0, 1);
    hARM.WaitDMA(0, 0 , 100000);
    $display("@%0t : Completing Initialize the MIM",$realtime);
  end else begin
    $display("@%0t : No need to initialize the MIM",$realtime);
  end
endtask

task  ARM_APEInitInstrMem();
  ARM_APEInitIM();
  ARM_APEInitMIM();    
endtask

task  ARM_APEInitDataMem();
  localparam DDRSize =32'h400000;
  localparam LADDR_WIDTH = 19;
  localparam LEN = 1<<LADDR_WIDTH; 

  ARM hARM;
  byte Mem[], Mem0[], Mem1[];  
  DDR #(.BASE(`DDR_ADDR_BASE),.SIZE(DDRSize))  hDDR;
  hARM = new();   
  hDDR = new(); 
  hDDR.Run();

  // Initialize the DM0
  $readmemh("DM0.dat", hDDR.Data);
  $readmemh("DM0.dat", Mem);  
  if(Mem.size()!=0) begin
    hARM.DMA(0, 0, 32'h100000,     LEN, 0, 1, 0, 1,
                   `DDR_ADDR_BASE, LEN, 0, 1, 0, 1);
    hARM.WaitDMA(0, 0 , 100000);  
    $display("@%0t : Completing Initialize the DM0",$realtime);  
  end else begin
    $display("@%0t : No need to initialize the DM0",$realtime);
  end  

  // Initialize the DM1
  $readmemh("DM1.dat", hDDR.Data); 
  $readmemh("DM1.dat", Mem0);  
  if(Mem0.size()!=0) begin
    hARM.DMA(0, 0, 32'h200000,     LEN, 0, 1, 0, 1,
                   `DDR_ADDR_BASE, LEN, 0, 1, 0, 1);
    hARM.WaitDMA(0, 0 , 100000);
    $display("@%0t : Completing Initialize the DM1",$realtime);  
  end else begin
    $display("@%0t : No need to initialize the DM1",$realtime);
  end

  // Initialize the DM2
  $readmemh("DM2.dat", hDDR.Data); 
  $readmemh("DM2.dat", Mem1);  
  if(Mem1.size()!=0) begin
    hARM.DMA(0, 0, 32'h300000,     LEN, 0, 1, 0, 1,
                   `DDR_ADDR_BASE, LEN, 0, 1, 0, 1);
    hARM.WaitDMA(0, 0 , 100000);
    $display("@%0t : Completing Initialize the DM2",$realtime);  
  end else begin
    $display("No need to initialize the DM2");
  end

endtask



