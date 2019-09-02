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

//Task to Initialize the APE 
task  APEInitInstrMem();
  // IM Instruction Code
`ifdef PLATFORM_FPGA
  TestTop.FPGA_Top_inst.uAPE.uIM.IMInit("./IM.data");
  
  // MIM Cluster Instruction Code
  TestTop.FPGA_Top_inst.uAPE.uMIM.MIMInit("./MIM.data");
`else
  TestTop.uAPE.uIM.IMInit("./IM.data");

  // MIM Cluster Instruction Code
  TestTop.uAPE.uMIM.MIMInit("./MIM.data");
  
`endif
endtask

task APEInitDataMem(input bit [2:0] Gran, input bit [3:0] Size);  
  byte Data[];
  Data = new[1<<19];

  TestTop.uAPE.uDM0.DMInit(Gran, Size, "./DM0.dat");
  TestTop.uAPE.uDM1.DMInit(Gran, Size, "./DM1.dat");
  TestTop.uAPE.uDM2.DMInit(Gran, Size, "./DM2.dat"); 
  TestTop.uAPE.uDM3.DMInit(Gran, Size, "./DM3.dat"); 

  Data.delete();
endtask

task APEInitDataMem_new(input bit [2:0] Gran, input bit [3:0] Size, input int XNum);  
  byte Data[];
  Data = new[1<<19];

  TestTop.uAPE.uDM0.DMInit_new(Gran, Size, XNum, "./DM0.dat");
  TestTop.uAPE.uDM1.DMInit_new(Gran, Size, XNum, "./DM1.dat");
  TestTop.uAPE.uDM2.DMInit_new(Gran, Size, XNum, "./DM2.dat"); 
  TestTop.uAPE.uDM3.DMInit_new(Gran, Size, XNum, "./DM3.dat"); 

  Data.delete();
endtask

task APEReadIM();
  integer HandIM;
  byte    Data[];

  Data   = new[1<<18];
  HandIM = $fopen("./IM_actual32.dat");

  TestTop.uAPE.uIM.IMReadBytes(0, Data);

  $fdisplay(HandIM,"@00000000");
  for(int i=0;i<4096*4;i++) begin
       for(int j=0;j<16;j++)  begin
          $fwrite(HandIM,"%h ",Data[i*16+j]);
       end
       $fwrite(HandIM,"\n");
  end
  $fclose(HandIM);

endtask

task APEReadDataMem(input bit [2:0] Gran, input bit [3:0] Size);
  integer HandDM0,HandDM1,HandDM2,HandDM3;
  byte    Temp0,Temp1,Temp2,Temp3;
  byte    Data0[], Data1[], Data2[], Data3[];
  Data0 = new[1<<18];
  Data1 = new[1<<18];
  Data2 = new[1<<17];
  Data3 = new[1<<17];

  HandDM0 = $fopen("./DM0_actual32.dat");
  HandDM1 = $fopen("./DM1_actual32.dat");
  HandDM2 = $fopen("./DM2_actual32.dat");
  HandDM3 = $fopen("./DM3_actual32.dat");

  TestTop.uAPE.uDM0.DMReadBytes(0, Gran, Size, Data0);
  TestTop.uAPE.uDM1.DMReadBytes(0, Gran, Size, Data1);
  TestTop.uAPE.uDM2.DMReadBytes(0, Gran, Size, Data2); 
  TestTop.uAPE.uDM3.DMReadBytes(0, Gran, Size, Data3);

  $writememh("DM0_actual8.dat",Data0);
  $writememh("DM1_actual8.dat",Data1);
  $writememh("DM2_actual8.dat",Data2);
  $writememh("DM3_actual8.dat",Data3);


  $fdisplay(HandDM0,"@00000");
  $fdisplay(HandDM1,"@00000");
    for(int i=0;i<4096*16;i++) begin
       for(int j=0;j<4;j++)  begin
          $fwrite(HandDM0,"%h ",Data0[i*4+j]);
          $fwrite(HandDM1,"%h ",Data1[i*4+j]);
       end
       $fwrite(HandDM0,"\n");
       $fwrite(HandDM1,"\n");
    end
  $fclose(HandDM0);
  $fclose(HandDM1);

  $fdisplay(HandDM2,"@00000");
  $fdisplay(HandDM3,"@00000");
    for(int i=0;i<2048*16;i++) begin
       for(int j=0;j<4;j++)  begin
          $fwrite(HandDM2,"%h ",Data2[i*4+j]);
          $fwrite(HandDM3,"%h ",Data3[i*4+j]);
       end
       $fwrite(HandDM2,"\n");
       $fwrite(HandDM3,"\n");
    end
  $fclose(HandDM2);
  $fclose(HandDM3);

  Data0.delete();
  Data1.delete();
  Data2.delete();
  Data3.delete();
endtask

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
//	@(posedge TestTop.FPGA_Top_inst.uAPE.uSPU.CClk);
//    `else
//	@(posedge TestTop.uAPE.uSPU.CClk); 
//   `endif
//        `TD;
//        i= i+1;
//  end
//endtask

//RefModel
 function bit[511:0] Refmodel_DMLoad( input bit[31:0] Addr,input bit [2:0] Gran, input bit[3:0] KSize, input byte Data[4096][64] );
  
      bit[511:0]  DMValue512;
      bit[31:0]   DataIndexJ;
      bit[5:0]    DataIndexI;
      bit[6:0]    KG;
      bit[31:0]   Step;
      bit[5:0]    Bias;
      bit[5:0]    Count;
      bit         JFlag;

      KG = 1<<Gran;
      Step = 1<<KSize;

      JFlag=1'b0;


      Bias= ((Addr/(Step*64))%64)*KG;

      DataIndexJ = {{6{1'b0}},Addr[31:6]};
      DataIndexI = Addr[5:0]+Bias;

      for(int i=0; i<64; i++) begin
        Count=DataIndexJ/Step;
        Bias= Count*KG;
//          $display("Count=%0x,Bias=%0x,DataIndexI=%0x,DataIndexJ=%0x",Count,Bias,DataIndexI,DataIndexJ);
          DMValue512[8*i +:8] = Data[DataIndexJ][DataIndexI];
          DataIndexI = DataIndexI + 6'h1;
          if((i+1)%KG==0) begin
              if(JFlag) begin
                  DataIndexJ = DataIndexJ + Step-32'h1;
                  JFlag=1'b0;
              end else
                  DataIndexJ = DataIndexJ + Step;
          end 
          else if(DataIndexI==Bias) begin
              JFlag=1'b1;
              DataIndexJ = DataIndexJ + 32'h1;
          end      
      end
      
      return DMValue512;

  endfunction

  function bit[511:0] Refmodel_DMLoad_Less( input bit[31:0] Addr,input bit [2:0] Gran, input bit[3:0] KSize, input byte Data[2048][64] );
  
      bit[511:0]  DMValue512;
      bit[31:0]   DataIndexJ;
      bit[5:0]    DataIndexI;
      bit[6:0]    KG;
      bit[31:0]   Step;
      bit[5:0]    Bias;
      bit[5:0]    Count;
      bit         JFlag;

      KG = 1<<Gran;
      Step = 1<<KSize;

      JFlag=1'b0;


      Bias= ((Addr/(Step*64))%64)*KG;

      DataIndexJ = {{6{1'b0}},Addr[31:6]};
      DataIndexI = Addr[5:0]+Bias;

      for(int i=0; i<64; i++) begin
        Count=DataIndexJ/Step;
        Bias= Count*KG;
//          $display("Count=%0x,Bias=%0x,DataIndexI=%0x,DataIndexJ=%0x",Count,Bias,DataIndexI,DataIndexJ);
          DMValue512[8*i +:8] = Data[DataIndexJ][DataIndexI];
          DataIndexI = DataIndexI + 6'h1;
          if((i+1)%KG==0) begin
              if(JFlag) begin
                  DataIndexJ = DataIndexJ + Step-32'h1;
                  JFlag=1'b0;
              end else
                  DataIndexJ = DataIndexJ + Step;
          end 
          else if(DataIndexI==Bias) begin
              JFlag=1'b1;
              DataIndexJ = DataIndexJ + 32'h1;
          end      
      end
      
      return DMValue512;

  endfunction

 function bit[511:0]  Refmodel_DMLoad_Mask( input bit[31:0] Addr,input bit [2:0] Gran, input bit[3:0] KSize, input bit[63:0] Mask, input byte Data[4096][64] );
  
      bit[511:0]  DMValue512;
      bit[31:0]   DataIndexJ;
      bit[5:0]    DataIndexI;
      bit[6:0]    KG;
      bit[31:0]   Step;
      bit[5:0]    Bias;
      bit[5:0]    Count;
      bit         JFlag;

      KG = 1<<Gran;
      Step = 1<<KSize;

      JFlag=1'b0;


      Bias= ((Addr/(Step*64))%64)*KG;

      DataIndexJ = {{6{1'b0}},Addr[31:6]};
      DataIndexI = Addr[5:0]+Bias;

      for(int i=0; i<64; i++) begin
          Count=DataIndexJ/Step;
          Bias= Count*KG;
//          $display("Count=%0x,Bias=%0x,DataIndexI=%0x,DataIndexJ=%0x",Count,Bias,DataIndexI,DataIndexJ);
          DMValue512[8*i +:8] = Data[DataIndexJ][DataIndexI];
          DataIndexI = DataIndexI + 6'h1;
          if((i+1)%KG==0) begin
              if(JFlag) begin
                  DataIndexJ = DataIndexJ + Step-32'h1;
                  JFlag=1'b0;
              end else
                  DataIndexJ = DataIndexJ + Step;
          end 
          else if(DataIndexI==Bias) begin
              JFlag=1'b1;
              DataIndexJ = DataIndexJ + 32'h1;
          end
          DMValue512[8*i +:8] = DMValue512[8*i +:8]&{8{Mask[i]}};
      end
      
      return DMValue512;

  endfunction

  function bit[511:0] Refmodel_DMLoad_Less_Mask( input bit[31:0] Addr,input bit [2:0] Gran, input bit[3:0] KSize, input bit[63:0] Mask, input byte Data[2048][64] );
  
      bit[511:0]  DMValue512;
      bit[31:0]   DataIndexJ;
      bit[5:0]    DataIndexI;
      bit[6:0]    KG;
      bit[31:0]   Step;
      bit[5:0]    Bias;
      bit[5:0]    Count;
      bit         JFlag;

      KG = 1<<Gran;
      Step = 1<<KSize;

      JFlag=1'b0;


      Bias= ((Addr/(Step*64))%64)*KG;

      DataIndexJ = {{6{1'b0}},Addr[31:6]};
      DataIndexI = Addr[5:0]+Bias;

      for(int i=0; i<64; i++) begin
          Count=DataIndexJ/Step;
          Bias= Count*KG;
//          $display("Count=%0x,Bias=%0x,DataIndexI=%0x,DataIndexJ=%0x",Count,Bias,DataIndexI,DataIndexJ);
          DMValue512[8*i +:8] = Data[DataIndexJ][DataIndexI];
          DataIndexI = DataIndexI + 6'h1;
          if((i+1)%KG==0) begin
              if(JFlag) begin
                  DataIndexJ = DataIndexJ + Step-32'h1;
                  JFlag=1'b0;
              end else
                  DataIndexJ = DataIndexJ + Step;
          end 
          else if(DataIndexI==Bias) begin
              JFlag=1'b1;
              DataIndexJ = DataIndexJ + 32'h1;
          end
          DMValue512[8*i +:8] = DMValue512[8*i +:8]&{8{Mask[i]}};
      end
      
      return DMValue512;

  endfunction

  function bit[511:0] refmodel_discrete1_load(input bit[31:0] DataBase, input[511:0] MReg_Data, input byte Data[4096][64]);
       bit[511:0] DMValue;
       bit[31:0]  IndexBase,IndexOffset,IndexJ;

       IndexBase={6'h0,DataBase[31:6]};
//       $display("MReg_Data=%h",MReg_Data);
       for(int i=0; i<64; i++) begin
           IndexOffset={24'h0,MReg_Data[8*i+:8]};
           IndexJ=IndexBase|IndexOffset;
           DMValue[8*i+:8]= Data[IndexJ][i];
       end

       return DMValue;
    endfunction

    function bit[511:0] refmodel_discrete1_less_load(input bit[31:0] DataBase, input[511:0] MReg_Data, input byte Data[2048][64]);
       bit[511:0] DMValue;
       bit[31:0]  IndexBase,IndexOffset,IndexJ;

       IndexBase={6'h0,DataBase[31:6]};
//       $display("MReg_Data=%h",MReg_Data);
       for(int i=0; i<64; i=i+2) begin
           IndexOffset={24'h0,MReg_Data[8*i+:8]};
           IndexJ=IndexBase|IndexOffset;
           DMValue[8*i+:8]= Data[IndexJ][i];
           DMValue[8*i+8+:8]= Data[IndexJ][i+1];
       end

       return DMValue;
    endfunction

    function bit[511:0] refmodel_discrete_addr16(input bit[31:0] DataBase, input[511:0] MReg_Data, input bit[1:0] AddrGran, input bit[2:0] AddrIndex, input bit[2:0] Gran, input byte Data[4096][64]);
        bit[511:0] DMValue;
        bit[31:0]  IndexJ,DataBaseJ;
        bit[31:0]  DataBias,DataGranByte,AddrGranShort,AddrGranByte;
        bit[15:0]  Temp16[32];
        bit[31:0]  Temp32[16];
        bit[63:0]  Temp64[8];
        bit[127:0] Temp128[4];
        int p,q;
  
        DataBaseJ     = {20'h0,DataBase[17:6]};
        AddrGranShort = 1<<AddrGran;
        AddrGranByte  = AddrGranShort*2;
        DataGranByte  = 1<<Gran;

        DMValue=512'h0;

        if(AddrGranShort<AddrIndex) begin
            $display("AddrIndex exceeds the default size");
            DMValue = 512'h0;
        end else if(AddrGranByte<DataGranByte) begin
            $display("Data Size beyond the default size");
            DMValue = 512'h0;
        end else begin
//            $display("AddrGranShort=%x,AddrGranByte=%x,DataGranByte=%x",AddrGranShort,AddrGranByte,DataGranByte);            
            for(int i=0; i<64; i++) begin
                if(i%AddrGranByte==0) begin
                    DataBias = MReg_Data[(i/AddrGranByte)*AddrGranShort*16+AddrIndex*16+:16];
                    p=0;
                    if(i==0) q=0;
                    else     q=q+1;
                end
                IndexJ=DataBaseJ+DataBias/(AddrGranByte/DataGranByte);
                if((i%AddrGranByte)/DataGranByte==(DataBias%(AddrGranByte/DataGranByte))) begin
                    case(Gran) 
                       3'b000: begin
                          Temp16[q][15:0]={2{Data[IndexJ][i]}};
                       end
                       3'b001: begin
                          Temp16[q][8*p+:8]=Data[IndexJ][i];
//                          $display("Temp16[%0d]=%0x,p=%x,Data=%x",q,Temp16[q],p,Data[IndexJ][i]);
                          p=p+1;                       
                       end
                       3'b010: begin
                          Temp32[q][8*p+:8]=Data[IndexJ][i];
                          p=p+1;
                       end
                       3'b011: begin
                          Temp64[q][8*p+:8]=Data[IndexJ][i];
                          p=p+1;
                       end
                       3'b100: begin
                          Temp128[q][8*p+:8]=Data[IndexJ][i];
                          p=p+1;
                       end
                    endcase
//                    $display("Temp16[%0d]=%0x,p=%x,q=%x",i,Temp16[i],p,q);
                end 
//                $display("DataBaseJ=%x,DataBias=%x,IndexI=%x,IndexJ=%x",DataBaseJ,DataBias,i,IndexJ);
            end
            case(Gran)
                3'b000: begin
                   for(int i=0; i<q+1; i++) begin
                      DMValue[i*AddrGranShort*16+AddrIndex*16+:16]=Temp16[i];
//                      $display("Temp16[%0d]=%0x",i,Temp16[i]);
                   end
                end
                3'b001: begin
                   for(int i=0; i<q+1; i++) begin
                      DMValue[i*AddrGranShort*16+AddrIndex*16+:16]=Temp16[i];
//                      $display("Temp16[%0d]=%0x",i,Temp16[i]);
                   end
                end
                3'b010: begin
                   for(int i=0; i<q+1; i++) begin
                      DMValue[i*AddrGranShort*16+AddrIndex*16+:32]=Temp32[i];
                   end
                end
                3'b011: begin
                   for(int i=0; i<q+1; i++) begin
                      DMValue[i*AddrGranShort*16+AddrIndex*16+:64]=Temp64[i];
                   end
                end
                3'b100: begin
                   for(int i=0; i<q+1; i++) begin
                      DMValue[i*AddrGranShort*16+AddrIndex*16+:128]=Temp128[i];
                   end
                end  
            endcase          
        end

        return DMValue;

    endfunction

    function bit[511:0] refmodel_discrete2_load(input bit[31:0] DataBase, input[511:0] DataBaisL, input[511:0] DataBaisH, input byte Data[4096][64]);
       bit[511:0] DMValue;
       bit[31:0]  IndexBase,IndexOffsetL,IndexOffsetH,IndexJ;

       IndexBase={6'h0,DataBase[31:6]};
//       $display("MReg_Data=%h",MReg_Data);
       for(int i=0; i<64; i++) begin
           IndexOffsetL = {24'h0,DataBaisL[8*i+:8]};
           IndexOffsetH = {20'h0,DataBaisH[8*i+:4],8'h0};
           IndexJ       = IndexBase|IndexOffsetL|IndexOffsetH;

           DMValue[8*i+:8]= Data[IndexJ][i];
       end

       return DMValue;
    endfunction

    function bit[511:0] refmodel_discrete2_less_load(input bit[31:0] DataBase, input[511:0] DataBaisL, input[511:0] DataBaisH, input byte Data[2048][64]);
       bit[511:0] DMValue;
       bit[31:0]  IndexBase,IndexOffsetL,IndexOffsetH,IndexJ;

       IndexBase={6'h0,DataBase[31:6]};
//       $display("MReg_Data=%h",MReg_Data);
       for(int i=0; i<64; i=i+2) begin
           IndexOffsetL = {24'h0,DataBaisL[8*i+:8]};
           IndexOffsetH = {21'h0,DataBaisH[8*i+:3],8'h0};
           IndexJ       = IndexBase|IndexOffsetL|IndexOffsetH;

           DMValue[8*i+:8]= Data[IndexJ][i];
           DMValue[8*i+8+:8]= Data[IndexJ][i+1];
       end

       return DMValue;
    endfunction

task automatic WaitSPUCycles(int C);
   int i=0;
   while(i<C) begin
      `ifdef PLATFORM_FPGA
          @(negedge $root.TestTop.FPGA_Top_inst.uAPE.uSPU.CClk);
          if($root.TestTop.FPGA_Top_inst.uAPE.uSPU.uSPUPipeCtrl.oExeStall == 0) 
            i=i+1;
      `else
          @(negedge $root.TestTop.uAPE.uSPU.CClk);
          if($root.TestTop.uAPE.uSPU.uSPUPipeCtrl.oExeStall == 0) 
            i=i+1;
      `endif
   end
endtask

task automatic WaitSPUCycles_NStall(int C);begin
   int i=0;
   while(i<C) begin
      `ifdef PLATFORM_FPGA
          @(negedge $root.TestTop.FPGA_Top_inst.uAPE.uSPU.CClk);
            i=i+1;
      `else
          @(negedge $root.TestTop.uAPE.uSPU.CClk);
            i=i+1;
      `endif
   end
end
endtask

task automatic WaitSPUSYNStalledCycles(int C);
  int i=0;
  while(i<C) begin
      `ifdef PLATFORM_FPGA
	@(negedge TestTop.FPGA_Top_inst.uAPE.uSPU.CClk);
	if( TestTop.FPGA_Top_inst.uAPE.uSPU.uSYN.nEx0Stall == 0) i=i+1;
        //  $display("@time=%0t; i=%h; StallEn=%b", $realtime,i,TestTop.FPGA_Top_inst.uAPE.uSPU.uSYN.nEx0Stall); 
      `else
	@(negedge TestTop.uAPE.uSPU.CClk); begin
	if( TestTop.uAPE.uSPU.uSYN.nEx0Stall == 0)  begin i=i+1;
         // $display("@time=%0t; i=%h; StallEn=%b", $realtime,i,TestTop.uAPE.uSPU.uSYN.nEx0Stall); 
          end
        end
      `endif
       
  end
endtask

task automatic WaitSPUWrFIFOEnCycles();
  while(1) begin
   `ifdef PLATFORM_FPGA
	@(negedge TestTop.FPGA_Top_inst.uAPE.uSPU.CClk);
        if(TestTop.FPGA_Top_inst.uAPE.uSPU.uSYN.nEx0Stall == 1'b0) break;
    `else
	@(negedge TestTop.uAPE.uSPU.CClk); 
        if(TestTop.uAPE.uSPU.uSYN.nEx0Stall == 1'b0) break;
   `endif
        //`TD;
  end
endtask

task automatic WaitSPUSYNDPStalledCycles();
  int i=0;
  while(1) begin
      `ifdef PLATFORM_FPGA
	@(negedge TestTop.FPGA_Top_inst.uAPE.uSPU.CClk);
	if(TestTop.FPGA_Top_inst.uAPE.uSPU.uSYN.iDPStall == 0) 
          break;
        //  $display("@time=%0t; i=%h; StallEn=%b", $realtime,i,TestTop.FPGA_Top_inst.uAPE.uSPU.uSYN.nEx0Stall); 
        
      `else
	@(negedge TestTop.uAPE.uSPU.CClk); 
	if(TestTop.uAPE.uSPU.uSYN.iDPStall == 0)  
          break;
         // $display("@time=%0t; i=%h; StallEn=%b", $realtime,i,TestTop.uAPE.uSPU.uSYN.nEx0Stall); 
         
       
      `endif
       
  end
endtask

// Reg of MFetch
task automatic WaitMPUCyclesMFetch(int C);
   int i = 0;
   bit MicroValid;
   while(i<C)begin
      `ifdef PLATFORM_FPGA
         @(negedge TestTop.FPGA_Top_inst.uAPE.uMPU.CClk);
         MicroValid = $root.TestTop.FPGA_Top_inst.uAPE.uMPU.uMFetch.nCurrentMicroValid; 
      `else
         @(negedge TestTop.uAPE.uMPU.CClk);
         MicroValid = $root.TestTop.uAPE.uMPU.uMFetch.nCurrentMicroValid;
      `endif
      if(MicroValid) begin
         i = i + 1; 
      end           
   end
endtask

// Reg exclude of MFetch
task automatic WaitMPUCycles(int C);
   int i = 0;
   bit MicroValid;
   while(i<C)begin
      `ifdef PLATFORM_FPGA
         @(negedge TestTop.FPGA_Top_inst.uAPE.uMPU.CClk);
         MicroValid = $root.TestTop.FPGA_Top_inst.uAPE.uMPU.gen_dpath[3].uDPath.gen_IMA[3].uIMA.rEUStallEn[0]; 
      `else
         @(negedge TestTop.uAPE.uMPU.CClk);
         MicroValid = $root.TestTop.uAPE.uMPU.gen_dpath[3].uDPath.gen_IMA[3].uIMA.rEUStallEn[0];
      `endif
      if(!MicroValid) begin
         i = i + 1; 
      end           
   end
endtask

//Task to Wait SoC Cycles.
task automatic WaitSoCCycles(int C);
  repeat (C)  @(posedge TestTop.iSoCClk);
endtask

//////////////////////////////////////////////////////////////
`define MR_WIDTH     1664
//--Class Monitor
class  Monitor;
  extern task automatic R_Read(input bit[4:0] Index, output logic[31:0]  Data) ;
  extern task automatic ADDR_Read(output logic[31:0]  Data) ;

  extern task SVR_Read(input bit[1:0] Index, output logic[511:0] Data);

  extern task M_Read (input bit[5:0] Index, output logic[511:0] Data);
  extern task SHU_Read(input bit[1:0] Index, input bit[2:0] TRegID, output  logic[511:0] Data); 
  extern task BIU_Read(input bit[1:0] Index, input bit[1:0] TRegID, output  logic[511:0] Data); 
  extern task IMA_Read(input bit[1:0] Index, input bit[2:0] TRegID, output  logic[511:0] Data); 
  extern task KI_Read(output  logic[511:0] Data); 
  extern task M_Write(input bit[5:0] Index, input bit[511:0] Data); 
  extern task SHU_Write(input bit[1:0] Index, input bit[2:0] TRegID, input bit[511:0] Data); 
  extern task BIU_Write(input bit[1:0] Index, input bit[1:0] TRegID, input bit[511:0] Data); 
  extern task IMA_Write(input bit[1:0] Index, input bit[2:0] TRegID, input bit[511:0] Data); 
  extern task KI_Write(input bit[511:0] Data); 
  extern task MC_Write(input bit Rd, input bit[511:0] Data); 
  extern task MC_Read1(input bit Rd, output bit[511:0] Data); 
  extern task MRegLatch_Write(input bit[1:0] Sel, input bit[511:0] Data);

  extern task DMReadBytes(int Addr, ref byte Data[]) ; 
  extern task DMWriteBytes(int Addr, const ref byte Data[]) ; 

  extern task MACFlag_Read(input bit[1:0] GroupID, input bit[1:0] FlagType, output logic[63:0] Flag);
  extern task ALUFlag_Read(input bit[1:0] GroupID, input bit[1:0] FlagType, output logic[63:0] Flag);
  extern task T_Read(input bit[3:0] GroupID, input bit[2:0] TRegID, output logic[511:0] Data);

  extern task MFetchKI_Read(input bit[3:0] Mode, output logic[511:0] Data);  
  extern task MR_Read(input bit[1:0] Sel, output logic[`MR_WIDTH-1:0] Data);
//  extern task TBReg_Read(input bit[1:0] Sel, output logic[511:0] Data);
  extern task T7Reg_Read(input bit[1:0] Sel, output logic[511:0] Data);

  extern task MRegLatch_Read(input bit[1:0] Sel, output logic[511:0] Data);
  extern task ErasedBit_Read(input bit[1:0] Sel, output logic[63:0] Data);
  extern task MC_Read(input bit[3:0] PortID, output logic[47:0] Data);

  extern task display_256(input bit[255:0]  Data);
  extern task display_512(input logic[511:0]  Data);
  extern task display_MR(input logic[`MR_WIDTH-1:0]  Data);
endclass

//////////////////////////////////////////////////////////////
//Function read/write the Regsiter
`ifdef PLATFORM_FPGA
`define SPU_PATH  $root.TestTop.FPGA_Top_inst.uAPE.uSPU
`define MPU_PATH  $root.TestTop.FPGA_Top_inst.uAPE.uMPU
`else
`define SPU_PATH  $root.TestTop.uAPE.uSPU
`define MPU_PATH  $root.TestTop.uAPE.uMPU
`endif
task automatic Monitor::R_Read(input bit[4:0] Index, output logic[31:0] Data);begin
  `TD;
  Data = `SPU_PATH.uDecode.uRRegFile.rRReg[Index];
end
endtask

task automatic Monitor::ADDR_Read(output logic[31:0] Data);begin
  `TD;
  Data = `SPU_PATH.uSEQ.rIntAddr;
end
endtask

task automatic Monitor::SVR_Read(input bit[1:0] Index, output logic[511:0] Data);begin
  `TD;
  Data = `SPU_PATH.uDecode.rSVRReg[Index];
end
endtask


task Monitor::M_Read(input bit[5:0] Index, output logic[511:0] Data);
//`ifdef PLATFORM_FPGA
//`else
  Data = {`MPU_PATH.gen_dpath[3].uDPath.uMRegUnit.uM.Reg_Data[Index],
          `MPU_PATH.gen_dpath[2].uDPath.uMRegUnit.uM.Reg_Data[Index],
          `MPU_PATH.gen_dpath[1].uDPath.uMRegUnit.uM.Reg_Data[Index],
          `MPU_PATH.gen_dpath[0].uDPath.uMRegUnit.uM.Reg_Data[Index]};
//`endif
endtask

task Monitor::SHU_Read(input bit[1:0] Index, input bit[2:0] TRegID, output  logic[511:0] Data); 
   case(Index)
      2'b00: Data = `MPU_PATH.gen_shu[0].uSHU.uTReg_w8_r3_v8.rTReg[TRegID];
      2'b01: Data = `MPU_PATH.gen_shu[1].uSHU.uTReg_w8_r3_v8.rTReg[TRegID];
      2'b10: Data = `MPU_PATH.gen_shu[2].uSHU.uTReg_w8_r3_v8.rTReg[TRegID];
      2'b11: Data = `MPU_PATH.gen_shu[3].uSHU.uTReg_w8_r3_v8.rTReg[TRegID];
   endcase
endtask

task Monitor::BIU_Read(input bit[1:0] Index, input bit[1:0] TRegID, output logic[511:0] Data); 
   case(Index)
      2'b00: Data = `MPU_PATH.gen_biu[0].uBIU.TReg[TRegID];
      2'b01: Data = `MPU_PATH.gen_biu[1].uBIU.TReg[TRegID];
      2'b10: Data = `MPU_PATH.gen_biu[2].uBIU.TReg[TRegID];
      2'b11: Data = `MPU_PATH.gen_biu[3].uBIU.TReg[TRegID];
   endcase
endtask

task Monitor::IMA_Read(input bit[1:0] Index, input bit[2:0] TRegID, output logic[511:0] Data); 
   case(Index)
      2'b00:
         if(TRegID==3'h6) begin
            Data[511:480] = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.genblk2[3].uIMACBasicEX0.rResult;
            Data[479:448] = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.genblk2[2].uIMACBasicEX0.rResult;
            Data[447:416] = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.genblk2[1].uIMACBasicEX0.rResult;
            Data[415:384] = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.genblk2[0].uIMACBasicEX0.rResult;
            Data[383:352] = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.genblk2[3].uIMACBasicEX0.rResult;
            Data[351:320] = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.genblk2[2].uIMACBasicEX0.rResult;
            Data[319:288] = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.genblk2[1].uIMACBasicEX0.rResult;
            Data[287:256] = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.genblk2[0].uIMACBasicEX0.rResult;
            Data[255:224] = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.genblk2[3].uIMACBasicEX0.rResult;
            Data[223:192] = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.genblk2[2].uIMACBasicEX0.rResult;
            Data[191:160] = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.genblk2[1].uIMACBasicEX0.rResult;
            Data[159:128] = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.genblk2[0].uIMACBasicEX0.rResult;
            Data[127:96]  = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.genblk2[3].uIMACBasicEX0.rResult;
            Data[95:64]   = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.genblk2[2].uIMACBasicEX0.rResult;
            Data[63:32]   = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.genblk2[1].uIMACBasicEX0.rResult;
            Data[31:0]    = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.genblk2[0].uIMACBasicEX0.rResult;
         end
         else begin
            Data[511:384] = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.TReg.rTReg[TRegID];
            Data[383:256] = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.TReg.rTReg[TRegID];
            Data[255:128] = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.TReg.rTReg[TRegID];
            Data[127:0]   = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.TReg.rTReg[TRegID]; 
         end
      2'b01:
         if(TRegID==3'h6) begin
            Data[511:480] = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.genblk2[3].uIMACBasicEX0.rResult;
            Data[479:448] = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.genblk2[2].uIMACBasicEX0.rResult;
            Data[447:416] = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.genblk2[1].uIMACBasicEX0.rResult;
            Data[415:384] = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.genblk2[0].uIMACBasicEX0.rResult;
            Data[383:352] = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.genblk2[3].uIMACBasicEX0.rResult;
            Data[351:320] = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.genblk2[2].uIMACBasicEX0.rResult;
            Data[319:288] = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.genblk2[1].uIMACBasicEX0.rResult;
            Data[287:256] = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.genblk2[0].uIMACBasicEX0.rResult;
            Data[255:224] = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.genblk2[3].uIMACBasicEX0.rResult;
            Data[223:192] = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.genblk2[2].uIMACBasicEX0.rResult;
            Data[191:160] = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.genblk2[1].uIMACBasicEX0.rResult;
            Data[159:128] = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.genblk2[0].uIMACBasicEX0.rResult;
            Data[127:96]  = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.genblk2[3].uIMACBasicEX0.rResult;
            Data[95:64]   = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.genblk2[2].uIMACBasicEX0.rResult;
            Data[63:32]   = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.genblk2[1].uIMACBasicEX0.rResult;
            Data[31:0]    = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.genblk2[0].uIMACBasicEX0.rResult;
         end
         else begin
            Data[511:384] = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.TReg.rTReg[TRegID];
            Data[383:256] = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.TReg.rTReg[TRegID];
            Data[255:128] = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.TReg.rTReg[TRegID];
            Data[127:0]   = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.TReg.rTReg[TRegID];
         end
      2'b10:
         if(TRegID==3'h6) begin
            Data[511:480] = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.genblk2[3].uIMACBasicEX0.rResult;
            Data[479:448] = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.genblk2[2].uIMACBasicEX0.rResult;
            Data[447:416] = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.genblk2[1].uIMACBasicEX0.rResult;
            Data[415:384] = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.genblk2[0].uIMACBasicEX0.rResult;
            Data[383:352] = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.genblk2[3].uIMACBasicEX0.rResult;
            Data[351:320] = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.genblk2[2].uIMACBasicEX0.rResult;
            Data[319:288] = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.genblk2[1].uIMACBasicEX0.rResult;
            Data[287:256] = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.genblk2[0].uIMACBasicEX0.rResult;
            Data[255:224] = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.genblk2[3].uIMACBasicEX0.rResult;
            Data[223:192] = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.genblk2[2].uIMACBasicEX0.rResult;
            Data[191:160] = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.genblk2[1].uIMACBasicEX0.rResult;
            Data[159:128] = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.genblk2[0].uIMACBasicEX0.rResult;
            Data[127:96]  = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.genblk2[3].uIMACBasicEX0.rResult;
            Data[95:64]   = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.genblk2[2].uIMACBasicEX0.rResult;
            Data[63:32]   = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.genblk2[1].uIMACBasicEX0.rResult;
            Data[31:0]    = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.genblk2[0].uIMACBasicEX0.rResult;
         end
         else begin
            Data[511:384] = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.TReg.rTReg[TRegID];
            Data[383:256] = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.TReg.rTReg[TRegID];
            Data[255:128] = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.TReg.rTReg[TRegID];
            Data[127:0]   = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.TReg.rTReg[TRegID];
         end
      2'b11:
         if(TRegID==3'h6) begin
            Data[511:480] = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.genblk2[3].uIMACBasicEX0.rResult;
            Data[479:448] = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.genblk2[2].uIMACBasicEX0.rResult;
            Data[447:416] = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.genblk2[1].uIMACBasicEX0.rResult;
            Data[415:384] = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.genblk2[0].uIMACBasicEX0.rResult;
            Data[383:352] = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.genblk2[3].uIMACBasicEX0.rResult;
            Data[351:320] = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.genblk2[2].uIMACBasicEX0.rResult;
            Data[319:288] = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.genblk2[1].uIMACBasicEX0.rResult;
            Data[287:256] = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.genblk2[0].uIMACBasicEX0.rResult;
            Data[255:224] = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.genblk2[3].uIMACBasicEX0.rResult;
            Data[223:192] = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.genblk2[2].uIMACBasicEX0.rResult;
            Data[191:160] = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.genblk2[1].uIMACBasicEX0.rResult;
            Data[159:128] = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.genblk2[0].uIMACBasicEX0.rResult;
            Data[127:96]  = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.genblk2[3].uIMACBasicEX0.rResult;
            Data[95:64]   = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.genblk2[2].uIMACBasicEX0.rResult;
            Data[63:32]   = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.genblk2[1].uIMACBasicEX0.rResult;
            Data[31:0]    = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.genblk2[0].uIMACBasicEX0.rResult;
         end
         else begin
            Data[511:384] = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.TReg.rTReg[TRegID];
            Data[383:256] = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.TReg.rTReg[TRegID];
            Data[255:128] = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.TReg.rTReg[TRegID];
            Data[127:0]   = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.TReg.rTReg[TRegID];
         end
  endcase
endtask

task Monitor::KI_Read(output logic[511:0] Data);
    Data = {8'h00,{`MPU_PATH.uMFetch.KI[15]},8'h00,{`MPU_PATH.uMFetch.KI[14]},
            8'h00,{`MPU_PATH.uMFetch.KI[13]},8'h00,{`MPU_PATH.uMFetch.KI[12]},
            8'h00,{`MPU_PATH.uMFetch.KI[11]},8'h00,{`MPU_PATH.uMFetch.KI[10]},
            8'h00,{`MPU_PATH.uMFetch.KI[9]},8'h00,{`MPU_PATH.uMFetch.KI[8]},
            8'h00,{`MPU_PATH.uMFetch.KI[7]},8'h00,{`MPU_PATH.uMFetch.KI[6]},
            8'h00,{`MPU_PATH.uMFetch.KI[5]},8'h00,{`MPU_PATH.uMFetch.KI[4]},
            8'h00,{`MPU_PATH.uMFetch.KI[3]},8'h00,{`MPU_PATH.uMFetch.KI[2]},
            8'h00,{`MPU_PATH.uMFetch.KI[1]},8'h00,{`MPU_PATH.uMFetch.KI[0]}};
endtask

task Monitor::M_Write(input bit[5:0] Index, input bit[511:0] Data);
//`ifdef PLATFORM_FPGA
//
//`else
  `MPU_PATH.gen_dpath[3].uDPath.uMRegUnit.uM.Reg_Data[Index] = Data[511:384];
  `MPU_PATH.gen_dpath[2].uDPath.uMRegUnit.uM.Reg_Data[Index] = Data[383:256];
  `MPU_PATH.gen_dpath[1].uDPath.uMRegUnit.uM.Reg_Data[Index] = Data[255:128];
  `MPU_PATH.gen_dpath[0].uDPath.uMRegUnit.uM.Reg_Data[Index] = Data[127:0];
//`endif
endtask

task Monitor::SHU_Write(input bit[1:0] Index, input bit[2:0] TRegID, input bit[511:0] Data); 
   case(Index)
      2'b00: `MPU_PATH.gen_shu[0].uSHU.uTReg_w8_r3_v8.rTReg[TRegID] = Data;
      2'b01: `MPU_PATH.gen_shu[1].uSHU.uTReg_w8_r3_v8.rTReg[TRegID] = Data;
      2'b10: `MPU_PATH.gen_shu[2].uSHU.uTReg_w8_r3_v8.rTReg[TRegID] = Data;
      2'b11: `MPU_PATH.gen_shu[3].uSHU.uTReg_w8_r3_v8.rTReg[TRegID] = Data;
   endcase
endtask

task Monitor::BIU_Write(input bit[1:0] Index, input bit[1:0] TRegID, input bit[511:0] Data); 
   case(Index)
      2'b00: `MPU_PATH.gen_biu[0].uBIU.TReg[TRegID] = Data;
      2'b01: `MPU_PATH.gen_biu[1].uBIU.TReg[TRegID] = Data;
      2'b10: `MPU_PATH.gen_biu[2].uBIU.TReg[TRegID] = Data;
      2'b11: `MPU_PATH.gen_biu[3].uBIU.TReg[TRegID] = Data;
   endcase
endtask

task Monitor::IMA_Write(input bit[1:0] Index, input bit[2:0] TRegID, input bit[511:0] Data); 
   case(Index)
      2'b00:
         if(TRegID==3'h6) begin
            `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.genblk2[3].uIMACBasicEX0.rResult = Data[511:480];
            `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.genblk2[2].uIMACBasicEX0.rResult = Data[479:448];
            `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.genblk2[1].uIMACBasicEX0.rResult = Data[447:416];
            `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.genblk2[0].uIMACBasicEX0.rResult = Data[415:384];
            `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.genblk2[3].uIMACBasicEX0.rResult = Data[383:352];
            `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.genblk2[2].uIMACBasicEX0.rResult = Data[351:320];
            `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.genblk2[1].uIMACBasicEX0.rResult = Data[319:288];
            `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.genblk2[0].uIMACBasicEX0.rResult = Data[287:256];
            `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.genblk2[3].uIMACBasicEX0.rResult = Data[255:224];
            `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.genblk2[2].uIMACBasicEX0.rResult = Data[223:192];
            `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.genblk2[1].uIMACBasicEX0.rResult = Data[191:160];
            `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.genblk2[0].uIMACBasicEX0.rResult = Data[159:128];
            `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.genblk2[3].uIMACBasicEX0.rResult = Data[127:96]; 
            `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.genblk2[2].uIMACBasicEX0.rResult = Data[95:64]; 
            `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.genblk2[1].uIMACBasicEX0.rResult = Data[63:32]; 
            `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.genblk2[0].uIMACBasicEX0.rResult = Data[31:0]; 
         end
         else begin
            `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.TReg.rTReg[TRegID] = Data[511:384];
            `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.TReg.rTReg[TRegID] = Data[383:256];
            `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.TReg.rTReg[TRegID] = Data[255:128];
            `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.TReg.rTReg[TRegID] = Data[127:0]; 
         end
      2'b01:
         if(TRegID==3'h6) begin
            `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.genblk2[3].uIMACBasicEX0.rResult = Data[511:480];
            `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.genblk2[2].uIMACBasicEX0.rResult = Data[479:448];
            `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.genblk2[1].uIMACBasicEX0.rResult = Data[447:416];
            `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.genblk2[0].uIMACBasicEX0.rResult = Data[415:384];
            `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.genblk2[3].uIMACBasicEX0.rResult = Data[383:352];
            `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.genblk2[2].uIMACBasicEX0.rResult = Data[351:320];
            `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.genblk2[1].uIMACBasicEX0.rResult = Data[319:288];
            `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.genblk2[0].uIMACBasicEX0.rResult = Data[287:256];
            `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.genblk2[3].uIMACBasicEX0.rResult = Data[255:224];
            `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.genblk2[2].uIMACBasicEX0.rResult = Data[223:192];
            `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.genblk2[1].uIMACBasicEX0.rResult = Data[191:160];
            `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.genblk2[0].uIMACBasicEX0.rResult = Data[159:128];
            `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.genblk2[3].uIMACBasicEX0.rResult = Data[127:96]; 
            `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.genblk2[2].uIMACBasicEX0.rResult = Data[95:64]; 
            `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.genblk2[1].uIMACBasicEX0.rResult = Data[63:32]; 
            `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.genblk2[0].uIMACBasicEX0.rResult = Data[31:0]; 
         end
         else begin
            `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.TReg.rTReg[TRegID] = Data[511:384];
            `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.TReg.rTReg[TRegID] = Data[383:256];
            `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.TReg.rTReg[TRegID] = Data[255:128];
            `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.TReg.rTReg[TRegID] = Data[127:0]; 
         end
      2'b10:
         if(TRegID==3'h6) begin
            `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.genblk2[3].uIMACBasicEX0.rResult = Data[511:480];
            `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.genblk2[2].uIMACBasicEX0.rResult = Data[479:448];
            `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.genblk2[1].uIMACBasicEX0.rResult = Data[447:416];
            `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.genblk2[0].uIMACBasicEX0.rResult = Data[415:384];
            `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.genblk2[3].uIMACBasicEX0.rResult = Data[383:352];
            `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.genblk2[2].uIMACBasicEX0.rResult = Data[351:320];
            `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.genblk2[1].uIMACBasicEX0.rResult = Data[319:288];
            `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.genblk2[0].uIMACBasicEX0.rResult = Data[287:256];
            `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.genblk2[3].uIMACBasicEX0.rResult = Data[255:224];
            `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.genblk2[2].uIMACBasicEX0.rResult = Data[223:192];
            `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.genblk2[1].uIMACBasicEX0.rResult = Data[191:160];
            `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.genblk2[0].uIMACBasicEX0.rResult = Data[159:128];
            `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.genblk2[3].uIMACBasicEX0.rResult = Data[127:96]; 
            `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.genblk2[2].uIMACBasicEX0.rResult = Data[95:64]; 
            `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.genblk2[1].uIMACBasicEX0.rResult = Data[63:32]; 
            `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.genblk2[0].uIMACBasicEX0.rResult = Data[31:0]; 
         end
         else begin
            `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.TReg.rTReg[TRegID] = Data[511:384];
            `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.TReg.rTReg[TRegID] = Data[383:256];
            `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.TReg.rTReg[TRegID] = Data[255:128];
            `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.TReg.rTReg[TRegID] = Data[127:0]; 
         end
      2'b11:
         if(TRegID==3'h6) begin
            `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.genblk2[3].uIMACBasicEX0.rResult = Data[511:480];
            `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.genblk2[2].uIMACBasicEX0.rResult = Data[479:448];
            `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.genblk2[1].uIMACBasicEX0.rResult = Data[447:416];
            `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.genblk2[0].uIMACBasicEX0.rResult = Data[415:384];
            `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.genblk2[3].uIMACBasicEX0.rResult = Data[383:352];
            `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.genblk2[2].uIMACBasicEX0.rResult = Data[351:320];
            `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.genblk2[1].uIMACBasicEX0.rResult = Data[319:288];
            `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.genblk2[0].uIMACBasicEX0.rResult = Data[287:256];
            `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.genblk2[3].uIMACBasicEX0.rResult = Data[255:224];
            `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.genblk2[2].uIMACBasicEX0.rResult = Data[223:192];
            `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.genblk2[1].uIMACBasicEX0.rResult = Data[191:160];
            `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.genblk2[0].uIMACBasicEX0.rResult = Data[159:128];
            `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.genblk2[3].uIMACBasicEX0.rResult = Data[127:96]; 
            `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.genblk2[2].uIMACBasicEX0.rResult = Data[95:64]; 
            `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.genblk2[1].uIMACBasicEX0.rResult = Data[63:32]; 
            `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.genblk2[0].uIMACBasicEX0.rResult = Data[31:0]; 
         end
         else begin
            `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.TReg.rTReg[TRegID] = Data[511:384];
            `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.TReg.rTReg[TRegID] = Data[383:256];
            `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.TReg.rTReg[TRegID] = Data[255:128];
            `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.TReg.rTReg[TRegID] = Data[127:0]; 
         end
  endcase
endtask

task Monitor::KI_Write(input bit[511:0] Data);
   bit[7:0] temp[16];
   {temp[15],`MPU_PATH.uMFetch.KI[15], temp[14],`MPU_PATH.uMFetch.KI[14], temp[13],`MPU_PATH.uMFetch.KI[13], temp[12],`MPU_PATH.uMFetch.KI[12], temp[11],`MPU_PATH.uMFetch.KI[11], temp[10],`MPU_PATH.uMFetch.KI[10], temp[9],`MPU_PATH.uMFetch.KI[9], temp[8],`MPU_PATH.uMFetch.KI[8], temp[7],`MPU_PATH.uMFetch.KI[7], temp[6],`MPU_PATH.uMFetch.KI[6], temp[5],`MPU_PATH.uMFetch.KI[5], temp[4],`MPU_PATH.uMFetch.KI[4], temp[3],`MPU_PATH.uMFetch.KI[3], temp[2],`MPU_PATH.uMFetch.KI[2], temp[1],`MPU_PATH.uMFetch.KI[1], temp[0],`MPU_PATH.uMFetch.KI[0]} = Data;
endtask

  // Rd: read port
  task Monitor::MC_Write(input bit Rd, input bit[511:0] Data);
      if(Rd)
         for(int i=0; i<4; i++) begin
            for(int j=0; j<8; j++) begin
	            `MPU_PATH.uMRegCtrl.rMC[i][j][5:0] = Data[(i*8+j)*8+:8];
            end
        end
      else
         for(int i=0; i<5; i++) begin
            for(int j=0; j<8; j++) begin
	            `MPU_PATH.uMRegCtrl.rMC[i+4][j][5:0] = Data[(i*8+j)*8+:8];
            end
        end
  endtask

  // Rd: read port
  task Monitor::MC_Read1(input bit Rd, output bit[511:0] Data);
      Data = 0;
      if(Rd)
         for(int i=0; i<4; i++) begin
            for(int j=0; j<8; j++) begin
	            Data[(i*8+j)*8+:8] = `MPU_PATH.uMRegCtrl.rMC[i][j][5:0];
            end
        end
      else
         for(int i=0; i<5; i++) begin
            for(int j=0; j<8; j++) begin
	            Data[(i*8+j)*8+:8] = `MPU_PATH.uMRegCtrl.rMC[i+4][j][5:0];
            end
        end
  endtask

  // Sel: 00-read latch0, 01-read latch1, 10-write latch
  task Monitor::MRegLatch_Write(input bit[1:0] Sel, input bit[511:0] Data);
  `TD;
	case(Sel)
      2'b00:  `MPU_PATH.uMRegCtrl.rRPAddrLatch[0] = Data;
      2'b01:  `MPU_PATH.uMRegCtrl.rRPAddrLatch[1] = Data;
      2'b10:  `MPU_PATH.uMRegCtrl.rWPAddrLatch = Data;
		default: $display("Error Sel of MRegLatch_Write input!!!");
	endcase
  endtask

// read the Memory , the address is the byte index of the memory in 64 Granularity
task Monitor::DMReadBytes(int Addr, ref byte Data[]) ; 
  $display("Please Using the read function of DM directorly , as follows ");
 `ifdef PLATFORM_FPGA
  $display("  byte Data[] = new[64];              \n\
              $root.TestTop.FPGA_Top_inst.uAPE.uDM0.DMReadBytes(0,Gran,Size,Data);      \n\
          ");
 `else
  $display("  byte Data[] = new[64];              \n\
              $root.TestTop.uAPE.uDM0.DMReadBytes(0,Gran,Size,Data);      \n\
          ");
 `endif
  $stop;
endtask 

// write the Memory , the address is the byte index of the memory in 64 Granularity
task Monitor::DMWriteBytes(int Addr, const ref byte Data[]) ; 
  $display("Please Using the write function of DM directly , as follows ");
  `ifdef PLATFORM_FPGA
  $display("  byte Data[]                  \n\
              Data = new[64];              \n\
              for (int i=0; i< 64; i++) Data[i] = i; \n\
              $root.TestTop.FPGA_Top_inst.uAPE.uDM0.DMWriteBytes(0,Gran,Size,Data);      \n\
          ");
  `else 
  $display("  byte Data[]                  \n\
              Data = new[64];              \n\
              for (int i=0; i< 64; i++) Data[i] = i; \n\
              $root.TestTop.uAPE.uDM0.DMWriteBytes(0,Gran,Size,Data);      \n\
          ");
  `endif
  $stop;
endtask 


//GroupID:00-IMA0,01-IMA1,10-IMA2,11-IMA3 
task Monitor::MACFlag_Read(input bit[1:0] GroupID, input bit[1:0] FlagType, output logic[63:0] Flag);
  case(GroupID)
    2'b00:
      case(FlagType)
         //UFlag
         2'b01:
            Flag = {{`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.rFlag[47:32]},{`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.rFlag[47:32]},{`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.rFlag[47:32]},{`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.rFlag[47:32]}};
         //CFlag
         2'b10:
            Flag = {{`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.rFlag[31:16]},{`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.rFlag[31:16]},{`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.rFlag[31:16]},{`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.rFlag[31:16]}};
         //VFlag
         2'b11:
            Flag = {{`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.rFlag[15:0]},{`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.rFlag[15:0]},{`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.rFlag[15:0]},{`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.rFlag[15:0]}};
         default: $display("Error from MACFlag_Read: Wrong FlagType!!!");
      endcase
    2'b01:
      case(FlagType)
         //UFlag
         2'b01:
            Flag = {{`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.rFlag[47:32]},{`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.rFlag[47:32]},{`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.rFlag[47:32]},{`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.rFlag[47:32]}};
         //CFlag
         2'b10:
            Flag = {{`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.rFlag[31:16]},{`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.rFlag[31:16]},{`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.rFlag[31:16]},{`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.rFlag[31:16]}};
         //VFlag
         2'b11:
            Flag = {{`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.rFlag[15:0]},{`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.rFlag[15:0]},{`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.rFlag[15:0]},{`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.rFlag[15:0]}};
         default: $display("Error from MACFlag_Read: Wrong FlagType!!!");
      endcase
    2'b10:
      case(FlagType)
         //UFlag
         2'b01:
            Flag = {{`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.rFlag[47:32]},{`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.rFlag[47:32]},{`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.rFlag[47:32]},{`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.rFlag[47:32]}};
         //CFlag
         2'b10:
            Flag = {{`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.rFlag[31:16]},{`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.rFlag[31:16]},{`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.rFlag[31:16]},{`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.rFlag[31:16]}};
         //VFlag
         2'b11:
            Flag = {{`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.rFlag[15:0]},{`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.rFlag[15:0]},{`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.rFlag[15:0]},{`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.rFlag[15:0]}};
         default: $display("Error from MACFlag_Read: Wrong FlagType!!!");
      endcase
    2'b11:
      case(FlagType)
         //UFlag
         2'b01:
            Flag = {{`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.rFlag[47:32]},{`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.rFlag[47:32]},{`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.rFlag[47:32]},{`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.rFlag[47:32]}};
         //CFlag
         2'b10:
            Flag = {{`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.rFlag[31:16]},{`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.rFlag[31:16]},{`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.rFlag[31:16]},{`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.rFlag[31:16]}};
         //VFlag
         2'b11:
            Flag = {{`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.rFlag[15:0]},{`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.rFlag[15:0]},{`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.rFlag[15:0]},{`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.rFlag[15:0]}};
         default: $display("Error from MACFlag_Read: Wrong FlagType!!!");
      endcase
  endcase
endtask


//GroupID:00-IMA0,01-IMA1,10-IMA2,11-IMA3 
task Monitor::ALUFlag_Read(input bit[1:0] GroupID, input bit[1:0] FlagType, output logic[63:0] Flag);
  case(GroupID)
    2'b00:
      case(FlagType)
         //CFlag
         2'b10:
            Flag = {{`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.genblk2[3].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.genblk2[2].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.genblk2[1].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.genblk2[0].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.genblk2[3].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.genblk2[2].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.genblk2[1].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.genblk2[0].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.genblk2[3].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.genblk2[2].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.genblk2[1].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.genblk2[0].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.genblk2[3].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.genblk2[2].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.genblk2[1].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.genblk2[0].uIMACBasicEX0.oCIFlag[3:0]}};
         default: $display("Error from ALUFlag_Read: Wrong FlagType!!!");
      endcase
    2'b01:
      case(FlagType)
         //CFlag
         2'b10:
            Flag = {{`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.genblk2[3].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.genblk2[2].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.genblk2[1].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.genblk2[0].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.genblk2[3].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.genblk2[2].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.genblk2[1].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.genblk2[0].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.genblk2[3].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.genblk2[2].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.genblk2[1].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.genblk2[0].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.genblk2[3].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.genblk2[2].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.genblk2[1].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.genblk2[0].uIMACBasicEX0.oCIFlag[3:0]}};
         default: $display("Error from ALUFlag_Read: Wrong FlagType!!!");
      endcase
    2'b10:
      case(FlagType)
         //CFlag
         2'b10:
            Flag = {{`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.genblk2[3].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.genblk2[2].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.genblk2[1].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.genblk2[0].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.genblk2[3].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.genblk2[2].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.genblk2[1].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.genblk2[0].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.genblk2[3].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.genblk2[2].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.genblk2[1].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.genblk2[0].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.genblk2[3].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.genblk2[2].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.genblk2[1].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.genblk2[0].uIMACBasicEX0.oCIFlag[3:0]}};
         default: $display("Error from ALUFlag_Read: Wrong FlagType!!!");
      endcase
    2'b11:
      case(FlagType)
         //CFlag
         2'b10:
            Flag = {{`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.genblk2[3].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.genblk2[2].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.genblk2[1].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.genblk2[0].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.genblk2[3].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.genblk2[2].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.genblk2[1].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.genblk2[0].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.genblk2[3].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.genblk2[2].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.genblk2[1].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.genblk2[0].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.genblk2[3].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.genblk2[2].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.genblk2[1].uIMACBasicEX0.oCIFlag[3:0]},{`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.genblk2[0].uIMACBasicEX0.oCIFlag[3:0]}};
         default: $display("Error from ALUFlag_Read: Wrong FlagType!!!");
      endcase
  endcase
endtask


//GroupID:0000-IMA0,0001-IMA1,0010-IMA2,0011-IMA3,0100-SHU0,0101-SHU1,0110-SHU2,0111-SHU3,1000-BIU0,1001-BIU1,1010-BIU2,1011-BIU3 
task Monitor::T_Read(input bit[3:0] GroupID, input bit[2:0] TRegID, output logic[511:0] Data);

    case(GroupID)
      // IMA0
      4'b0000: begin
        if(TRegID==3'b110 || TRegID==3'b111) begin
           $display("Error There is no IMA0.T%h ", TRegID);
        end else begin
           Data = {{`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.TReg.rTReg[TRegID]},
                   {`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.TReg.rTReg[TRegID]},
                   {`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.TReg.rTReg[TRegID]},
                   {`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.TReg.rTReg[TRegID]}};
        end
      end

      // IMA1
      4'b0001:  begin
        if(TRegID==3'b110 || TRegID==3'b111) begin
           $display("Error There is no IMA1.T%h ", TRegID);
        end else begin
           Data = {{`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.TReg.rTReg[TRegID]},
                   {`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.TReg.rTReg[TRegID]},
                   {`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.TReg.rTReg[TRegID]},
                   {`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.TReg.rTReg[TRegID]}};
        end
      end

      // IMA2
      4'b0010: begin
        if(TRegID==3'b110 || TRegID==3'b111) begin
           $display("Error There is no IMA2.T%h ", TRegID);
        end else begin
           Data = {{`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.TReg.rTReg[TRegID]},
                   {`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.TReg.rTReg[TRegID]},
                   {`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.TReg.rTReg[TRegID]},
                   {`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.TReg.rTReg[TRegID]}};
        end
      end

      // IMA3
      4'b0011: begin
        if(TRegID==3'b110 || TRegID==3'b111) begin
           $display("Error There is no IMA3.T%h ", TRegID);
        end else begin
           Data = {{`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.TReg.rTReg[TRegID]},
                   {`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.TReg.rTReg[TRegID]},
                   {`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.TReg.rTReg[TRegID]},
                   {`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.TReg.rTReg[TRegID]}};
        end
      end

      //SHU0
      4'b0100:  begin
         Data = `MPU_PATH.gen_shu[0].uSHU.uTReg_w8_r3_v8.rTReg[TRegID];
      end

      //SHU1
      4'b0101:  begin
         Data = `MPU_PATH.gen_shu[1].uSHU.uTReg_w8_r3_v8.rTReg[TRegID];
      end

      //SHU2
      4'b0110:  begin
         Data = `MPU_PATH.gen_shu[2].uSHU.uTReg_w8_r3_v8.rTReg[TRegID];
      end

      //SHU3
      4'b0111:  begin
         Data = `MPU_PATH.gen_shu[3].uSHU.uTReg_w8_r3_v8.rTReg[TRegID];
      end

      //BIU0
      4'b1000:  begin
        case(TRegID)
          3'b000:  Data = `MPU_PATH.gen_biu[0].uBIU.TReg[0];
          3'b001:  Data = `MPU_PATH.gen_biu[0].uBIU.TReg[1];
          3'b010:  Data = `MPU_PATH.gen_biu[0].uBIU.TReg[2];
          3'b011:  Data = `MPU_PATH.gen_biu[0].uBIU.TReg[3];
          default: $display("Error BIU0.T%h in TestTop.uAPE.uMPU.uBIU0", TRegID);
        endcase
      end

      //BIU1
      4'b1001:  begin
        case(TRegID)
          3'b000:  Data = `MPU_PATH.gen_biu[1].uBIU.TReg[0];
          3'b001:  Data = `MPU_PATH.gen_biu[1].uBIU.TReg[1];
          3'b010:  Data = `MPU_PATH.gen_biu[1].uBIU.TReg[2];
          3'b011:  Data = `MPU_PATH.gen_biu[1].uBIU.TReg[3];
          default: $display("Error BIU1.T%h in TestTop.uAPE.uMPU.uBIU1", TRegID);
        endcase
      end

      //BIU2
      4'b1010:  begin
        case(TRegID)
          3'b000:  Data = `MPU_PATH.gen_biu[2].uBIU.TReg[0];
          3'b001:  Data = `MPU_PATH.gen_biu[2].uBIU.TReg[1];
          3'b010:  Data = `MPU_PATH.gen_biu[2].uBIU.TReg[2];
          3'b011:  Data = `MPU_PATH.gen_biu[2].uBIU.TReg[3];
          default: $display("Error BIU2.T%h in TestTop.uAPE.uMPU.uBIU2", TRegID);
        endcase
      end

      //BIU3
      4'b1011:  begin
        case(TRegID)
          3'b000:  Data = `MPU_PATH.gen_biu[3].uBIU.TReg[0];
          3'b001:  Data = `MPU_PATH.gen_biu[3].uBIU.TReg[1];
          3'b010:  Data = `MPU_PATH.gen_biu[3].uBIU.TReg[2];
          3'b011:  Data = `MPU_PATH.gen_biu[3].uBIU.TReg[3];
          default: $display("Error BIU3.T%h in TestTop.uAPE.uMPU.uBIU3", TRegID);
        endcase
      end

      default:  begin
        Data = 512'b0;
        $display("The GroupID is Error.",);
      end
    endcase
  endtask


  //Mode:0000 -> KI0-3, 0001 -> KI4-7, 0010 -> KI8-11, 0011 -> KI12-15, 0100 -> KI0-15, 0101 -> KI4-6, 0110 -> KI8-10, 0111 -> KI12-14
  task Monitor::MFetchKI_Read(input bit[3:0] Mode, output logic[511:0] Data);
    bit[511:0] Mask;
    `TD;
    case(Mode)
      //                    KI15     KI14     KI13     KI12     KI11     KI10     KI9      KI8      KI7      KI6      KI5      KI4      KI3      KI2      KI1      KI0 
      4'b0000:  Mask = 512'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_ffffffff_ffffffff_ffffffff_ffffffff;
      4'b0001:  Mask = 512'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_ffffffff_ffffffff_ffffffff_ffffffff_00000000_00000000_00000000_00000000;
      4'b0010:  Mask = 512'h00000000_00000000_00000000_00000000_ffffffff_ffffffff_ffffffff_ffffffff_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000;
      4'b0011:  Mask = 512'hffffffff_ffffffff_ffffffff_ffffffff_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000;
      4'b0100:  Mask = 512'hffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff_ffffffff;
      4'b0101:  Mask = 512'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_ffffffff_ffffffff_ffffffff_00000000_00000000_00000000_00000000;
      4'b0110:  Mask = 512'h00000000_00000000_00000000_00000000_00000000_ffffffff_ffffffff_ffffffff_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000;
      4'b0111:  Mask = 512'h00000000_ffffffff_ffffffff_ffffffff_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000;
    endcase

    Data = {8'h00,{`MPU_PATH.uMFetch.KI[15]},8'h00,{`MPU_PATH.uMFetch.KI[14]},
            8'h00,{`MPU_PATH.uMFetch.KI[13]},8'h00,{`MPU_PATH.uMFetch.KI[12]},
            8'h00,{`MPU_PATH.uMFetch.KI[11]},8'h00,{`MPU_PATH.uMFetch.KI[10]},
            8'h00,{`MPU_PATH.uMFetch.KI[9]},8'h00,{`MPU_PATH.uMFetch.KI[8]},
            8'h00,{`MPU_PATH.uMFetch.KI[7]},8'h00,{`MPU_PATH.uMFetch.KI[6]},
            8'h00,{`MPU_PATH.uMFetch.KI[5]},8'h00,{`MPU_PATH.uMFetch.KI[4]},
            8'h00,{`MPU_PATH.uMFetch.KI[3]},8'h00,{`MPU_PATH.uMFetch.KI[2]},
            8'h00,{`MPU_PATH.uMFetch.KI[1]},8'h00,{`MPU_PATH.uMFetch.KI[0]}} & Mask;
  endtask

  //Sel:00->IMA0, 01->IMA1, 10->IMA2, 11->IMA3
  task Monitor::MR_Read(input bit[1:0] Sel, output logic[`MR_WIDTH-1:0] Data);
    bit[39:0] IMA0_rExt[16];
    bit[39:0] IMA1_rExt[16];
    bit[39:0] IMA2_rExt[16];
    bit[39:0] IMA3_rExt[16];
    bit[63:0] IMA0_rMR[16];
    bit[63:0] IMA1_rMR[16];
    bit[63:0] IMA2_rMR[16];
    bit[63:0] IMA3_rMR[16];
    IMA0_rExt[15] = {`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.genblk3[3].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.genblk3[3].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.genblk3[3].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.genblk3[3].uEX2Unit.rExt[0]};
    IMA0_rExt[14] = {`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.genblk3[2].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.genblk3[2].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.genblk3[2].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.genblk3[2].uEX2Unit.rExt[0]};
    IMA0_rExt[13] = {`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.genblk3[1].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.genblk3[1].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.genblk3[1].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.genblk3[1].uEX2Unit.rExt[0]};
    IMA0_rExt[12] = {`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.genblk3[0].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.genblk3[0].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.genblk3[0].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.genblk3[0].uEX2Unit.rExt[0]};
    IMA0_rExt[11] = {`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.genblk3[3].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.genblk3[3].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.genblk3[3].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.genblk3[3].uEX2Unit.rExt[0]};
    IMA0_rExt[10] = {`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.genblk3[2].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.genblk3[2].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.genblk3[2].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.genblk3[2].uEX2Unit.rExt[0]};
    IMA0_rExt[9]  = {`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.genblk3[1].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.genblk3[1].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.genblk3[1].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.genblk3[1].uEX2Unit.rExt[0]};
    IMA0_rExt[8]  = {`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.genblk3[0].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.genblk3[0].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.genblk3[0].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.genblk3[0].uEX2Unit.rExt[0]};
    IMA0_rExt[7]  = {`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.genblk3[3].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.genblk3[3].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.genblk3[3].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.genblk3[3].uEX2Unit.rExt[0]};
    IMA0_rExt[6]  = {`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.genblk3[2].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.genblk3[2].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.genblk3[2].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.genblk3[2].uEX2Unit.rExt[0]};
    IMA0_rExt[5]  = {`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.genblk3[1].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.genblk3[1].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.genblk3[1].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.genblk3[1].uEX2Unit.rExt[0]};
    IMA0_rExt[4]  = {`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.genblk3[0].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.genblk3[0].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.genblk3[0].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.genblk3[0].uEX2Unit.rExt[0]};
    IMA0_rExt[3]  = {`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.genblk3[3].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.genblk3[3].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.genblk3[3].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.genblk3[3].uEX2Unit.rExt[0]};
    IMA0_rExt[2]  = {`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.genblk3[2].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.genblk3[2].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.genblk3[2].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.genblk3[2].uEX2Unit.rExt[0]};
    IMA0_rExt[1]  = {`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.genblk3[1].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.genblk3[1].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.genblk3[1].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.genblk3[1].uEX2Unit.rExt[0]};
    IMA0_rExt[0]  = {`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.genblk3[0].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.genblk3[0].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.genblk3[0].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.genblk3[0].uEX2Unit.rExt[0]};
    IMA1_rExt[15] = {`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.genblk3[3].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.genblk3[3].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.genblk3[3].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.genblk3[3].uEX2Unit.rExt[0]};
    IMA1_rExt[14] = {`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.genblk3[2].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.genblk3[2].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.genblk3[2].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.genblk3[2].uEX2Unit.rExt[0]};
    IMA1_rExt[13] = {`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.genblk3[1].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.genblk3[1].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.genblk3[1].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.genblk3[1].uEX2Unit.rExt[0]};
    IMA1_rExt[12] = {`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.genblk3[0].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.genblk3[0].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.genblk3[0].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.genblk3[0].uEX2Unit.rExt[0]};
    IMA1_rExt[11] = {`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.genblk3[3].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.genblk3[3].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.genblk3[3].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.genblk3[3].uEX2Unit.rExt[0]};
    IMA1_rExt[10] = {`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.genblk3[2].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.genblk3[2].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.genblk3[2].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.genblk3[2].uEX2Unit.rExt[0]};
    IMA1_rExt[9]  = {`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.genblk3[1].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.genblk3[1].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.genblk3[1].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.genblk3[1].uEX2Unit.rExt[0]};
    IMA1_rExt[8]  = {`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.genblk3[0].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.genblk3[0].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.genblk3[0].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.genblk3[0].uEX2Unit.rExt[0]};
    IMA1_rExt[7]  = {`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.genblk3[3].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.genblk3[3].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.genblk3[3].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.genblk3[3].uEX2Unit.rExt[0]};
    IMA1_rExt[6]  = {`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.genblk3[2].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.genblk3[2].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.genblk3[2].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.genblk3[2].uEX2Unit.rExt[0]};
    IMA1_rExt[5]  = {`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.genblk3[1].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.genblk3[1].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.genblk3[1].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.genblk3[1].uEX2Unit.rExt[0]};
    IMA1_rExt[4]  = {`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.genblk3[0].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.genblk3[0].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.genblk3[0].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.genblk3[0].uEX2Unit.rExt[0]};
    IMA1_rExt[3]  = {`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.genblk3[3].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.genblk3[3].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.genblk3[3].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.genblk3[3].uEX2Unit.rExt[0]};
    IMA1_rExt[2]  = {`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.genblk3[2].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.genblk3[2].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.genblk3[2].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.genblk3[2].uEX2Unit.rExt[0]};
    IMA1_rExt[1]  = {`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.genblk3[1].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.genblk3[1].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.genblk3[1].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.genblk3[1].uEX2Unit.rExt[0]};
    IMA1_rExt[0]  = {`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.genblk3[0].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.genblk3[0].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.genblk3[0].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.genblk3[0].uEX2Unit.rExt[0]};
    IMA2_rExt[15] = {`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.genblk3[3].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.genblk3[3].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.genblk3[3].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.genblk3[3].uEX2Unit.rExt[0]};
    IMA2_rExt[14] = {`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.genblk3[2].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.genblk3[2].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.genblk3[2].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.genblk3[2].uEX2Unit.rExt[0]};
    IMA2_rExt[13] = {`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.genblk3[1].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.genblk3[1].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.genblk3[1].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.genblk3[1].uEX2Unit.rExt[0]};
    IMA2_rExt[12] = {`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.genblk3[0].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.genblk3[0].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.genblk3[0].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.genblk3[0].uEX2Unit.rExt[0]};
    IMA2_rExt[11] = {`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.genblk3[3].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.genblk3[3].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.genblk3[3].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.genblk3[3].uEX2Unit.rExt[0]};
    IMA2_rExt[10] = {`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.genblk3[2].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.genblk3[2].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.genblk3[2].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.genblk3[2].uEX2Unit.rExt[0]};
    IMA2_rExt[9]  = {`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.genblk3[1].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.genblk3[1].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.genblk3[1].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.genblk3[1].uEX2Unit.rExt[0]};
    IMA2_rExt[8]  = {`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.genblk3[0].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.genblk3[0].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.genblk3[0].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.genblk3[0].uEX2Unit.rExt[0]};
    IMA2_rExt[7]  = {`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.genblk3[3].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.genblk3[3].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.genblk3[3].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.genblk3[3].uEX2Unit.rExt[0]};
    IMA2_rExt[6]  = {`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.genblk3[2].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.genblk3[2].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.genblk3[2].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.genblk3[2].uEX2Unit.rExt[0]};
    IMA2_rExt[5]  = {`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.genblk3[1].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.genblk3[1].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.genblk3[1].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.genblk3[1].uEX2Unit.rExt[0]};
    IMA2_rExt[4]  = {`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.genblk3[0].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.genblk3[0].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.genblk3[0].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.genblk3[0].uEX2Unit.rExt[0]};
    IMA2_rExt[3]  = {`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.genblk3[3].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.genblk3[3].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.genblk3[3].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.genblk3[3].uEX2Unit.rExt[0]};
    IMA2_rExt[2]  = {`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.genblk3[2].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.genblk3[2].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.genblk3[2].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.genblk3[2].uEX2Unit.rExt[0]};
    IMA2_rExt[1]  = {`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.genblk3[1].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.genblk3[1].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.genblk3[1].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.genblk3[1].uEX2Unit.rExt[0]};
    IMA2_rExt[0]  = {`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.genblk3[0].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.genblk3[0].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.genblk3[0].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.genblk3[0].uEX2Unit.rExt[0]};
    IMA3_rExt[15] = {`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.genblk3[3].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.genblk3[3].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.genblk3[3].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.genblk3[3].uEX2Unit.rExt[0]};
    IMA3_rExt[14] = {`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.genblk3[2].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.genblk3[2].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.genblk3[2].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.genblk3[2].uEX2Unit.rExt[0]};
    IMA3_rExt[13] = {`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.genblk3[1].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.genblk3[1].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.genblk3[1].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.genblk3[1].uEX2Unit.rExt[0]};
    IMA3_rExt[12] = {`MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.genblk3[0].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.genblk3[0].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.genblk3[0].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.genblk3[0].uEX2Unit.rExt[0]};
    IMA3_rExt[11] = {`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.genblk3[3].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.genblk3[3].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.genblk3[3].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.genblk3[3].uEX2Unit.rExt[0]};
    IMA3_rExt[10] = {`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.genblk3[2].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.genblk3[2].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.genblk3[2].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.genblk3[2].uEX2Unit.rExt[0]};
    IMA3_rExt[9]  = {`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.genblk3[1].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.genblk3[1].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.genblk3[1].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.genblk3[1].uEX2Unit.rExt[0]};
    IMA3_rExt[8]  = {`MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.genblk3[0].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.genblk3[0].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.genblk3[0].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.genblk3[0].uEX2Unit.rExt[0]};
    IMA3_rExt[7]  = {`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.genblk3[3].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.genblk3[3].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.genblk3[3].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.genblk3[3].uEX2Unit.rExt[0]};
    IMA3_rExt[6]  = {`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.genblk3[2].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.genblk3[2].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.genblk3[2].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.genblk3[2].uEX2Unit.rExt[0]};
    IMA3_rExt[5]  = {`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.genblk3[1].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.genblk3[1].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.genblk3[1].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.genblk3[1].uEX2Unit.rExt[0]};
    IMA3_rExt[4]  = {`MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.genblk3[0].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.genblk3[0].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.genblk3[0].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.genblk3[0].uEX2Unit.rExt[0]};
    IMA3_rExt[3]  = {`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.genblk3[3].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.genblk3[3].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.genblk3[3].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.genblk3[3].uEX2Unit.rExt[0]};
    IMA3_rExt[2]  = {`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.genblk3[2].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.genblk3[2].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.genblk3[2].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.genblk3[2].uEX2Unit.rExt[0]};
    IMA3_rExt[1]  = {`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.genblk3[1].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.genblk3[1].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.genblk3[1].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.genblk3[1].uEX2Unit.rExt[0]};
    IMA3_rExt[0]  = {`MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.genblk3[0].uEX2Unit.rExt[3], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.genblk3[0].uEX2Unit.rExt[2], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.genblk3[0].uEX2Unit.rExt[1], `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.genblk3[0].uEX2Unit.rExt[0]};
    IMA0_rMR[15]  = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.genblk3[3].uEX2Unit.rMR;
    IMA0_rMR[14]  = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.genblk3[2].uEX2Unit.rMR;
    IMA0_rMR[13]  = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.genblk3[1].uEX2Unit.rMR;
    IMA0_rMR[12]  = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[0].uIMA.genblk3[0].uEX2Unit.rMR;
    IMA0_rMR[11]  = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.genblk3[3].uEX2Unit.rMR;
    IMA0_rMR[10]  = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.genblk3[2].uEX2Unit.rMR;
    IMA0_rMR[9]   = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.genblk3[1].uEX2Unit.rMR;
    IMA0_rMR[8]   = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[0].uIMA.genblk3[0].uEX2Unit.rMR;
    IMA0_rMR[7]   = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.genblk3[3].uEX2Unit.rMR;
    IMA0_rMR[6]   = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.genblk3[2].uEX2Unit.rMR;
    IMA0_rMR[5]   = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.genblk3[1].uEX2Unit.rMR;
    IMA0_rMR[4]   = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[0].uIMA.genblk3[0].uEX2Unit.rMR;
    IMA0_rMR[3]   = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.genblk3[3].uEX2Unit.rMR;
    IMA0_rMR[2]   = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.genblk3[2].uEX2Unit.rMR;
    IMA0_rMR[1]   = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.genblk3[1].uEX2Unit.rMR;
    IMA0_rMR[0]   = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[0].uIMA.genblk3[0].uEX2Unit.rMR;
    IMA1_rMR[15]  = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.genblk3[3].uEX2Unit.rMR;
    IMA1_rMR[14]  = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.genblk3[2].uEX2Unit.rMR;
    IMA1_rMR[13]  = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.genblk3[1].uEX2Unit.rMR;
    IMA1_rMR[12]  = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[1].uIMA.genblk3[0].uEX2Unit.rMR;
    IMA1_rMR[11]  = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.genblk3[3].uEX2Unit.rMR;
    IMA1_rMR[10]  = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.genblk3[2].uEX2Unit.rMR;
    IMA1_rMR[9]   = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.genblk3[1].uEX2Unit.rMR;
    IMA1_rMR[8]   = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[1].uIMA.genblk3[0].uEX2Unit.rMR;
    IMA1_rMR[7]   = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.genblk3[3].uEX2Unit.rMR;
    IMA1_rMR[6]   = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.genblk3[2].uEX2Unit.rMR;
    IMA1_rMR[5]   = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.genblk3[1].uEX2Unit.rMR;
    IMA1_rMR[4]   = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[1].uIMA.genblk3[0].uEX2Unit.rMR;
    IMA1_rMR[3]   = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.genblk3[3].uEX2Unit.rMR;
    IMA1_rMR[2]   = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.genblk3[2].uEX2Unit.rMR;
    IMA1_rMR[1]   = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.genblk3[1].uEX2Unit.rMR;
    IMA1_rMR[0]   = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[1].uIMA.genblk3[0].uEX2Unit.rMR;
    IMA2_rMR[15]  = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.genblk3[3].uEX2Unit.rMR;
    IMA2_rMR[14]  = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.genblk3[2].uEX2Unit.rMR;
    IMA2_rMR[13]  = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.genblk3[1].uEX2Unit.rMR;
    IMA2_rMR[12]  = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[2].uIMA.genblk3[0].uEX2Unit.rMR;
    IMA2_rMR[11]  = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.genblk3[3].uEX2Unit.rMR;
    IMA2_rMR[10]  = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.genblk3[2].uEX2Unit.rMR;
    IMA2_rMR[9]   = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.genblk3[1].uEX2Unit.rMR;
    IMA2_rMR[8]   = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[2].uIMA.genblk3[0].uEX2Unit.rMR;
    IMA2_rMR[7]   = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.genblk3[3].uEX2Unit.rMR;
    IMA2_rMR[6]   = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.genblk3[2].uEX2Unit.rMR;
    IMA2_rMR[5]   = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.genblk3[1].uEX2Unit.rMR;
    IMA2_rMR[4]   = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[2].uIMA.genblk3[0].uEX2Unit.rMR;
    IMA2_rMR[3]   = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.genblk3[3].uEX2Unit.rMR;
    IMA2_rMR[2]   = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.genblk3[2].uEX2Unit.rMR;
    IMA2_rMR[1]   = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.genblk3[1].uEX2Unit.rMR;
    IMA2_rMR[0]   = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[2].uIMA.genblk3[0].uEX2Unit.rMR;
    IMA3_rMR[15]  = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.genblk3[3].uEX2Unit.rMR;
    IMA3_rMR[14]  = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.genblk3[2].uEX2Unit.rMR;
    IMA3_rMR[13]  = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.genblk3[1].uEX2Unit.rMR;
    IMA3_rMR[12]  = `MPU_PATH.gen_dpath[3].uDPath.gen_IMA[3].uIMA.genblk3[0].uEX2Unit.rMR;
    IMA3_rMR[11]  = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.genblk3[3].uEX2Unit.rMR;
    IMA3_rMR[10]  = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.genblk3[2].uEX2Unit.rMR;
    IMA3_rMR[9]   = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.genblk3[1].uEX2Unit.rMR;
    IMA3_rMR[8]   = `MPU_PATH.gen_dpath[2].uDPath.gen_IMA[3].uIMA.genblk3[0].uEX2Unit.rMR;
    IMA3_rMR[7]   = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.genblk3[3].uEX2Unit.rMR;
    IMA3_rMR[6]   = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.genblk3[2].uEX2Unit.rMR;
    IMA3_rMR[5]   = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.genblk3[1].uEX2Unit.rMR;
    IMA3_rMR[4]   = `MPU_PATH.gen_dpath[1].uDPath.gen_IMA[3].uIMA.genblk3[0].uEX2Unit.rMR;
    IMA3_rMR[3]   = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.genblk3[3].uEX2Unit.rMR;
    IMA3_rMR[2]   = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.genblk3[2].uEX2Unit.rMR;
    IMA3_rMR[1]   = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.genblk3[1].uEX2Unit.rMR;
    IMA3_rMR[0]   = `MPU_PATH.gen_dpath[0].uDPath.gen_IMA[3].uIMA.genblk3[0].uEX2Unit.rMR;
    case(Sel)
      2'b00:  Data = {IMA0_rExt[15],IMA0_rMR[15], IMA0_rExt[14],IMA0_rMR[14], IMA0_rExt[13],IMA0_rMR[13], IMA0_rExt[12],IMA0_rMR[12], IMA0_rExt[11],IMA0_rMR[11], IMA0_rExt[10],IMA0_rMR[10],IMA0_rExt[9],IMA0_rMR[9], IMA0_rExt[8],IMA0_rMR[8], IMA0_rExt[7],IMA0_rMR[7], IMA0_rExt[6],IMA0_rMR[6], IMA0_rExt[5],IMA0_rMR[5], IMA0_rExt[4],IMA0_rMR[4], IMA0_rExt[3],IMA0_rMR[3], IMA0_rExt[2],IMA0_rMR[2], IMA0_rExt[1],IMA0_rMR[1], IMA0_rExt[0],IMA0_rMR[0]};
      2'b01:  Data = {IMA1_rExt[15],IMA1_rMR[15], IMA1_rExt[14],IMA1_rMR[14], IMA1_rExt[13],IMA1_rMR[13], IMA1_rExt[12],IMA1_rMR[12], IMA1_rExt[11],IMA1_rMR[11], IMA1_rExt[10],IMA1_rMR[10],IMA1_rExt[9],IMA1_rMR[9], IMA1_rExt[8],IMA1_rMR[8], IMA1_rExt[7],IMA1_rMR[7], IMA1_rExt[6],IMA1_rMR[6], IMA1_rExt[5],IMA1_rMR[5], IMA1_rExt[4],IMA1_rMR[4], IMA1_rExt[3],IMA1_rMR[3], IMA1_rExt[2],IMA1_rMR[2], IMA1_rExt[1],IMA1_rMR[1], IMA1_rExt[0],IMA1_rMR[0]};
      2'b10:  Data = {IMA2_rExt[15],IMA2_rMR[15], IMA2_rExt[14],IMA2_rMR[14], IMA2_rExt[13],IMA2_rMR[13], IMA2_rExt[12],IMA2_rMR[12], IMA2_rExt[11],IMA2_rMR[11], IMA2_rExt[10],IMA2_rMR[10],IMA2_rExt[9],IMA2_rMR[9], IMA2_rExt[8],IMA2_rMR[8], IMA2_rExt[7],IMA2_rMR[7], IMA2_rExt[6],IMA2_rMR[6], IMA2_rExt[5],IMA2_rMR[5], IMA2_rExt[4],IMA2_rMR[4], IMA2_rExt[3],IMA2_rMR[3], IMA2_rExt[2],IMA2_rMR[2], IMA2_rExt[1],IMA2_rMR[1], IMA2_rExt[0],IMA2_rMR[0]};
      2'b11:  Data = {IMA3_rExt[15],IMA3_rMR[15], IMA3_rExt[14],IMA3_rMR[14], IMA3_rExt[13],IMA3_rMR[13], IMA3_rExt[12],IMA3_rMR[12], IMA3_rExt[11],IMA3_rMR[11], IMA3_rExt[10],IMA3_rMR[10],IMA3_rExt[9],IMA3_rMR[9], IMA3_rExt[8],IMA3_rMR[8], IMA3_rExt[7],IMA3_rMR[7], IMA3_rExt[6],IMA3_rMR[6], IMA3_rExt[5],IMA3_rMR[5], IMA3_rExt[4],IMA3_rMR[4], IMA3_rExt[3],IMA3_rMR[3], IMA3_rExt[2],IMA3_rMR[2], IMA3_rExt[1],IMA3_rMR[1], IMA3_rExt[0],IMA3_rMR[0]};
    endcase
  endtask

  // Sel: 00-SHU0, 01-SHU1, 10-SHU2, 11-SHU3
  task Monitor::T7Reg_Read(input bit[1:0] Sel, output logic[511:0] Data);
//  task Monitor::TBReg_Read(input bit[1:0] Sel, output logic[511:0] Data);

  	`TD;
//  $display("TBReg_Read needs to update!!!");
  $display("T7Reg_Read needs to update!!!");

	case(Sel)
      2'b00:  Data = `MPU_PATH.gen_shu[0].uSHU.uTReg_w8_r3_v8.rTReg[7];
      2'b01:  Data = `MPU_PATH.gen_shu[1].uSHU.uTReg_w8_r3_v8.rTReg[7];
      2'b10:  Data = `MPU_PATH.gen_shu[2].uSHU.uTReg_w8_r3_v8.rTReg[7];
      2'b11:  Data = `MPU_PATH.gen_shu[3].uSHU.uTReg_w8_r3_v8.rTReg[7];
	endcase
  endtask

  // Sel: 00-read latch0, 01-read latch1, 10-write latch
  task Monitor::MRegLatch_Read(input bit[1:0] Sel, output logic[511:0] Data);
  `TD;
	case(Sel)
      2'b00:  Data = `MPU_PATH.uMRegCtrl.rRPAddrLatch[0];
      2'b01:  Data = `MPU_PATH.uMRegCtrl.rRPAddrLatch[1];
      2'b10:  Data = `MPU_PATH.uMRegCtrl.rWPAddrLatch;
		default: $display("Error Sel of MRegLatch_Read input!!!");
	endcase
  endtask

  // Sel: 00-IMA0,01-IMA1,10-IMA2,11-IMA3
  task Monitor::ErasedBit_Read(input bit[1:0] Sel, output logic[63:0] Data);
  `TD;
	//case(Sel)
      //2'b00:  Data = {`MPU_PATH.uCom3.uDPath1.uIALU.IALU1.rErasedBit,`MPU_PATH.uCom3.uDPath1.uIALU.IALU0.rErasedBit,`MPU_PATH.uCom3.uDPath0.uIALU.IALU1.rErasedBit,`MPU_PATH.uCom3.uDPath0.uIALU.IALU1.rErasedBit,`MPU_PATH.uCom2.uDPath1.uIALU.IALU1.rErasedBit,`MPU_PATH.uCom2.uDPath1.uIALU.IALU0.rErasedBit,`MPU_PATH.uCom2.uDPath0.uIALU.IALU1.rErasedBit,`MPU_PATH.uCom2.uDPath0.uIALU.IALU1.rErasedBit,`MPU_PATH.uCom1.uDPath1.uIALU.IALU1.rErasedBit,`MPU_PATH.uCom1.uDPath1.uIALU.IALU0.rErasedBit,`MPU_PATH.uCom1.uDPath0.uIALU.IALU1.rErasedBit,`MPU_PATH.uCom1.uDPath0.uIALU.IALU1.rErasedBit,`MPU_PATH.uCom0.uDPath1.uIALU.IALU1.rErasedBit,`MPU_PATH.uCom0.uDPath1.uIALU.IALU0.rErasedBit,`MPU_PATH.uCom0.uDPath0.uIALU.IALU1.rErasedBit,`MPU_PATH.uCom0.uDPath0.uIALU.IALU1.rErasedBit};
      //2'b10:  Data = {`MPU_PATH.uCom3.uDPath1.uIFALU.IFALU1.rErasedBit,`MPU_PATH.uCom3.uDPath1.uIFALU.IFALU0.rErasedBit,`MPU_PATH.uCom3.uDPath0.uIFALU.IFALU1.rErasedBit,`MPU_PATH.uCom3.uDPath0.uIFALU.IFALU1.rErasedBit,`MPU_PATH.uCom2.uDPath1.uIFALU.IFALU1.rErasedBit,`MPU_PATH.uCom2.uDPath1.uIFALU.IFALU0.rErasedBit,`MPU_PATH.uCom2.uDPath0.uIFALU.IFALU1.rErasedBit,`MPU_PATH.uCom2.uDPath0.uIFALU.IFALU1.rErasedBit,`MPU_PATH.uCom1.uDPath1.uIFALU.IFALU1.rErasedBit,`MPU_PATH.uCom1.uDPath1.uIFALU.IFALU0.rErasedBit,`MPU_PATH.uCom1.uDPath0.uIFALU.IFALU1.rErasedBit,`MPU_PATH.uCom1.uDPath0.uIFALU.IFALU1.rErasedBit,`MPU_PATH.uCom0.uDPath1.uIFALU.IFALU1.rErasedBit,`MPU_PATH.uCom0.uDPath1.uIFALU.IFALU0.rErasedBit,`MPU_PATH.uCom0.uDPath0.uIFALU.IFALU1.rErasedBit,`MPU_PATH.uCom0.uDPath0.uIFALU.IFALU1.rErasedBit};
      //2'b01:  Data = {40'd0,`MPU_PATH.uCom3.uDPath1.uIMAC.rFlagErased,`MPU_PATH.uCom3.uDPath0.uIMAC.rFlagErased,`MPU_PATH.uCom2.uDPath1.uIMAC.rFlagErased,`MPU_PATH.uCom2.uDPath0.uIMAC.rFlagErased,`MPU_PATH.uCom1.uDPath1.uIMAC.rFlagErased,`MPU_PATH.uCom1.uDPath0.uIMAC.rFlagErased,`MPU_PATH.uCom0.uDPath1.uIMAC.rFlagErased,`MPU_PATH.uCom0.uDPath0.uIMAC.rFlagErased};
      //2'b11:  Data = {40'd0,`MPU_PATH.uCom3.uDPath1.uIFMAC.rFlagErased,`MPU_PATH.uCom3.uDPath0.uIFMAC.rFlagErased,`MPU_PATH.uCom2.uDPath1.uIFMAC.rFlagErased,`MPU_PATH.uCom2.uDPath0.uIFMAC.rFlagErased,`MPU_PATH.uCom1.uDPath1.uIFMAC.rFlagErased,`MPU_PATH.uCom1.uDPath0.uIFMAC.rFlagErased,`MPU_PATH.uCom0.uDPath1.uIFMAC.rFlagErased,`MPU_PATH.uCom0.uDPath0.uIFMAC.rFlagErased};
	//endcase
  endtask

  // PortID: 0000-0011(RP0-RP3), 0100-1000(WP0-WP4)
  task Monitor::MC_Read(input bit[3:0] PortID, output logic[47:0] Data);
  	`TD;
	case(PortID)
		4'b0000: Data = {`MPU_PATH.uMRegCtrl.rMC[0][7][5:0],`MPU_PATH.uMRegCtrl.rMC[0][6][5:0],`MPU_PATH.uMRegCtrl.rMC[0][5][5:0],`MPU_PATH.uMRegCtrl.rMC[0][4][5:0],`MPU_PATH.uMRegCtrl.rMC[0][3][5:0],`MPU_PATH.uMRegCtrl.rMC[0][2][5:0],`MPU_PATH.uMRegCtrl.rMC[0][1][5:0],`MPU_PATH.uMRegCtrl.rMC[0][0][5:0]};
		4'b0001: Data = {`MPU_PATH.uMRegCtrl.rMC[1][7][5:0],`MPU_PATH.uMRegCtrl.rMC[1][6][5:0],`MPU_PATH.uMRegCtrl.rMC[1][5][5:0],`MPU_PATH.uMRegCtrl.rMC[1][4][5:0],`MPU_PATH.uMRegCtrl.rMC[1][3][5:0],`MPU_PATH.uMRegCtrl.rMC[1][2][5:0],`MPU_PATH.uMRegCtrl.rMC[1][1][5:0],`MPU_PATH.uMRegCtrl.rMC[1][0][5:0]};
		4'b0010: Data = {`MPU_PATH.uMRegCtrl.rMC[2][7][5:0],`MPU_PATH.uMRegCtrl.rMC[2][6][5:0],`MPU_PATH.uMRegCtrl.rMC[2][5][5:0],`MPU_PATH.uMRegCtrl.rMC[2][4][5:0],`MPU_PATH.uMRegCtrl.rMC[2][3][5:0],`MPU_PATH.uMRegCtrl.rMC[2][2][5:0],`MPU_PATH.uMRegCtrl.rMC[2][1][5:0],`MPU_PATH.uMRegCtrl.rMC[2][0][5:0]};
		4'b0011: Data = {`MPU_PATH.uMRegCtrl.rMC[3][7][5:0],`MPU_PATH.uMRegCtrl.rMC[3][6][5:0],`MPU_PATH.uMRegCtrl.rMC[3][5][5:0],`MPU_PATH.uMRegCtrl.rMC[3][4][5:0],`MPU_PATH.uMRegCtrl.rMC[3][3][5:0],`MPU_PATH.uMRegCtrl.rMC[3][2][5:0],`MPU_PATH.uMRegCtrl.rMC[3][1][5:0],`MPU_PATH.uMRegCtrl.rMC[3][0][5:0]};
		4'b0100: Data = {`MPU_PATH.uMRegCtrl.rMC[4][7][5:0],`MPU_PATH.uMRegCtrl.rMC[4][6][5:0],`MPU_PATH.uMRegCtrl.rMC[4][5][5:0],`MPU_PATH.uMRegCtrl.rMC[4][4][5:0],`MPU_PATH.uMRegCtrl.rMC[4][3][5:0],`MPU_PATH.uMRegCtrl.rMC[4][2][5:0],`MPU_PATH.uMRegCtrl.rMC[4][1][5:0],`MPU_PATH.uMRegCtrl.rMC[4][0][5:0]};
		4'b0101: Data = {`MPU_PATH.uMRegCtrl.rMC[5][7][5:0],`MPU_PATH.uMRegCtrl.rMC[5][6][5:0],`MPU_PATH.uMRegCtrl.rMC[5][5][5:0],`MPU_PATH.uMRegCtrl.rMC[5][4][5:0],`MPU_PATH.uMRegCtrl.rMC[5][3][5:0],`MPU_PATH.uMRegCtrl.rMC[5][2][5:0],`MPU_PATH.uMRegCtrl.rMC[5][1][5:0],`MPU_PATH.uMRegCtrl.rMC[5][0][5:0]};
		4'b0110: Data = {`MPU_PATH.uMRegCtrl.rMC[6][7][5:0],`MPU_PATH.uMRegCtrl.rMC[6][6][5:0],`MPU_PATH.uMRegCtrl.rMC[6][5][5:0],`MPU_PATH.uMRegCtrl.rMC[6][4][5:0],`MPU_PATH.uMRegCtrl.rMC[6][3][5:0],`MPU_PATH.uMRegCtrl.rMC[6][2][5:0],`MPU_PATH.uMRegCtrl.rMC[6][1][5:0],`MPU_PATH.uMRegCtrl.rMC[6][0][5:0]};
		4'b0111: Data = {`MPU_PATH.uMRegCtrl.rMC[7][7][5:0],`MPU_PATH.uMRegCtrl.rMC[7][6][5:0],`MPU_PATH.uMRegCtrl.rMC[7][5][5:0],`MPU_PATH.uMRegCtrl.rMC[7][4][5:0],`MPU_PATH.uMRegCtrl.rMC[7][3][5:0],`MPU_PATH.uMRegCtrl.rMC[7][2][5:0],`MPU_PATH.uMRegCtrl.rMC[7][1][5:0],`MPU_PATH.uMRegCtrl.rMC[7][0][5:0]};
		4'b1000: Data = {`MPU_PATH.uMRegCtrl.rMC[8][7][5:0],`MPU_PATH.uMRegCtrl.rMC[8][6][5:0],`MPU_PATH.uMRegCtrl.rMC[8][5][5:0],`MPU_PATH.uMRegCtrl.rMC[8][4][5:0],`MPU_PATH.uMRegCtrl.rMC[8][3][5:0],`MPU_PATH.uMRegCtrl.rMC[8][2][5:0],`MPU_PATH.uMRegCtrl.rMC[8][1][5:0],`MPU_PATH.uMRegCtrl.rMC[8][0][5:0]};
	endcase
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

  task Monitor::display_MR(input logic[`MR_WIDTH-1:0]  Data);
    $display("Data=%h_%h_%h_%h_%h_%h_%h_%h_%h_%h_%h_%h_%h_%h_%h_%h,", 
        Data[104*16-1:104*15],Data[104*15-1:104*14],Data[104*14-1:104*13],Data[104*13-1:104*12],Data[104*12-1:104*11],Data[104*11-1:104*10],Data[104*10-1:104*9],Data[104*9-1:104*8],Data[104*8-1:104*7],Data[104*7-1:104*6],Data[104*6-1:104*5],Data[104*5-1:104*4],Data[104*4-1:104*3],Data[104*3-1:104*2],Data[104*2-1:104],Data[104-1:0]);
  endtask

`undef SPU_PATH  
`undef MPU_PATH  


//////////////////////////////////////////////////////////////
// Check
/*
******************************* MPU *******************************
*  task automatic CheckTValue(input int MPUPC, input int InstrCycle, input bit[3:0] GrpID, input bit[2:0] TID, input bit[511:0] ExpValue); 
*  task automatic Check2TValue(input int MPUPC, input int InstrCycle, input bit[3:0] GrpID, input bit[2:0] TID, input bit[511:0] ExpValue); 
*  task automatic CheckMValue(input int MPUPC, input int InstrCycle, input bit[5:0] RID, input bit[511:0] ExpValue); 
*  task automatic CheckMValueMFetch(input int MPUPC, input int InstrCycle, input bit[5:0] RID, input bit[511:0] ExpValue); 
*  task automatic CheckMCValue(input int MPUPC,input int InstrCycle, input bit[3:0] PortID, input bit[63:0] ExpValue); 
*  task automatic CheckMRegLatchValue(input int MPUPC, input int InstrCycle, input bit[1:0] Sel, input bit[511:0] ExpValue); 
*  task automatic CheckMRValue(input int MPUPC, input int InstrCycle, input bit[1:0] Sel, input bit[1:0] Width, input bit[1663:0] ExpValue); 
*  task automatic CheckMRLHValue(input int MPUPC, input int InstrCycle, input bit[1:0] Sel, bit[1:0] Width, input bit[1663:0] ExpValue); 
*  task automatic CheckMRLValue(input int MPUPC, input int InstrCycle, input bit[1:0] Sel, bit[1:0] Width, input bit[1663:0] ExpValue); 
*  task automatic CheckFLAGValue(input int MPUPC, input int InstrCycle, input bit[1:0] GrpID, input bit[1:0] FlagType, input bit[63:0] ExpValue); 
*  task automatic CheckErasedBitValue(input int MPUPC, input bit[1:0] GrpID, input bit[63:0] ExpValue);
*  task automatic CheckTLOW32Value(input int MPUPC, input int InstrCycle, input bit[3:0] GrpID, input bit[2:0] TID, input bit[511:0] ExpValue); 
*  task automatic CheckFLAGLOW16Value(input int MPUPC, input bit[1:0] GrpID, input bit[1:0] FlagType, input bit[63:0] ExpValue); 
*  task automatic CheckIMAWriteFLAGValue(input int MPUPC, input int InstrCycle, input bit[1:0] GrpID, input bit[2:0] FlagType, input bit[63:0] ExpValue); 
*  task automatic CheckDM0Value(input int MPUPC, input int InstrCycle, input int Addr, input bit [2:0] Gran, input [3:0] Size, input [2:0] CGran, input bit [511:0] ExpValue);
*  task automatic Check2DM0Value(input int MPUPC, input int InstrCycle, input int Addr, input bit [2:0] Gran, input [3:0] Size, input [2:0] CGran, input bit [511:0] ExpValue);
*  task automatic CheckDM1Value(input int MPUPC, input int InstrCycle, input int Addr, input bit [2:0] Gran, input [3:0] Size, input [2:0] CGran, input bit [511:0] ExpValue);
*  task automatic Check2DM1Value(input int MPUPC, input int InstrCycle, input int Addr, input bit [2:0] Gran, input [3:0] Size, input [2:0] CGran, input bit [511:0] ExpValue);
*  task automatic CheckDM2Value(input int MPUPC, input int InstrCycle, input int Addr, input bit [2:0] Gran, input [3:0] Size, input [2:0] CGran, input bit [511:0] ExpValue);
*  task automatic Check2DM2Value(input int MPUPC, input int InstrCycle, input int Addr, input bit [2:0] Gran, input [3:0] Size, input [2:0] CGran, input bit [511:0] ExpValue);
*  task automatic CheckJUMP( input int MPUSTARTPC, input int NextMPUSTARTPC);
*  task automatic CheckKIValueMFetch_JUMPS(input int MPUSTARTPC, input bit[4:0] KInum, input bit[23:0] ExpValue); 
*  task automatic CheckLoop(input int StartMPC, input int EndMPC, input int LpNum);
*  task automatic CheckMFetchKI_loopValue(input int MPUSTARTPC, input int InstrCycle, input bit[4:0] KInum, input int LpNum, input bit[23:0] ExpValue); 
*  task automatic CheckMValue_loop(input int MPUSTARTPC, input int InstrCycle, input bit[5:0] RID, input int LpNum, input bit[511:0] ExpValue); 
*  task automatic CheckTValue_loop(input int MPUSTARTPC, input int InstrCycle, input bit[3:0] GrpID, input bit[2:0] TID, input int LpNum, input bit[511:0] ExpValue);
*  task automatic CheckTBRegValue(input int MPUPC, input int InstrCycle, input bit[1:0] Sel, input bit[511:0] ExpValue); 
*  task automatic CheckKIsValue(input int MPUPC, input int InstrCycle, input bit[3:0] Mode, input bit[511:0] ExpValue); 
*  task automatic CheckKIValue(input int MPUPC, input int InstrCycle, input bit[4:0] KIID, input logic[23:0] ExpValue); 
*  task automatic CheckKITotalValue(input int MPUPC, input int InstrCycle, input bit[511:0] ExpValue); 
*  task automatic CheckKIsValueMFetch(input int MPUPC, input int InstrCycle, input bit[3:0] Mode, input bit[511:0] ExpValue); 
*  task automatic CheckKIValueMFetch(input int MPUPC, input int InstrCycle, input bit[4:0] KIID, input logic[23:0] ExpValue); 
*  task automatic CheckKITotalValueMFetch(input int MPUPC, input int InstrCycle, input bit[511:0] ExpValue); 
*  task automatic rand_stall(int C);
*  task automatic CheckLoopSPU(input int StartSPC, input int EndSPC, input int LpNum);

******************************* SPU *******************************
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
*  task automatic CheckDM0ValueSPUSTARTPC(input int SPUSTARTPC, input int InstrCycle, input int Addr,input logic[511:0] ExpValue);
*  task automatic CheckDM0Value32(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
*  task automatic CheckDM0Value16(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
*  task automatic CheckDM0Value8(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
*  task automatic CheckDM1ValueSPUSTARTPC(input int SPUSTARTPC, input int InstrCycle, input int Addr,input logic[511:0] ExpValue);
*  task automatic CheckDM1Value32(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
*  task automatic CheckDM1Value16(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
*  task automatic CheckDM1Value8(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
*  task automatic CheckDM2ValueSPUSTARTPC(input int SPUSTARTPC, input int InstrCycle, input int Addr,input logic[511:0] ExpValue);
*  task automatic CheckDM2Value32(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
*  task automatic CheckDM2Value16(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
*  task automatic CheckDM2Value8(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
*  task automatic CheckIMValueWord(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
*  task automatic CheckIMValueShort(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
*  task automatic CheckIMValueByte(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
*  task automatic CheckSVRValue(input int SPUSTARTPC, input int InstrCycle, input bit[1:0] SVRID, input logic[511:0] ExpValue); 
*  task automatic CheckFIFOValue(input int SPUSTARTPC, input int InstrCycle, input bit[1:0] FIFOID, input logic[31:0] ExpValue); 
*  task automatic CheckSEQIntEn(int SPUSTARTPC, input int InstrCycle, input logic ExpValue); 
*  task automatic CheckCallM(input int SPUSTARTPC, input int CallEn, input int CallAddr);
*  task automatic CheckMCValueSPUSTARTPC(input int SPUSTARTPC, input int InstrCycle, input bit[4:0] MCID, input logic[23:0] ExpValue); 
*/

`define SPU_STARTDC_PC  $root.TestTop.uAPE.uSPU.uFetch.rDispatchPC
`define SPU_STARTEX0_PC $root.TestTop.uAPE.uSPU.uFetch.rRRPC
`define MPU_DC_PC       $root.TestTop.uAPE.uMPU.uMFetch.rOrderMicroCode[470:456]
`define MPU_STARTDC_PC  $root.TestTop.uAPE.uMPU.uMFetch.rOrderMicroCodeAddr
`define MFetchValid     $root.TestTop.uAPE.uMPU.uMFetch.nCurrentMicroValid
`define MPUStall        $root.TestTop.uAPE.uMPU.uSHU0.nEUStallEn
`define DPStall         $root.TestTop.uAPE.uSPU.uDecode.oDPStall
`define ExeStall        $root.TestTop.uAPE.uSPU.uSPUPipeCtrl.oExeStall
`define IntStall        $root.TestTop.uAPE.uSPU.uSPUPipeCtrl.oIntStall
`define SYNStall        $root.TestTop.uAPE.uSPU.uSYN.oSYNStall
`define CALLEN          $root.TestTop.uAPE.uSPU.uSYN.oWrCallMAddrEn
`define CALL_ADDR       $root.TestTop.uAPE.uSPU.uSYN.oWrCallMAddrValue
`ifndef FPGA
`define DM0_BYTE(Num)   $root.TestTop.uAPE.uDM0.ByteRam[Num].RAM.uRamUnit.uut.mem_core_array
`define DM1_BYTE(Num)   $root.TestTop.uAPE.uDM1.ByteRam[Num].RAM.uRamUnit.uut.mem_core_array
`define DM2_BYTE(Num)   $root.TestTop.uAPE.uDM2.ByteRam[Num].RAM.uRamUnit.uut.mem_core_array
`define DM3_BYTE(Num)   $root.TestTop.uAPE.uDM3.ByteRam[Num].RAM.uRamUnit.uut.mem_core_array
`else
`define DM0_BYTE(Num)   $root.TestTop.uAPE.uDM0.ByteRam[Num].RAM.uRamUnit.memory
`define DM1_BYTE(Num)   $root.TestTop.uAPE.uDM1.ByteRam[Num].RAM.uRamUnit.memory
`define DM2_BYTE(Num)   $root.TestTop.uAPE.uDM2.ByteRam[Num].RAM.uRamUnit.memory
`define DM3_BYTE(Num)   $root.TestTop.uAPE.uDM3.ByteRam[Num].RAM.uRamUnit.memory
`endif

`define SCUInstr        $root.TestTop.uAPE.uSPU.uDecode.oSCUInstr
`define AGUInstr        $root.TestTop.uAPE.uSPU.uDecode.oAGUInstr
`define SYNInstr        $root.TestTop.uAPE.uSPU.uDecode.oSYNInstr
`define SEQInstr        $root.TestTop.uAPE.uSPU.uDecode.oSEQSendInstr
`define SEQCond         $root.TestTop.uAPE.uSPU.uDecode.oSEQCond
`define DecodeCClk     $root.TestTop.uAPE.uSPU.uDecode.CClk

`define TIME_OUT_CYCLE        100000
`define MPU_DELAY_CYCLE       4
`define SPU_DELAY_CYCLE       1

   task automatic CheckWFIFOValue(input int MPUPC, input int InstrCycle, input bit[1:0] FIFOID, input logic[31:0] ExpValue); 
      logic[31:0]   FIFOValue;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end

      WaitMPUCycles(InstrCycle); 
      
      FIFOValue = $root.TestTop.uAPE.uMPU.uMFetch.WFIFO[FIFOID];
      if(FIFOValue === ExpValue)
         $display("%0t Read FIFO[%0d] OK @MPUPC = %h!!", $realtime, FIFOID, MPUPC);
      else   
         begin
            $display("%0t Error @MPUPC = %h, Expected Value and Real Result are : %h, %h\n", $realtime, MPUPC, ExpValue, FIFOValue);
            $display(" ");
         end
   endtask

   task automatic CheckRFIFOValue(input int SPUPC, input int InstrCycle, input bit[1:0] FIFOID, input logic[31:0] ExpValue); 
      logic[31:0]   FIFOValue;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUPC && !`ExeStall)
            break;
      end
     // WaitSPUWrFIFOEnCycles();
      WaitSPUCycles(InstrCycle); 
      `TD
      FIFOValue = $root.TestTop.uAPE.uMPU.uMFetch.RFIFO[FIFOID];
      if(FIFOValue === ExpValue)
         $display("%0t Read FIFO[%0d] OK @SPU_STARTEX0_PC = %h!!", $realtime, FIFOID, SPUPC);
      else   
         begin
            $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are : %h, %h\n", $realtime, SPUPC, ExpValue, FIFOValue);
            $display(" ");
         end
   endtask

   task automatic CheckDM0Disc(input int MPUPC, input int InstrCycle, input int AddrBase, input[511:0] AddrBais, input bit[511:0] ExpValue);
       bit [511:0]    DMValue;
       bit [11:0]     DepthIndex,IndexBase,IndexBais;
       bit [5:0]      ByteIndex;

       IndexBase=AddrBase[17:6];

       while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
       end
 	   WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);

       for(int i=0; i<64; i++) begin
           ByteIndex  = i;
           IndexBais  = {4'h0,AddrBais[i*8+:8]};
           DepthIndex = IndexBase|IndexBais;

           case(ByteIndex)
               6'h00: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h00)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h00)[DepthIndex[11:1]][7:0];
               6'h01: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h01)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h01)[DepthIndex[11:1]][7:0];
               6'h02: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h02)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h02)[DepthIndex[11:1]][7:0];
               6'h03: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h03)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h03)[DepthIndex[11:1]][7:0];
               6'h04: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h04)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h04)[DepthIndex[11:1]][7:0];
               6'h05: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h05)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h05)[DepthIndex[11:1]][7:0];
               6'h06: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h06)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h06)[DepthIndex[11:1]][7:0];
               6'h07: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h07)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h07)[DepthIndex[11:1]][7:0];
               6'h08: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h08)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h08)[DepthIndex[11:1]][7:0];
               6'h09: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h09)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h09)[DepthIndex[11:1]][7:0];
               6'h0a: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h0a)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h0a)[DepthIndex[11:1]][7:0];
               6'h0b: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h0b)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h0b)[DepthIndex[11:1]][7:0];
               6'h0c: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h0c)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h0c)[DepthIndex[11:1]][7:0];
               6'h0d: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h0d)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h0d)[DepthIndex[11:1]][7:0];
               6'h0e: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h0e)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h0e)[DepthIndex[11:1]][7:0];
               6'h0f: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h0f)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h0f)[DepthIndex[11:1]][7:0];
               6'h10: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h10)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h10)[DepthIndex[11:1]][7:0];
               6'h11: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h11)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h11)[DepthIndex[11:1]][7:0];
               6'h12: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h12)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h12)[DepthIndex[11:1]][7:0];
               6'h13: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h13)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h13)[DepthIndex[11:1]][7:0];
               6'h14: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h14)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h14)[DepthIndex[11:1]][7:0];
               6'h15: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h15)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h15)[DepthIndex[11:1]][7:0];
               6'h16: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h16)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h16)[DepthIndex[11:1]][7:0];
               6'h17: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h17)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h17)[DepthIndex[11:1]][7:0];
               6'h18: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h18)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h18)[DepthIndex[11:1]][7:0];
               6'h19: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h19)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h19)[DepthIndex[11:1]][7:0];
               6'h1a: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h1a)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h1a)[DepthIndex[11:1]][7:0];
               6'h1b: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h1b)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h1b)[DepthIndex[11:1]][7:0];
               6'h1c: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h1c)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h1c)[DepthIndex[11:1]][7:0];
               6'h1d: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h1d)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h1d)[DepthIndex[11:1]][7:0];
               6'h1e: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h1e)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h1e)[DepthIndex[11:1]][7:0];
               6'h1f: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h1f)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h1f)[DepthIndex[11:1]][7:0];
               6'h20: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h20)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h20)[DepthIndex[11:1]][7:0];
               6'h21: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h21)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h21)[DepthIndex[11:1]][7:0];
               6'h22: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h22)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h22)[DepthIndex[11:1]][7:0];
               6'h23: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h23)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h23)[DepthIndex[11:1]][7:0];
               6'h24: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h24)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h24)[DepthIndex[11:1]][7:0];
               6'h25: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h25)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h25)[DepthIndex[11:1]][7:0];
               6'h26: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h26)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h26)[DepthIndex[11:1]][7:0];
               6'h27: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h27)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h27)[DepthIndex[11:1]][7:0];
               6'h28: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h28)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h28)[DepthIndex[11:1]][7:0];
               6'h29: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h29)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h29)[DepthIndex[11:1]][7:0];
               6'h2a: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h2a)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h2a)[DepthIndex[11:1]][7:0];
               6'h2b: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h2b)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h2b)[DepthIndex[11:1]][7:0];
               6'h2c: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h2c)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h2c)[DepthIndex[11:1]][7:0];
               6'h2d: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h2d)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h2d)[DepthIndex[11:1]][7:0];
               6'h2e: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h2e)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h2e)[DepthIndex[11:1]][7:0];
               6'h2f: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h2f)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h2f)[DepthIndex[11:1]][7:0];
               6'h30: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h30)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h30)[DepthIndex[11:1]][7:0];
               6'h31: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h31)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h31)[DepthIndex[11:1]][7:0];
               6'h32: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h32)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h32)[DepthIndex[11:1]][7:0];
               6'h33: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h33)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h33)[DepthIndex[11:1]][7:0];
               6'h34: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h34)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h34)[DepthIndex[11:1]][7:0];
               6'h35: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h35)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h35)[DepthIndex[11:1]][7:0];
               6'h36: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h36)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h36)[DepthIndex[11:1]][7:0];
               6'h37: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h37)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h37)[DepthIndex[11:1]][7:0];
               6'h38: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h38)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h38)[DepthIndex[11:1]][7:0];
               6'h39: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h39)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h39)[DepthIndex[11:1]][7:0];
               6'h3a: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h3a)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h3a)[DepthIndex[11:1]][7:0];
               6'h3b: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h3b)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h3b)[DepthIndex[11:1]][7:0];
               6'h3c: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h3c)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h3c)[DepthIndex[11:1]][7:0];
               6'h3d: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h3d)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h3d)[DepthIndex[11:1]][7:0];
               6'h3e: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h3e)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h3e)[DepthIndex[11:1]][7:0];
               6'h3f: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h3f)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h3f)[DepthIndex[11:1]][7:0];
           endcase
       end

       if(DMValue == ExpValue) 
           $display("%0t Read DM0 OK @MPU_DC_PC = %h!!", $time, MPUPC);
       else begin 
           $display("%0t Error @MPUDP_PC = %h, Expected Value and Real Result of DM0 are :", $time, MPUPC);
           Mon.display_512(ExpValue);
           Mon.display_512(DMValue);
           $display(" ");
       end
   endtask

   task automatic CheckDM1Disc(input int MPUPC, input int InstrCycle, input int AddrBase, input[511:0] AddrBais, input bit[511:0] ExpValue);
       bit [511:0]    DMValue;
       bit [11:0]     DepthIndex,IndexBase,IndexBais;
       bit [5:0]      ByteIndex;

       IndexBase=AddrBase[17:6];

       while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
       end
 	   WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);

       for(int i=0; i<64; i++) begin
           ByteIndex  = i;
           IndexBais  = {4'h0,AddrBais[i*8+:8]};
           DepthIndex = IndexBase|IndexBais;

           case(ByteIndex)
               6'h00: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h00)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h00)[DepthIndex[11:1]][7:0];
               6'h01: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h01)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h01)[DepthIndex[11:1]][7:0];
               6'h02: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h02)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h02)[DepthIndex[11:1]][7:0];
               6'h03: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h03)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h03)[DepthIndex[11:1]][7:0];
               6'h04: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h04)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h04)[DepthIndex[11:1]][7:0];
               6'h05: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h05)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h05)[DepthIndex[11:1]][7:0];
               6'h06: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h06)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h06)[DepthIndex[11:1]][7:0];
               6'h07: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h07)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h07)[DepthIndex[11:1]][7:0];
               6'h08: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h08)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h08)[DepthIndex[11:1]][7:0];
               6'h09: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h09)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h09)[DepthIndex[11:1]][7:0];
               6'h0a: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h0a)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h0a)[DepthIndex[11:1]][7:0];
               6'h0b: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h0b)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h0b)[DepthIndex[11:1]][7:0];
               6'h0c: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h0c)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h0c)[DepthIndex[11:1]][7:0];
               6'h0d: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h0d)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h0d)[DepthIndex[11:1]][7:0];
               6'h0e: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h0e)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h0e)[DepthIndex[11:1]][7:0];
               6'h0f: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h0f)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h0f)[DepthIndex[11:1]][7:0];
               6'h10: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h10)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h10)[DepthIndex[11:1]][7:0];
               6'h11: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h11)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h11)[DepthIndex[11:1]][7:0];
               6'h12: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h12)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h12)[DepthIndex[11:1]][7:0];
               6'h13: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h13)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h13)[DepthIndex[11:1]][7:0];
               6'h14: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h14)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h14)[DepthIndex[11:1]][7:0];
               6'h15: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h15)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h15)[DepthIndex[11:1]][7:0];
               6'h16: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h16)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h16)[DepthIndex[11:1]][7:0];
               6'h17: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h17)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h17)[DepthIndex[11:1]][7:0];
               6'h18: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h18)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h18)[DepthIndex[11:1]][7:0];
               6'h19: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h19)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h19)[DepthIndex[11:1]][7:0];
               6'h1a: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h1a)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h1a)[DepthIndex[11:1]][7:0];
               6'h1b: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h1b)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h1b)[DepthIndex[11:1]][7:0];
               6'h1c: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h1c)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h1c)[DepthIndex[11:1]][7:0];
               6'h1d: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h1d)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h1d)[DepthIndex[11:1]][7:0];
               6'h1e: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h1e)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h1e)[DepthIndex[11:1]][7:0];
               6'h1f: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h1f)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h1f)[DepthIndex[11:1]][7:0];
               6'h20: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h20)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h20)[DepthIndex[11:1]][7:0];
               6'h21: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h21)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h21)[DepthIndex[11:1]][7:0];
               6'h22: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h22)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h22)[DepthIndex[11:1]][7:0];
               6'h23: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h23)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h23)[DepthIndex[11:1]][7:0];
               6'h24: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h24)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h24)[DepthIndex[11:1]][7:0];
               6'h25: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h25)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h25)[DepthIndex[11:1]][7:0];
               6'h26: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h26)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h26)[DepthIndex[11:1]][7:0];
               6'h27: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h27)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h27)[DepthIndex[11:1]][7:0];
               6'h28: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h28)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h28)[DepthIndex[11:1]][7:0];
               6'h29: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h29)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h29)[DepthIndex[11:1]][7:0];
               6'h2a: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h2a)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h2a)[DepthIndex[11:1]][7:0];
               6'h2b: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h2b)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h2b)[DepthIndex[11:1]][7:0];
               6'h2c: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h2c)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h2c)[DepthIndex[11:1]][7:0];
               6'h2d: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h2d)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h2d)[DepthIndex[11:1]][7:0];
               6'h2e: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h2e)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h2e)[DepthIndex[11:1]][7:0];
               6'h2f: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h2f)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h2f)[DepthIndex[11:1]][7:0];
               6'h30: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h30)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h30)[DepthIndex[11:1]][7:0];
               6'h31: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h31)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h31)[DepthIndex[11:1]][7:0];
               6'h32: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h32)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h32)[DepthIndex[11:1]][7:0];
               6'h33: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h33)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h33)[DepthIndex[11:1]][7:0];
               6'h34: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h34)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h34)[DepthIndex[11:1]][7:0];
               6'h35: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h35)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h35)[DepthIndex[11:1]][7:0];
               6'h36: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h36)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h36)[DepthIndex[11:1]][7:0];
               6'h37: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h37)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h37)[DepthIndex[11:1]][7:0];
               6'h38: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h38)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h38)[DepthIndex[11:1]][7:0];
               6'h39: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h39)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h39)[DepthIndex[11:1]][7:0];
               6'h3a: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h3a)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h3a)[DepthIndex[11:1]][7:0];
               6'h3b: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h3b)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h3b)[DepthIndex[11:1]][7:0];
               6'h3c: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h3c)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h3c)[DepthIndex[11:1]][7:0];
               6'h3d: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h3d)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h3d)[DepthIndex[11:1]][7:0];
               6'h3e: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h3e)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h3e)[DepthIndex[11:1]][7:0];
               6'h3f: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h3f)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h3f)[DepthIndex[11:1]][7:0];
           endcase
       end

       if(DMValue == ExpValue) 
           $display("%0t Read DM1 OK @MPU_DC_PC = %h!!", $time, MPUPC);
       else begin 
           $display("%0t Error @MPUDP_PC = %h, Expected Value and Real Result of DM1 are :", $time, MPUPC);
           Mon.display_512(ExpValue);
           Mon.display_512(DMValue);
           $display(" ");
       end
   endtask

   task automatic CheckDM2Disc(input int MPUPC, input int InstrCycle, input int AddrBase, input[511:0] AddrBais, input bit[511:0] ExpValue);
       bit [511:0]    DMValue;
       bit [10:0]     DepthIndex,IndexBase,IndexBais;
       bit [6:0]      ByteIndex;

       IndexBase  = AddrBase[16:6];
       ByteIndex  = 0;

       while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
       end
 	   WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);

       for(int i=0; i<64; i=i+2) begin
           
           IndexBais  = {4'h0,AddrBais[i*8+:8]};
           DepthIndex = IndexBase|IndexBais;

           case(ByteIndex)
               6'h00: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h00)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h00)[DepthIndex[10:0]][15:8];
               end
               6'h01: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h01)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h01)[DepthIndex[10:0]][15:8];
               end
               6'h02: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h02)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h02)[DepthIndex[10:0]][15:8];
               end
               6'h03: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h03)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h03)[DepthIndex[10:0]][15:8];
               end
               6'h04: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h04)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h04)[DepthIndex[10:0]][15:8];
               end
               6'h05: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h05)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h05)[DepthIndex[10:0]][15:8];
               end
               6'h06: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h06)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h06)[DepthIndex[10:0]][15:8];
               end
               6'h07: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h07)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h07)[DepthIndex[10:0]][15:8];
               end
               6'h08: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h08)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h08)[DepthIndex[10:0]][15:8];
               end
               6'h09: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h09)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h09)[DepthIndex[10:0]][15:8];
               end
               6'h0a: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h0a)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h0a)[DepthIndex[10:0]][15:8];
               end
               6'h0b: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h0b)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h0b)[DepthIndex[10:0]][15:8];
               end
               6'h0c: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h0c)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h0c)[DepthIndex[10:0]][15:8];
               end
               6'h0d: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h0d)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h0d)[DepthIndex[10:0]][15:8];
               end
               6'h0e: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h0e)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h0e)[DepthIndex[10:0]][15:8];
               end
               6'h0f: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h0f)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h0f)[DepthIndex[10:0]][15:8];
               end
               6'h10: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h10)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h10)[DepthIndex[10:0]][15:8];
               end
               6'h11: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h11)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h11)[DepthIndex[10:0]][15:8];
               end
               6'h12: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h12)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h12)[DepthIndex[10:0]][15:8];
               end
               6'h13: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h13)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h13)[DepthIndex[10:0]][15:8];
               end
               6'h14: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h14)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h14)[DepthIndex[10:0]][15:8];
               end
               6'h15: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h15)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h15)[DepthIndex[10:0]][15:8];
               end
               6'h16: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h16)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h16)[DepthIndex[10:0]][15:8];
               end
               6'h17: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h17)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h17)[DepthIndex[10:0]][15:8];
               end
               6'h18: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h18)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h18)[DepthIndex[10:0]][15:8];
               end
               6'h19: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h19)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h19)[DepthIndex[10:0]][15:8];
               end
               6'h1a: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h1a)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h1a)[DepthIndex[10:0]][15:8];
               end
               6'h1b: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h1b)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h1b)[DepthIndex[10:0]][15:8];
               end
               6'h1c: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h1c)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h1c)[DepthIndex[10:0]][15:8];
               end
               6'h1d: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h1d)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h1d)[DepthIndex[10:0]][15:8];
               end
               6'h1e: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h1e)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h1e)[DepthIndex[10:0]][15:8];
               end
               6'h1f: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h1f)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h1f)[DepthIndex[10:0]][15:8];
               end
           endcase
           ByteIndex=ByteIndex+1;
       end

       if(DMValue == ExpValue) 
           $display("%0t Read DM2 OK @MPU_DC_PC = %h!!", $time, MPUPC);
       else begin 
           $display("%0t Error @MPUDP_PC = %h, Expected Value and Real Result of DM2 are :", $time, MPUPC);
           Mon.display_512(ExpValue);
           Mon.display_512(DMValue);
           $display(" ");
       end
   endtask

   task automatic CheckDM3Disc(input int MPUPC, input int InstrCycle, input int AddrBase, input[511:0] AddrBais, input bit[511:0] ExpValue);
       bit [511:0]    DMValue;
       bit [10:0]     DepthIndex,IndexBase,IndexBais;
       bit [5:0]      ByteIndex;

       IndexBase=AddrBase[16:6];

       while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
       end
 	   WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);

       for(int i=0; i<64; i=i+2) begin
           IndexBais  = {4'h0,AddrBais[i*8+:8]};
           DepthIndex = IndexBase|IndexBais;

           case(ByteIndex)
               6'h00: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h00)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h00)[DepthIndex[10:0]][15:8];
               end
               6'h01: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h01)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h01)[DepthIndex[10:0]][15:8];
               end
               6'h02: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h02)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h02)[DepthIndex[10:0]][15:8];
               end
               6'h03: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h03)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h03)[DepthIndex[10:0]][15:8];
               end
               6'h04: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h04)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h04)[DepthIndex[10:0]][15:8];
               end
               6'h05: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h05)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h05)[DepthIndex[10:0]][15:8];
               end
               6'h06: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h06)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h06)[DepthIndex[10:0]][15:8];
               end
               6'h07: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h07)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h07)[DepthIndex[10:0]][15:8];
               end
               6'h08: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h08)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h08)[DepthIndex[10:0]][15:8];
               end
               6'h09: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h09)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h09)[DepthIndex[10:0]][15:8];
               end
               6'h0a: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h0a)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h0a)[DepthIndex[10:0]][15:8];
               end
               6'h0b: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h0b)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h0b)[DepthIndex[10:0]][15:8];
               end
               6'h0c: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h0c)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h0c)[DepthIndex[10:0]][15:8];
               end
               6'h0d: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h0d)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h0d)[DepthIndex[10:0]][15:8];
               end
               6'h0e: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h0e)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h0e)[DepthIndex[10:0]][15:8];
               end
               6'h0f: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h0f)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h0f)[DepthIndex[10:0]][15:8];
               end
               6'h10: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h10)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h10)[DepthIndex[10:0]][15:8];
               end
               6'h11: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h11)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h11)[DepthIndex[10:0]][15:8];
               end
               6'h12: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h12)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h12)[DepthIndex[10:0]][15:8];
               end
               6'h13: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h13)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h13)[DepthIndex[10:0]][15:8];
               end
               6'h14: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h14)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h14)[DepthIndex[10:0]][15:8];
               end
               6'h15: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h15)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h15)[DepthIndex[10:0]][15:8];
               end
               6'h16: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h16)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h16)[DepthIndex[10:0]][15:8];
               end
               6'h17: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h17)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h17)[DepthIndex[10:0]][15:8];
               end
               6'h18: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h18)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h18)[DepthIndex[10:0]][15:8];
               end
               6'h19: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h19)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h19)[DepthIndex[10:0]][15:8];
               end
               6'h1a: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h1a)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h1a)[DepthIndex[10:0]][15:8];
               end
               6'h1b: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h1b)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h1b)[DepthIndex[10:0]][15:8];
               end
               6'h1c: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h1c)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h1c)[DepthIndex[10:0]][15:8];
               end
               6'h1d: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h1d)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h1d)[DepthIndex[10:0]][15:8];
               end
               6'h1e: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h1e)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h1e)[DepthIndex[10:0]][15:8];
               end
               6'h1f: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h1f)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h1f)[DepthIndex[10:0]][15:8];
               end
           endcase
           ByteIndex=ByteIndex+1;
       end

       if(DMValue == ExpValue) 
           $display("%0t Read DM3 OK @MPU_DC_PC = %h!!", $time, MPUPC);
       else begin 
           $display("%0t Error @MPUDP_PC = %h, Expected Value and Real Result of DM3 are :", $time, MPUPC);
           Mon.display_512(ExpValue);
           Mon.display_512(DMValue);
           $display(" ");
       end
   endtask

   task automatic CheckDM0Disc2(input int MPUPC, input int InstrCycle, input int AddrBase, input[511:0] AddrBaisL, input[511:0] AddrBaisH, input bit[511:0] ExpValue);
       bit [511:0]    DMValue;
       bit [11:0]     DepthIndex,IndexBase,IndexBaisL,IndexBaisH;
       bit [5:0]      ByteIndex;

       IndexBase=AddrBase[17:6];

       while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
       end
 	   WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);

       for(int i=0; i<64; i++) begin
           ByteIndex   = i;
           IndexBaisL  = {4'h0,AddrBaisL[i*8+:8]};
           IndexBaisH  = {AddrBaisH[i*8+:4],8'h0};
           DepthIndex  = IndexBase|IndexBaisL|IndexBaisH;

           case(ByteIndex)
               6'h00: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h00)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h00)[DepthIndex[11:1]][7:0];
               6'h01: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h01)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h01)[DepthIndex[11:1]][7:0];
               6'h02: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h02)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h02)[DepthIndex[11:1]][7:0];
               6'h03: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h03)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h03)[DepthIndex[11:1]][7:0];
               6'h04: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h04)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h04)[DepthIndex[11:1]][7:0];
               6'h05: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h05)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h05)[DepthIndex[11:1]][7:0];
               6'h06: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h06)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h06)[DepthIndex[11:1]][7:0];
               6'h07: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h07)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h07)[DepthIndex[11:1]][7:0];
               6'h08: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h08)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h08)[DepthIndex[11:1]][7:0];
               6'h09: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h09)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h09)[DepthIndex[11:1]][7:0];
               6'h0a: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h0a)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h0a)[DepthIndex[11:1]][7:0];
               6'h0b: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h0b)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h0b)[DepthIndex[11:1]][7:0];
               6'h0c: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h0c)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h0c)[DepthIndex[11:1]][7:0];
               6'h0d: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h0d)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h0d)[DepthIndex[11:1]][7:0];
               6'h0e: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h0e)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h0e)[DepthIndex[11:1]][7:0];
               6'h0f: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h0f)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h0f)[DepthIndex[11:1]][7:0];
               6'h10: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h10)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h10)[DepthIndex[11:1]][7:0];
               6'h11: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h11)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h11)[DepthIndex[11:1]][7:0];
               6'h12: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h12)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h12)[DepthIndex[11:1]][7:0];
               6'h13: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h13)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h13)[DepthIndex[11:1]][7:0];
               6'h14: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h14)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h14)[DepthIndex[11:1]][7:0];
               6'h15: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h15)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h15)[DepthIndex[11:1]][7:0];
               6'h16: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h16)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h16)[DepthIndex[11:1]][7:0];
               6'h17: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h17)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h17)[DepthIndex[11:1]][7:0];
               6'h18: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h18)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h18)[DepthIndex[11:1]][7:0];
               6'h19: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h19)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h19)[DepthIndex[11:1]][7:0];
               6'h1a: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h1a)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h1a)[DepthIndex[11:1]][7:0];
               6'h1b: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h1b)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h1b)[DepthIndex[11:1]][7:0];
               6'h1c: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h1c)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h1c)[DepthIndex[11:1]][7:0];
               6'h1d: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h1d)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h1d)[DepthIndex[11:1]][7:0];
               6'h1e: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h1e)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h1e)[DepthIndex[11:1]][7:0];
               6'h1f: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h1f)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h1f)[DepthIndex[11:1]][7:0];
               6'h20: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h20)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h20)[DepthIndex[11:1]][7:0];
               6'h21: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h21)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h21)[DepthIndex[11:1]][7:0];
               6'h22: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h22)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h22)[DepthIndex[11:1]][7:0];
               6'h23: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h23)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h23)[DepthIndex[11:1]][7:0];
               6'h24: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h24)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h24)[DepthIndex[11:1]][7:0];
               6'h25: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h25)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h25)[DepthIndex[11:1]][7:0];
               6'h26: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h26)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h26)[DepthIndex[11:1]][7:0];
               6'h27: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h27)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h27)[DepthIndex[11:1]][7:0];
               6'h28: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h28)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h28)[DepthIndex[11:1]][7:0];
               6'h29: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h29)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h29)[DepthIndex[11:1]][7:0];
               6'h2a: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h2a)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h2a)[DepthIndex[11:1]][7:0];
               6'h2b: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h2b)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h2b)[DepthIndex[11:1]][7:0];
               6'h2c: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h2c)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h2c)[DepthIndex[11:1]][7:0];
               6'h2d: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h2d)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h2d)[DepthIndex[11:1]][7:0];
               6'h2e: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h2e)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h2e)[DepthIndex[11:1]][7:0];
               6'h2f: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h2f)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h2f)[DepthIndex[11:1]][7:0];
               6'h30: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h30)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h30)[DepthIndex[11:1]][7:0];
               6'h31: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h31)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h31)[DepthIndex[11:1]][7:0];
               6'h32: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h32)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h32)[DepthIndex[11:1]][7:0];
               6'h33: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h33)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h33)[DepthIndex[11:1]][7:0];
               6'h34: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h34)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h34)[DepthIndex[11:1]][7:0];
               6'h35: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h35)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h35)[DepthIndex[11:1]][7:0];
               6'h36: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h36)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h36)[DepthIndex[11:1]][7:0];
               6'h37: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h37)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h37)[DepthIndex[11:1]][7:0];
               6'h38: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h38)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h38)[DepthIndex[11:1]][7:0];
               6'h39: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h39)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h39)[DepthIndex[11:1]][7:0];
               6'h3a: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h3a)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h3a)[DepthIndex[11:1]][7:0];
               6'h3b: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h3b)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h3b)[DepthIndex[11:1]][7:0];
               6'h3c: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h3c)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h3c)[DepthIndex[11:1]][7:0];
               6'h3d: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h3d)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h3d)[DepthIndex[11:1]][7:0];
               6'h3e: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h3e)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h3e)[DepthIndex[11:1]][7:0];
               6'h3f: DMValue[i*8+:8] = DepthIndex[0] ? `DM0_BYTE(6'h3f)[DepthIndex[11:1]][15:8] : `DM0_BYTE(6'h3f)[DepthIndex[11:1]][7:0];
           endcase
       end

       if(DMValue == ExpValue) 
           $display("%0t Read DM0 OK @MPU_DC_PC = %h!!", $time, MPUPC);
       else begin 
           $display("%0t Error @MPUDP_PC = %h, Expected Value and Real Result of DM0 are :", $time, MPUPC);
           Mon.display_512(ExpValue);
           Mon.display_512(DMValue);
           $display(" ");
       end
   endtask

   task automatic CheckDM1Disc2(input int MPUPC, input int InstrCycle, input int AddrBase, input[511:0] AddrBaisL, input[511:0] AddrBaisH, input bit[511:0] ExpValue);
       bit [511:0]    DMValue;
       bit [11:0]     DepthIndex,IndexBase,IndexBaisL,IndexBaisH;
       bit [5:0]      ByteIndex;

       IndexBase=AddrBase[17:6];

       while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
       end
 	   WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);

       for(int i=0; i<64; i++) begin
           ByteIndex  = i;
           IndexBaisL  = {4'h0,AddrBaisL[i*8+:8]};
           IndexBaisH  = {AddrBaisH[i*8+:4],8'h0};
           DepthIndex  = IndexBase|IndexBaisL|IndexBaisH;

           case(ByteIndex)
               6'h00: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h00)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h00)[DepthIndex[11:1]][7:0];
               6'h01: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h01)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h01)[DepthIndex[11:1]][7:0];
               6'h02: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h02)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h02)[DepthIndex[11:1]][7:0];
               6'h03: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h03)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h03)[DepthIndex[11:1]][7:0];
               6'h04: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h04)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h04)[DepthIndex[11:1]][7:0];
               6'h05: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h05)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h05)[DepthIndex[11:1]][7:0];
               6'h06: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h06)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h06)[DepthIndex[11:1]][7:0];
               6'h07: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h07)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h07)[DepthIndex[11:1]][7:0];
               6'h08: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h08)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h08)[DepthIndex[11:1]][7:0];
               6'h09: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h09)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h09)[DepthIndex[11:1]][7:0];
               6'h0a: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h0a)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h0a)[DepthIndex[11:1]][7:0];
               6'h0b: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h0b)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h0b)[DepthIndex[11:1]][7:0];
               6'h0c: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h0c)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h0c)[DepthIndex[11:1]][7:0];
               6'h0d: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h0d)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h0d)[DepthIndex[11:1]][7:0];
               6'h0e: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h0e)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h0e)[DepthIndex[11:1]][7:0];
               6'h0f: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h0f)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h0f)[DepthIndex[11:1]][7:0];
               6'h10: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h10)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h10)[DepthIndex[11:1]][7:0];
               6'h11: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h11)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h11)[DepthIndex[11:1]][7:0];
               6'h12: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h12)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h12)[DepthIndex[11:1]][7:0];
               6'h13: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h13)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h13)[DepthIndex[11:1]][7:0];
               6'h14: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h14)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h14)[DepthIndex[11:1]][7:0];
               6'h15: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h15)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h15)[DepthIndex[11:1]][7:0];
               6'h16: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h16)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h16)[DepthIndex[11:1]][7:0];
               6'h17: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h17)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h17)[DepthIndex[11:1]][7:0];
               6'h18: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h18)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h18)[DepthIndex[11:1]][7:0];
               6'h19: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h19)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h19)[DepthIndex[11:1]][7:0];
               6'h1a: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h1a)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h1a)[DepthIndex[11:1]][7:0];
               6'h1b: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h1b)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h1b)[DepthIndex[11:1]][7:0];
               6'h1c: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h1c)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h1c)[DepthIndex[11:1]][7:0];
               6'h1d: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h1d)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h1d)[DepthIndex[11:1]][7:0];
               6'h1e: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h1e)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h1e)[DepthIndex[11:1]][7:0];
               6'h1f: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h1f)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h1f)[DepthIndex[11:1]][7:0];
               6'h20: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h20)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h20)[DepthIndex[11:1]][7:0];
               6'h21: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h21)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h21)[DepthIndex[11:1]][7:0];
               6'h22: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h22)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h22)[DepthIndex[11:1]][7:0];
               6'h23: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h23)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h23)[DepthIndex[11:1]][7:0];
               6'h24: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h24)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h24)[DepthIndex[11:1]][7:0];
               6'h25: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h25)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h25)[DepthIndex[11:1]][7:0];
               6'h26: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h26)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h26)[DepthIndex[11:1]][7:0];
               6'h27: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h27)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h27)[DepthIndex[11:1]][7:0];
               6'h28: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h28)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h28)[DepthIndex[11:1]][7:0];
               6'h29: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h29)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h29)[DepthIndex[11:1]][7:0];
               6'h2a: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h2a)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h2a)[DepthIndex[11:1]][7:0];
               6'h2b: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h2b)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h2b)[DepthIndex[11:1]][7:0];
               6'h2c: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h2c)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h2c)[DepthIndex[11:1]][7:0];
               6'h2d: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h2d)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h2d)[DepthIndex[11:1]][7:0];
               6'h2e: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h2e)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h2e)[DepthIndex[11:1]][7:0];
               6'h2f: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h2f)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h2f)[DepthIndex[11:1]][7:0];
               6'h30: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h30)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h30)[DepthIndex[11:1]][7:0];
               6'h31: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h31)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h31)[DepthIndex[11:1]][7:0];
               6'h32: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h32)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h32)[DepthIndex[11:1]][7:0];
               6'h33: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h33)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h33)[DepthIndex[11:1]][7:0];
               6'h34: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h34)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h34)[DepthIndex[11:1]][7:0];
               6'h35: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h35)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h35)[DepthIndex[11:1]][7:0];
               6'h36: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h36)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h36)[DepthIndex[11:1]][7:0];
               6'h37: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h37)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h37)[DepthIndex[11:1]][7:0];
               6'h38: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h38)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h38)[DepthIndex[11:1]][7:0];
               6'h39: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h39)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h39)[DepthIndex[11:1]][7:0];
               6'h3a: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h3a)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h3a)[DepthIndex[11:1]][7:0];
               6'h3b: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h3b)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h3b)[DepthIndex[11:1]][7:0];
               6'h3c: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h3c)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h3c)[DepthIndex[11:1]][7:0];
               6'h3d: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h3d)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h3d)[DepthIndex[11:1]][7:0];
               6'h3e: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h3e)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h3e)[DepthIndex[11:1]][7:0];
               6'h3f: DMValue[i*8+:8] = DepthIndex[0] ? `DM1_BYTE(6'h3f)[DepthIndex[11:1]][15:8] : `DM1_BYTE(6'h3f)[DepthIndex[11:1]][7:0];
           endcase
       end

       if(DMValue == ExpValue) 
           $display("%0t Read DM1 OK @MPU_DC_PC = %h!!", $time, MPUPC);
       else begin 
           $display("%0t Error @MPUDP_PC = %h, Expected Value and Real Result of DM1 are :", $time, MPUPC);
           Mon.display_512(ExpValue);
           Mon.display_512(DMValue);
           $display(" ");
       end
   endtask

   task automatic CheckDM2Disc2(input int MPUPC, input int InstrCycle, input int AddrBase, input[511:0] AddrBaisL, input[511:0] AddrBaisH, input bit[511:0] ExpValue);
       bit [511:0]    DMValue;
       bit [10:0]     DepthIndex,IndexBase,IndexBaisL,IndexBaisH;
       bit [6:0]      ByteIndex;

       IndexBase  = AddrBase[16:6];
       ByteIndex  = 0;

       while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
       end
 	   WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);

       for(int i=0; i<64; i=i+2) begin
           
           IndexBaisL  = {4'h0,AddrBaisL[i*8+:8]};
           IndexBaisH  = {AddrBaisH[i*8+:3],8'h0};
           DepthIndex  = IndexBase|IndexBaisL|IndexBaisH;

           case(ByteIndex)
               6'h00: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h00)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h00)[DepthIndex[10:0]][15:8];
               end
               6'h01: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h01)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h01)[DepthIndex[10:0]][15:8];
               end
               6'h02: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h02)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h02)[DepthIndex[10:0]][15:8];
               end
               6'h03: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h03)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h03)[DepthIndex[10:0]][15:8];
               end
               6'h04: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h04)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h04)[DepthIndex[10:0]][15:8];
               end
               6'h05: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h05)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h05)[DepthIndex[10:0]][15:8];
               end
               6'h06: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h06)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h06)[DepthIndex[10:0]][15:8];
               end
               6'h07: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h07)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h07)[DepthIndex[10:0]][15:8];
               end
               6'h08: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h08)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h08)[DepthIndex[10:0]][15:8];
               end
               6'h09: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h09)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h09)[DepthIndex[10:0]][15:8];
               end
               6'h0a: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h0a)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h0a)[DepthIndex[10:0]][15:8];
               end
               6'h0b: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h0b)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h0b)[DepthIndex[10:0]][15:8];
               end
               6'h0c: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h0c)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h0c)[DepthIndex[10:0]][15:8];
               end
               6'h0d: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h0d)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h0d)[DepthIndex[10:0]][15:8];
               end
               6'h0e: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h0e)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h0e)[DepthIndex[10:0]][15:8];
               end
               6'h0f: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h0f)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h0f)[DepthIndex[10:0]][15:8];
               end
               6'h10: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h10)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h10)[DepthIndex[10:0]][15:8];
               end
               6'h11: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h11)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h11)[DepthIndex[10:0]][15:8];
               end
               6'h12: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h12)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h12)[DepthIndex[10:0]][15:8];
               end
               6'h13: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h13)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h13)[DepthIndex[10:0]][15:8];
               end
               6'h14: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h14)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h14)[DepthIndex[10:0]][15:8];
               end
               6'h15: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h15)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h15)[DepthIndex[10:0]][15:8];
               end
               6'h16: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h16)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h16)[DepthIndex[10:0]][15:8];
               end
               6'h17: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h17)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h17)[DepthIndex[10:0]][15:8];
               end
               6'h18: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h18)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h18)[DepthIndex[10:0]][15:8];
               end
               6'h19: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h19)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h19)[DepthIndex[10:0]][15:8];
               end
               6'h1a: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h1a)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h1a)[DepthIndex[10:0]][15:8];
               end
               6'h1b: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h1b)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h1b)[DepthIndex[10:0]][15:8];
               end
               6'h1c: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h1c)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h1c)[DepthIndex[10:0]][15:8];
               end
               6'h1d: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h1d)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h1d)[DepthIndex[10:0]][15:8];
               end
               6'h1e: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h1e)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h1e)[DepthIndex[10:0]][15:8];
               end
               6'h1f: begin
                  DMValue[i*8+:8]   = `DM2_BYTE(6'h1f)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM2_BYTE(6'h1f)[DepthIndex[10:0]][15:8];
               end
           endcase
           ByteIndex=ByteIndex+1;
       end

       if(DMValue == ExpValue) 
           $display("%0t Read DM2 OK @MPU_DC_PC = %h!!", $time, MPUPC);
       else begin 
           $display("%0t Error @MPUDP_PC = %h, Expected Value and Real Result of DM2 are :", $time, MPUPC);
           Mon.display_512(ExpValue);
           Mon.display_512(DMValue);
           $display(" ");
       end
   endtask

   task automatic CheckDM3Disc2(input int MPUPC, input int InstrCycle, input int AddrBase, input[511:0] AddrBaisL, input[511:0] AddrBaisH, input bit[511:0] ExpValue);
       bit [511:0]    DMValue;
       bit [10:0]     DepthIndex,IndexBase,IndexBaisL,IndexBaisH;
       bit [5:0]      ByteIndex;

       IndexBase=AddrBase[16:6];

       while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
       end
 	   WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);

       for(int i=0; i<64; i=i+2) begin
           IndexBaisL  = {4'h0,AddrBaisL[i*8+:8]};
           IndexBaisH  = {AddrBaisH[i*8+:3],8'h0};
           DepthIndex  = IndexBase|IndexBaisL|IndexBaisH;

           case(ByteIndex)
               6'h00: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h00)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h00)[DepthIndex[10:0]][15:8];
               end
               6'h01: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h01)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h01)[DepthIndex[10:0]][15:8];
               end
               6'h02: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h02)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h02)[DepthIndex[10:0]][15:8];
               end
               6'h03: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h03)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h03)[DepthIndex[10:0]][15:8];
               end
               6'h04: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h04)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h04)[DepthIndex[10:0]][15:8];
               end
               6'h05: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h05)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h05)[DepthIndex[10:0]][15:8];
               end
               6'h06: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h06)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h06)[DepthIndex[10:0]][15:8];
               end
               6'h07: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h07)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h07)[DepthIndex[10:0]][15:8];
               end
               6'h08: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h08)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h08)[DepthIndex[10:0]][15:8];
               end
               6'h09: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h09)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h09)[DepthIndex[10:0]][15:8];
               end
               6'h0a: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h0a)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h0a)[DepthIndex[10:0]][15:8];
               end
               6'h0b: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h0b)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h0b)[DepthIndex[10:0]][15:8];
               end
               6'h0c: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h0c)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h0c)[DepthIndex[10:0]][15:8];
               end
               6'h0d: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h0d)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h0d)[DepthIndex[10:0]][15:8];
               end
               6'h0e: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h0e)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h0e)[DepthIndex[10:0]][15:8];
               end
               6'h0f: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h0f)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h0f)[DepthIndex[10:0]][15:8];
               end
               6'h10: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h10)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h10)[DepthIndex[10:0]][15:8];
               end
               6'h11: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h11)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h11)[DepthIndex[10:0]][15:8];
               end
               6'h12: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h12)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h12)[DepthIndex[10:0]][15:8];
               end
               6'h13: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h13)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h13)[DepthIndex[10:0]][15:8];
               end
               6'h14: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h14)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h14)[DepthIndex[10:0]][15:8];
               end
               6'h15: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h15)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h15)[DepthIndex[10:0]][15:8];
               end
               6'h16: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h16)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h16)[DepthIndex[10:0]][15:8];
               end
               6'h17: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h17)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h17)[DepthIndex[10:0]][15:8];
               end
               6'h18: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h18)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h18)[DepthIndex[10:0]][15:8];
               end
               6'h19: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h19)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h19)[DepthIndex[10:0]][15:8];
               end
               6'h1a: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h1a)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h1a)[DepthIndex[10:0]][15:8];
               end
               6'h1b: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h1b)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h1b)[DepthIndex[10:0]][15:8];
               end
               6'h1c: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h1c)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h1c)[DepthIndex[10:0]][15:8];
               end
               6'h1d: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h1d)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h1d)[DepthIndex[10:0]][15:8];
               end
               6'h1e: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h1e)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h1e)[DepthIndex[10:0]][15:8];
               end
               6'h1f: begin
                  DMValue[i*8+:8]   = `DM3_BYTE(6'h1f)[DepthIndex[10:0]][7:0];
                  DMValue[i*8+8+:8] = `DM3_BYTE(6'h1f)[DepthIndex[10:0]][15:8];
               end
           endcase
           ByteIndex=ByteIndex+1;
       end

       if(DMValue == ExpValue) 
           $display("%0t Read DM3 OK @MPU_DC_PC = %h!!", $time, MPUPC);
       else begin 
           $display("%0t Error @MPUDP_PC = %h, Expected Value and Real Result of DM3 are :", $time, MPUPC);
           Mon.display_512(ExpValue);
           Mon.display_512(DMValue);
           $display(" ");
       end
   endtask


// MPU
   task automatic MPUReg_Write(bit init);
      bit[511:0] AllReg_bf[142];
      bit[511:0] AllReg_af[142];
      bit[511:0] MRegValue[64];
      bit[511:0] SHUValue[4][8];
      bit[511:0] BIUValue[4][4];
      bit[511:0] IMAValue[4][6];
      bit[511:0] KIValue;
      bit[511:0] MCRValue;
      bit[511:0] MCWValue;
      bit[511:0] MRL0Value;
      bit[511:0] MRL1Value;
      bit[511:0] MWLValue;

      $readmemh("../../../Source/Include/0516MPURegs_bf", AllReg_bf);
      for(int i=0; i<64; i++) begin
         if(init)
            Mon.M_Write(i, AllReg_bf[i]);
            //Mon.M_Write(i, {{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()}});
         else begin
            Mon.M_Read(i, MRegValue[i]);
            //$display("M[%0d] is:", i);
            //$display("%0h", MRegValue[i]);
            AllReg_af[i] = MRegValue[i];
         end
      end

      for(int i=0; i<4; i++) begin
         for(int j=0; j<8; j++) begin
            if(init)
               Mon.SHU_Write(i, j, AllReg_bf[64+i*8+j]);
               //Mon.SHU_Write(i, j, {{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()}});
            else begin
               Mon.SHU_Read(i, j, SHUValue[i][j]);
               //$display("SHU[%0d][%0d] is:", i, j);
               //$display("%0h", SHUValue[i][j]);
               AllReg_af[64+i*8+j] = SHUValue[i][j];
            end
         end
      end

      for(int i=0; i<4; i++) begin
         for(int j=0; j<4; j++) begin
            if(init)
               Mon.BIU_Write(i, j, AllReg_bf[96+i*4+j]);
               //Mon.BIU_Write(i, j, {{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()}});
            else begin
               Mon.BIU_Read(i, j, BIUValue[i][j]);
               //$display("BIU[%0d][%0d] is:", i, j);
               //$display("%0h", BIUValue[i][j]);
               AllReg_af[96+i*4+j] = BIUValue[i][j];
            end
         end
      end

      for(int i=0; i<4; i++) begin
         for(int j=0; j<6; j++) begin
            if(init)
               Mon.IMA_Write(i, j, AllReg_bf[112+i*6+j]);
               //Mon.IMA_Write(i, j, {{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()}});
            else begin
               Mon.IMA_Read(i, j, IMAValue[i][j]);
               //$display("IMA[%0d][%0d] is:", i, j);
               //$display("%0h", IMAValue[i][j]);
               AllReg_af[112+i*6+j] = IMAValue[i][j];
            end  
         end
      end

      if(init)
         Mon.KI_Write(AllReg_bf[136]);
         //Mon.KI_Write({{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()}});
      else begin
         Mon.KI_Read(KIValue);
         //$display("KI is:");
         //$display("%0h", KIValue);
         AllReg_af[136] = KIValue;
      end

      if(init) begin
         //read port
         Mon.MC_Write(1'b1, AllReg_bf[137]);
         //Mon.MC_Write(1'b1, {{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()}});
         //write port
         Mon.MC_Write(1'b0, AllReg_bf[138]);
         //Mon.MC_Write(1'b0, {{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()}});
      end
      else begin
         Mon.MC_Read1(1'b1, MCRValue);
         //$display("MCRValue is:");
         //$display("%0h", MCRValue);
         Mon.MC_Read1(1'b0, MCWValue);
         //$display("MCWValue is:");
         //$display("%0h", MCWValue);
         AllReg_af[137] = MCRValue;
         AllReg_af[138] = MCWValue;
      end

      if(init) begin
         //read latch0
         Mon.MRegLatch_Write(2'b0, AllReg_bf[139]);
         //Mon.MRegLatch_Write(2'b0, {{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()}});
         //read latch1
         Mon.MRegLatch_Write(2'b1, AllReg_bf[140]);
         //Mon.MRegLatch_Write(2'b1, {{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()}});
         //write latch
         Mon.MRegLatch_Write(2'b10, AllReg_bf[141]);
         //Mon.MRegLatch_Write(2'b10, {{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()},{$urandom()}});
      end
      else begin
         Mon.MRegLatch_Read(2'b0, MRL0Value);
         //$display("MRL0Value is:");
         //$display("%0h", MRL0Value);
         Mon.MRegLatch_Read(2'b1, MRL1Value);
         //$display("MRL1Value is:");
         //$display("%0h", MRL1Value);
         Mon.MRegLatch_Read(2'b10, MWLValue);
         //$display("MWLValue is:");
         //$display("%0h", MWLValue);
         AllReg_af[139] = MRL0Value;
         AllReg_af[140] = MRL1Value;
         AllReg_af[141] = MWLValue;
      end

      //for(int i=0; i<142; i++)
      //   $display("AllReg_bf[%0d] is %0h", i, AllReg_bf[i]);
      if(init)
         $writememh("MPURegs_bf", AllReg_bf);
      $writememh("MPURegs_af", AllReg_af);
   endtask: MPUReg_Write


   // GrpID: 0000-IMA0,0001-IMA1,0010-IMA2,0011-IMA3,0100-SHU0,0101-SHU1,0110-SHU2,0111-SHU3,1000-BIU0,1001-BIU1,1010-BIU2,1011-BIU3;  TID: 000~111
   task automatic CheckTValue(input int MPUPC, input int InstrCycle, input bit[3:0] GrpID, input bit[2:0] TID, input bit[511:0] ExpValue); 
      bit[511:0]   TValue;
      
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end
 		WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);
      Mon.T_Read(GrpID, TID, TValue);
      
      if(TValue == ExpValue) 
         case(GrpID)
            4'b0000: $display("%0t Read IMA0.T%0d OK @MPU_DC_PC = %h!!", $time, TID, MPUPC);
            4'b0001: $display("%0t Read IMA1.T%0d OK @MPU_DC_PC = %h!!", $time, TID, MPUPC);
            4'b0010: $display("%0t Read IMA2.T%0d OK @MPU_DC_PC = %h!!", $time, TID, MPUPC);
            4'b0011: $display("%0t Read IMA3.T%0d OK @MPU_DC_PC = %h!!", $time, TID, MPUPC);
            4'b0100: $display("%0t Read SHU0.T%0d OK @MPU_DC_PC = %h!!", $time, TID, MPUPC);
            4'b0101: $display("%0t Read SHU1.T%0d OK @MPU_DC_PC = %h!!", $time, TID, MPUPC);
            4'b0110: $display("%0t Read SHU2.T%0d OK @MPU_DC_PC = %h!!", $time, TID, MPUPC);
            4'b0111: $display("%0t Read SHU3.T%0d OK @MPU_DC_PC = %h!!", $time, TID, MPUPC);
            4'b1000: $display("%0t Read BIU0.T%0d OK @MPU_DC_PC = %h!!", $time, TID, MPUPC);
            4'b1001: $display("%0t Read BIU1.T%0d OK @MPU_DC_PC = %h!!", $time, TID, MPUPC);
            4'b1010: $display("%0t Read BIU2.T%0d OK @MPU_DC_PC = %h!!", $time, TID, MPUPC);
            4'b1011: $display("%0t Read BIU3.T%0d OK @MPU_DC_PC = %h!!", $time, TID, MPUPC);
            default: $display("%0t Error GroupID of CheckTValue!!!  @MPUDP_PC = %h!!", $time, MPUPC);
         endcase
      else begin 
         case(GrpID)
            4'b0000: $display("%0t Error @MPUDP_PC = %h, Expected Value and Real Result of IMA0.T%0d are :", $time, MPUPC, TID);
            4'b0001: $display("%0t Error @MPUDP_PC = %h, Expected Value and Real Result of IMA1.T%0d are :", $time, MPUPC, TID);
            4'b0010: $display("%0t Error @MPUDP_PC = %h, Expected Value and Real Result of IMA2.T%0d are :", $time, MPUPC, TID);
            4'b0011: $display("%0t Error @MPUDP_PC = %h, Expected Value and Real Result of IMA3.T%0d are :", $time, MPUPC, TID);
            4'b0100: $display("%0t Error @MPUDP_PC = %h, Expected Value and Real Result of SHU0.T%0d are :", $time, MPUPC, TID);
            4'b0101: $display("%0t Error @MPUDP_PC = %h, Expected Value and Real Result of SHU1.T%0d are :", $time, MPUPC, TID);
            4'b0110: $display("%0t Error @MPUDP_PC = %h, Expected Value and Real Result of SHU2.T%0d are :", $time, MPUPC, TID);
            4'b0111: $display("%0t Error @MPUDP_PC = %h, Expected Value and Real Result of SHU3.T%0d are :", $time, MPUPC, TID);
            4'b1000: $display("%0t Error @MPUDP_PC = %h, Expected Value and Real Result of BIU0.T%0d are :", $time, MPUPC, TID);
            4'b1001: $display("%0t Error @MPUDP_PC = %h, Expected Value and Real Result of BIU1.T%0d are :", $time, MPUPC, TID);
            4'b1010: $display("%0t Error @MPUDP_PC = %h, Expected Value and Real Result of BIU2.T%0d are :", $time, MPUPC, TID);
            4'b1011: $display("%0t Error @MPUDP_PC = %h, Expected Value and Real Result of BIU3.T%0d are :", $time, MPUPC, TID);
            default: $display("%0t Error GroupID of CheckTValue!!!  @MPUDP_PC = %h!!", $time, MPUPC);
         endcase
         Mon.display_512(ExpValue);
         Mon.display_512(TValue);
         $display(" ");
      end
   endtask

   // check TReg secondly
   task automatic Check2TValue(input int MPUPC, input int InstrCycle, input bit[3:0] GrpID, input bit[2:0] TID, input bit[511:0] ExpValue); 
      bit[511:0]   TValue;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end
 		WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end
 		WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);
      Mon.T_Read(GrpID, TID,TValue);
      
      if(TValue == ExpValue) 
         case(GrpID)
            4'b0000: $display("%0t Read IMA0.T%0d OK @MPUDP_PC = %h second time!!", $time, TID, MPUPC);
            4'b0001: $display("%0t Read IMA1.T%0d OK @MPUDP_PC = %h second time!!", $time, TID, MPUPC);
            4'b0010: $display("%0t Read IMA2.T%0d OK @MPUDP_PC = %h second time!!", $time, TID, MPUPC);
            4'b0011: $display("%0t Read IMA3.T%0d OK @MPUDP_PC = %h second time!!", $time, TID, MPUPC);
            4'b0100: $display("%0t Read SHU0.T%0d OK @MPUDP_PC = %h second time!!", $time, TID, MPUPC);
            4'b0101: $display("%0t Read SHU1.T%0d OK @MPUDP_PC = %h second time!!", $time, TID, MPUPC);
            4'b0110: $display("%0t Read SHU2.T%0d OK @MPUDP_PC = %h second time!!", $time, TID, MPUPC);
            4'b0111: $display("%0t Read SHU3.T%0d OK @MPUDP_PC = %h second time!!", $time, TID, MPUPC);
            4'b1000: $display("%0t Read BIU0.T%0d OK @MPUDP_PC = %h second time!!", $time, TID, MPUPC);
            4'b1001: $display("%0t Read BIU1.T%0d OK @MPUDP_PC = %h second time!!", $time, TID, MPUPC);
            4'b1010: $display("%0t Read BIU2.T%0d OK @MPUDP_PC = %h second time!!", $time, TID, MPUPC);
            4'b1011: $display("%0t Read BIU3.T%0d OK @MPUDP_PC = %h second time!!", $time, TID, MPUPC);
            default: $display("%0t Error GroupID of Check2TValue!!!  @MPUDP_PC = %h!!", $time, MPUPC);
         endcase
      else begin 
         case(GrpID)
            4'b0000: $display("%0t Error @MPUDP_PC = %h second time, Expected Value and Real Result of IMA0.T%0d are :", $time, MPUPC, TID);
            4'b0001: $display("%0t Error @MPUDP_PC = %h second time, Expected Value and Real Result of IMA1.T%0d are :", $time, MPUPC, TID);
            4'b0010: $display("%0t Error @MPUDP_PC = %h second time, Expected Value and Real Result of IMA2.T%0d are :", $time, MPUPC, TID);
            4'b0011: $display("%0t Error @MPUDP_PC = %h second time, Expected Value and Real Result of IMA3.T%0d are :", $time, MPUPC, TID);
            4'b0100: $display("%0t Error @MPUDP_PC = %h second time, Expected Value and Real Result of SHU0.T%0d are :", $time, MPUPC, TID);
            4'b0101: $display("%0t Error @MPUDP_PC = %h second time, Expected Value and Real Result of SHU1.T%0d are :", $time, MPUPC, TID);
            4'b0110: $display("%0t Error @MPUDP_PC = %h second time, Expected Value and Real Result of SHU2.T%0d are :", $time, MPUPC, TID);
            4'b0111: $display("%0t Error @MPUDP_PC = %h second time, Expected Value and Real Result of SHU3.T%0d are :", $time, MPUPC, TID);
            4'b1000: $display("%0t Error @MPUDP_PC = %h second time, Expected Value and Real Result of BIU0.T%0d are :", $time, MPUPC, TID);
            4'b1001: $display("%0t Error @MPUDP_PC = %h second time, Expected Value and Real Result of BIU1.T%0d are :", $time, MPUPC, TID);
            4'b1010: $display("%0t Error @MPUDP_PC = %h second time, Expected Value and Real Result of BIU2.T%0d are :", $time, MPUPC, TID);
            4'b1011: $display("%0t Error @MPUDP_PC = %h second time, Expected Value and Real Result of BIU3.T%0d are :", $time, MPUPC, TID);
            default: $display("%0t Error GroupID of Check2TValue!!!  @MPUDP_PC = %h!!", $time, MPUPC);
         endcase
         Mon.display_512(ExpValue);
         Mon.display_512(TValue);
         $display(" ");
      end
   endtask

   // GrpID: 0000-IMA0,0001-IMA1,0010-IMA2,0011-IMA3,0100-SHU0,0101-SHU1,0110-SHU2,0111-SHU3,1000-BIU0,1001-BIU1,1010-BIU2,1011-BIU3;  TID: 000~111
   task automatic CheckTLOW32Value(input int MPUPC, input int InstrCycle, input bit[3:0] GrpID, input bit[2:0] TID, input bit[511:0] ExpValue); 
      bit[511:0]   TValue;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end
      
 		WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);
      Mon.T_Read(GrpID, TID,TValue);
		TValue = TValue & 512'h00000000_ffffffff_00000000_ffffffff_00000000_ffffffff_00000000_ffffffff_00000000_ffffffff_00000000_ffffffff_00000000_ffffffff_00000000_ffffffff;

      if(TValue === ExpValue) 
         case(GrpID)
            4'b0000: $display("%0t Read IMA0.T%0d OK @MPU_DC_PC = %h!!", $time, TID, MPUPC);
            4'b0001: $display("%0t Read IMA1.T%0d OK @MPU_DC_PC = %h!!", $time, TID, MPUPC);
            4'b0010: $display("%0t Read IMA2.T%0d OK @MPU_DC_PC = %h!!", $time, TID, MPUPC);
            4'b0011: $display("%0t Read IMA3.T%0d OK @MPU_DC_PC = %h!!", $time, TID, MPUPC);
            4'b0100: $display("%0t Read SHU0.T%0d OK @MPU_DC_PC = %h!!", $time, TID, MPUPC);
            4'b0101: $display("%0t Read SHU1.T%0d OK @MPU_DC_PC = %h!!", $time, TID, MPUPC);
            4'b0110: $display("%0t Read SHU2.T%0d OK @MPU_DC_PC = %h!!", $time, TID, MPUPC);
            4'b0111: $display("%0t Read SHU3.T%0d OK @MPU_DC_PC = %h!!", $time, TID, MPUPC);
            4'b1000: $display("%0t Read BIU0.T%0d OK @MPU_DC_PC = %h!!", $time, TID, MPUPC);
            4'b1001: $display("%0t Read BIU1.T%0d OK @MPU_DC_PC = %h!!", $time, TID, MPUPC);
            4'b1010: $display("%0t Read BIU2.T%0d OK @MPU_DC_PC = %h!!", $time, TID, MPUPC);
            4'b1011: $display("%0t Read BIU3.T%0d OK @MPU_DC_PC = %h!!", $time, TID, MPUPC);
            default: $display("%0t Error GroupID of CheckTLOW32Value!!!  @MPUDP_PC = %h!!", $time, MPUPC);
         endcase
      else begin 
         case(GrpID)
            4'b0000: $display("%0t Error @MPUDP_PC = %h, Expected Value and Real Result of IMA0.T%0d are :", $time, MPUPC, TID);
            4'b0001: $display("%0t Error @MPUDP_PC = %h, Expected Value and Real Result of IMA1.T%0d are :", $time, MPUPC, TID);
            4'b0010: $display("%0t Error @MPUDP_PC = %h, Expected Value and Real Result of IMA2.T%0d are :", $time, MPUPC, TID);
            4'b0011: $display("%0t Error @MPUDP_PC = %h, Expected Value and Real Result of IMA3.T%0d are :", $time, MPUPC, TID);
            4'b0100: $display("%0t Error @MPUDP_PC = %h, Expected Value and Real Result of SHU0.T%0d are :", $time, MPUPC, TID);
            4'b0101: $display("%0t Error @MPUDP_PC = %h, Expected Value and Real Result of SHU1.T%0d are :", $time, MPUPC, TID);
            4'b0110: $display("%0t Error @MPUDP_PC = %h, Expected Value and Real Result of SHU2.T%0d are :", $time, MPUPC, TID);
            4'b0111: $display("%0t Error @MPUDP_PC = %h, Expected Value and Real Result of SHU3.T%0d are :", $time, MPUPC, TID);
            4'b1000: $display("%0t Error @MPUDP_PC = %h, Expected Value and Real Result of BIU0.T%0d are :", $time, MPUPC, TID);
            4'b1001: $display("%0t Error @MPUDP_PC = %h, Expected Value and Real Result of BIU1.T%0d are :", $time, MPUPC, TID);
            4'b1010: $display("%0t Error @MPUDP_PC = %h, Expected Value and Real Result of BIU2.T%0d are :", $time, MPUPC, TID);
            4'b1011: $display("%0t Error @MPUDP_PC = %h, Expected Value and Real Result of BIU3.T%0d are :", $time, MPUPC, TID);
            default: $display("%0t Error GroupID of CheckTLOW32Value!!!  @MPUDP_PC = %h!!", $time, MPUPC);
         endcase
         Mon.display_512(ExpValue);
         Mon.display_512(TValue);
         $display(" ");
      end
   endtask

   task automatic CheckMValue(input int MPUPC, input int InstrCycle, input bit[5:0] RID, input bit[511:0] ExpValue); 
      bit[511:0]   MValue;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC)
            break;
      end

 		WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);

      Mon.M_Read(RID, MValue);
      if(MValue === ExpValue) $display("%0t Read M[%d] of OK @MPU_DC_PC = %h!!", $realtime, RID, MPUPC);
      else  begin
        $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of M[%d] are : ", $realtime, MPUPC, RID);
        Mon.display_512(ExpValue);            
        Mon.display_512(MValue);
        $display(" ");        
      end
   endtask

   task automatic CheckMValueMFetch(input int MPUPC, input int InstrCycle, input bit[5:0] RID, input bit[511:0] ExpValue); 
      bit[511:0]   MValue;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end

 		WaitMPUCycles(InstrCycle);

      Mon.M_Read(RID, MValue);
      if(MValue === ExpValue) $display("%0t Read M[%d] of OK @MPU_DC_PC = %h!!", $realtime, RID, MPUPC);
      else  begin
        $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of M[%d] are : ", $realtime, MPUPC, RID);
        Mon.display_512(ExpValue);            
        Mon.display_512(MValue);
        $display(" ");        
      end
   endtask

   //Sel:00->IMA0, 01->IMA1, 10->IMA2, 11->IMA3
   //Width: 00->byte, 01->short, 10->word
   task automatic CheckMRValue(input int MPUPC, input int InstrCycle, input bit[1:0] Sel, bit[1:0] Width, input bit[1663:0] ExpValue); 
      bit[1663:0] MRValue;
      bit[103:0]  MR_Mask_Short;
      bit[103:0]  MR_Mask_Word;

      MR_Mask_Short = {10'h3ff, 10'h0, 10'h3ff, 10'h0, 64'hffffffff_ffffffff};
      MR_Mask_Word  = {10'h3ff, 10'h0, 10'h0, 10'h0, 64'hffffffff_ffffffff};

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end

 		WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);

      Mon.MR_Read(Sel, MRValue);
      case(Width)
         2'b00:
            MRValue = MRValue;
         2'b01:
            for(int i=0; i<16; i++) begin
               ExpValue[i*104+:104] = ExpValue[i*104+:104] & MR_Mask_Short;
               MRValue[i*104+:104] = MRValue[i*104+:104] & MR_Mask_Short;
            end
         2'b10:
            for(int i=0; i<16; i++) begin
               ExpValue[i*104+:104] = ExpValue[i*104+:104] & MR_Mask_Word;
               MRValue[i*104+:104] = MRValue[i*104+:104] & MR_Mask_Word;
            end
         default:
            $display("%0t Error Width of CheckMRValue!!!  @MPU_DC_PC = %h!!", $realtime, MPUPC);
      endcase

      if(MRValue === ExpValue)  
			case(Sel)
				2'b00:	$display("%0t Read MR of IMA0 OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
				2'b01:	$display("%0t Read MR of IMA1 OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
				2'b10:	$display("%0t Read MR of IMA2 OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
				2'b11:	$display("%0t Read MR of IMA3 OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
			endcase
      else begin
			case(Sel)
				2'b00: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA0.MR are : ", $realtime, MPUPC);
				2'b01: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA1.MR are : ", $realtime, MPUPC);
				2'b10: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA2.MR are : ", $realtime, MPUPC);
				2'b11: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA3.MR are : ", $realtime, MPUPC);
			endcase
         Mon.display_MR(ExpValue);
         Mon.display_MR(MRValue);
       	$display(" ");        
      end
   endtask

   //Sel:00->IMA0, 01->IMA1, 10->IMA2, 11->IMA3
   //Width: 00->byte, 01->short
   task automatic CheckMRLHValue(input int MPUPC, input int InstrCycle, input bit[1:0] Sel, bit[1:0] Width, input bit[1663:0] ExpValue); 
      bit[1663:0] MRValue;
      bit[103:0]  MR_Mask;

      MR_Mask = {40'h0, 64'hffffffff_ffffffff};

      if(Width==2'b10 || Width==2'b11)
         $display("%0t Error Width of CheckMRLHValue!!!  @MPU_DC_PC = %h!!", $realtime, MPUPC);

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end

 		WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);

      Mon.MR_Read(Sel, MRValue);

      for(int i=0; i<16; i++) begin
         ExpValue[i*104+:104] = ExpValue[i*104+:104] & MR_Mask;
         MRValue[i*104+:104] = MRValue[i*104+:104] & MR_Mask;
      end

      if(MRValue === ExpValue)  
			case(Sel)
				2'b00:	$display("%0t Read MR of IMA0 OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
				2'b01:	$display("%0t Read MR of IMA1 OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
				2'b10:	$display("%0t Read MR of IMA2 OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
				2'b11:	$display("%0t Read MR of IMA3 OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
			endcase
      else begin
			case(Sel)
				2'b00: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA0.MR are : ", $realtime, MPUPC);
				2'b01: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA1.MR are : ", $realtime, MPUPC);
				2'b10: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA2.MR are : ", $realtime, MPUPC);
				2'b11: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA3.MR are : ", $realtime, MPUPC);
			endcase
         Mon.display_MR(ExpValue);
         Mon.display_MR(MRValue);
       	$display(" ");        
      end
   endtask

   //Sel:00->IMA0, 01->IMA1, 10->IMA2, 11->IMA3
   //Width: 00->byte, 01->short
   task automatic CheckMRLValue(input int MPUPC, input int InstrCycle, input bit[1:0] Sel, bit[1:0] Width, input bit[1663:0] ExpValue); 
      bit[1663:0] MRValue;
      bit[103:0]  MR_Mask;

      MR_Mask = {72'h0, 32'hffffffff};

      if(Width==2'b10 || Width==2'b11)
         $display("%0t Error Width of CheckMRLValue!!!  @MPU_DC_PC = %h!!", $realtime, MPUPC);

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end

 		WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);

      Mon.MR_Read(Sel, MRValue);

      for(int i=0; i<16; i++) begin
         ExpValue[i*104+:104] = ExpValue[i*104+:104] & MR_Mask;
         MRValue[i*104+:104] = MRValue[i*104+:104] & MR_Mask;
      end

      if(MRValue === ExpValue)  
			case(Sel)
				2'b00:	$display("%0t Read MR of IMA0 OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
				2'b01:	$display("%0t Read MR of IMA1 OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
				2'b10:	$display("%0t Read MR of IMA2 OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
				2'b11:	$display("%0t Read MR of IMA3 OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
			endcase
      else begin
			case(Sel)
				2'b00: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA0.MR are : ", $realtime, MPUPC);
				2'b01: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA1.MR are : ", $realtime, MPUPC);
				2'b10: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA2.MR are : ", $realtime, MPUPC);
				2'b11: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA3.MR are : ", $realtime, MPUPC);
			endcase
         Mon.display_MR(ExpValue);
         Mon.display_MR(MRValue);
       	$display(" ");        
      end
   endtask

   // PortID: 0000-0011(RP0-RP3), 0100-1000(WP0-WP4)
   task automatic CheckMCValue(input int MPUPC,input int InstrCycle, input bit[3:0] PortID, input bit[63:0] ExpValue); 
      bit[47:0] MCValue;
		bit[63:0] MCValue_temp;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end

 		WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);

      Mon.MC_Read(PortID, MCValue);
		MCValue_temp = {2'b00,MCValue[47:42],2'b00,MCValue[41:36],2'b00,MCValue[35:30],2'b00,MCValue[29:24],2'b00,MCValue[23:18],2'b00,MCValue[17:12],2'b00,MCValue[11:6],2'b00,MCValue[5:0]};
		ExpValue = ExpValue & 64'h3f3f3f3f_3f3f3f3f;

      if(MCValue_temp === ExpValue)  
			case(PortID)
				4'b0000:	$display("%0t Read MC Value of RP0 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
				4'b0001:	$display("%0t Read MC Value of RP1 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
				4'b0010:	$display("%0t Read MC Value of RP2 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
				4'b0011:	$display("%0t Read MC Value of RP3 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
				4'b0100:	$display("%0t Read MC Value of WP0 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
				4'b0101:	$display("%0t Read MC Value of WP1 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
				4'b0110:	$display("%0t Read MC Value of WP2 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
				4'b0111:	$display("%0t Read MC Value of WP3 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
				4'b1000:	$display("%0t Read MC Value of WP4 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
				default: $display("%0t Error PortID of CheckMCValue!!!  @MPUDC_PC = %h!!", $realtime, MPUPC);
			endcase
      else  begin
		  case(PortID)
				4'b0000:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_RP0 are : ", $realtime, MPUPC);
				4'b0001:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_RP1 are : ", $realtime, MPUPC);
				4'b0010:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_RP2 are : ", $realtime, MPUPC);
				4'b0011:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_RP3 are : ", $realtime, MPUPC);
				4'b0100:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_WP0 are : ", $realtime, MPUPC);
				4'b0101:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_WP1 are : ", $realtime, MPUPC);
				4'b0110:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_WP2 are : ", $realtime, MPUPC);
				4'b0111:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_WP3 are : ", $realtime, MPUPC);
				4'b1000:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_WP4 are : ", $realtime, MPUPC);
				default: $display("%0t Error PortID of CheckMCValue!!!  @MPUDC_PC = %h!!", $realtime, MPUPC);
        endcase
        $display("%h_%h,",ExpValue[63:32], ExpValue[31:0]);
        $display("%h_%h,",MCValue_temp[63:32], MCValue_temp[31:0]);
        $display(" ");        
      end
   endtask

   // PortID: 0000-0011(RP0-RP3), 0100-1000(WP0-WP4)
   task automatic CheckMCValueSI(input int MPUPC,input int InstrCycle, input bit[3:0] PortID, input bit[1:0] Sel, input bit[63:0] ExpValue); 
      bit[47:0] MCValue;
		bit[63:0] MCValue_temp;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end

 		WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);

      Mon.MC_Read(PortID, MCValue);
		MCValue_temp = {2'b00,MCValue[47:42],2'b00,MCValue[41:36],2'b00,MCValue[35:30],2'b00,MCValue[29:24],2'b00,MCValue[23:18],2'b00,MCValue[17:12],2'b00,MCValue[11:6],2'b00,MCValue[5:0]};
		ExpValue = ExpValue & 64'h3f3f3f3f_3f3f3f3f;
      
      if(Sel==2'b01) begin
          if(MCValue_temp[31:0] === ExpValue[31:0])  
	        	case(PortID)
	        		4'b0000:	$display("%0t Read MC Value of RP0 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
	        		4'b0001:	$display("%0t Read MC Value of RP1 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
	        		4'b0010:	$display("%0t Read MC Value of RP2 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
	        		4'b0011:	$display("%0t Read MC Value of RP3 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
	        		4'b0100:	$display("%0t Read MC Value of WP0 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
	        		4'b0101:	$display("%0t Read MC Value of WP1 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
	        		4'b0110:	$display("%0t Read MC Value of WP2 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
	        		4'b0111:	$display("%0t Read MC Value of WP3 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
	        		4'b1000:	$display("%0t Read MC Value of WP4 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
	        		default: $display("%0t Error PortID of CheckMCValue!!!  @MPUDC_PC = %h!!", $realtime, MPUPC);
	        	endcase
          else  begin
	          case(PortID)
	        		4'b0000:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_RP0 are : ", $realtime, MPUPC);
	        		4'b0001:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_RP1 are : ", $realtime, MPUPC);
	        		4'b0010:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_RP2 are : ", $realtime, MPUPC);
	        		4'b0011:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_RP3 are : ", $realtime, MPUPC);
	        		4'b0100:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_WP0 are : ", $realtime, MPUPC);
	        		4'b0101:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_WP1 are : ", $realtime, MPUPC);
	        		4'b0110:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_WP2 are : ", $realtime, MPUPC);
	        		4'b0111:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_WP3 are : ", $realtime, MPUPC);
	        		4'b1000:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_WP4 are : ", $realtime, MPUPC);
	        		default: $display("%0t Error PortID of CheckMCValue!!!  @MPUDC_PC = %h!!", $realtime, MPUPC);
            endcase
            $display("%h,", ExpValue[31:0]);
            $display("%h,", MCValue_temp[31:0]);
            $display(" ");        
          end
      end else if(Sel==2'b10) begin
          if(MCValue_temp[63:32] === ExpValue[63:32])  
	        	case(PortID)
	        		4'b0000:	$display("%0t Read MC Value of RP0 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
	        		4'b0001:	$display("%0t Read MC Value of RP1 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
	        		4'b0010:	$display("%0t Read MC Value of RP2 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
	        		4'b0011:	$display("%0t Read MC Value of RP3 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
	        		4'b0100:	$display("%0t Read MC Value of WP0 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
	        		4'b0101:	$display("%0t Read MC Value of WP1 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
	        		4'b0110:	$display("%0t Read MC Value of WP2 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
	        		4'b0111:	$display("%0t Read MC Value of WP3 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
	        		4'b1000:	$display("%0t Read MC Value of WP4 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
	        		default: $display("%0t Error PortID of CheckMCValue!!!  @MPUDC_PC = %h!!", $realtime, MPUPC);
	        	endcase
          else  begin
	          case(PortID)
	        		4'b0000:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_RP0 are : ", $realtime, MPUPC);
	        		4'b0001:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_RP1 are : ", $realtime, MPUPC);
	        		4'b0010:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_RP2 are : ", $realtime, MPUPC);
	        		4'b0011:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_RP3 are : ", $realtime, MPUPC);
	        		4'b0100:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_WP0 are : ", $realtime, MPUPC);
	        		4'b0101:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_WP1 are : ", $realtime, MPUPC);
	        		4'b0110:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_WP2 are : ", $realtime, MPUPC);
	        		4'b0111:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_WP3 are : ", $realtime, MPUPC);
	        		4'b1000:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_WP4 are : ", $realtime, MPUPC);
	        		default: $display("%0t Error PortID of CheckMCValue!!!  @MPUDC_PC = %h!!", $realtime, MPUPC);
            endcase
            $display("%h,",ExpValue[63:32]);
            $display("%h,",MCValue_temp[63:32]);
            $display(" ");        
          end
      end else if(Sel==2'b11) begin
          if(MCValue_temp === ExpValue)  
	        	case(PortID)
	        		4'b0000:	$display("%0t Read MC Value of RP0 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
	        		4'b0001:	$display("%0t Read MC Value of RP1 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
	        		4'b0010:	$display("%0t Read MC Value of RP2 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
	        		4'b0011:	$display("%0t Read MC Value of RP3 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
	        		4'b0100:	$display("%0t Read MC Value of WP0 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
	        		4'b0101:	$display("%0t Read MC Value of WP1 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
	        		4'b0110:	$display("%0t Read MC Value of WP2 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
	        		4'b0111:	$display("%0t Read MC Value of WP3 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
	        		4'b1000:	$display("%0t Read MC Value of WP4 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
	        		default: $display("%0t Error PortID of CheckMCValue!!!  @MPUDC_PC = %h!!", $realtime, MPUPC);
	        	endcase
          else  begin
	          case(PortID)
	        		4'b0000:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_RP0 are : ", $realtime, MPUPC);
	        		4'b0001:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_RP1 are : ", $realtime, MPUPC);
	        		4'b0010:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_RP2 are : ", $realtime, MPUPC);
	        		4'b0011:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_RP3 are : ", $realtime, MPUPC);
	        		4'b0100:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_WP0 are : ", $realtime, MPUPC);
	        		4'b0101:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_WP1 are : ", $realtime, MPUPC);
	        		4'b0110:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_WP2 are : ", $realtime, MPUPC);
	        		4'b0111:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_WP3 are : ", $realtime, MPUPC);
	        		4'b1000:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MC_WP4 are : ", $realtime, MPUPC);
	        		default: $display("%0t Error PortID of CheckMCValue!!!  @MPUDC_PC = %h!!", $realtime, MPUPC);
            endcase
            $display("%h_%h,",ExpValue[63:32], ExpValue[31:0]);
            $display("%h_%h,",MCValue_temp[63:32], MCValue_temp[31:0]);
            $display(" ");        
          end
      end else begin
          $display("%0t Error Sel of CheckMCValue!!!  @MPUDC_PC = %h!!", $realtime, MPUPC);
      end
   endtask

   // Sel: 00-read latch0, 01-read latch1, 10-write latch
   task automatic CheckMRegLatchValue(input int MPUPC, input int InstrCycle, input bit[1:0] Sel, input bit[511:0] ExpValue); 
      bit[511:0] MRegLatch;
      
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end

 		WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);

      Mon.MRegLatch_Read(Sel, MRegLatch);
      if(MRegLatch === ExpValue)  
			case(Sel)
				2'b00:	$display("%0t Read MRegReadLatch0 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
				2'b01:	$display("%0t Read MRegReadLatch1 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
				2'b10:	$display("%0t Read MRegWriteLatch OK @MPUDC_PC = %h!!", $realtime, MPUPC);
				default: $display("%0t Error Sel of CheckMRegLatchValue!!!  @MPUDC_PC = %h!!", $realtime, MPUPC);
			endcase
      else  begin
		  case(Sel)
				2'b00:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MRegReadLatch0 are : ", $realtime, MPUPC);
				2'b01:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MRegReadLatch1 are : ", $realtime, MPUPC);
				2'b10:	$display("%0t Error @MPUDC_PC = %h, Expected Value and real value of MRegWriteLatch are : ", $realtime, MPUPC);
				default: $display("%0t Error Sel CheckMRegLatchValue!!!  @MPUDC_PC = %h!!", $realtime, MPUPC);
        endcase
		  Mon.display_512(ExpValue);            
        Mon.display_512(MRegLatch);
        $display(" ");        
      end
   endtask

   //GroupID:00-IMA0,01-IMA1,10-IMA2,11-IMA3
   //FlagType:10-C,11-V
   task automatic CheckFLAGValue(input int MPUPC, input int InstrCycle, input bit[1:0] GrpID, input bit[1:0] FlagType, input bit[63:0] ExpValue); 
		bit[63:0] CFlag, VFlag;
		int Cis1_counter = 0;	// bit counter of C, which is '1'
		int Vok_counter = 0;	   // bit counter of V, which is "ExpValue==VFlag"  

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end
		
      WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);

      if(InstrCycle == 3) begin
         Mon.MACFlag_Read(GrpID, 2'b10, CFlag);
         Mon.MACFlag_Read(GrpID, 2'b11, VFlag);
      end
      if(InstrCycle == 1) begin
         Mon.ALUFlag_Read(GrpID, 2'b10, CFlag);
      end
      
		case(FlagType)
			2'b10: begin
     				    if(CFlag == ExpValue)  
	  				    	 case(GrpID)
	  				    	 	 2'b00: $display("%0t Read IMA0 CFlag OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
	  				    	 	 2'b01: $display("%0t Read IMA1 CFlag OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
	  				    	 	 2'b10: $display("%0t Read IMA2 CFlag OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
	  				    	 	 2'b11: $display("%0t Read IMA3 CFlag OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
	  				    	 endcase
     				    else begin
	  				    	 case(GrpID)
	  				    		 2'b00: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA0 CFlag are : ", $realtime, MPUPC);
	  				    		 2'b01: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA1 CFlag are : ", $realtime, MPUPC);
	  				    		 2'b10: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA2 CFlag are : ", $realtime, MPUPC);
	  				    		 2'b11: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA3 CFlag are : ", $realtime, MPUPC);
					       endcase
	       		       $display("%h_%h_%h_%h,",ExpValue[63:48], ExpValue[47:32], ExpValue[31:16], ExpValue[15:0]);
       			    	 $display("%h_%h_%h_%h,",CFlag[63:48], CFlag[47:32], CFlag[31:16], CFlag[15:0]);
     				       $display(" ");
					    end
			end
			2'b11: begin
					 	 for(int i=0;i<64;i++) begin
						 	 if(CFlag[i]) begin
						 	 	 Cis1_counter++; 
						 	 	 if(VFlag[i]==ExpValue[i]) Vok_counter++;
					    	 end
					 	 end
     				    if(Cis1_counter==0) begin
					    	 $display("%0t @MPU_DC_PC = %h, No overflow, so VFlag is invalid", $realtime, MPUPC);
	  				     	 //case(GrpID)
	  				     	 //	 2'b00: $display("%0t @MPU_DC_PC = %h, Real value of IMA0 VFlag are : %h_%h", $realtime, MPUPC, VFlag[63:32], VFlag[31:0]);
	  				     	 //	 2'b01: $display("%0t @MPU_DC_PC = %h, Real value of IMA1 VFlag are : %h_%h", $realtime, MPUPC, VFlag[63:32], VFlag[31:0]);
	  				     	 //	 2'b10: $display("%0t @MPU_DC_PC = %h, Real value of IMA2 VFlag are : %h_%h", $realtime, MPUPC, VFlag[63:32], VFlag[31:0]);
	  				     	 //	 2'b11: $display("%0t @MPU_DC_PC = %h, Real value of IMA3 VFlag are : %h_%h", $realtime, MPUPC, VFlag[63:32], VFlag[31:0]);
					    	 //endcase
                   end
					    else if(Cis1_counter==Vok_counter)  
	  				     	 case(GrpID)
	  				     	 	 2'b00: $display("%0t Read IMA0 VFlag OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
	  				     	 	 2'b01: $display("%0t Read IMA1 VFlag OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
	  				     	 	 2'b10: $display("%0t Read IMA2 VFlag OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
	  				     	 	 2'b11: $display("%0t Read IMA3 VFlag OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
	  				     	 endcase
     				    else begin
	  				     	 case(GrpID)
	  				     	  	 2'b00: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA0 VFlag are : ", $realtime, MPUPC);
	  				     	  	 2'b01: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA1 VFlag are : ", $realtime, MPUPC);
	  				     	  	 2'b10: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA2 VFlag are : ", $realtime, MPUPC);
	  				     	  	 2'b11: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA3 VFlag are : ", $realtime, MPUPC);
					    	 endcase
	       		    	 $display("%h_%h,",ExpValue[63:32], ExpValue[31:0]);
       			     	 $display("%h_%h,",VFlag[63:32], VFlag[31:0]);
     				       $display(" ");
					    end
		   end
         default: $display("Error from CheckFLAGValue: Wrong FlagType!!!");
	  	endcase
   endtask

   //GroupID:00-IMA0,01-IMA1,10-IMA2,11-IMA3
   //FlagType:10-C,11-V
   task automatic CheckFLAGLOW16Value(input int MPUPC, input int InstrCycle, input bit[1:0] GrpID, input bit[1:0] FlagType, input bit[63:0] ExpValue); 
		bit[63:0] CFlag, VFlag;
		int Cis1_counter = 0;	// bit counter of C, which is '1'
		int Vok_counter = 0;	// bit counter of V, which is "ExpValue==VFlag"  

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end

      WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);
		
      if(InstrCycle == 3) begin
         Mon.MACFlag_Read(GrpID, 2'b10, CFlag);
         Mon.MACFlag_Read(GrpID, 2'b11, VFlag);
      end
      if(InstrCycle == 1) begin
         Mon.ALUFlag_Read(GrpID, 2'b10, CFlag);
      end
      
		CFlag = CFlag & 64'h0f0f_0f0f_0f0f_0f0f;
		VFlag = VFlag & 64'h0f0f_0f0f_0f0f_0f0f;

		case(FlagType)
			2'b10: begin
     				    if(CFlag == ExpValue)  
	  				    	 case(GrpID)
	  				    	 	 2'b00: $display("%0t Read IMA0 CFlag OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
	  				    	 	 2'b01: $display("%0t Read IMA1 CFlag OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
	  				    	 	 2'b10: $display("%0t Read IMA2 CFlag OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
	  				    	 	 2'b11: $display("%0t Read IMA3 CFlag OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
	  				    	 endcase
     				    else begin
	  				    	 case(GrpID)
	  				    		 2'b00: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA0 CFlag are : ", $realtime, MPUPC);
	  				    		 2'b01: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA1 CFlag are : ", $realtime, MPUPC);
	  				    		 2'b10: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA2 CFlag are : ", $realtime, MPUPC);
	  				    		 2'b11: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA3 CFlag are : ", $realtime, MPUPC);
					       endcase
	       		       $display("%h_%h_%h_%h,",ExpValue[63:48], ExpValue[47:32], ExpValue[31:16], ExpValue[15:0]);
       			    	 $display("%h_%h_%h_%h,",CFlag[63:48], CFlag[47:32], CFlag[31:16], CFlag[15:0]);
     				       $display(" ");
					    end
			end
			2'b11: begin
					 	 for(int i=0;i<64;i++) begin
						 	 if(CFlag[i]) begin
						 	 	 Cis1_counter++; 
						 	 	 if(VFlag[i]==ExpValue[i]) Vok_counter++;
					    	 end
					 	 end
     				    if(Cis1_counter==0) begin
					    	 $display("%0t @MPU_DC_PC = %h, No overflow, so VFlag is invalid!!!!!!", $realtime, MPUPC);
	  				     	 case(GrpID)
	  				     	 	 2'b00: $display("%0t @MPU_DC_PC = %h, Real value of IMA0 VFlag are : %h_%h", $realtime, MPUPC, VFlag[63:32], VFlag[31:0]);
	  				     	 	 2'b01: $display("%0t @MPU_DC_PC = %h, Real value of IMA1 VFlag are : %h_%h", $realtime, MPUPC, VFlag[63:32], VFlag[31:0]);
	  				     	 	 2'b10: $display("%0t @MPU_DC_PC = %h, Real value of IMA2 VFlag are : %h_%h", $realtime, MPUPC, VFlag[63:32], VFlag[31:0]);
	  				     	 	 2'b11: $display("%0t @MPU_DC_PC = %h, Real value of IMA3 VFlag are : %h_%h", $realtime, MPUPC, VFlag[63:32], VFlag[31:0]);
					    	 endcase
                   end
					    else if(Cis1_counter==Vok_counter)  
	  				     	 case(GrpID)
	  				     	 	 2'b00: $display("%0t Read IMA0 VFlag OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
	  				     	 	 2'b01: $display("%0t Read IMA1 VFlag OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
	  				     	 	 2'b10: $display("%0t Read IMA2 VFlag OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
	  				     	 	 2'b11: $display("%0t Read IMA3 VFlag OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
	  				     	 endcase
     				    else begin
	  				     	 case(GrpID)
	  				     	  	 2'b00: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA0 VFlag are : ", $realtime, MPUPC);
	  				     	  	 2'b01: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA1 VFlag are : ", $realtime, MPUPC);
	  				     	  	 2'b10: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA2 VFlag are : ", $realtime, MPUPC);
	  				     	  	 2'b11: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA3 VFlag are : ", $realtime, MPUPC);
					    	 endcase
	       		    	 $display("%h_%h,",ExpValue[63:32], ExpValue[31:0]);
       			     	 $display("%h_%h,",VFlag[63:32], VFlag[31:0]);
     				       $display(" ");
					    end
		   end
         default: $display("Error from CheckFLAGValue: Wrong FlagType!!!");
	  	endcase
   endtask

   //GroupID:00-IMA0,01-IMA1,10-IMA2,11-IMA3
   task automatic CheckErasedBitValue(input int MPUPC, input int InstrCycle, input bit[1:0] GrpID, input bit[63:0] ExpValue);
  		bit[63:0] ErasedBit;
      
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end
		
      WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);
      Mon.ErasedBit_Read(GrpID, ErasedBit);
		case(GrpID)
			2'b00:
				if(ExpValue===ErasedBit) $display("%0t Read IMA0 ErasedBit OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
				else begin 
					$display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA0 ErasedBit are : ", $realtime, MPUPC);
	       		$display("%h_%h,",ExpValue[63:32], ExpValue[31:0]);
					$display("%h_%h,",ErasedBit[63:32],ErasedBit[31:0]);
				end
			2'b10:
				if(ExpValue===ErasedBit) $display("%0t Read IMA2 ErasedBit OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
				else begin 
					$display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA2 ErasedBit are : ", $realtime, MPUPC);
	       		$display("%h_%h,",ExpValue[63:32], ExpValue[31:0]);
					$display("%h_%h,",ErasedBit[63:32],ErasedBit[31:0]);
				end
			2'b01:
				if(ExpValue[23:0]===ErasedBit[23:0]) $display("%0t Read IMA1 ErasedBit OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
				else begin 
					$display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA1 ErasedBit are : ", $realtime, MPUPC);
	       		$display("%h,",ExpValue[23:0]);
					$display("%h,",ErasedBit[23:0]);
				end
			2'b11:
				if(ExpValue[23:0]===ErasedBit[23:0]) $display("%0t Read IMA3 ErasedBit OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
				else begin 
					$display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA3 ErasedBit are : ", $realtime, MPUPC);
	       		$display("%h,",ExpValue[23:0]);
					$display("%h,",ErasedBit[23:0]);
				end
		endcase
   endtask

   //GrpID: 0000-IMA0,0001-IMA1,0010-IMA2,0011-IMA3
   //FlagType:00-ALU(C),01-MAC(U),10-MAC(C),11-MAC(V)
   task automatic CheckIMAWriteFLAGValue(input int MPUPC, input int InstrCycle, input bit[1:0] GrpID, input bit[1:0] FlagType, input bit[63:0] ExpValue); 
		bit[63:0] UFlag, CFlag, VFlag;
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end
		
      WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);
      if(FlagType == 2'b00) begin
         Mon.ALUFlag_Read(GrpID, 2'b10, CFlag);
      end
      else begin
         Mon.MACFlag_Read(GrpID, FlagType, UFlag);
         Mon.MACFlag_Read(GrpID, FlagType, CFlag);
         Mon.MACFlag_Read(GrpID, FlagType, VFlag);
      end

		case(FlagType)
			2'b00: begin
     			if(CFlag == ExpValue)  
	  				case(GrpID)
	  				 	2'b00: $display("%0t Read IMA0 CFlag(ALU) OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
	  				 	2'b01: $display("%0t Read IMA1 CFlag(ALU) OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
	  				 	2'b10: $display("%0t Read IMA2 CFlag(ALU) OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
	  				 	2'b11: $display("%0t Read IMA3 CFlag(ALU) OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
	  				endcase
     			else begin
	  				case(GrpID)
	  				 	2'b00: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA0 CFlag(ALU) are : ", $realtime, MPUPC);
	  				 	2'b01: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA1 CFlag(ALU) are : ", $realtime, MPUPC);
	  				 	2'b10: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA2 CFlag(ALU) are : ", $realtime, MPUPC);
	  				 	2'b11: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA3 CFlag(ALU) are : ", $realtime, MPUPC);
				   endcase
	       	   $display("%h_%h,",ExpValue[63:32], ExpValue[31:0]);
       			$display("%h_%h,",CFlag[63:32], CFlag[31:0]);
     			   $display(" ");
				end
			end
			2'b01: begin
     			if(UFlag == ExpValue)  
	  				 case(GrpID)
	  				 	 2'b00: $display("%0t Read IMA0 UFlag(MAC) OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
	  				 	 2'b01: $display("%0t Read IMA1 UFlag(MAC) OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
	  				 	 2'b10: $display("%0t Read IMA2 UFlag(MAC) OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
	  				 	 2'b11: $display("%0t Read IMA3 UFlag(MAC) OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
	  				 endcase
     			else begin
	  			 	case(GrpID)
	  			 	   2'b00: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA0 UFlag(MAC) are : ", $realtime, MPUPC);
	  			 	 	2'b01: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA1 UFlag(MAC) are : ", $realtime, MPUPC);
	  			 	 	2'b10: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA2 UFlag(MAC) are : ", $realtime, MPUPC);
	  			 	 	2'b11: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA3 UFlag(MAC) are : ", $realtime, MPUPC);
				   endcase
	       	   $display("%h_%h,",ExpValue[63:32], ExpValue[31:0]);
       			$display("%h_%h,",UFlag[63:32], UFlag[31:0]);
     			   $display(" ");
				end
			end
			2'b10: begin
     				if(CFlag == ExpValue)  
	  					case(GrpID)
	  					 	2'b00: $display("%0t Read IMA0 CFlag(MAC) OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
	  					 	2'b01: $display("%0t Read IMA1 CFlag(MAC) OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
	  					 	2'b10: $display("%0t Read IMA2 CFlag(MAC) OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
	  					 	2'b11: $display("%0t Read IMA3 CFlag(MAC) OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
	  					endcase
     				else begin
	  					case(GrpID)
	  						2'b00: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA0 CFlag(MAC) are : ", $realtime, MPUPC);
	  						2'b01: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA1 CFlag(MAC) are : ", $realtime, MPUPC);
	  						2'b10: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA2 CFlag(MAC) are : ", $realtime, MPUPC);
	  						2'b11: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA3 CFlag(MAC) are : ", $realtime, MPUPC);
					   endcase
	       		   $display("%h_%h,",ExpValue[63:32], ExpValue[31:0]);
       		 	   $display("%h_%h,",CFlag[63:32], CFlag[31:0]);
     				   $display(" ");
					end
			   end
			2'b11: begin
     			if(VFlag == ExpValue)  
				   case(GrpID)
	  					2'b00: $display("%0t Read IMA0 VFlag(MAC) OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
	  					2'b01: $display("%0t Read IMA1 VFlag(MAC) OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
	  					2'b10: $display("%0t Read IMA2 VFlag(MAC) OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
	  					2'b11: $display("%0t Read IMA3 VFlag(MAC) OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
					endcase
     			else begin
	  			 	case(GrpID)
	  			 	  	2'b00: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA0 VFlag(MAC) are : ", $realtime, MPUPC);
	  			 	  	2'b01: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA1 VFlag(MAC) are : ", $realtime, MPUPC);
	  			 	  	2'b10: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA2 VFlag(MAC) are : ", $realtime, MPUPC);
	  			 	  	2'b11: $display("%0t Error @MPU_DC_PC = %h, Expected Value and real value of IMA3 VFlag(MAC) are : ", $realtime, MPUPC);
					endcase
	       		$display("%h_%h,",ExpValue[63:32], ExpValue[31:0]);
       		 	$display("%h_%h,",VFlag[63:32], VFlag[31:0]);
     			   $display(" ");
				end
			end
	  	endcase
   endtask

   task automatic CheckDM0Value(input int MPUPC, input int InstrCycle, input int Addr, input bit [2:0] Gran, input [3:0] Size, input [2:0] CGran, input bit [511:0] ExpValue);
      bit[511:0]   DMValue512;
      byte Byte1Value[];
      byte Byte2Value[];
      byte Byte4Value[];
      byte Byte8Value[];
      byte Byte16Value[];
      byte Byte32Value[];
      byte Byte64Value[];
      int i;

      Byte1Value  = new[1];
      Byte2Value  = new[2];
      Byte4Value  = new[4];
      Byte8Value  = new[8];
      Byte16Value  = new[16];
      Byte32Value  = new[32];
      Byte64Value  = new[64];
      
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end
      
 		WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);

      case(CGran)
        3'd0: begin
          for(i=0; i<64; i++) begin
            $root.TestTop.uAPE.uDM0.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte1Value);
            DMValue512[8*i +:8] = Byte1Value[0] ;
          end
        end
        3'd1: begin
          for(i=0; i<32; i++) begin
            $root.TestTop.uAPE.uDM0.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte2Value);
            DMValue512[16*i   +: 8] = Byte2Value[0] ;
            DMValue512[16*i+8 +: 8] = Byte2Value[1] ;
          end
        end
        3'd2: begin
          for(i=0; i<16; i++) begin
            $root.TestTop.uAPE.uDM0.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte4Value);
            DMValue512[32*i   +: 8] = Byte4Value[0] ;
            DMValue512[32*i+8 +: 8] = Byte4Value[1] ;
            DMValue512[32*i+16+: 8] = Byte4Value[2] ;
            DMValue512[32*i+24+: 8] = Byte4Value[3] ;
          end
        end
        3'd3: begin
          for(i=0; i<8; i++) begin
            $root.TestTop.uAPE.uDM0.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte8Value);
            DMValue512[64*i   +: 8] = Byte8Value[0] ;
            DMValue512[64*i+8 +: 8] = Byte8Value[1] ;
            DMValue512[64*i+16+: 8] = Byte8Value[2] ;
            DMValue512[64*i+24+: 8] = Byte8Value[3] ;
            DMValue512[64*i+32+: 8] = Byte8Value[4] ;
            DMValue512[64*i+40+: 8] = Byte8Value[5] ;
            DMValue512[64*i+48+: 8] = Byte8Value[6] ;
            DMValue512[64*i+56+: 8] = Byte8Value[7] ;
          end
        end
        3'd4: begin
          for(i=0; i<4; i++) begin
            $root.TestTop.uAPE.uDM0.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte16Value);
            DMValue512[128*i    +: 8] = Byte16Value[0] ;
            DMValue512[128*i+  8+: 8] = Byte16Value[1] ;
            DMValue512[128*i+ 16+: 8] = Byte16Value[2] ;
            DMValue512[128*i+ 24+: 8] = Byte16Value[3] ;
            DMValue512[128*i+ 32+: 8] = Byte16Value[4] ;
            DMValue512[128*i+ 40+: 8] = Byte16Value[5] ;
            DMValue512[128*i+ 48+: 8] = Byte16Value[6] ;
            DMValue512[128*i+ 56+: 8] = Byte16Value[7] ;
            DMValue512[128*i+ 64+: 8] = Byte16Value[8] ;
            DMValue512[128*i+ 72+: 8] = Byte16Value[9] ;
            DMValue512[128*i+ 80+: 8] = Byte16Value[10] ;
            DMValue512[128*i+ 88+: 8] = Byte16Value[11] ;
            DMValue512[128*i+ 96+: 8] = Byte16Value[12] ;
            DMValue512[128*i+104+: 8] = Byte16Value[13] ;
            DMValue512[128*i+112+: 8] = Byte16Value[14] ;
            DMValue512[128*i+120+: 8] = Byte16Value[15] ;
          end
        end
        3'd5: begin
          for(i=0; i<2; i++) begin
            $root.TestTop.uAPE.uDM0.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte32Value);
            DMValue512[256*i    +: 8] = Byte32Value[0] ;
            DMValue512[256*i+  8+: 8] = Byte32Value[1] ;
            DMValue512[256*i+ 16+: 8] = Byte32Value[2] ;
            DMValue512[256*i+ 24+: 8] = Byte32Value[3] ;
            DMValue512[256*i+ 32+: 8] = Byte32Value[4] ;
            DMValue512[256*i+ 40+: 8] = Byte32Value[5] ;
            DMValue512[256*i+ 48+: 8] = Byte32Value[6] ;
            DMValue512[256*i+ 56+: 8] = Byte32Value[7] ;
            DMValue512[256*i+ 64+: 8] = Byte32Value[8] ;
            DMValue512[256*i+ 72+: 8] = Byte32Value[9] ;
            DMValue512[256*i+ 80+: 8] = Byte32Value[10] ;
            DMValue512[256*i+ 88+: 8] = Byte32Value[11] ;
            DMValue512[256*i+ 96+: 8] = Byte32Value[12] ;
            DMValue512[256*i+104+: 8] = Byte32Value[13] ;
            DMValue512[256*i+112+: 8] = Byte32Value[14] ;
            DMValue512[256*i+120+: 8] = Byte32Value[15] ;
            DMValue512[256*i+128+: 8] = Byte32Value[16] ;
            DMValue512[256*i+136+: 8] = Byte32Value[17] ;
            DMValue512[256*i+144+: 8] = Byte32Value[18] ;
            DMValue512[256*i+152+: 8] = Byte32Value[19] ;
            DMValue512[256*i+160+: 8] = Byte32Value[20] ;
            DMValue512[256*i+168+: 8] = Byte32Value[21] ;
            DMValue512[256*i+176+: 8] = Byte32Value[22] ;
            DMValue512[256*i+184+: 8] = Byte32Value[23] ;
            DMValue512[256*i+192+: 8] = Byte32Value[24] ;
            DMValue512[256*i+200+: 8] = Byte32Value[25] ;
            DMValue512[256*i+208+: 8] = Byte32Value[26] ;
            DMValue512[256*i+216+: 8] = Byte32Value[27] ;
            DMValue512[256*i+224+: 8] = Byte32Value[28] ;
            DMValue512[256*i+232+: 8] = Byte32Value[29] ;
            DMValue512[256*i+240+: 8] = Byte32Value[30] ;
            DMValue512[256*i+248+: 8] = Byte32Value[31] ;
          end
        end
        3'd6: begin
          $root.TestTop.uAPE.uDM0.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte64Value); 
          DMValue512[0  +: 8] = Byte64Value[0] ;
          DMValue512[8  +: 8] = Byte64Value[1] ;
          DMValue512[16 +: 8] = Byte64Value[2] ;
          DMValue512[24 +: 8] = Byte64Value[3] ;
          DMValue512[32 +: 8] = Byte64Value[4] ;
          DMValue512[40 +: 8] = Byte64Value[5] ;
          DMValue512[48 +: 8] = Byte64Value[6] ;
          DMValue512[56 +: 8] = Byte64Value[7] ;
          DMValue512[64 +: 8] = Byte64Value[8] ;
          DMValue512[72 +: 8] = Byte64Value[9] ;
          DMValue512[80 +: 8] = Byte64Value[10] ;
          DMValue512[88 +: 8] = Byte64Value[11] ;
          DMValue512[96 +: 8] = Byte64Value[12] ;
          DMValue512[104+: 8] = Byte64Value[13] ;
          DMValue512[112+: 8] = Byte64Value[14] ;
          DMValue512[120+: 8] = Byte64Value[15] ;
          DMValue512[128+: 8] = Byte64Value[16] ;
          DMValue512[136+: 8] = Byte64Value[17] ;
          DMValue512[144+: 8] = Byte64Value[18] ;
          DMValue512[152+: 8] = Byte64Value[19] ;
          DMValue512[160+: 8] = Byte64Value[20] ;
          DMValue512[168+: 8] = Byte64Value[21] ;
          DMValue512[176+: 8] = Byte64Value[22] ;
          DMValue512[184+: 8] = Byte64Value[23] ;
          DMValue512[192+: 8] = Byte64Value[24] ;
          DMValue512[200+: 8] = Byte64Value[25] ;
          DMValue512[208+: 8] = Byte64Value[26] ;
          DMValue512[216+: 8] = Byte64Value[27] ;
          DMValue512[224+: 8] = Byte64Value[28] ;
          DMValue512[232+: 8] = Byte64Value[29] ;
          DMValue512[240+: 8] = Byte64Value[30] ;
          DMValue512[248+: 8] = Byte64Value[31] ;
          DMValue512[256+: 8] = Byte64Value[32] ;
          DMValue512[264+: 8] = Byte64Value[33] ;
          DMValue512[272+: 8] = Byte64Value[34] ;
          DMValue512[280+: 8] = Byte64Value[35] ;
          DMValue512[288+: 8] = Byte64Value[36] ;
          DMValue512[296+: 8] = Byte64Value[37] ;
          DMValue512[304+: 8] = Byte64Value[38] ;
          DMValue512[312+: 8] = Byte64Value[39] ;
          DMValue512[320+: 8] = Byte64Value[40] ;
          DMValue512[328+: 8] = Byte64Value[41] ;
          DMValue512[336+: 8] = Byte64Value[42] ;
          DMValue512[344+: 8] = Byte64Value[43] ;
          DMValue512[352+: 8] = Byte64Value[44] ;
          DMValue512[360+: 8] = Byte64Value[45] ;
          DMValue512[368+: 8] = Byte64Value[46] ;
          DMValue512[376+: 8] = Byte64Value[47] ;
          DMValue512[384+: 8] = Byte64Value[48] ;
          DMValue512[392+: 8] = Byte64Value[49] ;
          DMValue512[400+: 8] = Byte64Value[50] ;
          DMValue512[408+: 8] = Byte64Value[51] ;
          DMValue512[416+: 8] = Byte64Value[52] ;
          DMValue512[424+: 8] = Byte64Value[53] ;
          DMValue512[432+: 8] = Byte64Value[54] ;
          DMValue512[440+: 8] = Byte64Value[55] ;
          DMValue512[448+: 8] = Byte64Value[56] ;
          DMValue512[456+: 8] = Byte64Value[57] ;
          DMValue512[464+: 8] = Byte64Value[58] ;
          DMValue512[472+: 8] = Byte64Value[59] ;
          DMValue512[480+: 8] = Byte64Value[60] ;
          DMValue512[488+: 8] = Byte64Value[61] ;
          DMValue512[496+: 8] = Byte64Value[62] ;
          DMValue512[504+: 8] = Byte64Value[63] ;
        end
        default: $display("The input of CGran is invalid !\n\n");
      endcase
      
      if(DMValue512 === ExpValue) $display("%0t Read DM0 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
      else  begin
        $display("%0t Error @MPUDC_PC = %h, Expected Value and Real Result are :", $realtime, MPUPC);
        Mon.display_512(ExpValue);
        Mon.display_512(DMValue512);
        $display(" ");
      end

      Byte1Value.delete();
      Byte2Value.delete();
      Byte4Value.delete();
      Byte8Value.delete();
      Byte16Value.delete();
      Byte32Value.delete();
      Byte64Value.delete();
    
  endtask

  task automatic CheckDM0Value_Mask(input int MPUPC, input int InstrCycle, input int Addr, input bit [2:0] Gran, input [3:0] Size, input [2:0] CGran, input bit[511:0] Mask, input bit [511:0] ExpValue);
      bit[511:0]   DMValue512;
      byte Byte1Value[];
      byte Byte2Value[];
      byte Byte4Value[];
      byte Byte8Value[];
      byte Byte16Value[];
      byte Byte32Value[];
      byte Byte64Value[];
      int i;

      Byte1Value  = new[1];
      Byte2Value  = new[2];
      Byte4Value  = new[4];
      Byte8Value  = new[8];
      Byte16Value  = new[16];
      Byte32Value  = new[32];
      Byte64Value  = new[64];
      
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end
      
 		WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);

      case(CGran)
        3'd0: begin
          for(i=0; i<64; i++) begin
            $root.TestTop.uAPE.uDM0.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte1Value);
            DMValue512[8*i +:8] = Byte1Value[0] ;
          end
        end
        3'd1: begin
          for(i=0; i<32; i++) begin
            $root.TestTop.uAPE.uDM0.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte2Value);
            DMValue512[16*i   +: 8] = Byte2Value[0] ;
            DMValue512[16*i+8 +: 8] = Byte2Value[1] ;
          end
        end
        3'd2: begin
          for(i=0; i<16; i++) begin
            $root.TestTop.uAPE.uDM0.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte4Value);
            DMValue512[32*i   +: 8] = Byte4Value[0] ;
            DMValue512[32*i+8 +: 8] = Byte4Value[1] ;
            DMValue512[32*i+16+: 8] = Byte4Value[2] ;
            DMValue512[32*i+24+: 8] = Byte4Value[3] ;
          end
        end
        3'd3: begin
          for(i=0; i<8; i++) begin
            $root.TestTop.uAPE.uDM0.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte8Value);
            DMValue512[64*i   +: 8] = Byte8Value[0] ;
            DMValue512[64*i+8 +: 8] = Byte8Value[1] ;
            DMValue512[64*i+16+: 8] = Byte8Value[2] ;
            DMValue512[64*i+24+: 8] = Byte8Value[3] ;
            DMValue512[64*i+32+: 8] = Byte8Value[4] ;
            DMValue512[64*i+40+: 8] = Byte8Value[5] ;
            DMValue512[64*i+48+: 8] = Byte8Value[6] ;
            DMValue512[64*i+56+: 8] = Byte8Value[7] ;
          end
        end
        3'd4: begin
          for(i=0; i<4; i++) begin
            $root.TestTop.uAPE.uDM0.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte16Value);
            DMValue512[128*i    +: 8] = Byte16Value[0] ;
            DMValue512[128*i+  8+: 8] = Byte16Value[1] ;
            DMValue512[128*i+ 16+: 8] = Byte16Value[2] ;
            DMValue512[128*i+ 24+: 8] = Byte16Value[3] ;
            DMValue512[128*i+ 32+: 8] = Byte16Value[4] ;
            DMValue512[128*i+ 40+: 8] = Byte16Value[5] ;
            DMValue512[128*i+ 48+: 8] = Byte16Value[6] ;
            DMValue512[128*i+ 56+: 8] = Byte16Value[7] ;
            DMValue512[128*i+ 64+: 8] = Byte16Value[8] ;
            DMValue512[128*i+ 72+: 8] = Byte16Value[9] ;
            DMValue512[128*i+ 80+: 8] = Byte16Value[10] ;
            DMValue512[128*i+ 88+: 8] = Byte16Value[11] ;
            DMValue512[128*i+ 96+: 8] = Byte16Value[12] ;
            DMValue512[128*i+104+: 8] = Byte16Value[13] ;
            DMValue512[128*i+112+: 8] = Byte16Value[14] ;
            DMValue512[128*i+120+: 8] = Byte16Value[15] ;
          end
        end
        3'd5: begin
          for(i=0; i<2; i++) begin
            $root.TestTop.uAPE.uDM0.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte32Value);
            DMValue512[256*i    +: 8] = Byte32Value[0] ;
            DMValue512[256*i+  8+: 8] = Byte32Value[1] ;
            DMValue512[256*i+ 16+: 8] = Byte32Value[2] ;
            DMValue512[256*i+ 24+: 8] = Byte32Value[3] ;
            DMValue512[256*i+ 32+: 8] = Byte32Value[4] ;
            DMValue512[256*i+ 40+: 8] = Byte32Value[5] ;
            DMValue512[256*i+ 48+: 8] = Byte32Value[6] ;
            DMValue512[256*i+ 56+: 8] = Byte32Value[7] ;
            DMValue512[256*i+ 64+: 8] = Byte32Value[8] ;
            DMValue512[256*i+ 72+: 8] = Byte32Value[9] ;
            DMValue512[256*i+ 80+: 8] = Byte32Value[10] ;
            DMValue512[256*i+ 88+: 8] = Byte32Value[11] ;
            DMValue512[256*i+ 96+: 8] = Byte32Value[12] ;
            DMValue512[256*i+104+: 8] = Byte32Value[13] ;
            DMValue512[256*i+112+: 8] = Byte32Value[14] ;
            DMValue512[256*i+120+: 8] = Byte32Value[15] ;
            DMValue512[256*i+128+: 8] = Byte32Value[16] ;
            DMValue512[256*i+136+: 8] = Byte32Value[17] ;
            DMValue512[256*i+144+: 8] = Byte32Value[18] ;
            DMValue512[256*i+152+: 8] = Byte32Value[19] ;
            DMValue512[256*i+160+: 8] = Byte32Value[20] ;
            DMValue512[256*i+168+: 8] = Byte32Value[21] ;
            DMValue512[256*i+176+: 8] = Byte32Value[22] ;
            DMValue512[256*i+184+: 8] = Byte32Value[23] ;
            DMValue512[256*i+192+: 8] = Byte32Value[24] ;
            DMValue512[256*i+200+: 8] = Byte32Value[25] ;
            DMValue512[256*i+208+: 8] = Byte32Value[26] ;
            DMValue512[256*i+216+: 8] = Byte32Value[27] ;
            DMValue512[256*i+224+: 8] = Byte32Value[28] ;
            DMValue512[256*i+232+: 8] = Byte32Value[29] ;
            DMValue512[256*i+240+: 8] = Byte32Value[30] ;
            DMValue512[256*i+248+: 8] = Byte32Value[31] ;
          end
        end
        3'd6: begin
          $root.TestTop.uAPE.uDM0.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte64Value); 
          DMValue512[0  +: 8] = Byte64Value[0] ;
          DMValue512[8  +: 8] = Byte64Value[1] ;
          DMValue512[16 +: 8] = Byte64Value[2] ;
          DMValue512[24 +: 8] = Byte64Value[3] ;
          DMValue512[32 +: 8] = Byte64Value[4] ;
          DMValue512[40 +: 8] = Byte64Value[5] ;
          DMValue512[48 +: 8] = Byte64Value[6] ;
          DMValue512[56 +: 8] = Byte64Value[7] ;
          DMValue512[64 +: 8] = Byte64Value[8] ;
          DMValue512[72 +: 8] = Byte64Value[9] ;
          DMValue512[80 +: 8] = Byte64Value[10] ;
          DMValue512[88 +: 8] = Byte64Value[11] ;
          DMValue512[96 +: 8] = Byte64Value[12] ;
          DMValue512[104+: 8] = Byte64Value[13] ;
          DMValue512[112+: 8] = Byte64Value[14] ;
          DMValue512[120+: 8] = Byte64Value[15] ;
          DMValue512[128+: 8] = Byte64Value[16] ;
          DMValue512[136+: 8] = Byte64Value[17] ;
          DMValue512[144+: 8] = Byte64Value[18] ;
          DMValue512[152+: 8] = Byte64Value[19] ;
          DMValue512[160+: 8] = Byte64Value[20] ;
          DMValue512[168+: 8] = Byte64Value[21] ;
          DMValue512[176+: 8] = Byte64Value[22] ;
          DMValue512[184+: 8] = Byte64Value[23] ;
          DMValue512[192+: 8] = Byte64Value[24] ;
          DMValue512[200+: 8] = Byte64Value[25] ;
          DMValue512[208+: 8] = Byte64Value[26] ;
          DMValue512[216+: 8] = Byte64Value[27] ;
          DMValue512[224+: 8] = Byte64Value[28] ;
          DMValue512[232+: 8] = Byte64Value[29] ;
          DMValue512[240+: 8] = Byte64Value[30] ;
          DMValue512[248+: 8] = Byte64Value[31] ;
          DMValue512[256+: 8] = Byte64Value[32] ;
          DMValue512[264+: 8] = Byte64Value[33] ;
          DMValue512[272+: 8] = Byte64Value[34] ;
          DMValue512[280+: 8] = Byte64Value[35] ;
          DMValue512[288+: 8] = Byte64Value[36] ;
          DMValue512[296+: 8] = Byte64Value[37] ;
          DMValue512[304+: 8] = Byte64Value[38] ;
          DMValue512[312+: 8] = Byte64Value[39] ;
          DMValue512[320+: 8] = Byte64Value[40] ;
          DMValue512[328+: 8] = Byte64Value[41] ;
          DMValue512[336+: 8] = Byte64Value[42] ;
          DMValue512[344+: 8] = Byte64Value[43] ;
          DMValue512[352+: 8] = Byte64Value[44] ;
          DMValue512[360+: 8] = Byte64Value[45] ;
          DMValue512[368+: 8] = Byte64Value[46] ;
          DMValue512[376+: 8] = Byte64Value[47] ;
          DMValue512[384+: 8] = Byte64Value[48] ;
          DMValue512[392+: 8] = Byte64Value[49] ;
          DMValue512[400+: 8] = Byte64Value[50] ;
          DMValue512[408+: 8] = Byte64Value[51] ;
          DMValue512[416+: 8] = Byte64Value[52] ;
          DMValue512[424+: 8] = Byte64Value[53] ;
          DMValue512[432+: 8] = Byte64Value[54] ;
          DMValue512[440+: 8] = Byte64Value[55] ;
          DMValue512[448+: 8] = Byte64Value[56] ;
          DMValue512[456+: 8] = Byte64Value[57] ;
          DMValue512[464+: 8] = Byte64Value[58] ;
          DMValue512[472+: 8] = Byte64Value[59] ;
          DMValue512[480+: 8] = Byte64Value[60] ;
          DMValue512[488+: 8] = Byte64Value[61] ;
          DMValue512[496+: 8] = Byte64Value[62] ;
          DMValue512[504+: 8] = Byte64Value[63] ;
        end
        default: $display("The input of CGran is invalid !\n\n");
      endcase
      
      if((DMValue512&Mask) === ExpValue) $display("%0t Read DM0 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
      else  begin
        $display("%0t Error @MPUDC_PC = %h, Expected Value and Real Result are :", $realtime, MPUPC);
        Mon.display_512(ExpValue);
        Mon.display_512(DMValue512&Mask);
        $display(" ");
      end

      Byte1Value.delete();
      Byte2Value.delete();
      Byte4Value.delete();
      Byte8Value.delete();
      Byte16Value.delete();
      Byte32Value.delete();
      Byte64Value.delete();
    
  endtask
  
   task automatic Check2DM0Value(input int MPUPC, input int InstrCycle, input int Addr, input bit [2:0] Gran, input [3:0] Size, input [2:0] CGran, input bit [511:0] ExpValue);
      bit[511:0]   DMValue512;
      byte Byte1Value[];
      byte Byte2Value[];
      byte Byte4Value[];
      byte Byte8Value[];
      byte Byte16Value[];
      byte Byte32Value[];
      byte Byte64Value[];

      Byte1Value  = new[1];
      Byte2Value  = new[2];
      Byte4Value  = new[4];
      Byte8Value  = new[8];
      Byte16Value  = new[16];
      Byte32Value  = new[32];
      Byte64Value  = new[64];
      
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end
      WaitMPUCycles(InstrCycle);

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end
 		WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);

      case(CGran)
        3'd0: begin
          for(int i=0; i<64; i++) begin
            $root.TestTop.uAPE.uDM0.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte1Value);
            DMValue512[8*i +:8] = Byte1Value[0] ;
          end
        end
        3'd1: begin
          for(int i=0; i<32; i++) begin
            $root.TestTop.uAPE.uDM0.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte2Value);
            DMValue512[16*i   +: 8] = Byte2Value[0] ;
            DMValue512[16*i+8 +: 8] = Byte2Value[1] ;
          end
        end
        3'd2: begin
          for(int i=0; i<16; i++) begin
            $root.TestTop.uAPE.uDM0.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte4Value);
            DMValue512[32*i   +: 8] = Byte4Value[0] ;
            DMValue512[32*i+8 +: 8] = Byte4Value[1] ;
            DMValue512[32*i+16+: 8] = Byte4Value[2] ;
            DMValue512[32*i+24+: 8] = Byte4Value[3] ;
          end
        end
        3'd3: begin
          for(int i=0; i<8; i++) begin
            $root.TestTop.uAPE.uDM0.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte8Value);
            DMValue512[64*i   +: 8] = Byte8Value[0] ;
            DMValue512[64*i+8 +: 8] = Byte8Value[1] ;
            DMValue512[64*i+16+: 8] = Byte8Value[2] ;
            DMValue512[64*i+24+: 8] = Byte8Value[3] ;
            DMValue512[64*i+32+: 8] = Byte8Value[4] ;
            DMValue512[64*i+40+: 8] = Byte8Value[5] ;
            DMValue512[64*i+48+: 8] = Byte8Value[6] ;
            DMValue512[64*i+56+: 8] = Byte8Value[7] ;
          end
        end
        3'd4: begin
          for(int i=0; i<4; i++) begin
            $root.TestTop.uAPE.uDM0.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte16Value);
            DMValue512[128*i    +: 8] = Byte16Value[0] ;
            DMValue512[128*i+  8+: 8] = Byte16Value[1] ;
            DMValue512[128*i+ 16+: 8] = Byte16Value[2] ;
            DMValue512[128*i+ 24+: 8] = Byte16Value[3] ;
            DMValue512[128*i+ 32+: 8] = Byte16Value[4] ;
            DMValue512[128*i+ 40+: 8] = Byte16Value[5] ;
            DMValue512[128*i+ 48+: 8] = Byte16Value[6] ;
            DMValue512[128*i+ 56+: 8] = Byte16Value[7] ;
            DMValue512[128*i+ 64+: 8] = Byte16Value[8] ;
            DMValue512[128*i+ 72+: 8] = Byte16Value[9] ;
            DMValue512[128*i+ 80+: 8] = Byte16Value[10] ;
            DMValue512[128*i+ 88+: 8] = Byte16Value[11] ;
            DMValue512[128*i+ 96+: 8] = Byte16Value[12] ;
            DMValue512[128*i+104+: 8] = Byte16Value[13] ;
            DMValue512[128*i+112+: 8] = Byte16Value[14] ;
            DMValue512[128*i+120+: 8] = Byte16Value[15] ;
          end
        end
        3'd5: begin
          for(int i=0; i<2; i++) begin
            $root.TestTop.uAPE.uDM0.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte32Value);
            DMValue512[256*i    +: 8] = Byte32Value[0] ;
            DMValue512[256*i+  8+: 8] = Byte32Value[1] ;
            DMValue512[256*i+ 16+: 8] = Byte32Value[2] ;
            DMValue512[256*i+ 24+: 8] = Byte32Value[3] ;
            DMValue512[256*i+ 32+: 8] = Byte32Value[4] ;
            DMValue512[256*i+ 40+: 8] = Byte32Value[5] ;
            DMValue512[256*i+ 48+: 8] = Byte32Value[6] ;
            DMValue512[256*i+ 56+: 8] = Byte32Value[7] ;
            DMValue512[256*i+ 64+: 8] = Byte32Value[8] ;
            DMValue512[256*i+ 72+: 8] = Byte32Value[9] ;
            DMValue512[256*i+ 80+: 8] = Byte32Value[10] ;
            DMValue512[256*i+ 88+: 8] = Byte32Value[11] ;
            DMValue512[256*i+ 96+: 8] = Byte32Value[12] ;
            DMValue512[256*i+104+: 8] = Byte32Value[13] ;
            DMValue512[256*i+112+: 8] = Byte32Value[14] ;
            DMValue512[256*i+120+: 8] = Byte32Value[15] ;
            DMValue512[256*i+128+: 8] = Byte32Value[16] ;
            DMValue512[256*i+136+: 8] = Byte32Value[17] ;
            DMValue512[256*i+144+: 8] = Byte32Value[18] ;
            DMValue512[256*i+152+: 8] = Byte32Value[19] ;
            DMValue512[256*i+160+: 8] = Byte32Value[20] ;
            DMValue512[256*i+168+: 8] = Byte32Value[21] ;
            DMValue512[256*i+176+: 8] = Byte32Value[22] ;
            DMValue512[256*i+184+: 8] = Byte32Value[23] ;
            DMValue512[256*i+192+: 8] = Byte32Value[24] ;
            DMValue512[256*i+200+: 8] = Byte32Value[25] ;
            DMValue512[256*i+208+: 8] = Byte32Value[26] ;
            DMValue512[256*i+216+: 8] = Byte32Value[27] ;
            DMValue512[256*i+224+: 8] = Byte32Value[28] ;
            DMValue512[256*i+232+: 8] = Byte32Value[29] ;
            DMValue512[256*i+240+: 8] = Byte32Value[30] ;
            DMValue512[256*i+248+: 8] = Byte32Value[31] ;
          end
        end
        3'd6: begin
          $root.TestTop.uAPE.uDM0.DMReadBytes(Addr+((1<<Size)*64)*0, Gran, Size, Byte64Value); 
          DMValue512[0  +: 8] = Byte64Value[0] ;
          DMValue512[8  +: 8] = Byte64Value[1] ;
          DMValue512[16 +: 8] = Byte64Value[2] ;
          DMValue512[24 +: 8] = Byte64Value[3] ;
          DMValue512[32 +: 8] = Byte64Value[4] ;
          DMValue512[40 +: 8] = Byte64Value[5] ;
          DMValue512[48 +: 8] = Byte64Value[6] ;
          DMValue512[56 +: 8] = Byte64Value[7] ;
          DMValue512[64 +: 8] = Byte64Value[8] ;
          DMValue512[72 +: 8] = Byte64Value[9] ;
          DMValue512[80 +: 8] = Byte64Value[10] ;
          DMValue512[88 +: 8] = Byte64Value[11] ;
          DMValue512[96 +: 8] = Byte64Value[12] ;
          DMValue512[104+: 8] = Byte64Value[13] ;
          DMValue512[112+: 8] = Byte64Value[14] ;
          DMValue512[120+: 8] = Byte64Value[15] ;
          DMValue512[128+: 8] = Byte64Value[16] ;
          DMValue512[136+: 8] = Byte64Value[17] ;
          DMValue512[144+: 8] = Byte64Value[18] ;
          DMValue512[152+: 8] = Byte64Value[19] ;
          DMValue512[160+: 8] = Byte64Value[20] ;
          DMValue512[168+: 8] = Byte64Value[21] ;
          DMValue512[176+: 8] = Byte64Value[22] ;
          DMValue512[184+: 8] = Byte64Value[23] ;
          DMValue512[192+: 8] = Byte64Value[24] ;
          DMValue512[200+: 8] = Byte64Value[25] ;
          DMValue512[208+: 8] = Byte64Value[26] ;
          DMValue512[216+: 8] = Byte64Value[27] ;
          DMValue512[224+: 8] = Byte64Value[28] ;
          DMValue512[232+: 8] = Byte64Value[29] ;
          DMValue512[240+: 8] = Byte64Value[30] ;
          DMValue512[248+: 8] = Byte64Value[31] ;
          DMValue512[256+: 8] = Byte64Value[32] ;
          DMValue512[264+: 8] = Byte64Value[33] ;
          DMValue512[272+: 8] = Byte64Value[34] ;
          DMValue512[280+: 8] = Byte64Value[35] ;
          DMValue512[288+: 8] = Byte64Value[36] ;
          DMValue512[296+: 8] = Byte64Value[37] ;
          DMValue512[304+: 8] = Byte64Value[38] ;
          DMValue512[312+: 8] = Byte64Value[39] ;
          DMValue512[320+: 8] = Byte64Value[40] ;
          DMValue512[328+: 8] = Byte64Value[41] ;
          DMValue512[336+: 8] = Byte64Value[42] ;
          DMValue512[344+: 8] = Byte64Value[43] ;
          DMValue512[352+: 8] = Byte64Value[44] ;
          DMValue512[360+: 8] = Byte64Value[45] ;
          DMValue512[368+: 8] = Byte64Value[46] ;
          DMValue512[376+: 8] = Byte64Value[47] ;
          DMValue512[384+: 8] = Byte64Value[48] ;
          DMValue512[392+: 8] = Byte64Value[49] ;
          DMValue512[400+: 8] = Byte64Value[50] ;
          DMValue512[408+: 8] = Byte64Value[51] ;
          DMValue512[416+: 8] = Byte64Value[52] ;
          DMValue512[424+: 8] = Byte64Value[53] ;
          DMValue512[432+: 8] = Byte64Value[54] ;
          DMValue512[440+: 8] = Byte64Value[55] ;
          DMValue512[448+: 8] = Byte64Value[56] ;
          DMValue512[456+: 8] = Byte64Value[57] ;
          DMValue512[464+: 8] = Byte64Value[58] ;
          DMValue512[472+: 8] = Byte64Value[59] ;
          DMValue512[480+: 8] = Byte64Value[60] ;
          DMValue512[488+: 8] = Byte64Value[61] ;
          DMValue512[496+: 8] = Byte64Value[62] ;
          DMValue512[504+: 8] = Byte64Value[63] ;
        end
        default: $display("The input of CGran is invalid !\n\n");
      endcase

      if(DMValue512 === ExpValue) $display("%0t Read DM0  OK @MPU_DC_PC = %h second time!!", $realtime, MPUPC);
      else  begin
        $display("%0t Error @MPU_DC_PC = %h second time, Expected Value and Real Result are :", $realtime, MPUPC);
        Mon.display_512(ExpValue);
        Mon.display_512(DMValue512);
        $display(" ");
      end

      Byte1Value.delete();
      Byte2Value.delete();
      Byte4Value.delete();
      Byte8Value.delete();
      Byte16Value.delete();
      Byte32Value.delete();
      Byte64Value.delete();
   endtask

   task automatic CheckDM1Value(input int MPUPC, input int InstrCycle, input int Addr, input bit [2:0] Gran, input [3:0] Size, input [2:0] CGran, input bit [511:0] ExpValue);
      bit[511:0]   DMValue512;
      byte Byte1Value[];
      byte Byte2Value[];
      byte Byte4Value[];
      byte Byte8Value[];
      byte Byte16Value[];
      byte Byte32Value[];
      byte Byte64Value[];

      Byte1Value  = new[1];
      Byte2Value  = new[2];
      Byte4Value  = new[4];
      Byte8Value  = new[8];
      Byte16Value  = new[16];
      Byte32Value  = new[32];
      Byte64Value  = new[64];
      
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end
      
 		WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);

      case(CGran)
        3'd0: begin
          for(int i=0; i<64; i++) begin
            $root.TestTop.uAPE.uDM1.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte1Value);
            DMValue512[8*i +:8] = Byte1Value[0] ;
          end
        end
        3'd1: begin
          for(int i=0; i<32; i++) begin
            $root.TestTop.uAPE.uDM1.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte2Value);
            DMValue512[16*i   +: 8] = Byte2Value[0] ;
            DMValue512[16*i+8 +: 8] = Byte2Value[1] ;
          end
        end
        3'd2: begin
          for(int i=0; i<16; i++) begin
            $root.TestTop.uAPE.uDM1.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte4Value);
            DMValue512[32*i   +: 8] = Byte4Value[0] ;
            DMValue512[32*i+8 +: 8] = Byte4Value[1] ;
            DMValue512[32*i+16+: 8] = Byte4Value[2] ;
            DMValue512[32*i+24+: 8] = Byte4Value[3] ;
          end
        end
        3'd3: begin
          for(int i=0; i<8; i++) begin
            $root.TestTop.uAPE.uDM1.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte8Value);
            DMValue512[64*i   +: 8] = Byte8Value[0] ;
            DMValue512[64*i+8 +: 8] = Byte8Value[1] ;
            DMValue512[64*i+16+: 8] = Byte8Value[2] ;
            DMValue512[64*i+24+: 8] = Byte8Value[3] ;
            DMValue512[64*i+32+: 8] = Byte8Value[4] ;
            DMValue512[64*i+40+: 8] = Byte8Value[5] ;
            DMValue512[64*i+48+: 8] = Byte8Value[6] ;
            DMValue512[64*i+56+: 8] = Byte8Value[7] ;
          end
        end
        3'd4: begin
          for(int i=0; i<4; i++) begin
            $root.TestTop.uAPE.uDM1.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte16Value);
            DMValue512[128*i    +: 8] = Byte16Value[0] ;
            DMValue512[128*i+  8+: 8] = Byte16Value[1] ;
            DMValue512[128*i+ 16+: 8] = Byte16Value[2] ;
            DMValue512[128*i+ 24+: 8] = Byte16Value[3] ;
            DMValue512[128*i+ 32+: 8] = Byte16Value[4] ;
            DMValue512[128*i+ 40+: 8] = Byte16Value[5] ;
            DMValue512[128*i+ 48+: 8] = Byte16Value[6] ;
            DMValue512[128*i+ 56+: 8] = Byte16Value[7] ;
            DMValue512[128*i+ 64+: 8] = Byte16Value[8] ;
            DMValue512[128*i+ 72+: 8] = Byte16Value[9] ;
            DMValue512[128*i+ 80+: 8] = Byte16Value[10] ;
            DMValue512[128*i+ 88+: 8] = Byte16Value[11] ;
            DMValue512[128*i+ 96+: 8] = Byte16Value[12] ;
            DMValue512[128*i+104+: 8] = Byte16Value[13] ;
            DMValue512[128*i+112+: 8] = Byte16Value[14] ;
            DMValue512[128*i+120+: 8] = Byte16Value[15] ;
          end
        end
        3'd5: begin
          for(int i=0; i<2; i++) begin
            $root.TestTop.uAPE.uDM1.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte32Value);
            DMValue512[256*i    +: 8] = Byte32Value[0] ;
            DMValue512[256*i+  8+: 8] = Byte32Value[1] ;
            DMValue512[256*i+ 16+: 8] = Byte32Value[2] ;
            DMValue512[256*i+ 24+: 8] = Byte32Value[3] ;
            DMValue512[256*i+ 32+: 8] = Byte32Value[4] ;
            DMValue512[256*i+ 40+: 8] = Byte32Value[5] ;
            DMValue512[256*i+ 48+: 8] = Byte32Value[6] ;
            DMValue512[256*i+ 56+: 8] = Byte32Value[7] ;
            DMValue512[256*i+ 64+: 8] = Byte32Value[8] ;
            DMValue512[256*i+ 72+: 8] = Byte32Value[9] ;
            DMValue512[256*i+ 80+: 8] = Byte32Value[10] ;
            DMValue512[256*i+ 88+: 8] = Byte32Value[11] ;
            DMValue512[256*i+ 96+: 8] = Byte32Value[12] ;
            DMValue512[256*i+104+: 8] = Byte32Value[13] ;
            DMValue512[256*i+112+: 8] = Byte32Value[14] ;
            DMValue512[256*i+120+: 8] = Byte32Value[15] ;
            DMValue512[256*i+128+: 8] = Byte32Value[16] ;
            DMValue512[256*i+136+: 8] = Byte32Value[17] ;
            DMValue512[256*i+144+: 8] = Byte32Value[18] ;
            DMValue512[256*i+152+: 8] = Byte32Value[19] ;
            DMValue512[256*i+160+: 8] = Byte32Value[20] ;
            DMValue512[256*i+168+: 8] = Byte32Value[21] ;
            DMValue512[256*i+176+: 8] = Byte32Value[22] ;
            DMValue512[256*i+184+: 8] = Byte32Value[23] ;
            DMValue512[256*i+192+: 8] = Byte32Value[24] ;
            DMValue512[256*i+200+: 8] = Byte32Value[25] ;
            DMValue512[256*i+208+: 8] = Byte32Value[26] ;
            DMValue512[256*i+216+: 8] = Byte32Value[27] ;
            DMValue512[256*i+224+: 8] = Byte32Value[28] ;
            DMValue512[256*i+232+: 8] = Byte32Value[29] ;
            DMValue512[256*i+240+: 8] = Byte32Value[30] ;
            DMValue512[256*i+248+: 8] = Byte32Value[31] ;
          end
        end
        3'd6: begin
          $root.TestTop.uAPE.uDM1.DMReadBytes(Addr+((1<<Size)*64)*0, Gran, Size, Byte64Value); 
          DMValue512[0  +: 8] = Byte64Value[0] ;
          DMValue512[8  +: 8] = Byte64Value[1] ;
          DMValue512[16 +: 8] = Byte64Value[2] ;
          DMValue512[24 +: 8] = Byte64Value[3] ;
          DMValue512[32 +: 8] = Byte64Value[4] ;
          DMValue512[40 +: 8] = Byte64Value[5] ;
          DMValue512[48 +: 8] = Byte64Value[6] ;
          DMValue512[56 +: 8] = Byte64Value[7] ;
          DMValue512[64 +: 8] = Byte64Value[8] ;
          DMValue512[72 +: 8] = Byte64Value[9] ;
          DMValue512[80 +: 8] = Byte64Value[10] ;
          DMValue512[88 +: 8] = Byte64Value[11] ;
          DMValue512[96 +: 8] = Byte64Value[12] ;
          DMValue512[104+: 8] = Byte64Value[13] ;
          DMValue512[112+: 8] = Byte64Value[14] ;
          DMValue512[120+: 8] = Byte64Value[15] ;
          DMValue512[128+: 8] = Byte64Value[16] ;
          DMValue512[136+: 8] = Byte64Value[17] ;
          DMValue512[144+: 8] = Byte64Value[18] ;
          DMValue512[152+: 8] = Byte64Value[19] ;
          DMValue512[160+: 8] = Byte64Value[20] ;
          DMValue512[168+: 8] = Byte64Value[21] ;
          DMValue512[176+: 8] = Byte64Value[22] ;
          DMValue512[184+: 8] = Byte64Value[23] ;
          DMValue512[192+: 8] = Byte64Value[24] ;
          DMValue512[200+: 8] = Byte64Value[25] ;
          DMValue512[208+: 8] = Byte64Value[26] ;
          DMValue512[216+: 8] = Byte64Value[27] ;
          DMValue512[224+: 8] = Byte64Value[28] ;
          DMValue512[232+: 8] = Byte64Value[29] ;
          DMValue512[240+: 8] = Byte64Value[30] ;
          DMValue512[248+: 8] = Byte64Value[31] ;
          DMValue512[256+: 8] = Byte64Value[32] ;
          DMValue512[264+: 8] = Byte64Value[33] ;
          DMValue512[272+: 8] = Byte64Value[34] ;
          DMValue512[280+: 8] = Byte64Value[35] ;
          DMValue512[288+: 8] = Byte64Value[36] ;
          DMValue512[296+: 8] = Byte64Value[37] ;
          DMValue512[304+: 8] = Byte64Value[38] ;
          DMValue512[312+: 8] = Byte64Value[39] ;
          DMValue512[320+: 8] = Byte64Value[40] ;
          DMValue512[328+: 8] = Byte64Value[41] ;
          DMValue512[336+: 8] = Byte64Value[42] ;
          DMValue512[344+: 8] = Byte64Value[43] ;
          DMValue512[352+: 8] = Byte64Value[44] ;
          DMValue512[360+: 8] = Byte64Value[45] ;
          DMValue512[368+: 8] = Byte64Value[46] ;
          DMValue512[376+: 8] = Byte64Value[47] ;
          DMValue512[384+: 8] = Byte64Value[48] ;
          DMValue512[392+: 8] = Byte64Value[49] ;
          DMValue512[400+: 8] = Byte64Value[50] ;
          DMValue512[408+: 8] = Byte64Value[51] ;
          DMValue512[416+: 8] = Byte64Value[52] ;
          DMValue512[424+: 8] = Byte64Value[53] ;
          DMValue512[432+: 8] = Byte64Value[54] ;
          DMValue512[440+: 8] = Byte64Value[55] ;
          DMValue512[448+: 8] = Byte64Value[56] ;
          DMValue512[456+: 8] = Byte64Value[57] ;
          DMValue512[464+: 8] = Byte64Value[58] ;
          DMValue512[472+: 8] = Byte64Value[59] ;
          DMValue512[480+: 8] = Byte64Value[60] ;
          DMValue512[488+: 8] = Byte64Value[61] ;
          DMValue512[496+: 8] = Byte64Value[62] ;
          DMValue512[504+: 8] = Byte64Value[63] ;
        end
        default: $display("The input of CGran is invalid !\n\n");
      endcase
      
      if(DMValue512 === ExpValue) $display("%0t Read DM1  OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
      else  begin
        $display("%0t Error @MPU_DC_PC = %h, Expected Value and Real Result are :", $realtime, MPUPC);
        Mon.display_512(ExpValue);
        Mon.display_512(DMValue512);
        $display(" ");
      end

      Byte1Value.delete();
      Byte2Value.delete();
      Byte4Value.delete();
      Byte8Value.delete();
      Byte16Value.delete();
      Byte32Value.delete();
      Byte64Value.delete();
   endtask

   task automatic CheckDM1Value_Mask(input int MPUPC, input int InstrCycle, input int Addr, input bit [2:0] Gran, input [3:0] Size, input [2:0] CGran, input bit[511:0] Mask, input bit [511:0] ExpValue);
      bit[511:0]   DMValue512;
      byte Byte1Value[];
      byte Byte2Value[];
      byte Byte4Value[];
      byte Byte8Value[];
      byte Byte16Value[];
      byte Byte32Value[];
      byte Byte64Value[];

      Byte1Value  = new[1];
      Byte2Value  = new[2];
      Byte4Value  = new[4];
      Byte8Value  = new[8];
      Byte16Value  = new[16];
      Byte32Value  = new[32];
      Byte64Value  = new[64];
      
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end
      
 		WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);

      case(CGran)
        3'd0: begin
          for(int i=0; i<64; i++) begin
            $root.TestTop.uAPE.uDM1.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte1Value);
            DMValue512[8*i +:8] = Byte1Value[0] ;
          end
        end
        3'd1: begin
          for(int i=0; i<32; i++) begin
            $root.TestTop.uAPE.uDM1.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte2Value);
            DMValue512[16*i   +: 8] = Byte2Value[0] ;
            DMValue512[16*i+8 +: 8] = Byte2Value[1] ;
          end
        end
        3'd2: begin
          for(int i=0; i<16; i++) begin
            $root.TestTop.uAPE.uDM1.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte4Value);
            DMValue512[32*i   +: 8] = Byte4Value[0] ;
            DMValue512[32*i+8 +: 8] = Byte4Value[1] ;
            DMValue512[32*i+16+: 8] = Byte4Value[2] ;
            DMValue512[32*i+24+: 8] = Byte4Value[3] ;
          end
        end
        3'd3: begin
          for(int i=0; i<8; i++) begin
            $root.TestTop.uAPE.uDM1.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte8Value);
            DMValue512[64*i   +: 8] = Byte8Value[0] ;
            DMValue512[64*i+8 +: 8] = Byte8Value[1] ;
            DMValue512[64*i+16+: 8] = Byte8Value[2] ;
            DMValue512[64*i+24+: 8] = Byte8Value[3] ;
            DMValue512[64*i+32+: 8] = Byte8Value[4] ;
            DMValue512[64*i+40+: 8] = Byte8Value[5] ;
            DMValue512[64*i+48+: 8] = Byte8Value[6] ;
            DMValue512[64*i+56+: 8] = Byte8Value[7] ;
          end
        end
        3'd4: begin
          for(int i=0; i<4; i++) begin
            $root.TestTop.uAPE.uDM1.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte16Value);
            DMValue512[128*i    +: 8] = Byte16Value[0] ;
            DMValue512[128*i+  8+: 8] = Byte16Value[1] ;
            DMValue512[128*i+ 16+: 8] = Byte16Value[2] ;
            DMValue512[128*i+ 24+: 8] = Byte16Value[3] ;
            DMValue512[128*i+ 32+: 8] = Byte16Value[4] ;
            DMValue512[128*i+ 40+: 8] = Byte16Value[5] ;
            DMValue512[128*i+ 48+: 8] = Byte16Value[6] ;
            DMValue512[128*i+ 56+: 8] = Byte16Value[7] ;
            DMValue512[128*i+ 64+: 8] = Byte16Value[8] ;
            DMValue512[128*i+ 72+: 8] = Byte16Value[9] ;
            DMValue512[128*i+ 80+: 8] = Byte16Value[10] ;
            DMValue512[128*i+ 88+: 8] = Byte16Value[11] ;
            DMValue512[128*i+ 96+: 8] = Byte16Value[12] ;
            DMValue512[128*i+104+: 8] = Byte16Value[13] ;
            DMValue512[128*i+112+: 8] = Byte16Value[14] ;
            DMValue512[128*i+120+: 8] = Byte16Value[15] ;
          end
        end
        3'd5: begin
          for(int i=0; i<2; i++) begin
            $root.TestTop.uAPE.uDM1.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte32Value);
            DMValue512[256*i    +: 8] = Byte32Value[0] ;
            DMValue512[256*i+  8+: 8] = Byte32Value[1] ;
            DMValue512[256*i+ 16+: 8] = Byte32Value[2] ;
            DMValue512[256*i+ 24+: 8] = Byte32Value[3] ;
            DMValue512[256*i+ 32+: 8] = Byte32Value[4] ;
            DMValue512[256*i+ 40+: 8] = Byte32Value[5] ;
            DMValue512[256*i+ 48+: 8] = Byte32Value[6] ;
            DMValue512[256*i+ 56+: 8] = Byte32Value[7] ;
            DMValue512[256*i+ 64+: 8] = Byte32Value[8] ;
            DMValue512[256*i+ 72+: 8] = Byte32Value[9] ;
            DMValue512[256*i+ 80+: 8] = Byte32Value[10] ;
            DMValue512[256*i+ 88+: 8] = Byte32Value[11] ;
            DMValue512[256*i+ 96+: 8] = Byte32Value[12] ;
            DMValue512[256*i+104+: 8] = Byte32Value[13] ;
            DMValue512[256*i+112+: 8] = Byte32Value[14] ;
            DMValue512[256*i+120+: 8] = Byte32Value[15] ;
            DMValue512[256*i+128+: 8] = Byte32Value[16] ;
            DMValue512[256*i+136+: 8] = Byte32Value[17] ;
            DMValue512[256*i+144+: 8] = Byte32Value[18] ;
            DMValue512[256*i+152+: 8] = Byte32Value[19] ;
            DMValue512[256*i+160+: 8] = Byte32Value[20] ;
            DMValue512[256*i+168+: 8] = Byte32Value[21] ;
            DMValue512[256*i+176+: 8] = Byte32Value[22] ;
            DMValue512[256*i+184+: 8] = Byte32Value[23] ;
            DMValue512[256*i+192+: 8] = Byte32Value[24] ;
            DMValue512[256*i+200+: 8] = Byte32Value[25] ;
            DMValue512[256*i+208+: 8] = Byte32Value[26] ;
            DMValue512[256*i+216+: 8] = Byte32Value[27] ;
            DMValue512[256*i+224+: 8] = Byte32Value[28] ;
            DMValue512[256*i+232+: 8] = Byte32Value[29] ;
            DMValue512[256*i+240+: 8] = Byte32Value[30] ;
            DMValue512[256*i+248+: 8] = Byte32Value[31] ;
          end
        end
        3'd6: begin
          $root.TestTop.uAPE.uDM1.DMReadBytes(Addr+((1<<Size)*64)*0, Gran, Size, Byte64Value); 
          DMValue512[0  +: 8] = Byte64Value[0] ;
          DMValue512[8  +: 8] = Byte64Value[1] ;
          DMValue512[16 +: 8] = Byte64Value[2] ;
          DMValue512[24 +: 8] = Byte64Value[3] ;
          DMValue512[32 +: 8] = Byte64Value[4] ;
          DMValue512[40 +: 8] = Byte64Value[5] ;
          DMValue512[48 +: 8] = Byte64Value[6] ;
          DMValue512[56 +: 8] = Byte64Value[7] ;
          DMValue512[64 +: 8] = Byte64Value[8] ;
          DMValue512[72 +: 8] = Byte64Value[9] ;
          DMValue512[80 +: 8] = Byte64Value[10] ;
          DMValue512[88 +: 8] = Byte64Value[11] ;
          DMValue512[96 +: 8] = Byte64Value[12] ;
          DMValue512[104+: 8] = Byte64Value[13] ;
          DMValue512[112+: 8] = Byte64Value[14] ;
          DMValue512[120+: 8] = Byte64Value[15] ;
          DMValue512[128+: 8] = Byte64Value[16] ;
          DMValue512[136+: 8] = Byte64Value[17] ;
          DMValue512[144+: 8] = Byte64Value[18] ;
          DMValue512[152+: 8] = Byte64Value[19] ;
          DMValue512[160+: 8] = Byte64Value[20] ;
          DMValue512[168+: 8] = Byte64Value[21] ;
          DMValue512[176+: 8] = Byte64Value[22] ;
          DMValue512[184+: 8] = Byte64Value[23] ;
          DMValue512[192+: 8] = Byte64Value[24] ;
          DMValue512[200+: 8] = Byte64Value[25] ;
          DMValue512[208+: 8] = Byte64Value[26] ;
          DMValue512[216+: 8] = Byte64Value[27] ;
          DMValue512[224+: 8] = Byte64Value[28] ;
          DMValue512[232+: 8] = Byte64Value[29] ;
          DMValue512[240+: 8] = Byte64Value[30] ;
          DMValue512[248+: 8] = Byte64Value[31] ;
          DMValue512[256+: 8] = Byte64Value[32] ;
          DMValue512[264+: 8] = Byte64Value[33] ;
          DMValue512[272+: 8] = Byte64Value[34] ;
          DMValue512[280+: 8] = Byte64Value[35] ;
          DMValue512[288+: 8] = Byte64Value[36] ;
          DMValue512[296+: 8] = Byte64Value[37] ;
          DMValue512[304+: 8] = Byte64Value[38] ;
          DMValue512[312+: 8] = Byte64Value[39] ;
          DMValue512[320+: 8] = Byte64Value[40] ;
          DMValue512[328+: 8] = Byte64Value[41] ;
          DMValue512[336+: 8] = Byte64Value[42] ;
          DMValue512[344+: 8] = Byte64Value[43] ;
          DMValue512[352+: 8] = Byte64Value[44] ;
          DMValue512[360+: 8] = Byte64Value[45] ;
          DMValue512[368+: 8] = Byte64Value[46] ;
          DMValue512[376+: 8] = Byte64Value[47] ;
          DMValue512[384+: 8] = Byte64Value[48] ;
          DMValue512[392+: 8] = Byte64Value[49] ;
          DMValue512[400+: 8] = Byte64Value[50] ;
          DMValue512[408+: 8] = Byte64Value[51] ;
          DMValue512[416+: 8] = Byte64Value[52] ;
          DMValue512[424+: 8] = Byte64Value[53] ;
          DMValue512[432+: 8] = Byte64Value[54] ;
          DMValue512[440+: 8] = Byte64Value[55] ;
          DMValue512[448+: 8] = Byte64Value[56] ;
          DMValue512[456+: 8] = Byte64Value[57] ;
          DMValue512[464+: 8] = Byte64Value[58] ;
          DMValue512[472+: 8] = Byte64Value[59] ;
          DMValue512[480+: 8] = Byte64Value[60] ;
          DMValue512[488+: 8] = Byte64Value[61] ;
          DMValue512[496+: 8] = Byte64Value[62] ;
          DMValue512[504+: 8] = Byte64Value[63] ;
        end
        default: $display("The input of CGran is invalid !\n\n");
      endcase
      
      if((DMValue512&Mask) === ExpValue) $display("%0t Read DM1  OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
      else  begin
        $display("%0t Error @MPU_DC_PC = %h, Expected Value and Real Result are :", $realtime, MPUPC);
        Mon.display_512(ExpValue);
        Mon.display_512(DMValue512&Mask);
        $display(" ");
      end

      Byte1Value.delete();
      Byte2Value.delete();
      Byte4Value.delete();
      Byte8Value.delete();
      Byte16Value.delete();
      Byte32Value.delete();
      Byte64Value.delete();
   endtask

   task automatic Check2DM1Value(input int MPUPC, input int InstrCycle, input int Addr, input bit [2:0] Gran, input [3:0] Size, input [2:0] CGran, input bit [511:0] ExpValue);
      bit[511:0]   DMValue512;
      byte Byte1Value[];
      byte Byte2Value[];
      byte Byte4Value[];
      byte Byte8Value[];
      byte Byte16Value[];
      byte Byte32Value[];
      byte Byte64Value[];

      Byte1Value  = new[1];
      Byte2Value  = new[2];
      Byte4Value  = new[4];
      Byte8Value  = new[8];
      Byte16Value  = new[16];
      Byte32Value  = new[32];
      Byte64Value  = new[64];
      
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end
      WaitMPUCycles(InstrCycle);

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end
 		WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);

      case(CGran)
        3'd0: begin
          for(int i=0; i<64; i++) begin
            $root.TestTop.uAPE.uDM1.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte1Value);
            DMValue512[8*i +:8] = Byte1Value[0] ;
          end
        end
        3'd1: begin
          for(int i=0; i<32; i++) begin
            $root.TestTop.uAPE.uDM1.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte2Value);
            DMValue512[16*i   +: 8] = Byte2Value[0] ;
            DMValue512[16*i+8 +: 8] = Byte2Value[1] ;
          end
        end
        3'd2: begin
          for(int i=0; i<16; i++) begin
            $root.TestTop.uAPE.uDM1.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte4Value);
            DMValue512[32*i   +: 8] = Byte4Value[0] ;
            DMValue512[32*i+8 +: 8] = Byte4Value[1] ;
            DMValue512[32*i+16+: 8] = Byte4Value[2] ;
            DMValue512[32*i+24+: 8] = Byte4Value[3] ;
          end
        end
        3'd3: begin
          for(int i=0; i<8; i++) begin
            $root.TestTop.uAPE.uDM1.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte8Value);
            DMValue512[64*i   +: 8] = Byte8Value[0] ;
            DMValue512[64*i+8 +: 8] = Byte8Value[1] ;
            DMValue512[64*i+16+: 8] = Byte8Value[2] ;
            DMValue512[64*i+24+: 8] = Byte8Value[3] ;
            DMValue512[64*i+32+: 8] = Byte8Value[4] ;
            DMValue512[64*i+40+: 8] = Byte8Value[5] ;
            DMValue512[64*i+48+: 8] = Byte8Value[6] ;
            DMValue512[64*i+56+: 8] = Byte8Value[7] ;
          end
        end
        3'd4: begin
          for(int i=0; i<4; i++) begin
            $root.TestTop.uAPE.uDM1.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte16Value);
            DMValue512[128*i    +: 8] = Byte16Value[0] ;
            DMValue512[128*i+  8+: 8] = Byte16Value[1] ;
            DMValue512[128*i+ 16+: 8] = Byte16Value[2] ;
            DMValue512[128*i+ 24+: 8] = Byte16Value[3] ;
            DMValue512[128*i+ 32+: 8] = Byte16Value[4] ;
            DMValue512[128*i+ 40+: 8] = Byte16Value[5] ;
            DMValue512[128*i+ 48+: 8] = Byte16Value[6] ;
            DMValue512[128*i+ 56+: 8] = Byte16Value[7] ;
            DMValue512[128*i+ 64+: 8] = Byte16Value[8] ;
            DMValue512[128*i+ 72+: 8] = Byte16Value[9] ;
            DMValue512[128*i+ 80+: 8] = Byte16Value[10] ;
            DMValue512[128*i+ 88+: 8] = Byte16Value[11] ;
            DMValue512[128*i+ 96+: 8] = Byte16Value[12] ;
            DMValue512[128*i+104+: 8] = Byte16Value[13] ;
            DMValue512[128*i+112+: 8] = Byte16Value[14] ;
            DMValue512[128*i+120+: 8] = Byte16Value[15] ;
          end
        end
        3'd5: begin
          for(int i=0; i<2; i++) begin
            $root.TestTop.uAPE.uDM1.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte32Value);
            DMValue512[256*i    +: 8] = Byte32Value[0] ;
            DMValue512[256*i+  8+: 8] = Byte32Value[1] ;
            DMValue512[256*i+ 16+: 8] = Byte32Value[2] ;
            DMValue512[256*i+ 24+: 8] = Byte32Value[3] ;
            DMValue512[256*i+ 32+: 8] = Byte32Value[4] ;
            DMValue512[256*i+ 40+: 8] = Byte32Value[5] ;
            DMValue512[256*i+ 48+: 8] = Byte32Value[6] ;
            DMValue512[256*i+ 56+: 8] = Byte32Value[7] ;
            DMValue512[256*i+ 64+: 8] = Byte32Value[8] ;
            DMValue512[256*i+ 72+: 8] = Byte32Value[9] ;
            DMValue512[256*i+ 80+: 8] = Byte32Value[10] ;
            DMValue512[256*i+ 88+: 8] = Byte32Value[11] ;
            DMValue512[256*i+ 96+: 8] = Byte32Value[12] ;
            DMValue512[256*i+104+: 8] = Byte32Value[13] ;
            DMValue512[256*i+112+: 8] = Byte32Value[14] ;
            DMValue512[256*i+120+: 8] = Byte32Value[15] ;
            DMValue512[256*i+128+: 8] = Byte32Value[16] ;
            DMValue512[256*i+136+: 8] = Byte32Value[17] ;
            DMValue512[256*i+144+: 8] = Byte32Value[18] ;
            DMValue512[256*i+152+: 8] = Byte32Value[19] ;
            DMValue512[256*i+160+: 8] = Byte32Value[20] ;
            DMValue512[256*i+168+: 8] = Byte32Value[21] ;
            DMValue512[256*i+176+: 8] = Byte32Value[22] ;
            DMValue512[256*i+184+: 8] = Byte32Value[23] ;
            DMValue512[256*i+192+: 8] = Byte32Value[24] ;
            DMValue512[256*i+200+: 8] = Byte32Value[25] ;
            DMValue512[256*i+208+: 8] = Byte32Value[26] ;
            DMValue512[256*i+216+: 8] = Byte32Value[27] ;
            DMValue512[256*i+224+: 8] = Byte32Value[28] ;
            DMValue512[256*i+232+: 8] = Byte32Value[29] ;
            DMValue512[256*i+240+: 8] = Byte32Value[30] ;
            DMValue512[256*i+248+: 8] = Byte32Value[31] ;
          end
        end
        3'd6: begin
          $root.TestTop.uAPE.uDM1.DMReadBytes(Addr+((1<<Size)*64)*0, Gran, Size, Byte64Value); 
          DMValue512[0  +: 8] = Byte64Value[0] ;
          DMValue512[8  +: 8] = Byte64Value[1] ;
          DMValue512[16 +: 8] = Byte64Value[2] ;
          DMValue512[24 +: 8] = Byte64Value[3] ;
          DMValue512[32 +: 8] = Byte64Value[4] ;
          DMValue512[40 +: 8] = Byte64Value[5] ;
          DMValue512[48 +: 8] = Byte64Value[6] ;
          DMValue512[56 +: 8] = Byte64Value[7] ;
          DMValue512[64 +: 8] = Byte64Value[8] ;
          DMValue512[72 +: 8] = Byte64Value[9] ;
          DMValue512[80 +: 8] = Byte64Value[10] ;
          DMValue512[88 +: 8] = Byte64Value[11] ;
          DMValue512[96 +: 8] = Byte64Value[12] ;
          DMValue512[104+: 8] = Byte64Value[13] ;
          DMValue512[112+: 8] = Byte64Value[14] ;
          DMValue512[120+: 8] = Byte64Value[15] ;
          DMValue512[128+: 8] = Byte64Value[16] ;
          DMValue512[136+: 8] = Byte64Value[17] ;
          DMValue512[144+: 8] = Byte64Value[18] ;
          DMValue512[152+: 8] = Byte64Value[19] ;
          DMValue512[160+: 8] = Byte64Value[20] ;
          DMValue512[168+: 8] = Byte64Value[21] ;
          DMValue512[176+: 8] = Byte64Value[22] ;
          DMValue512[184+: 8] = Byte64Value[23] ;
          DMValue512[192+: 8] = Byte64Value[24] ;
          DMValue512[200+: 8] = Byte64Value[25] ;
          DMValue512[208+: 8] = Byte64Value[26] ;
          DMValue512[216+: 8] = Byte64Value[27] ;
          DMValue512[224+: 8] = Byte64Value[28] ;
          DMValue512[232+: 8] = Byte64Value[29] ;
          DMValue512[240+: 8] = Byte64Value[30] ;
          DMValue512[248+: 8] = Byte64Value[31] ;
          DMValue512[256+: 8] = Byte64Value[32] ;
          DMValue512[264+: 8] = Byte64Value[33] ;
          DMValue512[272+: 8] = Byte64Value[34] ;
          DMValue512[280+: 8] = Byte64Value[35] ;
          DMValue512[288+: 8] = Byte64Value[36] ;
          DMValue512[296+: 8] = Byte64Value[37] ;
          DMValue512[304+: 8] = Byte64Value[38] ;
          DMValue512[312+: 8] = Byte64Value[39] ;
          DMValue512[320+: 8] = Byte64Value[40] ;
          DMValue512[328+: 8] = Byte64Value[41] ;
          DMValue512[336+: 8] = Byte64Value[42] ;
          DMValue512[344+: 8] = Byte64Value[43] ;
          DMValue512[352+: 8] = Byte64Value[44] ;
          DMValue512[360+: 8] = Byte64Value[45] ;
          DMValue512[368+: 8] = Byte64Value[46] ;
          DMValue512[376+: 8] = Byte64Value[47] ;
          DMValue512[384+: 8] = Byte64Value[48] ;
          DMValue512[392+: 8] = Byte64Value[49] ;
          DMValue512[400+: 8] = Byte64Value[50] ;
          DMValue512[408+: 8] = Byte64Value[51] ;
          DMValue512[416+: 8] = Byte64Value[52] ;
          DMValue512[424+: 8] = Byte64Value[53] ;
          DMValue512[432+: 8] = Byte64Value[54] ;
          DMValue512[440+: 8] = Byte64Value[55] ;
          DMValue512[448+: 8] = Byte64Value[56] ;
          DMValue512[456+: 8] = Byte64Value[57] ;
          DMValue512[464+: 8] = Byte64Value[58] ;
          DMValue512[472+: 8] = Byte64Value[59] ;
          DMValue512[480+: 8] = Byte64Value[60] ;
          DMValue512[488+: 8] = Byte64Value[61] ;
          DMValue512[496+: 8] = Byte64Value[62] ;
          DMValue512[504+: 8] = Byte64Value[63] ;
        end
        default: $display("The input of CGran is invalid !\n\n");
      endcase
      
      if(DMValue512 === ExpValue) $display("%0t Read DM1  OK @MPU_DC_PC = %h second time!!", $realtime, MPUPC);
      else  begin
        $display("%0t Error @MPU_DC_PC = %h second time, Expected Value and Real Result are :", $realtime, MPUPC);
        Mon.display_512(ExpValue);
        Mon.display_512(DMValue512);
        $display(" ");
      end

      Byte1Value.delete();
      Byte2Value.delete();
      Byte4Value.delete();
      Byte8Value.delete();
      Byte16Value.delete();
      Byte32Value.delete();
      Byte64Value.delete();
   endtask

   task automatic CheckDM2Value(input int MPUPC, input int InstrCycle, input int Addr, input bit [2:0] Gran, input [3:0] Size, input [2:0] CGran, input bit [511:0] ExpValue);
      bit[511:0]   DMValue512;
      byte Byte1Value[];
      byte Byte2Value[];
      byte Byte4Value[];
      byte Byte8Value[];
      byte Byte16Value[];
      byte Byte32Value[];
      byte Byte64Value[];

      Byte1Value  = new[1];
      Byte2Value  = new[2];
      Byte4Value  = new[4];
      Byte8Value  = new[8];
      Byte16Value  = new[16];
      Byte32Value  = new[32];
      Byte64Value  = new[64];
      
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end
      
 		WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);

      case(CGran)
        3'd0: begin
          for(int i=0; i<64; i++) begin
            $root.TestTop.uAPE.uDM2.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte1Value);
            DMValue512[8*i +:8] = Byte1Value[0] ;
          end
        end
        3'd1: begin
          for(int i=0; i<32; i++) begin
            $root.TestTop.uAPE.uDM2.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte2Value);
            DMValue512[16*i   +: 8] = Byte2Value[0] ;
            DMValue512[16*i+8 +: 8] = Byte2Value[1] ;
          end
        end
        3'd2: begin
          for(int i=0; i<16; i++) begin
            $root.TestTop.uAPE.uDM2.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte4Value);
            DMValue512[32*i   +: 8] = Byte4Value[0] ;
            DMValue512[32*i+8 +: 8] = Byte4Value[1] ;
            DMValue512[32*i+16+: 8] = Byte4Value[2] ;
            DMValue512[32*i+24+: 8] = Byte4Value[3] ;
          end
        end
        3'd3: begin
          for(int i=0; i<8; i++) begin
            $root.TestTop.uAPE.uDM2.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte8Value);
            DMValue512[64*i   +: 8] = Byte8Value[0] ;
            DMValue512[64*i+8 +: 8] = Byte8Value[1] ;
            DMValue512[64*i+16+: 8] = Byte8Value[2] ;
            DMValue512[64*i+24+: 8] = Byte8Value[3] ;
            DMValue512[64*i+32+: 8] = Byte8Value[4] ;
            DMValue512[64*i+40+: 8] = Byte8Value[5] ;
            DMValue512[64*i+48+: 8] = Byte8Value[6] ;
            DMValue512[64*i+56+: 8] = Byte8Value[7] ;
          end
        end
        3'd4: begin
          for(int i=0; i<4; i++) begin
            $root.TestTop.uAPE.uDM2.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte16Value);
            DMValue512[128*i    +: 8] = Byte16Value[0] ;
            DMValue512[128*i+  8+: 8] = Byte16Value[1] ;
            DMValue512[128*i+ 16+: 8] = Byte16Value[2] ;
            DMValue512[128*i+ 24+: 8] = Byte16Value[3] ;
            DMValue512[128*i+ 32+: 8] = Byte16Value[4] ;
            DMValue512[128*i+ 40+: 8] = Byte16Value[5] ;
            DMValue512[128*i+ 48+: 8] = Byte16Value[6] ;
            DMValue512[128*i+ 56+: 8] = Byte16Value[7] ;
            DMValue512[128*i+ 64+: 8] = Byte16Value[8] ;
            DMValue512[128*i+ 72+: 8] = Byte16Value[9] ;
            DMValue512[128*i+ 80+: 8] = Byte16Value[10] ;
            DMValue512[128*i+ 88+: 8] = Byte16Value[11] ;
            DMValue512[128*i+ 96+: 8] = Byte16Value[12] ;
            DMValue512[128*i+104+: 8] = Byte16Value[13] ;
            DMValue512[128*i+112+: 8] = Byte16Value[14] ;
            DMValue512[128*i+120+: 8] = Byte16Value[15] ;
          end
        end
        3'd5: begin
          for(int i=0; i<2; i++) begin
            $root.TestTop.uAPE.uDM2.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte32Value);
            DMValue512[256*i    +: 8] = Byte32Value[0] ;
            DMValue512[256*i+  8+: 8] = Byte32Value[1] ;
            DMValue512[256*i+ 16+: 8] = Byte32Value[2] ;
            DMValue512[256*i+ 24+: 8] = Byte32Value[3] ;
            DMValue512[256*i+ 32+: 8] = Byte32Value[4] ;
            DMValue512[256*i+ 40+: 8] = Byte32Value[5] ;
            DMValue512[256*i+ 48+: 8] = Byte32Value[6] ;
            DMValue512[256*i+ 56+: 8] = Byte32Value[7] ;
            DMValue512[256*i+ 64+: 8] = Byte32Value[8] ;
            DMValue512[256*i+ 72+: 8] = Byte32Value[9] ;
            DMValue512[256*i+ 80+: 8] = Byte32Value[10] ;
            DMValue512[256*i+ 88+: 8] = Byte32Value[11] ;
            DMValue512[256*i+ 96+: 8] = Byte32Value[12] ;
            DMValue512[256*i+104+: 8] = Byte32Value[13] ;
            DMValue512[256*i+112+: 8] = Byte32Value[14] ;
            DMValue512[256*i+120+: 8] = Byte32Value[15] ;
            DMValue512[256*i+128+: 8] = Byte32Value[16] ;
            DMValue512[256*i+136+: 8] = Byte32Value[17] ;
            DMValue512[256*i+144+: 8] = Byte32Value[18] ;
            DMValue512[256*i+152+: 8] = Byte32Value[19] ;
            DMValue512[256*i+160+: 8] = Byte32Value[20] ;
            DMValue512[256*i+168+: 8] = Byte32Value[21] ;
            DMValue512[256*i+176+: 8] = Byte32Value[22] ;
            DMValue512[256*i+184+: 8] = Byte32Value[23] ;
            DMValue512[256*i+192+: 8] = Byte32Value[24] ;
            DMValue512[256*i+200+: 8] = Byte32Value[25] ;
            DMValue512[256*i+208+: 8] = Byte32Value[26] ;
            DMValue512[256*i+216+: 8] = Byte32Value[27] ;
            DMValue512[256*i+224+: 8] = Byte32Value[28] ;
            DMValue512[256*i+232+: 8] = Byte32Value[29] ;
            DMValue512[256*i+240+: 8] = Byte32Value[30] ;
            DMValue512[256*i+248+: 8] = Byte32Value[31] ;
          end
        end
        3'd6: begin
          $root.TestTop.uAPE.uDM2.DMReadBytes(Addr+((1<<Size)*64)*0, Gran, Size, Byte64Value); 
          DMValue512[0  +: 8] = Byte64Value[0] ;
          DMValue512[8  +: 8] = Byte64Value[1] ;
          DMValue512[16 +: 8] = Byte64Value[2] ;
          DMValue512[24 +: 8] = Byte64Value[3] ;
          DMValue512[32 +: 8] = Byte64Value[4] ;
          DMValue512[40 +: 8] = Byte64Value[5] ;
          DMValue512[48 +: 8] = Byte64Value[6] ;
          DMValue512[56 +: 8] = Byte64Value[7] ;
          DMValue512[64 +: 8] = Byte64Value[8] ;
          DMValue512[72 +: 8] = Byte64Value[9] ;
          DMValue512[80 +: 8] = Byte64Value[10] ;
          DMValue512[88 +: 8] = Byte64Value[11] ;
          DMValue512[96 +: 8] = Byte64Value[12] ;
          DMValue512[104+: 8] = Byte64Value[13] ;
          DMValue512[112+: 8] = Byte64Value[14] ;
          DMValue512[120+: 8] = Byte64Value[15] ;
          DMValue512[128+: 8] = Byte64Value[16] ;
          DMValue512[136+: 8] = Byte64Value[17] ;
          DMValue512[144+: 8] = Byte64Value[18] ;
          DMValue512[152+: 8] = Byte64Value[19] ;
          DMValue512[160+: 8] = Byte64Value[20] ;
          DMValue512[168+: 8] = Byte64Value[21] ;
          DMValue512[176+: 8] = Byte64Value[22] ;
          DMValue512[184+: 8] = Byte64Value[23] ;
          DMValue512[192+: 8] = Byte64Value[24] ;
          DMValue512[200+: 8] = Byte64Value[25] ;
          DMValue512[208+: 8] = Byte64Value[26] ;
          DMValue512[216+: 8] = Byte64Value[27] ;
          DMValue512[224+: 8] = Byte64Value[28] ;
          DMValue512[232+: 8] = Byte64Value[29] ;
          DMValue512[240+: 8] = Byte64Value[30] ;
          DMValue512[248+: 8] = Byte64Value[31] ;
          DMValue512[256+: 8] = Byte64Value[32] ;
          DMValue512[264+: 8] = Byte64Value[33] ;
          DMValue512[272+: 8] = Byte64Value[34] ;
          DMValue512[280+: 8] = Byte64Value[35] ;
          DMValue512[288+: 8] = Byte64Value[36] ;
          DMValue512[296+: 8] = Byte64Value[37] ;
          DMValue512[304+: 8] = Byte64Value[38] ;
          DMValue512[312+: 8] = Byte64Value[39] ;
          DMValue512[320+: 8] = Byte64Value[40] ;
          DMValue512[328+: 8] = Byte64Value[41] ;
          DMValue512[336+: 8] = Byte64Value[42] ;
          DMValue512[344+: 8] = Byte64Value[43] ;
          DMValue512[352+: 8] = Byte64Value[44] ;
          DMValue512[360+: 8] = Byte64Value[45] ;
          DMValue512[368+: 8] = Byte64Value[46] ;
          DMValue512[376+: 8] = Byte64Value[47] ;
          DMValue512[384+: 8] = Byte64Value[48] ;
          DMValue512[392+: 8] = Byte64Value[49] ;
          DMValue512[400+: 8] = Byte64Value[50] ;
          DMValue512[408+: 8] = Byte64Value[51] ;
          DMValue512[416+: 8] = Byte64Value[52] ;
          DMValue512[424+: 8] = Byte64Value[53] ;
          DMValue512[432+: 8] = Byte64Value[54] ;
          DMValue512[440+: 8] = Byte64Value[55] ;
          DMValue512[448+: 8] = Byte64Value[56] ;
          DMValue512[456+: 8] = Byte64Value[57] ;
          DMValue512[464+: 8] = Byte64Value[58] ;
          DMValue512[472+: 8] = Byte64Value[59] ;
          DMValue512[480+: 8] = Byte64Value[60] ;
          DMValue512[488+: 8] = Byte64Value[61] ;
          DMValue512[496+: 8] = Byte64Value[62] ;
          DMValue512[504+: 8] = Byte64Value[63] ;
        end
        default: $display("The input of CGran is invalid !\n\n");
      endcase
      
      if(DMValue512 === ExpValue) $display("%0t Read DM  OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
      else  begin
        $display("%0t Error @MPU_DC_PC = %h, Expected Value and Real Result are :", $realtime, MPUPC);
        Mon.display_512(ExpValue);
        Mon.display_512(DMValue512);
        $display(" ");
      end

      Byte1Value.delete();
      Byte2Value.delete();
      Byte4Value.delete();
      Byte8Value.delete();
      Byte16Value.delete();
      Byte32Value.delete();
      Byte64Value.delete();
   endtask

   task automatic CheckDM2Value_Mask(input int MPUPC, input int InstrCycle, input int Addr, input bit [2:0] Gran, input [3:0] Size, input [2:0] CGran, input bit[511:0] Mask, input bit [511:0] ExpValue);
      bit[511:0]   DMValue512;
      byte Byte1Value[];
      byte Byte2Value[];
      byte Byte4Value[];
      byte Byte8Value[];
      byte Byte16Value[];
      byte Byte32Value[];
      byte Byte64Value[];

      Byte1Value  = new[1];
      Byte2Value  = new[2];
      Byte4Value  = new[4];
      Byte8Value  = new[8];
      Byte16Value  = new[16];
      Byte32Value  = new[32];
      Byte64Value  = new[64];
      
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end
      
 		WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);

      case(CGran)
        3'd0: begin
          for(int i=0; i<64; i++) begin
            $root.TestTop.uAPE.uDM2.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte1Value);
            DMValue512[8*i +:8] = Byte1Value[0] ;
          end
        end
        3'd1: begin
          for(int i=0; i<32; i++) begin
            $root.TestTop.uAPE.uDM2.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte2Value);
            DMValue512[16*i   +: 8] = Byte2Value[0] ;
            DMValue512[16*i+8 +: 8] = Byte2Value[1] ;
          end
        end
        3'd2: begin
          for(int i=0; i<16; i++) begin
            $root.TestTop.uAPE.uDM2.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte4Value);
            DMValue512[32*i   +: 8] = Byte4Value[0] ;
            DMValue512[32*i+8 +: 8] = Byte4Value[1] ;
            DMValue512[32*i+16+: 8] = Byte4Value[2] ;
            DMValue512[32*i+24+: 8] = Byte4Value[3] ;
          end
        end
        3'd3: begin
          for(int i=0; i<8; i++) begin
            $root.TestTop.uAPE.uDM2.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte8Value);
            DMValue512[64*i   +: 8] = Byte8Value[0] ;
            DMValue512[64*i+8 +: 8] = Byte8Value[1] ;
            DMValue512[64*i+16+: 8] = Byte8Value[2] ;
            DMValue512[64*i+24+: 8] = Byte8Value[3] ;
            DMValue512[64*i+32+: 8] = Byte8Value[4] ;
            DMValue512[64*i+40+: 8] = Byte8Value[5] ;
            DMValue512[64*i+48+: 8] = Byte8Value[6] ;
            DMValue512[64*i+56+: 8] = Byte8Value[7] ;
          end
        end
        3'd4: begin
          for(int i=0; i<4; i++) begin
            $root.TestTop.uAPE.uDM2.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte16Value);
            DMValue512[128*i    +: 8] = Byte16Value[0] ;
            DMValue512[128*i+  8+: 8] = Byte16Value[1] ;
            DMValue512[128*i+ 16+: 8] = Byte16Value[2] ;
            DMValue512[128*i+ 24+: 8] = Byte16Value[3] ;
            DMValue512[128*i+ 32+: 8] = Byte16Value[4] ;
            DMValue512[128*i+ 40+: 8] = Byte16Value[5] ;
            DMValue512[128*i+ 48+: 8] = Byte16Value[6] ;
            DMValue512[128*i+ 56+: 8] = Byte16Value[7] ;
            DMValue512[128*i+ 64+: 8] = Byte16Value[8] ;
            DMValue512[128*i+ 72+: 8] = Byte16Value[9] ;
            DMValue512[128*i+ 80+: 8] = Byte16Value[10] ;
            DMValue512[128*i+ 88+: 8] = Byte16Value[11] ;
            DMValue512[128*i+ 96+: 8] = Byte16Value[12] ;
            DMValue512[128*i+104+: 8] = Byte16Value[13] ;
            DMValue512[128*i+112+: 8] = Byte16Value[14] ;
            DMValue512[128*i+120+: 8] = Byte16Value[15] ;
          end
        end
        3'd5: begin
          for(int i=0; i<2; i++) begin
            $root.TestTop.uAPE.uDM2.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte32Value);
            DMValue512[256*i    +: 8] = Byte32Value[0] ;
            DMValue512[256*i+  8+: 8] = Byte32Value[1] ;
            DMValue512[256*i+ 16+: 8] = Byte32Value[2] ;
            DMValue512[256*i+ 24+: 8] = Byte32Value[3] ;
            DMValue512[256*i+ 32+: 8] = Byte32Value[4] ;
            DMValue512[256*i+ 40+: 8] = Byte32Value[5] ;
            DMValue512[256*i+ 48+: 8] = Byte32Value[6] ;
            DMValue512[256*i+ 56+: 8] = Byte32Value[7] ;
            DMValue512[256*i+ 64+: 8] = Byte32Value[8] ;
            DMValue512[256*i+ 72+: 8] = Byte32Value[9] ;
            DMValue512[256*i+ 80+: 8] = Byte32Value[10] ;
            DMValue512[256*i+ 88+: 8] = Byte32Value[11] ;
            DMValue512[256*i+ 96+: 8] = Byte32Value[12] ;
            DMValue512[256*i+104+: 8] = Byte32Value[13] ;
            DMValue512[256*i+112+: 8] = Byte32Value[14] ;
            DMValue512[256*i+120+: 8] = Byte32Value[15] ;
            DMValue512[256*i+128+: 8] = Byte32Value[16] ;
            DMValue512[256*i+136+: 8] = Byte32Value[17] ;
            DMValue512[256*i+144+: 8] = Byte32Value[18] ;
            DMValue512[256*i+152+: 8] = Byte32Value[19] ;
            DMValue512[256*i+160+: 8] = Byte32Value[20] ;
            DMValue512[256*i+168+: 8] = Byte32Value[21] ;
            DMValue512[256*i+176+: 8] = Byte32Value[22] ;
            DMValue512[256*i+184+: 8] = Byte32Value[23] ;
            DMValue512[256*i+192+: 8] = Byte32Value[24] ;
            DMValue512[256*i+200+: 8] = Byte32Value[25] ;
            DMValue512[256*i+208+: 8] = Byte32Value[26] ;
            DMValue512[256*i+216+: 8] = Byte32Value[27] ;
            DMValue512[256*i+224+: 8] = Byte32Value[28] ;
            DMValue512[256*i+232+: 8] = Byte32Value[29] ;
            DMValue512[256*i+240+: 8] = Byte32Value[30] ;
            DMValue512[256*i+248+: 8] = Byte32Value[31] ;
          end
        end
        3'd6: begin
          $root.TestTop.uAPE.uDM2.DMReadBytes(Addr+((1<<Size)*64)*0, Gran, Size, Byte64Value); 
          DMValue512[0  +: 8] = Byte64Value[0] ;
          DMValue512[8  +: 8] = Byte64Value[1] ;
          DMValue512[16 +: 8] = Byte64Value[2] ;
          DMValue512[24 +: 8] = Byte64Value[3] ;
          DMValue512[32 +: 8] = Byte64Value[4] ;
          DMValue512[40 +: 8] = Byte64Value[5] ;
          DMValue512[48 +: 8] = Byte64Value[6] ;
          DMValue512[56 +: 8] = Byte64Value[7] ;
          DMValue512[64 +: 8] = Byte64Value[8] ;
          DMValue512[72 +: 8] = Byte64Value[9] ;
          DMValue512[80 +: 8] = Byte64Value[10] ;
          DMValue512[88 +: 8] = Byte64Value[11] ;
          DMValue512[96 +: 8] = Byte64Value[12] ;
          DMValue512[104+: 8] = Byte64Value[13] ;
          DMValue512[112+: 8] = Byte64Value[14] ;
          DMValue512[120+: 8] = Byte64Value[15] ;
          DMValue512[128+: 8] = Byte64Value[16] ;
          DMValue512[136+: 8] = Byte64Value[17] ;
          DMValue512[144+: 8] = Byte64Value[18] ;
          DMValue512[152+: 8] = Byte64Value[19] ;
          DMValue512[160+: 8] = Byte64Value[20] ;
          DMValue512[168+: 8] = Byte64Value[21] ;
          DMValue512[176+: 8] = Byte64Value[22] ;
          DMValue512[184+: 8] = Byte64Value[23] ;
          DMValue512[192+: 8] = Byte64Value[24] ;
          DMValue512[200+: 8] = Byte64Value[25] ;
          DMValue512[208+: 8] = Byte64Value[26] ;
          DMValue512[216+: 8] = Byte64Value[27] ;
          DMValue512[224+: 8] = Byte64Value[28] ;
          DMValue512[232+: 8] = Byte64Value[29] ;
          DMValue512[240+: 8] = Byte64Value[30] ;
          DMValue512[248+: 8] = Byte64Value[31] ;
          DMValue512[256+: 8] = Byte64Value[32] ;
          DMValue512[264+: 8] = Byte64Value[33] ;
          DMValue512[272+: 8] = Byte64Value[34] ;
          DMValue512[280+: 8] = Byte64Value[35] ;
          DMValue512[288+: 8] = Byte64Value[36] ;
          DMValue512[296+: 8] = Byte64Value[37] ;
          DMValue512[304+: 8] = Byte64Value[38] ;
          DMValue512[312+: 8] = Byte64Value[39] ;
          DMValue512[320+: 8] = Byte64Value[40] ;
          DMValue512[328+: 8] = Byte64Value[41] ;
          DMValue512[336+: 8] = Byte64Value[42] ;
          DMValue512[344+: 8] = Byte64Value[43] ;
          DMValue512[352+: 8] = Byte64Value[44] ;
          DMValue512[360+: 8] = Byte64Value[45] ;
          DMValue512[368+: 8] = Byte64Value[46] ;
          DMValue512[376+: 8] = Byte64Value[47] ;
          DMValue512[384+: 8] = Byte64Value[48] ;
          DMValue512[392+: 8] = Byte64Value[49] ;
          DMValue512[400+: 8] = Byte64Value[50] ;
          DMValue512[408+: 8] = Byte64Value[51] ;
          DMValue512[416+: 8] = Byte64Value[52] ;
          DMValue512[424+: 8] = Byte64Value[53] ;
          DMValue512[432+: 8] = Byte64Value[54] ;
          DMValue512[440+: 8] = Byte64Value[55] ;
          DMValue512[448+: 8] = Byte64Value[56] ;
          DMValue512[456+: 8] = Byte64Value[57] ;
          DMValue512[464+: 8] = Byte64Value[58] ;
          DMValue512[472+: 8] = Byte64Value[59] ;
          DMValue512[480+: 8] = Byte64Value[60] ;
          DMValue512[488+: 8] = Byte64Value[61] ;
          DMValue512[496+: 8] = Byte64Value[62] ;
          DMValue512[504+: 8] = Byte64Value[63] ;
        end
        default: $display("The input of CGran is invalid !\n\n");
      endcase
      
      if((DMValue512&Mask)=== ExpValue) $display("%0t Read DM  OK @MPU_DC_PC = %h!!", $realtime, MPUPC);
      else  begin
        $display("%0t Error @MPU_DC_PC = %h, Expected Value and Real Result are :", $realtime, MPUPC);
        Mon.display_512(ExpValue);
        Mon.display_512(DMValue512&Mask);
        $display(" ");
      end

      Byte1Value.delete();
      Byte2Value.delete();
      Byte4Value.delete();
      Byte8Value.delete();
      Byte16Value.delete();
      Byte32Value.delete();
      Byte64Value.delete();
   endtask

   task automatic Check2DM2Value(input int MPUPC, input int InstrCycle, input int Addr, input bit [2:0] Gran, input [3:0] Size, input [2:0] CGran, input bit [511:0] ExpValue);
      bit[511:0]   DMValue512;
      byte Byte1Value[];
      byte Byte2Value[];
      byte Byte4Value[];
      byte Byte8Value[];
      byte Byte16Value[];
      byte Byte32Value[];
      byte Byte64Value[];

      Byte1Value  = new[1];
      Byte2Value  = new[2];
      Byte4Value  = new[4];
      Byte8Value  = new[8];
      Byte16Value  = new[16];
      Byte32Value  = new[32];
      Byte64Value  = new[64];
      
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end
      WaitMPUCycles(InstrCycle);

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end
 		WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);

      case(CGran)
        3'd0: begin
          for(int i=0; i<64; i++) begin
            $root.TestTop.uAPE.uDM2.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte1Value);
            DMValue512[8*i +:8] = Byte1Value[0] ;
          end
        end
        3'd1: begin
          for(int i=0; i<32; i++) begin
            $root.TestTop.uAPE.uDM2.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte2Value);
            DMValue512[16*i   +: 8] = Byte2Value[0] ;
            DMValue512[16*i+8 +: 8] = Byte2Value[1] ;
          end
        end
        3'd2: begin
          for(int i=0; i<16; i++) begin
            $root.TestTop.uAPE.uDM2.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte4Value);
            DMValue512[32*i   +: 8] = Byte4Value[0] ;
            DMValue512[32*i+8 +: 8] = Byte4Value[1] ;
            DMValue512[32*i+16+: 8] = Byte4Value[2] ;
            DMValue512[32*i+24+: 8] = Byte4Value[3] ;
          end
        end
        3'd3: begin
          for(int i=0; i<8; i++) begin
            $root.TestTop.uAPE.uDM2.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte8Value);
            DMValue512[64*i   +: 8] = Byte8Value[0] ;
            DMValue512[64*i+8 +: 8] = Byte8Value[1] ;
            DMValue512[64*i+16+: 8] = Byte8Value[2] ;
            DMValue512[64*i+24+: 8] = Byte8Value[3] ;
            DMValue512[64*i+32+: 8] = Byte8Value[4] ;
            DMValue512[64*i+40+: 8] = Byte8Value[5] ;
            DMValue512[64*i+48+: 8] = Byte8Value[6] ;
            DMValue512[64*i+56+: 8] = Byte8Value[7] ;
          end
        end
        3'd4: begin
          for(int i=0; i<4; i++) begin
            $root.TestTop.uAPE.uDM2.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte16Value);
            DMValue512[128*i    +: 8] = Byte16Value[0] ;
            DMValue512[128*i+  8+: 8] = Byte16Value[1] ;
            DMValue512[128*i+ 16+: 8] = Byte16Value[2] ;
            DMValue512[128*i+ 24+: 8] = Byte16Value[3] ;
            DMValue512[128*i+ 32+: 8] = Byte16Value[4] ;
            DMValue512[128*i+ 40+: 8] = Byte16Value[5] ;
            DMValue512[128*i+ 48+: 8] = Byte16Value[6] ;
            DMValue512[128*i+ 56+: 8] = Byte16Value[7] ;
            DMValue512[128*i+ 64+: 8] = Byte16Value[8] ;
            DMValue512[128*i+ 72+: 8] = Byte16Value[9] ;
            DMValue512[128*i+ 80+: 8] = Byte16Value[10] ;
            DMValue512[128*i+ 88+: 8] = Byte16Value[11] ;
            DMValue512[128*i+ 96+: 8] = Byte16Value[12] ;
            DMValue512[128*i+104+: 8] = Byte16Value[13] ;
            DMValue512[128*i+112+: 8] = Byte16Value[14] ;
            DMValue512[128*i+120+: 8] = Byte16Value[15] ;
          end
        end
        3'd5: begin
          for(int i=0; i<2; i++) begin
            $root.TestTop.uAPE.uDM2.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte32Value);
            DMValue512[256*i    +: 8] = Byte32Value[0] ;
            DMValue512[256*i+  8+: 8] = Byte32Value[1] ;
            DMValue512[256*i+ 16+: 8] = Byte32Value[2] ;
            DMValue512[256*i+ 24+: 8] = Byte32Value[3] ;
            DMValue512[256*i+ 32+: 8] = Byte32Value[4] ;
            DMValue512[256*i+ 40+: 8] = Byte32Value[5] ;
            DMValue512[256*i+ 48+: 8] = Byte32Value[6] ;
            DMValue512[256*i+ 56+: 8] = Byte32Value[7] ;
            DMValue512[256*i+ 64+: 8] = Byte32Value[8] ;
            DMValue512[256*i+ 72+: 8] = Byte32Value[9] ;
            DMValue512[256*i+ 80+: 8] = Byte32Value[10] ;
            DMValue512[256*i+ 88+: 8] = Byte32Value[11] ;
            DMValue512[256*i+ 96+: 8] = Byte32Value[12] ;
            DMValue512[256*i+104+: 8] = Byte32Value[13] ;
            DMValue512[256*i+112+: 8] = Byte32Value[14] ;
            DMValue512[256*i+120+: 8] = Byte32Value[15] ;
            DMValue512[256*i+128+: 8] = Byte32Value[16] ;
            DMValue512[256*i+136+: 8] = Byte32Value[17] ;
            DMValue512[256*i+144+: 8] = Byte32Value[18] ;
            DMValue512[256*i+152+: 8] = Byte32Value[19] ;
            DMValue512[256*i+160+: 8] = Byte32Value[20] ;
            DMValue512[256*i+168+: 8] = Byte32Value[21] ;
            DMValue512[256*i+176+: 8] = Byte32Value[22] ;
            DMValue512[256*i+184+: 8] = Byte32Value[23] ;
            DMValue512[256*i+192+: 8] = Byte32Value[24] ;
            DMValue512[256*i+200+: 8] = Byte32Value[25] ;
            DMValue512[256*i+208+: 8] = Byte32Value[26] ;
            DMValue512[256*i+216+: 8] = Byte32Value[27] ;
            DMValue512[256*i+224+: 8] = Byte32Value[28] ;
            DMValue512[256*i+232+: 8] = Byte32Value[29] ;
            DMValue512[256*i+240+: 8] = Byte32Value[30] ;
            DMValue512[256*i+248+: 8] = Byte32Value[31] ;
          end
        end
        3'd6: begin
          $root.TestTop.uAPE.uDM2.DMReadBytes(Addr+((1<<Size)*64)*0, Gran, Size, Byte64Value); 
          DMValue512[0  +: 8] = Byte64Value[0] ;
          DMValue512[8  +: 8] = Byte64Value[1] ;
          DMValue512[16 +: 8] = Byte64Value[2] ;
          DMValue512[24 +: 8] = Byte64Value[3] ;
          DMValue512[32 +: 8] = Byte64Value[4] ;
          DMValue512[40 +: 8] = Byte64Value[5] ;
          DMValue512[48 +: 8] = Byte64Value[6] ;
          DMValue512[56 +: 8] = Byte64Value[7] ;
          DMValue512[64 +: 8] = Byte64Value[8] ;
          DMValue512[72 +: 8] = Byte64Value[9] ;
          DMValue512[80 +: 8] = Byte64Value[10] ;
          DMValue512[88 +: 8] = Byte64Value[11] ;
          DMValue512[96 +: 8] = Byte64Value[12] ;
          DMValue512[104+: 8] = Byte64Value[13] ;
          DMValue512[112+: 8] = Byte64Value[14] ;
          DMValue512[120+: 8] = Byte64Value[15] ;
          DMValue512[128+: 8] = Byte64Value[16] ;
          DMValue512[136+: 8] = Byte64Value[17] ;
          DMValue512[144+: 8] = Byte64Value[18] ;
          DMValue512[152+: 8] = Byte64Value[19] ;
          DMValue512[160+: 8] = Byte64Value[20] ;
          DMValue512[168+: 8] = Byte64Value[21] ;
          DMValue512[176+: 8] = Byte64Value[22] ;
          DMValue512[184+: 8] = Byte64Value[23] ;
          DMValue512[192+: 8] = Byte64Value[24] ;
          DMValue512[200+: 8] = Byte64Value[25] ;
          DMValue512[208+: 8] = Byte64Value[26] ;
          DMValue512[216+: 8] = Byte64Value[27] ;
          DMValue512[224+: 8] = Byte64Value[28] ;
          DMValue512[232+: 8] = Byte64Value[29] ;
          DMValue512[240+: 8] = Byte64Value[30] ;
          DMValue512[248+: 8] = Byte64Value[31] ;
          DMValue512[256+: 8] = Byte64Value[32] ;
          DMValue512[264+: 8] = Byte64Value[33] ;
          DMValue512[272+: 8] = Byte64Value[34] ;
          DMValue512[280+: 8] = Byte64Value[35] ;
          DMValue512[288+: 8] = Byte64Value[36] ;
          DMValue512[296+: 8] = Byte64Value[37] ;
          DMValue512[304+: 8] = Byte64Value[38] ;
          DMValue512[312+: 8] = Byte64Value[39] ;
          DMValue512[320+: 8] = Byte64Value[40] ;
          DMValue512[328+: 8] = Byte64Value[41] ;
          DMValue512[336+: 8] = Byte64Value[42] ;
          DMValue512[344+: 8] = Byte64Value[43] ;
          DMValue512[352+: 8] = Byte64Value[44] ;
          DMValue512[360+: 8] = Byte64Value[45] ;
          DMValue512[368+: 8] = Byte64Value[46] ;
          DMValue512[376+: 8] = Byte64Value[47] ;
          DMValue512[384+: 8] = Byte64Value[48] ;
          DMValue512[392+: 8] = Byte64Value[49] ;
          DMValue512[400+: 8] = Byte64Value[50] ;
          DMValue512[408+: 8] = Byte64Value[51] ;
          DMValue512[416+: 8] = Byte64Value[52] ;
          DMValue512[424+: 8] = Byte64Value[53] ;
          DMValue512[432+: 8] = Byte64Value[54] ;
          DMValue512[440+: 8] = Byte64Value[55] ;
          DMValue512[448+: 8] = Byte64Value[56] ;
          DMValue512[456+: 8] = Byte64Value[57] ;
          DMValue512[464+: 8] = Byte64Value[58] ;
          DMValue512[472+: 8] = Byte64Value[59] ;
          DMValue512[480+: 8] = Byte64Value[60] ;
          DMValue512[488+: 8] = Byte64Value[61] ;
          DMValue512[496+: 8] = Byte64Value[62] ;
          DMValue512[504+: 8] = Byte64Value[63] ;
        end
        default: $display("The input of CGran is invalid !\n\n");
      endcase
      
      if(DMValue512 === ExpValue) $display("%0t Read DM2  OK @MPU_DC_PC = %h second time!!", $realtime, MPUPC);
      else  begin
        $display("%0t Error @MPU_DC_PC = %h second time, Expected Value and Real Result are :", $realtime, MPUPC);
        Mon.display_512(ExpValue);
        Mon.display_512(DMValue512);
        $display(" ");
      end

      Byte1Value.delete();
      Byte2Value.delete();
      Byte4Value.delete();
      Byte8Value.delete();
      Byte16Value.delete();
      Byte32Value.delete();
      Byte64Value.delete();
   endtask

   task automatic CheckDM3Value(input int MPUPC, input int InstrCycle, input int Addr, input bit [2:0] Gran, input [3:0] Size, input [2:0] CGran, input bit [511:0] ExpValue);
      bit[511:0]   DMValue512;
      byte Byte1Value[];
      byte Byte2Value[];
      byte Byte4Value[];
      byte Byte8Value[];
      byte Byte16Value[];
      byte Byte32Value[];
      byte Byte64Value[];
      int i;

      Byte1Value  = new[1];
      Byte2Value  = new[2];
      Byte4Value  = new[4];
      Byte8Value  = new[8];
      Byte16Value  = new[16];
      Byte32Value  = new[32];
      Byte64Value  = new[64];
      
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end
      
 		WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);

      case(CGran)
        3'd0: begin
          for(i=0; i<64; i++) begin
            $root.TestTop.uAPE.uDM3.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte1Value);
            DMValue512[8*i +:8] = Byte1Value[0] ;
          end
        end
        3'd1: begin
          for(i=0; i<32; i++) begin
            $root.TestTop.uAPE.uDM3.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte2Value);
            DMValue512[16*i   +: 8] = Byte2Value[0] ;
            DMValue512[16*i+8 +: 8] = Byte2Value[1] ;
          end
        end
        3'd2: begin
          for(i=0; i<16; i++) begin
            $root.TestTop.uAPE.uDM3.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte4Value);
            DMValue512[32*i   +: 8] = Byte4Value[0] ;
            DMValue512[32*i+8 +: 8] = Byte4Value[1] ;
            DMValue512[32*i+16+: 8] = Byte4Value[2] ;
            DMValue512[32*i+24+: 8] = Byte4Value[3] ;
          end
        end
        3'd3: begin
          for(i=0; i<8; i++) begin
            $root.TestTop.uAPE.uDM3.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte8Value);
            DMValue512[64*i   +: 8] = Byte8Value[0] ;
            DMValue512[64*i+8 +: 8] = Byte8Value[1] ;
            DMValue512[64*i+16+: 8] = Byte8Value[2] ;
            DMValue512[64*i+24+: 8] = Byte8Value[3] ;
            DMValue512[64*i+32+: 8] = Byte8Value[4] ;
            DMValue512[64*i+40+: 8] = Byte8Value[5] ;
            DMValue512[64*i+48+: 8] = Byte8Value[6] ;
            DMValue512[64*i+56+: 8] = Byte8Value[7] ;
          end
        end
        3'd4: begin
          for(i=0; i<4; i++) begin
            $root.TestTop.uAPE.uDM3.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte16Value);
            DMValue512[128*i    +: 8] = Byte16Value[0] ;
            DMValue512[128*i+  8+: 8] = Byte16Value[1] ;
            DMValue512[128*i+ 16+: 8] = Byte16Value[2] ;
            DMValue512[128*i+ 24+: 8] = Byte16Value[3] ;
            DMValue512[128*i+ 32+: 8] = Byte16Value[4] ;
            DMValue512[128*i+ 40+: 8] = Byte16Value[5] ;
            DMValue512[128*i+ 48+: 8] = Byte16Value[6] ;
            DMValue512[128*i+ 56+: 8] = Byte16Value[7] ;
            DMValue512[128*i+ 64+: 8] = Byte16Value[8] ;
            DMValue512[128*i+ 72+: 8] = Byte16Value[9] ;
            DMValue512[128*i+ 80+: 8] = Byte16Value[10] ;
            DMValue512[128*i+ 88+: 8] = Byte16Value[11] ;
            DMValue512[128*i+ 96+: 8] = Byte16Value[12] ;
            DMValue512[128*i+104+: 8] = Byte16Value[13] ;
            DMValue512[128*i+112+: 8] = Byte16Value[14] ;
            DMValue512[128*i+120+: 8] = Byte16Value[15] ;
          end
        end
        3'd5: begin
          for(i=0; i<2; i++) begin
            $root.TestTop.uAPE.uDM3.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte32Value);
            DMValue512[256*i    +: 8] = Byte32Value[0] ;
            DMValue512[256*i+  8+: 8] = Byte32Value[1] ;
            DMValue512[256*i+ 16+: 8] = Byte32Value[2] ;
            DMValue512[256*i+ 24+: 8] = Byte32Value[3] ;
            DMValue512[256*i+ 32+: 8] = Byte32Value[4] ;
            DMValue512[256*i+ 40+: 8] = Byte32Value[5] ;
            DMValue512[256*i+ 48+: 8] = Byte32Value[6] ;
            DMValue512[256*i+ 56+: 8] = Byte32Value[7] ;
            DMValue512[256*i+ 64+: 8] = Byte32Value[8] ;
            DMValue512[256*i+ 72+: 8] = Byte32Value[9] ;
            DMValue512[256*i+ 80+: 8] = Byte32Value[10] ;
            DMValue512[256*i+ 88+: 8] = Byte32Value[11] ;
            DMValue512[256*i+ 96+: 8] = Byte32Value[12] ;
            DMValue512[256*i+104+: 8] = Byte32Value[13] ;
            DMValue512[256*i+112+: 8] = Byte32Value[14] ;
            DMValue512[256*i+120+: 8] = Byte32Value[15] ;
            DMValue512[256*i+128+: 8] = Byte32Value[16] ;
            DMValue512[256*i+136+: 8] = Byte32Value[17] ;
            DMValue512[256*i+144+: 8] = Byte32Value[18] ;
            DMValue512[256*i+152+: 8] = Byte32Value[19] ;
            DMValue512[256*i+160+: 8] = Byte32Value[20] ;
            DMValue512[256*i+168+: 8] = Byte32Value[21] ;
            DMValue512[256*i+176+: 8] = Byte32Value[22] ;
            DMValue512[256*i+184+: 8] = Byte32Value[23] ;
            DMValue512[256*i+192+: 8] = Byte32Value[24] ;
            DMValue512[256*i+200+: 8] = Byte32Value[25] ;
            DMValue512[256*i+208+: 8] = Byte32Value[26] ;
            DMValue512[256*i+216+: 8] = Byte32Value[27] ;
            DMValue512[256*i+224+: 8] = Byte32Value[28] ;
            DMValue512[256*i+232+: 8] = Byte32Value[29] ;
            DMValue512[256*i+240+: 8] = Byte32Value[30] ;
            DMValue512[256*i+248+: 8] = Byte32Value[31] ;
          end
        end
        3'd6: begin
          $root.TestTop.uAPE.uDM3.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte64Value); 
          DMValue512[0  +: 8] = Byte64Value[0] ;
          DMValue512[8  +: 8] = Byte64Value[1] ;
          DMValue512[16 +: 8] = Byte64Value[2] ;
          DMValue512[24 +: 8] = Byte64Value[3] ;
          DMValue512[32 +: 8] = Byte64Value[4] ;
          DMValue512[40 +: 8] = Byte64Value[5] ;
          DMValue512[48 +: 8] = Byte64Value[6] ;
          DMValue512[56 +: 8] = Byte64Value[7] ;
          DMValue512[64 +: 8] = Byte64Value[8] ;
          DMValue512[72 +: 8] = Byte64Value[9] ;
          DMValue512[80 +: 8] = Byte64Value[10] ;
          DMValue512[88 +: 8] = Byte64Value[11] ;
          DMValue512[96 +: 8] = Byte64Value[12] ;
          DMValue512[104+: 8] = Byte64Value[13] ;
          DMValue512[112+: 8] = Byte64Value[14] ;
          DMValue512[120+: 8] = Byte64Value[15] ;
          DMValue512[128+: 8] = Byte64Value[16] ;
          DMValue512[136+: 8] = Byte64Value[17] ;
          DMValue512[144+: 8] = Byte64Value[18] ;
          DMValue512[152+: 8] = Byte64Value[19] ;
          DMValue512[160+: 8] = Byte64Value[20] ;
          DMValue512[168+: 8] = Byte64Value[21] ;
          DMValue512[176+: 8] = Byte64Value[22] ;
          DMValue512[184+: 8] = Byte64Value[23] ;
          DMValue512[192+: 8] = Byte64Value[24] ;
          DMValue512[200+: 8] = Byte64Value[25] ;
          DMValue512[208+: 8] = Byte64Value[26] ;
          DMValue512[216+: 8] = Byte64Value[27] ;
          DMValue512[224+: 8] = Byte64Value[28] ;
          DMValue512[232+: 8] = Byte64Value[29] ;
          DMValue512[240+: 8] = Byte64Value[30] ;
          DMValue512[248+: 8] = Byte64Value[31] ;
          DMValue512[256+: 8] = Byte64Value[32] ;
          DMValue512[264+: 8] = Byte64Value[33] ;
          DMValue512[272+: 8] = Byte64Value[34] ;
          DMValue512[280+: 8] = Byte64Value[35] ;
          DMValue512[288+: 8] = Byte64Value[36] ;
          DMValue512[296+: 8] = Byte64Value[37] ;
          DMValue512[304+: 8] = Byte64Value[38] ;
          DMValue512[312+: 8] = Byte64Value[39] ;
          DMValue512[320+: 8] = Byte64Value[40] ;
          DMValue512[328+: 8] = Byte64Value[41] ;
          DMValue512[336+: 8] = Byte64Value[42] ;
          DMValue512[344+: 8] = Byte64Value[43] ;
          DMValue512[352+: 8] = Byte64Value[44] ;
          DMValue512[360+: 8] = Byte64Value[45] ;
          DMValue512[368+: 8] = Byte64Value[46] ;
          DMValue512[376+: 8] = Byte64Value[47] ;
          DMValue512[384+: 8] = Byte64Value[48] ;
          DMValue512[392+: 8] = Byte64Value[49] ;
          DMValue512[400+: 8] = Byte64Value[50] ;
          DMValue512[408+: 8] = Byte64Value[51] ;
          DMValue512[416+: 8] = Byte64Value[52] ;
          DMValue512[424+: 8] = Byte64Value[53] ;
          DMValue512[432+: 8] = Byte64Value[54] ;
          DMValue512[440+: 8] = Byte64Value[55] ;
          DMValue512[448+: 8] = Byte64Value[56] ;
          DMValue512[456+: 8] = Byte64Value[57] ;
          DMValue512[464+: 8] = Byte64Value[58] ;
          DMValue512[472+: 8] = Byte64Value[59] ;
          DMValue512[480+: 8] = Byte64Value[60] ;
          DMValue512[488+: 8] = Byte64Value[61] ;
          DMValue512[496+: 8] = Byte64Value[62] ;
          DMValue512[504+: 8] = Byte64Value[63] ;
        end
        default: $display("The input of CGran is invalid !\n\n");
      endcase
      
      if(DMValue512 === ExpValue) $display("%0t Read DM0 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
      else  begin
        $display("%0t Error @MPUDC_PC = %h, Expected Value and Real Result are :", $realtime, MPUPC);
        Mon.display_512(ExpValue);
        Mon.display_512(DMValue512);
        $display(" ");
      end

      Byte1Value.delete();
      Byte2Value.delete();
      Byte4Value.delete();
      Byte8Value.delete();
      Byte16Value.delete();
      Byte32Value.delete();
      Byte64Value.delete();
    
  endtask

   task automatic CheckDM3Value_Mask(input int MPUPC, input int InstrCycle, input int Addr, input bit [2:0] Gran, input [3:0] Size, input [2:0] CGran, input bit[511:0] Mask, input bit [511:0] ExpValue);
      bit[511:0]   DMValue512;
      byte Byte1Value[];
      byte Byte2Value[];
      byte Byte4Value[];
      byte Byte8Value[];
      byte Byte16Value[];
      byte Byte32Value[];
      byte Byte64Value[];
      int i;

      Byte1Value  = new[1];
      Byte2Value  = new[2];
      Byte4Value  = new[4];
      Byte8Value  = new[8];
      Byte16Value  = new[16];
      Byte32Value  = new[32];
      Byte64Value  = new[64];
      
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end
      
 		WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);

      case(CGran)
        3'd0: begin
          for(i=0; i<64; i++) begin
            $root.TestTop.uAPE.uDM3.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte1Value);
            DMValue512[8*i +:8] = Byte1Value[0] ;
          end
        end
        3'd1: begin
          for(i=0; i<32; i++) begin
            $root.TestTop.uAPE.uDM3.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte2Value);
            DMValue512[16*i   +: 8] = Byte2Value[0] ;
            DMValue512[16*i+8 +: 8] = Byte2Value[1] ;
          end
        end
        3'd2: begin
          for(i=0; i<16; i++) begin
            $root.TestTop.uAPE.uDM3.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte4Value);
            DMValue512[32*i   +: 8] = Byte4Value[0] ;
            DMValue512[32*i+8 +: 8] = Byte4Value[1] ;
            DMValue512[32*i+16+: 8] = Byte4Value[2] ;
            DMValue512[32*i+24+: 8] = Byte4Value[3] ;
          end
        end
        3'd3: begin
          for(i=0; i<8; i++) begin
            $root.TestTop.uAPE.uDM3.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte8Value);
            DMValue512[64*i   +: 8] = Byte8Value[0] ;
            DMValue512[64*i+8 +: 8] = Byte8Value[1] ;
            DMValue512[64*i+16+: 8] = Byte8Value[2] ;
            DMValue512[64*i+24+: 8] = Byte8Value[3] ;
            DMValue512[64*i+32+: 8] = Byte8Value[4] ;
            DMValue512[64*i+40+: 8] = Byte8Value[5] ;
            DMValue512[64*i+48+: 8] = Byte8Value[6] ;
            DMValue512[64*i+56+: 8] = Byte8Value[7] ;
          end
        end
        3'd4: begin
          for(i=0; i<4; i++) begin
            $root.TestTop.uAPE.uDM3.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte16Value);
            DMValue512[128*i    +: 8] = Byte16Value[0] ;
            DMValue512[128*i+  8+: 8] = Byte16Value[1] ;
            DMValue512[128*i+ 16+: 8] = Byte16Value[2] ;
            DMValue512[128*i+ 24+: 8] = Byte16Value[3] ;
            DMValue512[128*i+ 32+: 8] = Byte16Value[4] ;
            DMValue512[128*i+ 40+: 8] = Byte16Value[5] ;
            DMValue512[128*i+ 48+: 8] = Byte16Value[6] ;
            DMValue512[128*i+ 56+: 8] = Byte16Value[7] ;
            DMValue512[128*i+ 64+: 8] = Byte16Value[8] ;
            DMValue512[128*i+ 72+: 8] = Byte16Value[9] ;
            DMValue512[128*i+ 80+: 8] = Byte16Value[10] ;
            DMValue512[128*i+ 88+: 8] = Byte16Value[11] ;
            DMValue512[128*i+ 96+: 8] = Byte16Value[12] ;
            DMValue512[128*i+104+: 8] = Byte16Value[13] ;
            DMValue512[128*i+112+: 8] = Byte16Value[14] ;
            DMValue512[128*i+120+: 8] = Byte16Value[15] ;
          end
        end
        3'd5: begin
          for(i=0; i<2; i++) begin
            $root.TestTop.uAPE.uDM3.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte32Value);
            DMValue512[256*i    +: 8] = Byte32Value[0] ;
            DMValue512[256*i+  8+: 8] = Byte32Value[1] ;
            DMValue512[256*i+ 16+: 8] = Byte32Value[2] ;
            DMValue512[256*i+ 24+: 8] = Byte32Value[3] ;
            DMValue512[256*i+ 32+: 8] = Byte32Value[4] ;
            DMValue512[256*i+ 40+: 8] = Byte32Value[5] ;
            DMValue512[256*i+ 48+: 8] = Byte32Value[6] ;
            DMValue512[256*i+ 56+: 8] = Byte32Value[7] ;
            DMValue512[256*i+ 64+: 8] = Byte32Value[8] ;
            DMValue512[256*i+ 72+: 8] = Byte32Value[9] ;
            DMValue512[256*i+ 80+: 8] = Byte32Value[10] ;
            DMValue512[256*i+ 88+: 8] = Byte32Value[11] ;
            DMValue512[256*i+ 96+: 8] = Byte32Value[12] ;
            DMValue512[256*i+104+: 8] = Byte32Value[13] ;
            DMValue512[256*i+112+: 8] = Byte32Value[14] ;
            DMValue512[256*i+120+: 8] = Byte32Value[15] ;
            DMValue512[256*i+128+: 8] = Byte32Value[16] ;
            DMValue512[256*i+136+: 8] = Byte32Value[17] ;
            DMValue512[256*i+144+: 8] = Byte32Value[18] ;
            DMValue512[256*i+152+: 8] = Byte32Value[19] ;
            DMValue512[256*i+160+: 8] = Byte32Value[20] ;
            DMValue512[256*i+168+: 8] = Byte32Value[21] ;
            DMValue512[256*i+176+: 8] = Byte32Value[22] ;
            DMValue512[256*i+184+: 8] = Byte32Value[23] ;
            DMValue512[256*i+192+: 8] = Byte32Value[24] ;
            DMValue512[256*i+200+: 8] = Byte32Value[25] ;
            DMValue512[256*i+208+: 8] = Byte32Value[26] ;
            DMValue512[256*i+216+: 8] = Byte32Value[27] ;
            DMValue512[256*i+224+: 8] = Byte32Value[28] ;
            DMValue512[256*i+232+: 8] = Byte32Value[29] ;
            DMValue512[256*i+240+: 8] = Byte32Value[30] ;
            DMValue512[256*i+248+: 8] = Byte32Value[31] ;
          end
        end
        3'd6: begin
          $root.TestTop.uAPE.uDM3.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte64Value); 
          DMValue512[0  +: 8] = Byte64Value[0] ;
          DMValue512[8  +: 8] = Byte64Value[1] ;
          DMValue512[16 +: 8] = Byte64Value[2] ;
          DMValue512[24 +: 8] = Byte64Value[3] ;
          DMValue512[32 +: 8] = Byte64Value[4] ;
          DMValue512[40 +: 8] = Byte64Value[5] ;
          DMValue512[48 +: 8] = Byte64Value[6] ;
          DMValue512[56 +: 8] = Byte64Value[7] ;
          DMValue512[64 +: 8] = Byte64Value[8] ;
          DMValue512[72 +: 8] = Byte64Value[9] ;
          DMValue512[80 +: 8] = Byte64Value[10] ;
          DMValue512[88 +: 8] = Byte64Value[11] ;
          DMValue512[96 +: 8] = Byte64Value[12] ;
          DMValue512[104+: 8] = Byte64Value[13] ;
          DMValue512[112+: 8] = Byte64Value[14] ;
          DMValue512[120+: 8] = Byte64Value[15] ;
          DMValue512[128+: 8] = Byte64Value[16] ;
          DMValue512[136+: 8] = Byte64Value[17] ;
          DMValue512[144+: 8] = Byte64Value[18] ;
          DMValue512[152+: 8] = Byte64Value[19] ;
          DMValue512[160+: 8] = Byte64Value[20] ;
          DMValue512[168+: 8] = Byte64Value[21] ;
          DMValue512[176+: 8] = Byte64Value[22] ;
          DMValue512[184+: 8] = Byte64Value[23] ;
          DMValue512[192+: 8] = Byte64Value[24] ;
          DMValue512[200+: 8] = Byte64Value[25] ;
          DMValue512[208+: 8] = Byte64Value[26] ;
          DMValue512[216+: 8] = Byte64Value[27] ;
          DMValue512[224+: 8] = Byte64Value[28] ;
          DMValue512[232+: 8] = Byte64Value[29] ;
          DMValue512[240+: 8] = Byte64Value[30] ;
          DMValue512[248+: 8] = Byte64Value[31] ;
          DMValue512[256+: 8] = Byte64Value[32] ;
          DMValue512[264+: 8] = Byte64Value[33] ;
          DMValue512[272+: 8] = Byte64Value[34] ;
          DMValue512[280+: 8] = Byte64Value[35] ;
          DMValue512[288+: 8] = Byte64Value[36] ;
          DMValue512[296+: 8] = Byte64Value[37] ;
          DMValue512[304+: 8] = Byte64Value[38] ;
          DMValue512[312+: 8] = Byte64Value[39] ;
          DMValue512[320+: 8] = Byte64Value[40] ;
          DMValue512[328+: 8] = Byte64Value[41] ;
          DMValue512[336+: 8] = Byte64Value[42] ;
          DMValue512[344+: 8] = Byte64Value[43] ;
          DMValue512[352+: 8] = Byte64Value[44] ;
          DMValue512[360+: 8] = Byte64Value[45] ;
          DMValue512[368+: 8] = Byte64Value[46] ;
          DMValue512[376+: 8] = Byte64Value[47] ;
          DMValue512[384+: 8] = Byte64Value[48] ;
          DMValue512[392+: 8] = Byte64Value[49] ;
          DMValue512[400+: 8] = Byte64Value[50] ;
          DMValue512[408+: 8] = Byte64Value[51] ;
          DMValue512[416+: 8] = Byte64Value[52] ;
          DMValue512[424+: 8] = Byte64Value[53] ;
          DMValue512[432+: 8] = Byte64Value[54] ;
          DMValue512[440+: 8] = Byte64Value[55] ;
          DMValue512[448+: 8] = Byte64Value[56] ;
          DMValue512[456+: 8] = Byte64Value[57] ;
          DMValue512[464+: 8] = Byte64Value[58] ;
          DMValue512[472+: 8] = Byte64Value[59] ;
          DMValue512[480+: 8] = Byte64Value[60] ;
          DMValue512[488+: 8] = Byte64Value[61] ;
          DMValue512[496+: 8] = Byte64Value[62] ;
          DMValue512[504+: 8] = Byte64Value[63] ;
        end
        default: $display("The input of CGran is invalid !\n\n");
      endcase
      
      if((DMValue512&Mask) === ExpValue) $display("%0t Read DM0 OK @MPUDC_PC = %h!!", $realtime, MPUPC);
      else  begin
        $display("%0t Error @MPUDC_PC = %h, Expected Value and Real Result are :", $realtime, MPUPC);
        Mon.display_512(ExpValue);
        Mon.display_512(DMValue512&Mask);
        $display(" ");
      end

      Byte1Value.delete();
      Byte2Value.delete();
      Byte4Value.delete();
      Byte8Value.delete();
      Byte16Value.delete();
      Byte32Value.delete();
      Byte64Value.delete();
    
  endtask
  
   task automatic Check2DM3Value(input int MPUPC, input int InstrCycle, input int Addr, input bit [2:0] Gran, input [3:0] Size, input [2:0] CGran, input bit [511:0] ExpValue);
      bit[511:0]   DMValue512;
      byte Byte1Value[];
      byte Byte2Value[];
      byte Byte4Value[];
      byte Byte8Value[];
      byte Byte16Value[];
      byte Byte32Value[];
      byte Byte64Value[];

      Byte1Value  = new[1];
      Byte2Value  = new[2];
      Byte4Value  = new[4];
      Byte8Value  = new[8];
      Byte16Value  = new[16];
      Byte32Value  = new[32];
      Byte64Value  = new[64];
      
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end
      WaitMPUCycles(InstrCycle);

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end
 		WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);

      case(CGran)
        3'd0: begin
          for(int i=0; i<64; i++) begin
            $root.TestTop.uAPE.uDM3.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte1Value);
            DMValue512[8*i +:8] = Byte1Value[0] ;
          end
        end
        3'd1: begin
          for(int i=0; i<32; i++) begin
            $root.TestTop.uAPE.uDM3.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte2Value);
            DMValue512[16*i   +: 8] = Byte2Value[0] ;
            DMValue512[16*i+8 +: 8] = Byte2Value[1] ;
          end
        end
        3'd2: begin
          for(int i=0; i<16; i++) begin
            $root.TestTop.uAPE.uDM3.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte4Value);
            DMValue512[32*i   +: 8] = Byte4Value[0] ;
            DMValue512[32*i+8 +: 8] = Byte4Value[1] ;
            DMValue512[32*i+16+: 8] = Byte4Value[2] ;
            DMValue512[32*i+24+: 8] = Byte4Value[3] ;
          end
        end
        3'd3: begin
          for(int i=0; i<8; i++) begin
            $root.TestTop.uAPE.uDM3.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte8Value);
            DMValue512[64*i   +: 8] = Byte8Value[0] ;
            DMValue512[64*i+8 +: 8] = Byte8Value[1] ;
            DMValue512[64*i+16+: 8] = Byte8Value[2] ;
            DMValue512[64*i+24+: 8] = Byte8Value[3] ;
            DMValue512[64*i+32+: 8] = Byte8Value[4] ;
            DMValue512[64*i+40+: 8] = Byte8Value[5] ;
            DMValue512[64*i+48+: 8] = Byte8Value[6] ;
            DMValue512[64*i+56+: 8] = Byte8Value[7] ;
          end
        end
        3'd4: begin
          for(int i=0; i<4; i++) begin
            $root.TestTop.uAPE.uDM3.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte16Value);
            DMValue512[128*i    +: 8] = Byte16Value[0] ;
            DMValue512[128*i+  8+: 8] = Byte16Value[1] ;
            DMValue512[128*i+ 16+: 8] = Byte16Value[2] ;
            DMValue512[128*i+ 24+: 8] = Byte16Value[3] ;
            DMValue512[128*i+ 32+: 8] = Byte16Value[4] ;
            DMValue512[128*i+ 40+: 8] = Byte16Value[5] ;
            DMValue512[128*i+ 48+: 8] = Byte16Value[6] ;
            DMValue512[128*i+ 56+: 8] = Byte16Value[7] ;
            DMValue512[128*i+ 64+: 8] = Byte16Value[8] ;
            DMValue512[128*i+ 72+: 8] = Byte16Value[9] ;
            DMValue512[128*i+ 80+: 8] = Byte16Value[10] ;
            DMValue512[128*i+ 88+: 8] = Byte16Value[11] ;
            DMValue512[128*i+ 96+: 8] = Byte16Value[12] ;
            DMValue512[128*i+104+: 8] = Byte16Value[13] ;
            DMValue512[128*i+112+: 8] = Byte16Value[14] ;
            DMValue512[128*i+120+: 8] = Byte16Value[15] ;
          end
        end
        3'd5: begin
          for(int i=0; i<2; i++) begin
            $root.TestTop.uAPE.uDM3.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte32Value);
            DMValue512[256*i    +: 8] = Byte32Value[0] ;
            DMValue512[256*i+  8+: 8] = Byte32Value[1] ;
            DMValue512[256*i+ 16+: 8] = Byte32Value[2] ;
            DMValue512[256*i+ 24+: 8] = Byte32Value[3] ;
            DMValue512[256*i+ 32+: 8] = Byte32Value[4] ;
            DMValue512[256*i+ 40+: 8] = Byte32Value[5] ;
            DMValue512[256*i+ 48+: 8] = Byte32Value[6] ;
            DMValue512[256*i+ 56+: 8] = Byte32Value[7] ;
            DMValue512[256*i+ 64+: 8] = Byte32Value[8] ;
            DMValue512[256*i+ 72+: 8] = Byte32Value[9] ;
            DMValue512[256*i+ 80+: 8] = Byte32Value[10] ;
            DMValue512[256*i+ 88+: 8] = Byte32Value[11] ;
            DMValue512[256*i+ 96+: 8] = Byte32Value[12] ;
            DMValue512[256*i+104+: 8] = Byte32Value[13] ;
            DMValue512[256*i+112+: 8] = Byte32Value[14] ;
            DMValue512[256*i+120+: 8] = Byte32Value[15] ;
            DMValue512[256*i+128+: 8] = Byte32Value[16] ;
            DMValue512[256*i+136+: 8] = Byte32Value[17] ;
            DMValue512[256*i+144+: 8] = Byte32Value[18] ;
            DMValue512[256*i+152+: 8] = Byte32Value[19] ;
            DMValue512[256*i+160+: 8] = Byte32Value[20] ;
            DMValue512[256*i+168+: 8] = Byte32Value[21] ;
            DMValue512[256*i+176+: 8] = Byte32Value[22] ;
            DMValue512[256*i+184+: 8] = Byte32Value[23] ;
            DMValue512[256*i+192+: 8] = Byte32Value[24] ;
            DMValue512[256*i+200+: 8] = Byte32Value[25] ;
            DMValue512[256*i+208+: 8] = Byte32Value[26] ;
            DMValue512[256*i+216+: 8] = Byte32Value[27] ;
            DMValue512[256*i+224+: 8] = Byte32Value[28] ;
            DMValue512[256*i+232+: 8] = Byte32Value[29] ;
            DMValue512[256*i+240+: 8] = Byte32Value[30] ;
            DMValue512[256*i+248+: 8] = Byte32Value[31] ;
          end
        end
        3'd6: begin
          $root.TestTop.uAPE.uDM3.DMReadBytes(Addr+((1<<Size)*64)*0, Gran, Size, Byte64Value); 
          DMValue512[0  +: 8] = Byte64Value[0] ;
          DMValue512[8  +: 8] = Byte64Value[1] ;
          DMValue512[16 +: 8] = Byte64Value[2] ;
          DMValue512[24 +: 8] = Byte64Value[3] ;
          DMValue512[32 +: 8] = Byte64Value[4] ;
          DMValue512[40 +: 8] = Byte64Value[5] ;
          DMValue512[48 +: 8] = Byte64Value[6] ;
          DMValue512[56 +: 8] = Byte64Value[7] ;
          DMValue512[64 +: 8] = Byte64Value[8] ;
          DMValue512[72 +: 8] = Byte64Value[9] ;
          DMValue512[80 +: 8] = Byte64Value[10] ;
          DMValue512[88 +: 8] = Byte64Value[11] ;
          DMValue512[96 +: 8] = Byte64Value[12] ;
          DMValue512[104+: 8] = Byte64Value[13] ;
          DMValue512[112+: 8] = Byte64Value[14] ;
          DMValue512[120+: 8] = Byte64Value[15] ;
          DMValue512[128+: 8] = Byte64Value[16] ;
          DMValue512[136+: 8] = Byte64Value[17] ;
          DMValue512[144+: 8] = Byte64Value[18] ;
          DMValue512[152+: 8] = Byte64Value[19] ;
          DMValue512[160+: 8] = Byte64Value[20] ;
          DMValue512[168+: 8] = Byte64Value[21] ;
          DMValue512[176+: 8] = Byte64Value[22] ;
          DMValue512[184+: 8] = Byte64Value[23] ;
          DMValue512[192+: 8] = Byte64Value[24] ;
          DMValue512[200+: 8] = Byte64Value[25] ;
          DMValue512[208+: 8] = Byte64Value[26] ;
          DMValue512[216+: 8] = Byte64Value[27] ;
          DMValue512[224+: 8] = Byte64Value[28] ;
          DMValue512[232+: 8] = Byte64Value[29] ;
          DMValue512[240+: 8] = Byte64Value[30] ;
          DMValue512[248+: 8] = Byte64Value[31] ;
          DMValue512[256+: 8] = Byte64Value[32] ;
          DMValue512[264+: 8] = Byte64Value[33] ;
          DMValue512[272+: 8] = Byte64Value[34] ;
          DMValue512[280+: 8] = Byte64Value[35] ;
          DMValue512[288+: 8] = Byte64Value[36] ;
          DMValue512[296+: 8] = Byte64Value[37] ;
          DMValue512[304+: 8] = Byte64Value[38] ;
          DMValue512[312+: 8] = Byte64Value[39] ;
          DMValue512[320+: 8] = Byte64Value[40] ;
          DMValue512[328+: 8] = Byte64Value[41] ;
          DMValue512[336+: 8] = Byte64Value[42] ;
          DMValue512[344+: 8] = Byte64Value[43] ;
          DMValue512[352+: 8] = Byte64Value[44] ;
          DMValue512[360+: 8] = Byte64Value[45] ;
          DMValue512[368+: 8] = Byte64Value[46] ;
          DMValue512[376+: 8] = Byte64Value[47] ;
          DMValue512[384+: 8] = Byte64Value[48] ;
          DMValue512[392+: 8] = Byte64Value[49] ;
          DMValue512[400+: 8] = Byte64Value[50] ;
          DMValue512[408+: 8] = Byte64Value[51] ;
          DMValue512[416+: 8] = Byte64Value[52] ;
          DMValue512[424+: 8] = Byte64Value[53] ;
          DMValue512[432+: 8] = Byte64Value[54] ;
          DMValue512[440+: 8] = Byte64Value[55] ;
          DMValue512[448+: 8] = Byte64Value[56] ;
          DMValue512[456+: 8] = Byte64Value[57] ;
          DMValue512[464+: 8] = Byte64Value[58] ;
          DMValue512[472+: 8] = Byte64Value[59] ;
          DMValue512[480+: 8] = Byte64Value[60] ;
          DMValue512[488+: 8] = Byte64Value[61] ;
          DMValue512[496+: 8] = Byte64Value[62] ;
          DMValue512[504+: 8] = Byte64Value[63] ;
        end
        default: $display("The input of CGran is invalid !\n\n");
      endcase

      if(DMValue512 === ExpValue) $display("%0t Read DM0  OK @MPU_DC_PC = %h second time!!", $realtime, MPUPC);
      else  begin
        $display("%0t Error @MPU_DC_PC = %h second time, Expected Value and Real Result are :", $realtime, MPUPC);
        Mon.display_512(ExpValue);
        Mon.display_512(DMValue512);
        $display(" ");
      end

      Byte1Value.delete();
      Byte2Value.delete();
      Byte4Value.delete();
      Byte8Value.delete();
      Byte16Value.delete();
      Byte32Value.delete();
      Byte64Value.delete();
   endtask

   // start PC !!!
   task automatic CheckJUMP(input int MPUSTARTPC, input int NextMPUSTARTPC);
      while(1) begin
         @(iCvSmpIF.APECB)
         if((`MPU_STARTDC_PC === MPUSTARTPC) && `MFetchValid)
            break;
      end
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MFetchValid)
            break;
      end
      if(`MPU_STARTDC_PC != NextMPUSTARTPC)
         $display( "%0t Error @MPU_STARTDC_PC = %h, ExpectedNextSTARTPC = %h , RealNextSTARTPC = %h", $realtime, MPUSTARTPC, NextMPUSTARTPC, `MPU_STARTDC_PC);
      else
         $display( "%0t JUMP addr %h OK  @MPU_STARTDC_PC = %h!!", $realtime, NextMPUSTARTPC, MPUSTARTPC);
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

   // start PC !!!
   task automatic CheckKIValueMFetch_JUMPS(input int MPUSTARTPC, input bit[4:0] KInum, input bit[23:0] ExpValue); 
      bit [23:0] MFetchKIValue;

      while(1) begin
         @(iCvSmpIF.APECB)
         if((`MPU_STARTDC_PC === MPUSTARTPC) && `MFetchValid)
            break;
      end
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MFetchValid)
            break;
      end
      MFetchKIValue = $root.TestTop.uAPE.uMPU.uMFetch.KI[KInum];
      
      if(MFetchKIValue === ExpValue)
         $display("%0t Read MFetchKI[%0d] OK @MPU_STARTDC_PC = %h!!", $realtime, KInum, MPUSTARTPC);
      else   
        begin
          $display("%0t Read MFetchKI[%0d] Error @MPU_STARTDC_PC = %h, Expected Value = %h!! , Real Result = %h!! :", $realtime, KInum, MPUSTARTPC, ExpValue, MFetchKIValue);
          $display(" ");
        end
   endtask

   // start PC !!!
   task automatic CheckLoop(input int StartMPC, input int EndMPC, input int LpNum);
      int PCHitNum_Loop = 0;
      while(1)begin
         @(iCvSmpIF.APECB)
         if((`MPU_STARTDC_PC === StartMPC) && `MFetchValid) 
	         PCHitNum_Loop = PCHitNum_Loop + 1;
         if((`MPU_STARTDC_PC === EndMPC) && `MFetchValid)
            break;
      end
      if(PCHitNum_Loop == LpNum)
         $display("MPU Loop Passed @MPU_STARTDC_PC = %h, ActualLpNum = %h",StartMPC, PCHitNum_Loop);
      else
         $display("***Loop Error*** @MPU_STARTDC_PC = %h, ExpectedLpNum = %h, ActualLpNum = %h", StartMPC, LpNum, PCHitNum_Loop);
   endtask

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


   task automatic CheckMFetchKI_loopValue(input int MPUPC, input int InstrCycle, input bit[4:0] KInum, input int LpNum, input bit[23:0] ExpValue); 
      bit [23:0] MFetchKI_loopValue;
      int PCHitNum_KI = 0;

      while(1)begin
         @(iCvSmpIF.APECB)
         if((`MPU_DC_PC === MPUPC) && `MFetchValid) begin
            PCHitNum_KI = PCHitNum_KI + 1;
         end
         if(PCHitNum_KI == LpNum) begin
            WaitMPUCyclesMFetch(InstrCycle); 
            MFetchKI_loopValue = $root.TestTop.uAPE.uMPU.uMFetch.KI[KInum];
            break;
         end  
      end
         
      if(MFetchKI_loopValue === ExpValue)
         $display("%0t Read KI[%0d] OK @MPU_DC_PC = %h!!, loopnum = %h!!", $realtime, KInum, MPUPC, PCHitNum_KI);
      else begin
         $display("%0t Read KI[%0d] Error @MPU_DC_PC = %h, Expected Value = %h!! , Real Result = %h!! :", $realtime, KInum, MPUPC, ExpValue, MFetchKI_loopValue);
         $display(" ");
      end
   endtask

   // start PC !!!
   task automatic CheckMValue_loop(input int MPUSTARTPC, input int InstrCycle, input bit[5:0] RID, input int LpNum, input bit[511:0] ExpValue); 
      bit[511:0]   MValue;
      int PCHitNum_M = 0;

      while(1)begin
         @(iCvSmpIF.APECB)
         if((`MPU_STARTDC_PC === MPUSTARTPC) && `MFetchValid)
            PCHitNum_M = PCHitNum_M + 1;
         if(PCHitNum_M == LpNum) begin
            WaitMPUCycles(InstrCycle + `MPU_DELAY_CYCLE);
            Mon.M_Read(RID, MValue);
    	      break;
         end  
      end
      
      if(MValue === ExpValue)
         $display("%0t Read M[%0d] of OK @MPU_STARTDC_PC = %h!! ,loopnum = %h!!", $realtime, RID, MPUSTARTPC,PCHitNum_M);
      else  begin
        $display("%0t Read M[%0d] Error @MPU_STARTDC_PC = %h ,loopnum = %h!!, Expected Value and real value are : ", $realtime, RID, MPUSTARTPC, PCHitNum_M);
        Mon.display_512(ExpValue);            
        Mon.display_512(MValue);
        $display(" ");        
      end
   endtask

   // start PC !!!
   // GrpID: 0000-IMA0,0001-IMA1,0010-IMA2,0011-IMA3,0100-SHU0,0101-SHU1,0110-SHU2,0111-SHU3,1000-BIU0,1001-BIU1,1010-BIU2,1011-BIU3;  TID: 000~111   
    task automatic CheckTValue_loop(input int MPUSTARTPC, input int InstrCycle, input bit[3:0] GrpID, input bit[2:0] TID, input int LpNum, input bit[511:0] ExpValue); 
      bit[511:0]   TValue;
      int PCHitNum_T = 0;

      while(1)begin
         @(iCvSmpIF.APECB)
         if((`MPU_STARTDC_PC === MPUSTARTPC) && `MFetchValid)
            PCHitNum_T = PCHitNum_T + 1;
         if(PCHitNum_T == LpNum) begin
            WaitMPUCycles(InstrCycle + `MPU_DELAY_CYCLE);
            Mon.T_Read(GrpID, TID,TValue);
    	      break;
         end  
      end

      if(TValue === ExpValue)
         $display("%0t Read %4b T %3b  OK @MPU_STARTDC_PC = %h!!, loopnum = %h!!", $realtime, GrpID, TID, MPUSTARTPC, PCHitNum_T);
      else begin
          $display("%0t Read %4b T %3b Error @MPU_STARTDC_PC = %h, loopnum = %h!! Expected Value and Real Result are :", $realtime, GrpID, TID, MPUSTARTPC, PCHitNum_T);
          Mon.display_512(ExpValue);
          Mon.display_512(TValue);
          $display(" ");
      end
   endtask

   // Sel: 00-SHU0, 01-SHU1, 10-SHU2, 11-SHU3
   task automatic CheckT7RegValue(input int MPUPC, input int InstrCycle, input bit[1:0] Sel, input bit[511:0] ExpValue); 
      bit[511:0] T7Reg;
//   task automatic CheckTBRegValue(input int MPUPC, input int InstrCycle, input bit[1:0] Sel, input bit[511:0] ExpValue); 
//      bit[511:0] TBReg;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end

 		WaitMPUCycles(InstrCycle+`MPU_DELAY_CYCLE);
      Mon.T7Reg_Read(Sel, T7Reg);
      if(T7Reg === ExpValue)  $display("%0t Read T7Reg OK @MPUDC_PC = %h!!", $realtime, MPUPC);

//      Mon.TBReg_Read(Sel, TBReg);
//      if(TBReg === ExpValue)  $display("%0t Read TBReg OK @MPUDC_PC = %h!!", $realtime, MPUPC);
      else  begin
        $display("%0t Error @MPUDC_PC = %h, Expected Value and real value of T7Reg are : ", $realtime, MPUPC);
        Mon.display_512(ExpValue);            
        Mon.display_512(T7Reg);
        $display(" ");        
      end
   endtask

   // source regs exclude MFetch
   //Mode:0000 -> KI12-15, 0001 -> KI16-19, 0010 -> KI20-23, 0011 -> KI24-27, 0100 -> KI12-27, 0101 -> KI16-18, 0110 -> KI20-22, 0111 -> KI24-26
   task automatic CheckKIsValue(input int MPUPC, input int InstrCycle, input bit[3:0] Mode, input bit[511:0] ExpValue); 
      bit[511:0]   Mask;
      bit[511:0]   KIsValue;
      bit[511:0]   ExpValidValue;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end
      
      WaitMPUCyclesMFetch(InstrCycle + `MPU_DELAY_CYCLE);
      
      Mon.MFetchKI_Read(Mode, KIsValue);

      case(Mode)
         //                    KI27     KI26     KI25     KI24     KI23     KI22     KI21     KI20     KI19     KI18     KI17     KI16     KI15     KI14     KI13     KI12
         4'b0000:  Mask = 512'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00ffffff_00ffffff_00ffffff_00ffffff; //KI12-15
         4'b0001:  Mask = 512'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00ffffff_00ffffff_00ffffff_00ffffff_00000000_00000000_00000000_00000000; //KI16-19
         4'b0010:  Mask = 512'h00000000_00000000_00000000_00000000_00ffffff_00ffffff_00ffffff_00ffffff_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000; //KI20-23
         4'b0011:  Mask = 512'h00ffffff_00ffffff_00ffffff_00ffffff_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000; //KI24-27
         4'b0100:  Mask = 512'h00ffffff_00ffffff_00ffffff_00ffffff_00ffffff_00ffffff_00ffffff_00ffffff_00ffffff_00ffffff_00ffffff_00ffffff_00ffffff_00ffffff_00ffffff_00ffffff; //KI12-27
         4'b0101:  Mask = 512'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00ffffff_00ffffff_00ffffff_00000000_00000000_00000000_00000000; //KI16-18
         4'b0110:  Mask = 512'h00000000_00000000_00000000_00000000_00000000_00ffffff_00ffffff_00ffffff_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000; //KI20-22
         4'b0111:  Mask = 512'h00000000_00ffffff_00ffffff_00ffffff_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000; //KI24-26
      endcase
      ExpValidValue = ExpValue & Mask;

      if(KIsValue === ExpValidValue)
         $display("%0t Read KIs OK @MPUDC_PC = %h!!", $realtime, MPUPC);
      else begin
         $display("%0t Error @MPUDC_PC = %h, Expected Value and Real Result are :", $realtime, MPUPC);
         Mon.display_512(ExpValidValue);
         Mon.display_512(KIsValue);
         $display(" ");
      end
   endtask
   
   // source regs exclude MFetch
   task automatic CheckKIValue(input int MPUPC, input int InstrCycle, input bit[4:0] KIID, input logic[23:0] ExpValue); 
      logic[23:0]   KIValue;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end
      
      WaitMPUCyclesMFetch(InstrCycle + `MPU_DELAY_CYCLE);
      `TD
      KIValue = $root.TestTop.uAPE.uMPU.uMFetch.KI[KIID];
      if(KIValue === ExpValue)
         $display("%0t Read KI[%0d] OK @MPUDC_PC = %h!!", $realtime, KIID, MPUPC);
      else   
        begin
          $display("%0t Error @MPUDC_PC = %h, Expected Value and Real Result of KI[%0d] are : %h, %h\n", $realtime, MPUPC, KIID, ExpValue, KIValue);
          $display(" ");
        end
   endtask

   // source regs exclude MFetch
   // check all the KIs
   task automatic CheckKITotalValue(input int MPUPC, input int InstrCycle, input bit[511:0] ExpValue); 
      bit [511:0] MFetchKIValue;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end

 		WaitMPUCyclesMFetch(InstrCycle+`MPU_DELAY_CYCLE);

      MFetchKIValue = {8'd0,$root.TestTop.uAPE.uMPU.uMFetch.KI[15],8'd0,$root.TestTop.uAPE.uMPU.uMFetch.KI[14],8'd0,$root.TestTop.uAPE.uMPU.uMFetch.KI[13],8'd0,$root.TestTop.uAPE.uMPU.uMFetch.KI[12],8'd0,$root.TestTop.uAPE.uMPU.uMFetch.KI[11],8'd0,$root.TestTop.uAPE.uMPU.uMFetch.KI[10],8'd0,$root.TestTop.uAPE.uMPU.uMFetch.KI[9],8'd0,$root.TestTop.uAPE.uMPU.uMFetch.KI[8],8'd0,$root.TestTop.uAPE.uMPU.uMFetch.KI[7],8'd0,$root.TestTop.uAPE.uMPU.uMFetch.KI[6],8'd0,$root.TestTop.uAPE.uMPU.uMFetch.KI[5],8'd0,$root.TestTop.uAPE.uMPU.uMFetch.KI[4],8'd0,$root.TestTop.uAPE.uMPU.uMFetch.KI[3],8'd0,$root.TestTop.uAPE.uMPU.uMFetch.KI[2],8'd0,$root.TestTop.uAPE.uMPU.uMFetch.KI[1],8'd0,$root.TestTop.uAPE.uMPU.uMFetch.KI[0]};
    	
      if(MFetchKIValue === ExpValue)
         $display("%0t Read KIs OK @MPUDC_PC = %h!!", $realtime, MPUPC);
      else   
         begin
        	   $display("%0t Error @MPUDC_PC = %h, Expected Value and real value of KIs are : ", $realtime, MPUPC);
        	   Mon.display_512(ExpValue);            
        	   Mon.display_512(MFetchKIValue);
            $display(" ");
         end
   endtask

   // source is MFetch
   //Mode:0000 -> KI12-15, 0001 -> KI16-19, 0010 -> KI20-23, 0011 -> KI24-27, 0100 -> KI12-27, 0101 -> KI16-18, 0110 -> KI20-22, 0111 -> KI24-26
   task automatic CheckKIsValueMFetch(input int MPUPC, input int InstrCycle, input bit[3:0] Mode, input bit[511:0] ExpValue); 
      bit[511:0]   Mask;
      bit[511:0]   KIsValue;
      bit[511:0]   ExpValidValue;
      // is && must??????????????????????????????????????
      //wait((`MPU_DP_PC == MPUPC)&& $root.TestTop.uAPE.uMPU.uMFetch.nCurrentMicroValid);
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end
      
      WaitMPUCyclesMFetch(InstrCycle);
      
      Mon.MFetchKI_Read(Mode, KIsValue);

      case(Mode)
         //                    KI27     KI26     KI25     KI24     KI23     KI22     KI21     KI20     KI19     KI18     KI17     KI16     KI15     KI14     KI13     KI12
         4'b0000:  Mask = 512'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00ffffff_00ffffff_00ffffff_00ffffff; //KI12-15
         4'b0001:  Mask = 512'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00ffffff_00ffffff_00ffffff_00ffffff_00000000_00000000_00000000_00000000; //KI16-19
         4'b0010:  Mask = 512'h00000000_00000000_00000000_00000000_00ffffff_00ffffff_00ffffff_00ffffff_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000; //KI20-23
         4'b0011:  Mask = 512'h00ffffff_00ffffff_00ffffff_00ffffff_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000; //KI24-27
         4'b0100:  Mask = 512'h00ffffff_00ffffff_00ffffff_00ffffff_00ffffff_00ffffff_00ffffff_00ffffff_00ffffff_00ffffff_00ffffff_00ffffff_00ffffff_00ffffff_00ffffff_00ffffff; //KI12-27
         4'b0101:  Mask = 512'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00ffffff_00ffffff_00ffffff_00000000_00000000_00000000_00000000; //KI16-18
         4'b0110:  Mask = 512'h00000000_00000000_00000000_00000000_00000000_00ffffff_00ffffff_00ffffff_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000; //KI20-22
         4'b0111:  Mask = 512'h00000000_00ffffff_00ffffff_00ffffff_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000; //KI24-26
      endcase
      ExpValidValue = ExpValue & Mask;

      if(KIsValue === ExpValidValue)
         $display("%0t Read KIs OK @MPUDC_PC = %h!!", $realtime, MPUPC);
      else begin
         $display("%0t Error @MPUDC_PC = %h, Expected Value and Real Result are :", $realtime, MPUPC);
         Mon.display_512(ExpValidValue);
         Mon.display_512(KIsValue);
         $display(" ");
      end
   endtask
   
   // source is MFetch
   task automatic CheckKIValueMFetch(input int MPUPC, input int InstrCycle, input bit[4:0] KIID, input logic[23:0] ExpValue); 
      logic[23:0]   KIValue;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end
      
      WaitMPUCyclesMFetch(InstrCycle);
      //`TD
      KIValue = $root.TestTop.uAPE.uMPU.uMFetch.KI[KIID];
      if(KIValue === ExpValue)
         $display("%0t Read KI[%0d] OK @MPUDC_PC = %h!!", $realtime, KIID, MPUPC);
      else   
        begin
          $display("%0t Error @MPUDC_PC = %h, Expected Value and Real Result of KI[%0d] are : %h, %h\n", $realtime, MPUPC, KIID, ExpValue, KIValue);
          $display(" ");
        end
   endtask

   // source is MFetch
   // check all the KIs
   task automatic CheckKITotalValueMFetch(input int MPUPC, input int InstrCycle, input bit[511:0] ExpValue); 
      bit [511:0] MFetchKIValue;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`MPU_DC_PC === MPUPC && `MFetchValid)
            break;
      end

 		WaitMPUCyclesMFetch(InstrCycle);

      MFetchKIValue = {8'd0,$root.TestTop.uAPE.uMPU.uMFetch.KI[15],8'd0,$root.TestTop.uAPE.uMPU.uMFetch.KI[14],8'd0,$root.TestTop.uAPE.uMPU.uMFetch.KI[13],8'd0,$root.TestTop.uAPE.uMPU.uMFetch.KI[12],8'd0,$root.TestTop.uAPE.uMPU.uMFetch.KI[11],8'd0,$root.TestTop.uAPE.uMPU.uMFetch.KI[10],8'd0,$root.TestTop.uAPE.uMPU.uMFetch.KI[9],8'd0,$root.TestTop.uAPE.uMPU.uMFetch.KI[8],8'd0,$root.TestTop.uAPE.uMPU.uMFetch.KI[7],8'd0,$root.TestTop.uAPE.uMPU.uMFetch.KI[6],8'd0,$root.TestTop.uAPE.uMPU.uMFetch.KI[5],8'd0,$root.TestTop.uAPE.uMPU.uMFetch.KI[4],8'd0,$root.TestTop.uAPE.uMPU.uMFetch.KI[3],8'd0,$root.TestTop.uAPE.uMPU.uMFetch.KI[2],8'd0,$root.TestTop.uAPE.uMPU.uMFetch.KI[1],8'd0,$root.TestTop.uAPE.uMPU.uMFetch.KI[0]};
    	
      if(MFetchKIValue === ExpValue)
         $display("%0t Read KIs OK @MPUDC_PC = %h!!", $realtime, MPUPC);
      else   
         begin
        	   $display("%0t Error @MPUDC_PC = %h, Expected Value and real value of KIs are : ", $realtime, MPUPC);
        	   Mon.display_512(ExpValue);            
        	   Mon.display_512(MFetchKIValue);
            $display(" ");
         end
   endtask

   // i don't know the purpose of this task, it was used in M_regTest
   task automatic rand_stall(int C);
      int a;
      int i=0;
      a = $urandom_range(C);
      $display("rand_stall needs to update!!!");
      //$display("rand stall cycle is %d", a);
      //force $root.TestTop.uAPE.uMPU.nOEStallFG[0]=0; 
      //while(i<=a) begin
      //   @(posedge TestTop.uAPE.uSPU.CClk)
      //   i=i+1;  
      //end 
      //force $root.TestTop.uAPE.uMPU.nOEStallFG[0]=1; 
   endtask


// SPU

   task automatic CheckMValue_SPU(input int SPUSTARTPC, input int InstrCycle, input bit[5:0] RID, input bit[511:0] ExpValue); 
      bit[511:0]   MValue;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end

 		WaitMPUCycles(InstrCycle+`SPU_DELAY_CYCLE);

      Mon.M_Read(RID, MValue);
      if(MValue === ExpValue) $display("%0t Read M[%d] of OK @SPU_STARTEX0_PC = %h!!", $realtime, RID, SPUSTARTPC);
      else  begin
        $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and real value of M[%d] are : ", $realtime, SPUSTARTPC, RID);
        Mon.display_512(ExpValue);            
        Mon.display_512(MValue);
        $display(" ");        
      end
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

      FlagValue = $root.TestTop.uAPE.uSPU.uSCU.uEx0Unit.oFlag;

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

	   FlagValue = $root.TestTop.uAPE.uSPU.uSCU.uEx0Unit.oFlag[1];

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

   task automatic CheckADDRValue(input int SPUSTARTPC, input int InstrCycle, input logic[31:0] ExpValue); 
      logic[31:0]   RValue;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
     // WaitSPUCycles(InstrCycle);
      Mon.ADDR_Read(RValue);
      if(RValue === ExpValue)
         $display("%0t Read INTADDR OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result 0f INTADDR are :%h ,%h\n", $realtime, SPUSTARTPC, ExpValue, RValue);
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

   task automatic CheckRValue_FIFO(input int SPUSTARTPC, input int InstrCycle, input bit[4:0] RID, input logic[31:0] ExpValue); 
      logic[31:0]   RValue;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);
      Mon.R_Read(RID, RValue);
      if(!RValue[31]) 
        begin
          if(RValue === ExpValue)
             $display("%0t Read R[%0d] OK @SPU_STARTEX0_PC = %h!!", $realtime, RID, SPUSTARTPC);
          else
             $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result 0f R[%0d] are :%h ,%h\n", $realtime, SPUSTARTPC, RID, ExpValue, RValue);
        end
      else
        begin
          if(RValue[31] === ExpValue[31])
            $display("%0t Read R[%0d] OK @SPU_STARTEX0_PC = %h!!", $realtime, RID, SPUSTARTPC);
          else
            $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result 0f R[%0d] are :%h ,%h\n", $realtime, SPUSTARTPC, RID, ExpValue, RValue);
        end
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

   task automatic Inst_Read(input int InputRegInstSlotNum, output bit flag);begin
     flag = (InputRegInstSlotNum === 0 && (`SCUInstr[30:0] !== 31'h4603_8000) === 1) || (InputRegInstSlotNum === 1 && (`AGUInstr[30:0] !== 31'h2007_0400) === 1) || (InputRegInstSlotNum === 2 && (`SYNInstr[30:0] !== 31'h6e00_0000) === 1) || (InputRegInstSlotNum === 3 && ((`SEQCond != 1'h0) || ((`SEQCond == 1'h0) && ((`SEQInstr[30:22] === 9'b0_0010_1111) || (`SEQInstr[30:23] === 8'b0011_0000) || (`SEQInstr[30:22] === 9'b0_0011_0011) || (`SEQInstr[30:22] === 9'b0_0011_0111)))) === 1);//SetCondReg,SetCondImme,ReadCond,SPU.Stop,DbgBreak

   end
   endtask

   /*task automatic DecodeReg_Read(input bit[4:0] Index, output logic[31:0] Data);begin
     begin
       Data = $root.TestTop.uAPE.uSPU.uDecode.uRRegFile.rRReg[Index];
       //if(Index == 2 && SPUSTARTPC == 324)
       //$display("%h  %h",Data,Index);
     end
   end
   endtask

   task automatic DecodeSVR_Read(input bit[1:0] Index, output logic[511:0] Data);begin
     begin
       Data = $root.TestTop.uAPE.uSPU.uDecode.rSVRReg[Index];
     end
   end
   endtask*/

   /*task automatic WaitSPUCycles_NStall2(int C,input int SPUSTARTPC,input bit[4:0] RID);begin
   int i=0;
   while(i<C) begin
      `ifdef PLATFORM_FPGA
          @(negedge $root.TestTop.FPGA_Top_inst.uAPE.uSPU.CClk);
            i=i+1;
      `else
          @(negedge $root.TestTop.uAPE.uSPU.CClk); begin
             if(SPUSTARTPC == 32'h128 && RID == 4)
             $display("%d",i);
             i=i+1;
           end
      `endif
   end
end
endtask*/

   task automatic CheckRValueDecode(input int SPUSTARTPC, input int InstrCycle, input bit[4:0] RID,const ref integer file[26],ref int Num[26],input int InputRegInstSlotNum); 
     begin
      logic[31:0]   RValue;

      integer fileTemp;
      logic flag;
      int InstrCycleTemp;
      InstrCycleTemp = InstrCycle + 1;

      fileTemp = file[RID];
      

      while(1) begin
         //@(iCvSmpIF.APECB) begin
         @(posedge `DecodeCClk) begin
           if(`SPU_STARTDC_PC === SPUSTARTPC && !`DPStall && !`ExeStall) begin
             Inst_Read(InputRegInstSlotNum,flag);
             //if(RID == 2 && SPUSTARTPC == 324)
             //$display("%h  %h  %h  %h  %h",SPUSTARTPC,flag,InputRegInstSlotNum,InstrCycleTemp,RID);
             break;
           end
         end
      end
      
      begin
        WaitSPUCycles_NStall(InstrCycleTemp);
        @(posedge `DecodeCClk);
        Mon.R_Read(RID, RValue);
        //DecodeReg_Read(RID, RValue/*,SPUSTARTPC*/);
        if(flag === 1) begin
          $fdisplay(fileTemp,"%h %h",RValue,SPUSTARTPC);
          Num[RID] = Num[RID] + 1;
        end
      end
      //$display("%d",Num[RID]);
    end
        
      
   endtask

   task automatic CheckSVRValueDecode(input int SPUSTARTPC, input int InstrCycle, input bit[1:0] RID, const ref integer file[4],ref int Num[4],input int InputSVRInstSlotNum); 
     begin
      logic[511:0]   SVRValue;

      integer fileTemp;
      logic flag;
      int InstrCycleTemp;
      InstrCycleTemp = InstrCycle + 1;

      fileTemp = file[RID];
      

      

      while(1) begin
         //@(iCvSmpIF.APECB) begin
         @(posedge `DecodeCClk) begin
           if(`SPU_STARTDC_PC === SPUSTARTPC && !`DPStall && !`ExeStall)begin
             Inst_Read(InputSVRInstSlotNum,flag);
             break;
           end
         end
      end
 
      begin
      WaitSPUCycles_NStall(InstrCycleTemp);
      @(posedge `DecodeCClk);
      Mon.SVR_Read(RID, SVRValue);
      //DecodeSVR_Read(RID, SVRValue);
      if(flag === 1) begin
        $fdisplay(fileTemp,"%h %h",SVRValue,SPUSTARTPC);
        Num[RID] = Num[RID] + 1;
      end
      end
    end
           
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

   task automatic CheckDM0ValueSPU(input int SPUSTARTPC, input int InstrCycle, input int Addr, input bit [2:0] Gran, input [3:0] Size, input [2:0] CGran, input bit [511:0] ExpValue);
      bit[511:0]   DMValue512;
      byte Byte1Value[];
      byte Byte2Value[];
      byte Byte4Value[];
      byte Byte8Value[];
      byte Byte16Value[];
      byte Byte32Value[];
      byte Byte64Value[];
      int i;

      Byte1Value  = new[1];
      Byte2Value  = new[2];
      Byte4Value  = new[4];
      Byte8Value  = new[8];
      Byte16Value  = new[16];
      Byte32Value  = new[32];
      Byte64Value  = new[64];
      
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);

      case(CGran)
        3'd0: begin
          for(i=0; i<64; i++) begin
            $root.TestTop.uAPE.uDM0.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte1Value);
            DMValue512[8*i +:8] = Byte1Value[0] ;
          end
        end
        3'd1: begin
          for(i=0; i<32; i++) begin
            $root.TestTop.uAPE.uDM0.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte2Value);
            DMValue512[16*i   +: 8] = Byte2Value[0] ;
            DMValue512[16*i+8 +: 8] = Byte2Value[1] ;
          end
        end
        3'd2: begin
          for(i=0; i<16; i++) begin
            $root.TestTop.uAPE.uDM0.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte4Value);
            DMValue512[32*i   +: 8] = Byte4Value[0] ;
            DMValue512[32*i+8 +: 8] = Byte4Value[1] ;
            DMValue512[32*i+16+: 8] = Byte4Value[2] ;
            DMValue512[32*i+24+: 8] = Byte4Value[3] ;
          end
        end
        3'd3: begin
          for(i=0; i<8; i++) begin
            $root.TestTop.uAPE.uDM0.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte8Value);
            DMValue512[64*i   +: 8] = Byte8Value[0] ;
            DMValue512[64*i+8 +: 8] = Byte8Value[1] ;
            DMValue512[64*i+16+: 8] = Byte8Value[2] ;
            DMValue512[64*i+24+: 8] = Byte8Value[3] ;
            DMValue512[64*i+32+: 8] = Byte8Value[4] ;
            DMValue512[64*i+40+: 8] = Byte8Value[5] ;
            DMValue512[64*i+48+: 8] = Byte8Value[6] ;
            DMValue512[64*i+56+: 8] = Byte8Value[7] ;
          end
        end
        3'd4: begin
          for(i=0; i<4; i++) begin
            $root.TestTop.uAPE.uDM0.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte16Value);
            DMValue512[128*i    +: 8] = Byte16Value[0] ;
            DMValue512[128*i+  8+: 8] = Byte16Value[1] ;
            DMValue512[128*i+ 16+: 8] = Byte16Value[2] ;
            DMValue512[128*i+ 24+: 8] = Byte16Value[3] ;
            DMValue512[128*i+ 32+: 8] = Byte16Value[4] ;
            DMValue512[128*i+ 40+: 8] = Byte16Value[5] ;
            DMValue512[128*i+ 48+: 8] = Byte16Value[6] ;
            DMValue512[128*i+ 56+: 8] = Byte16Value[7] ;
            DMValue512[128*i+ 64+: 8] = Byte16Value[8] ;
            DMValue512[128*i+ 72+: 8] = Byte16Value[9] ;
            DMValue512[128*i+ 80+: 8] = Byte16Value[10] ;
            DMValue512[128*i+ 88+: 8] = Byte16Value[11] ;
            DMValue512[128*i+ 96+: 8] = Byte16Value[12] ;
            DMValue512[128*i+104+: 8] = Byte16Value[13] ;
            DMValue512[128*i+112+: 8] = Byte16Value[14] ;
            DMValue512[128*i+120+: 8] = Byte16Value[15] ;
          end
        end
        3'd5: begin
          for(i=0; i<2; i++) begin
            $root.TestTop.uAPE.uDM0.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte32Value);
            DMValue512[256*i    +: 8] = Byte32Value[0] ;
            DMValue512[256*i+  8+: 8] = Byte32Value[1] ;
            DMValue512[256*i+ 16+: 8] = Byte32Value[2] ;
            DMValue512[256*i+ 24+: 8] = Byte32Value[3] ;
            DMValue512[256*i+ 32+: 8] = Byte32Value[4] ;
            DMValue512[256*i+ 40+: 8] = Byte32Value[5] ;
            DMValue512[256*i+ 48+: 8] = Byte32Value[6] ;
            DMValue512[256*i+ 56+: 8] = Byte32Value[7] ;
            DMValue512[256*i+ 64+: 8] = Byte32Value[8] ;
            DMValue512[256*i+ 72+: 8] = Byte32Value[9] ;
            DMValue512[256*i+ 80+: 8] = Byte32Value[10] ;
            DMValue512[256*i+ 88+: 8] = Byte32Value[11] ;
            DMValue512[256*i+ 96+: 8] = Byte32Value[12] ;
            DMValue512[256*i+104+: 8] = Byte32Value[13] ;
            DMValue512[256*i+112+: 8] = Byte32Value[14] ;
            DMValue512[256*i+120+: 8] = Byte32Value[15] ;
            DMValue512[256*i+128+: 8] = Byte32Value[16] ;
            DMValue512[256*i+136+: 8] = Byte32Value[17] ;
            DMValue512[256*i+144+: 8] = Byte32Value[18] ;
            DMValue512[256*i+152+: 8] = Byte32Value[19] ;
            DMValue512[256*i+160+: 8] = Byte32Value[20] ;
            DMValue512[256*i+168+: 8] = Byte32Value[21] ;
            DMValue512[256*i+176+: 8] = Byte32Value[22] ;
            DMValue512[256*i+184+: 8] = Byte32Value[23] ;
            DMValue512[256*i+192+: 8] = Byte32Value[24] ;
            DMValue512[256*i+200+: 8] = Byte32Value[25] ;
            DMValue512[256*i+208+: 8] = Byte32Value[26] ;
            DMValue512[256*i+216+: 8] = Byte32Value[27] ;
            DMValue512[256*i+224+: 8] = Byte32Value[28] ;
            DMValue512[256*i+232+: 8] = Byte32Value[29] ;
            DMValue512[256*i+240+: 8] = Byte32Value[30] ;
            DMValue512[256*i+248+: 8] = Byte32Value[31] ;
          end
        end
        3'd6: begin
          $root.TestTop.uAPE.uDM0.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte64Value); 
          DMValue512[0  +: 8] = Byte64Value[0] ;
          DMValue512[8  +: 8] = Byte64Value[1] ;
          DMValue512[16 +: 8] = Byte64Value[2] ;
          DMValue512[24 +: 8] = Byte64Value[3] ;
          DMValue512[32 +: 8] = Byte64Value[4] ;
          DMValue512[40 +: 8] = Byte64Value[5] ;
          DMValue512[48 +: 8] = Byte64Value[6] ;
          DMValue512[56 +: 8] = Byte64Value[7] ;
          DMValue512[64 +: 8] = Byte64Value[8] ;
          DMValue512[72 +: 8] = Byte64Value[9] ;
          DMValue512[80 +: 8] = Byte64Value[10] ;
          DMValue512[88 +: 8] = Byte64Value[11] ;
          DMValue512[96 +: 8] = Byte64Value[12] ;
          DMValue512[104+: 8] = Byte64Value[13] ;
          DMValue512[112+: 8] = Byte64Value[14] ;
          DMValue512[120+: 8] = Byte64Value[15] ;
          DMValue512[128+: 8] = Byte64Value[16] ;
          DMValue512[136+: 8] = Byte64Value[17] ;
          DMValue512[144+: 8] = Byte64Value[18] ;
          DMValue512[152+: 8] = Byte64Value[19] ;
          DMValue512[160+: 8] = Byte64Value[20] ;
          DMValue512[168+: 8] = Byte64Value[21] ;
          DMValue512[176+: 8] = Byte64Value[22] ;
          DMValue512[184+: 8] = Byte64Value[23] ;
          DMValue512[192+: 8] = Byte64Value[24] ;
          DMValue512[200+: 8] = Byte64Value[25] ;
          DMValue512[208+: 8] = Byte64Value[26] ;
          DMValue512[216+: 8] = Byte64Value[27] ;
          DMValue512[224+: 8] = Byte64Value[28] ;
          DMValue512[232+: 8] = Byte64Value[29] ;
          DMValue512[240+: 8] = Byte64Value[30] ;
          DMValue512[248+: 8] = Byte64Value[31] ;
          DMValue512[256+: 8] = Byte64Value[32] ;
          DMValue512[264+: 8] = Byte64Value[33] ;
          DMValue512[272+: 8] = Byte64Value[34] ;
          DMValue512[280+: 8] = Byte64Value[35] ;
          DMValue512[288+: 8] = Byte64Value[36] ;
          DMValue512[296+: 8] = Byte64Value[37] ;
          DMValue512[304+: 8] = Byte64Value[38] ;
          DMValue512[312+: 8] = Byte64Value[39] ;
          DMValue512[320+: 8] = Byte64Value[40] ;
          DMValue512[328+: 8] = Byte64Value[41] ;
          DMValue512[336+: 8] = Byte64Value[42] ;
          DMValue512[344+: 8] = Byte64Value[43] ;
          DMValue512[352+: 8] = Byte64Value[44] ;
          DMValue512[360+: 8] = Byte64Value[45] ;
          DMValue512[368+: 8] = Byte64Value[46] ;
          DMValue512[376+: 8] = Byte64Value[47] ;
          DMValue512[384+: 8] = Byte64Value[48] ;
          DMValue512[392+: 8] = Byte64Value[49] ;
          DMValue512[400+: 8] = Byte64Value[50] ;
          DMValue512[408+: 8] = Byte64Value[51] ;
          DMValue512[416+: 8] = Byte64Value[52] ;
          DMValue512[424+: 8] = Byte64Value[53] ;
          DMValue512[432+: 8] = Byte64Value[54] ;
          DMValue512[440+: 8] = Byte64Value[55] ;
          DMValue512[448+: 8] = Byte64Value[56] ;
          DMValue512[456+: 8] = Byte64Value[57] ;
          DMValue512[464+: 8] = Byte64Value[58] ;
          DMValue512[472+: 8] = Byte64Value[59] ;
          DMValue512[480+: 8] = Byte64Value[60] ;
          DMValue512[488+: 8] = Byte64Value[61] ;
          DMValue512[496+: 8] = Byte64Value[62] ;
          DMValue512[504+: 8] = Byte64Value[63] ;
        end
        default: $display("The input of CGran is invalid !\n\n");
      endcase
      
      if(DMValue512 === ExpValue) $display("%0t Read DM0 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
      else  begin
        $display("%0t Error @SPUSTARTPC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
        Mon.display_512(ExpValue);
        Mon.display_512(DMValue512);
        $display(" ");
      end

      Byte1Value.delete();
      Byte2Value.delete();
      Byte4Value.delete();
      Byte8Value.delete();
      Byte16Value.delete();
      Byte32Value.delete();
      Byte64Value.delete();
    
  endtask

  task automatic CheckDM1ValueSPU(input int SPUSTARTPC, input int InstrCycle, input int Addr, input bit [2:0] Gran, input [3:0] Size, input [2:0] CGran, input bit [511:0] ExpValue);
      bit[511:0]   DMValue512;
      byte Byte1Value[];
      byte Byte2Value[];
      byte Byte4Value[];
      byte Byte8Value[];
      byte Byte16Value[];
      byte Byte32Value[];
      byte Byte64Value[];
      int i;

      Byte1Value  = new[1];
      Byte2Value  = new[2];
      Byte4Value  = new[4];
      Byte8Value  = new[8];
      Byte16Value  = new[16];
      Byte32Value  = new[32];
      Byte64Value  = new[64];
      
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);

      case(CGran)
        3'd0: begin
          for(i=0; i<64; i++) begin
            $root.TestTop.uAPE.uDM1.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte1Value);
            DMValue512[8*i +:8] = Byte1Value[0] ;
          end
        end
        3'd1: begin
          for(i=0; i<32; i++) begin
            $root.TestTop.uAPE.uDM1.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte2Value);
            DMValue512[16*i   +: 8] = Byte2Value[0] ;
            DMValue512[16*i+8 +: 8] = Byte2Value[1] ;
          end
        end
        3'd2: begin
          for(i=0; i<16; i++) begin
            $root.TestTop.uAPE.uDM1.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte4Value);
            DMValue512[32*i   +: 8] = Byte4Value[0] ;
            DMValue512[32*i+8 +: 8] = Byte4Value[1] ;
            DMValue512[32*i+16+: 8] = Byte4Value[2] ;
            DMValue512[32*i+24+: 8] = Byte4Value[3] ;
          end
        end
        3'd3: begin
          for(i=0; i<8; i++) begin
            $root.TestTop.uAPE.uDM1.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte8Value);
            DMValue512[64*i   +: 8] = Byte8Value[0] ;
            DMValue512[64*i+8 +: 8] = Byte8Value[1] ;
            DMValue512[64*i+16+: 8] = Byte8Value[2] ;
            DMValue512[64*i+24+: 8] = Byte8Value[3] ;
            DMValue512[64*i+32+: 8] = Byte8Value[4] ;
            DMValue512[64*i+40+: 8] = Byte8Value[5] ;
            DMValue512[64*i+48+: 8] = Byte8Value[6] ;
            DMValue512[64*i+56+: 8] = Byte8Value[7] ;
          end
        end
        3'd4: begin
          for(i=0; i<4; i++) begin
            $root.TestTop.uAPE.uDM1.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte16Value);
            DMValue512[128*i    +: 8] = Byte16Value[0] ;
            DMValue512[128*i+  8+: 8] = Byte16Value[1] ;
            DMValue512[128*i+ 16+: 8] = Byte16Value[2] ;
            DMValue512[128*i+ 24+: 8] = Byte16Value[3] ;
            DMValue512[128*i+ 32+: 8] = Byte16Value[4] ;
            DMValue512[128*i+ 40+: 8] = Byte16Value[5] ;
            DMValue512[128*i+ 48+: 8] = Byte16Value[6] ;
            DMValue512[128*i+ 56+: 8] = Byte16Value[7] ;
            DMValue512[128*i+ 64+: 8] = Byte16Value[8] ;
            DMValue512[128*i+ 72+: 8] = Byte16Value[9] ;
            DMValue512[128*i+ 80+: 8] = Byte16Value[10] ;
            DMValue512[128*i+ 88+: 8] = Byte16Value[11] ;
            DMValue512[128*i+ 96+: 8] = Byte16Value[12] ;
            DMValue512[128*i+104+: 8] = Byte16Value[13] ;
            DMValue512[128*i+112+: 8] = Byte16Value[14] ;
            DMValue512[128*i+120+: 8] = Byte16Value[15] ;
          end
        end
        3'd5: begin
          for(i=0; i<2; i++) begin
            $root.TestTop.uAPE.uDM1.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte32Value);
            DMValue512[256*i    +: 8] = Byte32Value[0] ;
            DMValue512[256*i+  8+: 8] = Byte32Value[1] ;
            DMValue512[256*i+ 16+: 8] = Byte32Value[2] ;
            DMValue512[256*i+ 24+: 8] = Byte32Value[3] ;
            DMValue512[256*i+ 32+: 8] = Byte32Value[4] ;
            DMValue512[256*i+ 40+: 8] = Byte32Value[5] ;
            DMValue512[256*i+ 48+: 8] = Byte32Value[6] ;
            DMValue512[256*i+ 56+: 8] = Byte32Value[7] ;
            DMValue512[256*i+ 64+: 8] = Byte32Value[8] ;
            DMValue512[256*i+ 72+: 8] = Byte32Value[9] ;
            DMValue512[256*i+ 80+: 8] = Byte32Value[10] ;
            DMValue512[256*i+ 88+: 8] = Byte32Value[11] ;
            DMValue512[256*i+ 96+: 8] = Byte32Value[12] ;
            DMValue512[256*i+104+: 8] = Byte32Value[13] ;
            DMValue512[256*i+112+: 8] = Byte32Value[14] ;
            DMValue512[256*i+120+: 8] = Byte32Value[15] ;
            DMValue512[256*i+128+: 8] = Byte32Value[16] ;
            DMValue512[256*i+136+: 8] = Byte32Value[17] ;
            DMValue512[256*i+144+: 8] = Byte32Value[18] ;
            DMValue512[256*i+152+: 8] = Byte32Value[19] ;
            DMValue512[256*i+160+: 8] = Byte32Value[20] ;
            DMValue512[256*i+168+: 8] = Byte32Value[21] ;
            DMValue512[256*i+176+: 8] = Byte32Value[22] ;
            DMValue512[256*i+184+: 8] = Byte32Value[23] ;
            DMValue512[256*i+192+: 8] = Byte32Value[24] ;
            DMValue512[256*i+200+: 8] = Byte32Value[25] ;
            DMValue512[256*i+208+: 8] = Byte32Value[26] ;
            DMValue512[256*i+216+: 8] = Byte32Value[27] ;
            DMValue512[256*i+224+: 8] = Byte32Value[28] ;
            DMValue512[256*i+232+: 8] = Byte32Value[29] ;
            DMValue512[256*i+240+: 8] = Byte32Value[30] ;
            DMValue512[256*i+248+: 8] = Byte32Value[31] ;
          end
        end
        3'd6: begin
          $root.TestTop.uAPE.uDM1.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte64Value); 
          DMValue512[0  +: 8] = Byte64Value[0] ;
          DMValue512[8  +: 8] = Byte64Value[1] ;
          DMValue512[16 +: 8] = Byte64Value[2] ;
          DMValue512[24 +: 8] = Byte64Value[3] ;
          DMValue512[32 +: 8] = Byte64Value[4] ;
          DMValue512[40 +: 8] = Byte64Value[5] ;
          DMValue512[48 +: 8] = Byte64Value[6] ;
          DMValue512[56 +: 8] = Byte64Value[7] ;
          DMValue512[64 +: 8] = Byte64Value[8] ;
          DMValue512[72 +: 8] = Byte64Value[9] ;
          DMValue512[80 +: 8] = Byte64Value[10] ;
          DMValue512[88 +: 8] = Byte64Value[11] ;
          DMValue512[96 +: 8] = Byte64Value[12] ;
          DMValue512[104+: 8] = Byte64Value[13] ;
          DMValue512[112+: 8] = Byte64Value[14] ;
          DMValue512[120+: 8] = Byte64Value[15] ;
          DMValue512[128+: 8] = Byte64Value[16] ;
          DMValue512[136+: 8] = Byte64Value[17] ;
          DMValue512[144+: 8] = Byte64Value[18] ;
          DMValue512[152+: 8] = Byte64Value[19] ;
          DMValue512[160+: 8] = Byte64Value[20] ;
          DMValue512[168+: 8] = Byte64Value[21] ;
          DMValue512[176+: 8] = Byte64Value[22] ;
          DMValue512[184+: 8] = Byte64Value[23] ;
          DMValue512[192+: 8] = Byte64Value[24] ;
          DMValue512[200+: 8] = Byte64Value[25] ;
          DMValue512[208+: 8] = Byte64Value[26] ;
          DMValue512[216+: 8] = Byte64Value[27] ;
          DMValue512[224+: 8] = Byte64Value[28] ;
          DMValue512[232+: 8] = Byte64Value[29] ;
          DMValue512[240+: 8] = Byte64Value[30] ;
          DMValue512[248+: 8] = Byte64Value[31] ;
          DMValue512[256+: 8] = Byte64Value[32] ;
          DMValue512[264+: 8] = Byte64Value[33] ;
          DMValue512[272+: 8] = Byte64Value[34] ;
          DMValue512[280+: 8] = Byte64Value[35] ;
          DMValue512[288+: 8] = Byte64Value[36] ;
          DMValue512[296+: 8] = Byte64Value[37] ;
          DMValue512[304+: 8] = Byte64Value[38] ;
          DMValue512[312+: 8] = Byte64Value[39] ;
          DMValue512[320+: 8] = Byte64Value[40] ;
          DMValue512[328+: 8] = Byte64Value[41] ;
          DMValue512[336+: 8] = Byte64Value[42] ;
          DMValue512[344+: 8] = Byte64Value[43] ;
          DMValue512[352+: 8] = Byte64Value[44] ;
          DMValue512[360+: 8] = Byte64Value[45] ;
          DMValue512[368+: 8] = Byte64Value[46] ;
          DMValue512[376+: 8] = Byte64Value[47] ;
          DMValue512[384+: 8] = Byte64Value[48] ;
          DMValue512[392+: 8] = Byte64Value[49] ;
          DMValue512[400+: 8] = Byte64Value[50] ;
          DMValue512[408+: 8] = Byte64Value[51] ;
          DMValue512[416+: 8] = Byte64Value[52] ;
          DMValue512[424+: 8] = Byte64Value[53] ;
          DMValue512[432+: 8] = Byte64Value[54] ;
          DMValue512[440+: 8] = Byte64Value[55] ;
          DMValue512[448+: 8] = Byte64Value[56] ;
          DMValue512[456+: 8] = Byte64Value[57] ;
          DMValue512[464+: 8] = Byte64Value[58] ;
          DMValue512[472+: 8] = Byte64Value[59] ;
          DMValue512[480+: 8] = Byte64Value[60] ;
          DMValue512[488+: 8] = Byte64Value[61] ;
          DMValue512[496+: 8] = Byte64Value[62] ;
          DMValue512[504+: 8] = Byte64Value[63] ;
        end
        default: $display("The input of CGran is invalid !\n\n");
      endcase
      
      if(DMValue512 === ExpValue) $display("%0t Read DM1 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
      else  begin
        $display("%0t Error @SPUSTARTPC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
        Mon.display_512(ExpValue);
        Mon.display_512(DMValue512);
        $display(" ");
      end

      Byte1Value.delete();
      Byte2Value.delete();
      Byte4Value.delete();
      Byte8Value.delete();
      Byte16Value.delete();
      Byte32Value.delete();
      Byte64Value.delete();
    
  endtask

  task automatic CheckDM2ValueSPU(input int SPUSTARTPC, input int InstrCycle, input int Addr, input bit [2:0] Gran, input [3:0] Size, input [2:0] CGran, input bit [511:0] ExpValue);
      bit[511:0]   DMValue512;
      byte Byte1Value[];
      byte Byte2Value[];
      byte Byte4Value[];
      byte Byte8Value[];
      byte Byte16Value[];
      byte Byte32Value[];
      byte Byte64Value[];
      int i;

      Byte1Value  = new[1];
      Byte2Value  = new[2];
      Byte4Value  = new[4];
      Byte8Value  = new[8];
      Byte16Value  = new[16];
      Byte32Value  = new[32];
      Byte64Value  = new[64];
      
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);

      case(CGran)
        3'd0: begin
          for(i=0; i<64; i++) begin
            $root.TestTop.uAPE.uDM2.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte1Value);
            DMValue512[8*i +:8] = Byte1Value[0] ;
          end
        end
        3'd1: begin
          for(i=0; i<32; i++) begin
            $root.TestTop.uAPE.uDM2.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte2Value);
            DMValue512[16*i   +: 8] = Byte2Value[0] ;
            DMValue512[16*i+8 +: 8] = Byte2Value[1] ;
          end
        end
        3'd2: begin
          for(i=0; i<16; i++) begin
            $root.TestTop.uAPE.uDM2.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte4Value);
            DMValue512[32*i   +: 8] = Byte4Value[0] ;
            DMValue512[32*i+8 +: 8] = Byte4Value[1] ;
            DMValue512[32*i+16+: 8] = Byte4Value[2] ;
            DMValue512[32*i+24+: 8] = Byte4Value[3] ;
          end
        end
        3'd3: begin
          for(i=0; i<8; i++) begin
            $root.TestTop.uAPE.uDM2.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte8Value);
            DMValue512[64*i   +: 8] = Byte8Value[0] ;
            DMValue512[64*i+8 +: 8] = Byte8Value[1] ;
            DMValue512[64*i+16+: 8] = Byte8Value[2] ;
            DMValue512[64*i+24+: 8] = Byte8Value[3] ;
            DMValue512[64*i+32+: 8] = Byte8Value[4] ;
            DMValue512[64*i+40+: 8] = Byte8Value[5] ;
            DMValue512[64*i+48+: 8] = Byte8Value[6] ;
            DMValue512[64*i+56+: 8] = Byte8Value[7] ;
          end
        end
        3'd4: begin
          for(i=0; i<4; i++) begin
            $root.TestTop.uAPE.uDM2.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte16Value);
            DMValue512[128*i    +: 8] = Byte16Value[0] ;
            DMValue512[128*i+  8+: 8] = Byte16Value[1] ;
            DMValue512[128*i+ 16+: 8] = Byte16Value[2] ;
            DMValue512[128*i+ 24+: 8] = Byte16Value[3] ;
            DMValue512[128*i+ 32+: 8] = Byte16Value[4] ;
            DMValue512[128*i+ 40+: 8] = Byte16Value[5] ;
            DMValue512[128*i+ 48+: 8] = Byte16Value[6] ;
            DMValue512[128*i+ 56+: 8] = Byte16Value[7] ;
            DMValue512[128*i+ 64+: 8] = Byte16Value[8] ;
            DMValue512[128*i+ 72+: 8] = Byte16Value[9] ;
            DMValue512[128*i+ 80+: 8] = Byte16Value[10] ;
            DMValue512[128*i+ 88+: 8] = Byte16Value[11] ;
            DMValue512[128*i+ 96+: 8] = Byte16Value[12] ;
            DMValue512[128*i+104+: 8] = Byte16Value[13] ;
            DMValue512[128*i+112+: 8] = Byte16Value[14] ;
            DMValue512[128*i+120+: 8] = Byte16Value[15] ;
          end
        end
        3'd5: begin
          for(i=0; i<2; i++) begin
            $root.TestTop.uAPE.uDM2.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte32Value);
            DMValue512[256*i    +: 8] = Byte32Value[0] ;
            DMValue512[256*i+  8+: 8] = Byte32Value[1] ;
            DMValue512[256*i+ 16+: 8] = Byte32Value[2] ;
            DMValue512[256*i+ 24+: 8] = Byte32Value[3] ;
            DMValue512[256*i+ 32+: 8] = Byte32Value[4] ;
            DMValue512[256*i+ 40+: 8] = Byte32Value[5] ;
            DMValue512[256*i+ 48+: 8] = Byte32Value[6] ;
            DMValue512[256*i+ 56+: 8] = Byte32Value[7] ;
            DMValue512[256*i+ 64+: 8] = Byte32Value[8] ;
            DMValue512[256*i+ 72+: 8] = Byte32Value[9] ;
            DMValue512[256*i+ 80+: 8] = Byte32Value[10] ;
            DMValue512[256*i+ 88+: 8] = Byte32Value[11] ;
            DMValue512[256*i+ 96+: 8] = Byte32Value[12] ;
            DMValue512[256*i+104+: 8] = Byte32Value[13] ;
            DMValue512[256*i+112+: 8] = Byte32Value[14] ;
            DMValue512[256*i+120+: 8] = Byte32Value[15] ;
            DMValue512[256*i+128+: 8] = Byte32Value[16] ;
            DMValue512[256*i+136+: 8] = Byte32Value[17] ;
            DMValue512[256*i+144+: 8] = Byte32Value[18] ;
            DMValue512[256*i+152+: 8] = Byte32Value[19] ;
            DMValue512[256*i+160+: 8] = Byte32Value[20] ;
            DMValue512[256*i+168+: 8] = Byte32Value[21] ;
            DMValue512[256*i+176+: 8] = Byte32Value[22] ;
            DMValue512[256*i+184+: 8] = Byte32Value[23] ;
            DMValue512[256*i+192+: 8] = Byte32Value[24] ;
            DMValue512[256*i+200+: 8] = Byte32Value[25] ;
            DMValue512[256*i+208+: 8] = Byte32Value[26] ;
            DMValue512[256*i+216+: 8] = Byte32Value[27] ;
            DMValue512[256*i+224+: 8] = Byte32Value[28] ;
            DMValue512[256*i+232+: 8] = Byte32Value[29] ;
            DMValue512[256*i+240+: 8] = Byte32Value[30] ;
            DMValue512[256*i+248+: 8] = Byte32Value[31] ;
          end
        end
        3'd6: begin
          $root.TestTop.uAPE.uDM2.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte64Value); 
          DMValue512[0  +: 8] = Byte64Value[0] ;
          DMValue512[8  +: 8] = Byte64Value[1] ;
          DMValue512[16 +: 8] = Byte64Value[2] ;
          DMValue512[24 +: 8] = Byte64Value[3] ;
          DMValue512[32 +: 8] = Byte64Value[4] ;
          DMValue512[40 +: 8] = Byte64Value[5] ;
          DMValue512[48 +: 8] = Byte64Value[6] ;
          DMValue512[56 +: 8] = Byte64Value[7] ;
          DMValue512[64 +: 8] = Byte64Value[8] ;
          DMValue512[72 +: 8] = Byte64Value[9] ;
          DMValue512[80 +: 8] = Byte64Value[10] ;
          DMValue512[88 +: 8] = Byte64Value[11] ;
          DMValue512[96 +: 8] = Byte64Value[12] ;
          DMValue512[104+: 8] = Byte64Value[13] ;
          DMValue512[112+: 8] = Byte64Value[14] ;
          DMValue512[120+: 8] = Byte64Value[15] ;
          DMValue512[128+: 8] = Byte64Value[16] ;
          DMValue512[136+: 8] = Byte64Value[17] ;
          DMValue512[144+: 8] = Byte64Value[18] ;
          DMValue512[152+: 8] = Byte64Value[19] ;
          DMValue512[160+: 8] = Byte64Value[20] ;
          DMValue512[168+: 8] = Byte64Value[21] ;
          DMValue512[176+: 8] = Byte64Value[22] ;
          DMValue512[184+: 8] = Byte64Value[23] ;
          DMValue512[192+: 8] = Byte64Value[24] ;
          DMValue512[200+: 8] = Byte64Value[25] ;
          DMValue512[208+: 8] = Byte64Value[26] ;
          DMValue512[216+: 8] = Byte64Value[27] ;
          DMValue512[224+: 8] = Byte64Value[28] ;
          DMValue512[232+: 8] = Byte64Value[29] ;
          DMValue512[240+: 8] = Byte64Value[30] ;
          DMValue512[248+: 8] = Byte64Value[31] ;
          DMValue512[256+: 8] = Byte64Value[32] ;
          DMValue512[264+: 8] = Byte64Value[33] ;
          DMValue512[272+: 8] = Byte64Value[34] ;
          DMValue512[280+: 8] = Byte64Value[35] ;
          DMValue512[288+: 8] = Byte64Value[36] ;
          DMValue512[296+: 8] = Byte64Value[37] ;
          DMValue512[304+: 8] = Byte64Value[38] ;
          DMValue512[312+: 8] = Byte64Value[39] ;
          DMValue512[320+: 8] = Byte64Value[40] ;
          DMValue512[328+: 8] = Byte64Value[41] ;
          DMValue512[336+: 8] = Byte64Value[42] ;
          DMValue512[344+: 8] = Byte64Value[43] ;
          DMValue512[352+: 8] = Byte64Value[44] ;
          DMValue512[360+: 8] = Byte64Value[45] ;
          DMValue512[368+: 8] = Byte64Value[46] ;
          DMValue512[376+: 8] = Byte64Value[47] ;
          DMValue512[384+: 8] = Byte64Value[48] ;
          DMValue512[392+: 8] = Byte64Value[49] ;
          DMValue512[400+: 8] = Byte64Value[50] ;
          DMValue512[408+: 8] = Byte64Value[51] ;
          DMValue512[416+: 8] = Byte64Value[52] ;
          DMValue512[424+: 8] = Byte64Value[53] ;
          DMValue512[432+: 8] = Byte64Value[54] ;
          DMValue512[440+: 8] = Byte64Value[55] ;
          DMValue512[448+: 8] = Byte64Value[56] ;
          DMValue512[456+: 8] = Byte64Value[57] ;
          DMValue512[464+: 8] = Byte64Value[58] ;
          DMValue512[472+: 8] = Byte64Value[59] ;
          DMValue512[480+: 8] = Byte64Value[60] ;
          DMValue512[488+: 8] = Byte64Value[61] ;
          DMValue512[496+: 8] = Byte64Value[62] ;
          DMValue512[504+: 8] = Byte64Value[63] ;
        end
        default: $display("The input of CGran is invalid !\n\n");
      endcase
      
      if(DMValue512 === ExpValue) $display("%0t Read DM2 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
      else  begin
        $display("%0t Error @SPUSTARTPC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
        Mon.display_512(ExpValue);
        Mon.display_512(DMValue512);
        $display(" ");
      end

      Byte1Value.delete();
      Byte2Value.delete();
      Byte4Value.delete();
      Byte8Value.delete();
      Byte16Value.delete();
      Byte32Value.delete();
      Byte64Value.delete();
    
  endtask

  task automatic CheckDM3ValueSPU(input int SPUSTARTPC, input int InstrCycle, input int Addr, input bit [2:0] Gran, input [3:0] Size, input [2:0] CGran, input bit [511:0] ExpValue);
      bit[511:0]   DMValue512;
      byte Byte1Value[];
      byte Byte2Value[];
      byte Byte4Value[];
      byte Byte8Value[];
      byte Byte16Value[];
      byte Byte32Value[];
      byte Byte64Value[];
      int i;

      Byte1Value  = new[1];
      Byte2Value  = new[2];
      Byte4Value  = new[4];
      Byte8Value  = new[8];
      Byte16Value  = new[16];
      Byte32Value  = new[32];
      Byte64Value  = new[64];
      
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);

      case(CGran)
        3'd0: begin
          for(i=0; i<64; i++) begin
            $root.TestTop.uAPE.uDM3.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte1Value);
            DMValue512[8*i +:8] = Byte1Value[0] ;
          end
        end
        3'd1: begin
          for(i=0; i<32; i++) begin
            $root.TestTop.uAPE.uDM3.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte2Value);
            DMValue512[16*i   +: 8] = Byte2Value[0] ;
            DMValue512[16*i+8 +: 8] = Byte2Value[1] ;
          end
        end
        3'd2: begin
          for(i=0; i<16; i++) begin
            $root.TestTop.uAPE.uDM3.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte4Value);
            DMValue512[32*i   +: 8] = Byte4Value[0] ;
            DMValue512[32*i+8 +: 8] = Byte4Value[1] ;
            DMValue512[32*i+16+: 8] = Byte4Value[2] ;
            DMValue512[32*i+24+: 8] = Byte4Value[3] ;
          end
        end
        3'd3: begin
          for(i=0; i<8; i++) begin
            $root.TestTop.uAPE.uDM3.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte8Value);
            DMValue512[64*i   +: 8] = Byte8Value[0] ;
            DMValue512[64*i+8 +: 8] = Byte8Value[1] ;
            DMValue512[64*i+16+: 8] = Byte8Value[2] ;
            DMValue512[64*i+24+: 8] = Byte8Value[3] ;
            DMValue512[64*i+32+: 8] = Byte8Value[4] ;
            DMValue512[64*i+40+: 8] = Byte8Value[5] ;
            DMValue512[64*i+48+: 8] = Byte8Value[6] ;
            DMValue512[64*i+56+: 8] = Byte8Value[7] ;
          end
        end
        3'd4: begin
          for(i=0; i<4; i++) begin
            $root.TestTop.uAPE.uDM3.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte16Value);
            DMValue512[128*i    +: 8] = Byte16Value[0] ;
            DMValue512[128*i+  8+: 8] = Byte16Value[1] ;
            DMValue512[128*i+ 16+: 8] = Byte16Value[2] ;
            DMValue512[128*i+ 24+: 8] = Byte16Value[3] ;
            DMValue512[128*i+ 32+: 8] = Byte16Value[4] ;
            DMValue512[128*i+ 40+: 8] = Byte16Value[5] ;
            DMValue512[128*i+ 48+: 8] = Byte16Value[6] ;
            DMValue512[128*i+ 56+: 8] = Byte16Value[7] ;
            DMValue512[128*i+ 64+: 8] = Byte16Value[8] ;
            DMValue512[128*i+ 72+: 8] = Byte16Value[9] ;
            DMValue512[128*i+ 80+: 8] = Byte16Value[10] ;
            DMValue512[128*i+ 88+: 8] = Byte16Value[11] ;
            DMValue512[128*i+ 96+: 8] = Byte16Value[12] ;
            DMValue512[128*i+104+: 8] = Byte16Value[13] ;
            DMValue512[128*i+112+: 8] = Byte16Value[14] ;
            DMValue512[128*i+120+: 8] = Byte16Value[15] ;
          end
        end
        3'd5: begin
          for(i=0; i<2; i++) begin
            $root.TestTop.uAPE.uDM3.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte32Value);
            DMValue512[256*i    +: 8] = Byte32Value[0] ;
            DMValue512[256*i+  8+: 8] = Byte32Value[1] ;
            DMValue512[256*i+ 16+: 8] = Byte32Value[2] ;
            DMValue512[256*i+ 24+: 8] = Byte32Value[3] ;
            DMValue512[256*i+ 32+: 8] = Byte32Value[4] ;
            DMValue512[256*i+ 40+: 8] = Byte32Value[5] ;
            DMValue512[256*i+ 48+: 8] = Byte32Value[6] ;
            DMValue512[256*i+ 56+: 8] = Byte32Value[7] ;
            DMValue512[256*i+ 64+: 8] = Byte32Value[8] ;
            DMValue512[256*i+ 72+: 8] = Byte32Value[9] ;
            DMValue512[256*i+ 80+: 8] = Byte32Value[10] ;
            DMValue512[256*i+ 88+: 8] = Byte32Value[11] ;
            DMValue512[256*i+ 96+: 8] = Byte32Value[12] ;
            DMValue512[256*i+104+: 8] = Byte32Value[13] ;
            DMValue512[256*i+112+: 8] = Byte32Value[14] ;
            DMValue512[256*i+120+: 8] = Byte32Value[15] ;
            DMValue512[256*i+128+: 8] = Byte32Value[16] ;
            DMValue512[256*i+136+: 8] = Byte32Value[17] ;
            DMValue512[256*i+144+: 8] = Byte32Value[18] ;
            DMValue512[256*i+152+: 8] = Byte32Value[19] ;
            DMValue512[256*i+160+: 8] = Byte32Value[20] ;
            DMValue512[256*i+168+: 8] = Byte32Value[21] ;
            DMValue512[256*i+176+: 8] = Byte32Value[22] ;
            DMValue512[256*i+184+: 8] = Byte32Value[23] ;
            DMValue512[256*i+192+: 8] = Byte32Value[24] ;
            DMValue512[256*i+200+: 8] = Byte32Value[25] ;
            DMValue512[256*i+208+: 8] = Byte32Value[26] ;
            DMValue512[256*i+216+: 8] = Byte32Value[27] ;
            DMValue512[256*i+224+: 8] = Byte32Value[28] ;
            DMValue512[256*i+232+: 8] = Byte32Value[29] ;
            DMValue512[256*i+240+: 8] = Byte32Value[30] ;
            DMValue512[256*i+248+: 8] = Byte32Value[31] ;
          end
        end
        3'd6: begin
          $root.TestTop.uAPE.uDM3.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte64Value); 
          DMValue512[0  +: 8] = Byte64Value[0] ;
          DMValue512[8  +: 8] = Byte64Value[1] ;
          DMValue512[16 +: 8] = Byte64Value[2] ;
          DMValue512[24 +: 8] = Byte64Value[3] ;
          DMValue512[32 +: 8] = Byte64Value[4] ;
          DMValue512[40 +: 8] = Byte64Value[5] ;
          DMValue512[48 +: 8] = Byte64Value[6] ;
          DMValue512[56 +: 8] = Byte64Value[7] ;
          DMValue512[64 +: 8] = Byte64Value[8] ;
          DMValue512[72 +: 8] = Byte64Value[9] ;
          DMValue512[80 +: 8] = Byte64Value[10] ;
          DMValue512[88 +: 8] = Byte64Value[11] ;
          DMValue512[96 +: 8] = Byte64Value[12] ;
          DMValue512[104+: 8] = Byte64Value[13] ;
          DMValue512[112+: 8] = Byte64Value[14] ;
          DMValue512[120+: 8] = Byte64Value[15] ;
          DMValue512[128+: 8] = Byte64Value[16] ;
          DMValue512[136+: 8] = Byte64Value[17] ;
          DMValue512[144+: 8] = Byte64Value[18] ;
          DMValue512[152+: 8] = Byte64Value[19] ;
          DMValue512[160+: 8] = Byte64Value[20] ;
          DMValue512[168+: 8] = Byte64Value[21] ;
          DMValue512[176+: 8] = Byte64Value[22] ;
          DMValue512[184+: 8] = Byte64Value[23] ;
          DMValue512[192+: 8] = Byte64Value[24] ;
          DMValue512[200+: 8] = Byte64Value[25] ;
          DMValue512[208+: 8] = Byte64Value[26] ;
          DMValue512[216+: 8] = Byte64Value[27] ;
          DMValue512[224+: 8] = Byte64Value[28] ;
          DMValue512[232+: 8] = Byte64Value[29] ;
          DMValue512[240+: 8] = Byte64Value[30] ;
          DMValue512[248+: 8] = Byte64Value[31] ;
          DMValue512[256+: 8] = Byte64Value[32] ;
          DMValue512[264+: 8] = Byte64Value[33] ;
          DMValue512[272+: 8] = Byte64Value[34] ;
          DMValue512[280+: 8] = Byte64Value[35] ;
          DMValue512[288+: 8] = Byte64Value[36] ;
          DMValue512[296+: 8] = Byte64Value[37] ;
          DMValue512[304+: 8] = Byte64Value[38] ;
          DMValue512[312+: 8] = Byte64Value[39] ;
          DMValue512[320+: 8] = Byte64Value[40] ;
          DMValue512[328+: 8] = Byte64Value[41] ;
          DMValue512[336+: 8] = Byte64Value[42] ;
          DMValue512[344+: 8] = Byte64Value[43] ;
          DMValue512[352+: 8] = Byte64Value[44] ;
          DMValue512[360+: 8] = Byte64Value[45] ;
          DMValue512[368+: 8] = Byte64Value[46] ;
          DMValue512[376+: 8] = Byte64Value[47] ;
          DMValue512[384+: 8] = Byte64Value[48] ;
          DMValue512[392+: 8] = Byte64Value[49] ;
          DMValue512[400+: 8] = Byte64Value[50] ;
          DMValue512[408+: 8] = Byte64Value[51] ;
          DMValue512[416+: 8] = Byte64Value[52] ;
          DMValue512[424+: 8] = Byte64Value[53] ;
          DMValue512[432+: 8] = Byte64Value[54] ;
          DMValue512[440+: 8] = Byte64Value[55] ;
          DMValue512[448+: 8] = Byte64Value[56] ;
          DMValue512[456+: 8] = Byte64Value[57] ;
          DMValue512[464+: 8] = Byte64Value[58] ;
          DMValue512[472+: 8] = Byte64Value[59] ;
          DMValue512[480+: 8] = Byte64Value[60] ;
          DMValue512[488+: 8] = Byte64Value[61] ;
          DMValue512[496+: 8] = Byte64Value[62] ;
          DMValue512[504+: 8] = Byte64Value[63] ;
        end
        default: $display("The input of CGran is invalid !\n\n");
      endcase
      
      if(DMValue512 === ExpValue) $display("%0t Read DM2 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
      else  begin
        $display("%0t Error @SPUSTARTPC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
        Mon.display_512(ExpValue);
        Mon.display_512(DMValue512);
        $display(" ");
      end

      Byte1Value.delete();
      Byte2Value.delete();
      Byte4Value.delete();
      Byte8Value.delete();
      Byte16Value.delete();
      Byte32Value.delete();
      Byte64Value.delete();
    
  endtask

  task automatic CheckDM0ValueSPUCol(input int SPUSTARTPC, input int InstrCycle, input int Addr, input bit [1:0] AGran, input bit [2:0] Gran, input [3:0] Size, input [2:0] CGran, input bit [511:0] ExpValue);
      bit[511:0]   DMValue512;
      byte Byte1Value[];
      byte Byte2Value[];
      byte Byte4Value[];
      byte Byte8Value[];
      byte Byte16Value[];
      byte Byte32Value[];
      byte Byte64Value[];
      int i;

      Byte1Value  = new[1];
      Byte2Value  = new[2];
      Byte4Value  = new[4];
      Byte8Value  = new[8];
      Byte16Value  = new[16];
      Byte32Value  = new[32];
      Byte64Value  = new[64];
      
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);

      case(CGran)
        3'd0: begin
          for(i=0; i<64; i++) begin
            $root.TestTop.uAPE.uDM0.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte1Value);
            DMValue512[8*i +:8] = Byte1Value[0] ;
          end
        end
        3'd1: begin
          for(i=0; i<32; i++) begin
            $root.TestTop.uAPE.uDM0.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte2Value);
            DMValue512[16*i   +: 8] = Byte2Value[0] ;
            DMValue512[16*i+8 +: 8] = Byte2Value[1] ;
          end
        end
        3'd2: begin
          for(i=0; i<16; i++) begin
            $root.TestTop.uAPE.uDM0.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte4Value);
            DMValue512[32*i   +: 8] = Byte4Value[0] ;
            DMValue512[32*i+8 +: 8] = Byte4Value[1] ;
            DMValue512[32*i+16+: 8] = Byte4Value[2] ;
            DMValue512[32*i+24+: 8] = Byte4Value[3] ;
          end
        end
        3'd3: begin
          for(i=0; i<8; i++) begin
            $root.TestTop.uAPE.uDM0.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte8Value);
            DMValue512[64*i   +: 8] = Byte8Value[0] ;
            DMValue512[64*i+8 +: 8] = Byte8Value[1] ;
            DMValue512[64*i+16+: 8] = Byte8Value[2] ;
            DMValue512[64*i+24+: 8] = Byte8Value[3] ;
            DMValue512[64*i+32+: 8] = Byte8Value[4] ;
            DMValue512[64*i+40+: 8] = Byte8Value[5] ;
            DMValue512[64*i+48+: 8] = Byte8Value[6] ;
            DMValue512[64*i+56+: 8] = Byte8Value[7] ;
          end
        end
        3'd4: begin
          for(i=0; i<4; i++) begin
            $root.TestTop.uAPE.uDM0.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte16Value);
            DMValue512[128*i    +: 8] = Byte16Value[0] ;
            DMValue512[128*i+  8+: 8] = Byte16Value[1] ;
            DMValue512[128*i+ 16+: 8] = Byte16Value[2] ;
            DMValue512[128*i+ 24+: 8] = Byte16Value[3] ;
            DMValue512[128*i+ 32+: 8] = Byte16Value[4] ;
            DMValue512[128*i+ 40+: 8] = Byte16Value[5] ;
            DMValue512[128*i+ 48+: 8] = Byte16Value[6] ;
            DMValue512[128*i+ 56+: 8] = Byte16Value[7] ;
            DMValue512[128*i+ 64+: 8] = Byte16Value[8] ;
            DMValue512[128*i+ 72+: 8] = Byte16Value[9] ;
            DMValue512[128*i+ 80+: 8] = Byte16Value[10] ;
            DMValue512[128*i+ 88+: 8] = Byte16Value[11] ;
            DMValue512[128*i+ 96+: 8] = Byte16Value[12] ;
            DMValue512[128*i+104+: 8] = Byte16Value[13] ;
            DMValue512[128*i+112+: 8] = Byte16Value[14] ;
            DMValue512[128*i+120+: 8] = Byte16Value[15] ;
          end
        end
        3'd5: begin
          for(i=0; i<2; i++) begin
            $root.TestTop.uAPE.uDM0.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte32Value);
            DMValue512[256*i    +: 8] = Byte32Value[0] ;
            DMValue512[256*i+  8+: 8] = Byte32Value[1] ;
            DMValue512[256*i+ 16+: 8] = Byte32Value[2] ;
            DMValue512[256*i+ 24+: 8] = Byte32Value[3] ;
            DMValue512[256*i+ 32+: 8] = Byte32Value[4] ;
            DMValue512[256*i+ 40+: 8] = Byte32Value[5] ;
            DMValue512[256*i+ 48+: 8] = Byte32Value[6] ;
            DMValue512[256*i+ 56+: 8] = Byte32Value[7] ;
            DMValue512[256*i+ 64+: 8] = Byte32Value[8] ;
            DMValue512[256*i+ 72+: 8] = Byte32Value[9] ;
            DMValue512[256*i+ 80+: 8] = Byte32Value[10] ;
            DMValue512[256*i+ 88+: 8] = Byte32Value[11] ;
            DMValue512[256*i+ 96+: 8] = Byte32Value[12] ;
            DMValue512[256*i+104+: 8] = Byte32Value[13] ;
            DMValue512[256*i+112+: 8] = Byte32Value[14] ;
            DMValue512[256*i+120+: 8] = Byte32Value[15] ;
            DMValue512[256*i+128+: 8] = Byte32Value[16] ;
            DMValue512[256*i+136+: 8] = Byte32Value[17] ;
            DMValue512[256*i+144+: 8] = Byte32Value[18] ;
            DMValue512[256*i+152+: 8] = Byte32Value[19] ;
            DMValue512[256*i+160+: 8] = Byte32Value[20] ;
            DMValue512[256*i+168+: 8] = Byte32Value[21] ;
            DMValue512[256*i+176+: 8] = Byte32Value[22] ;
            DMValue512[256*i+184+: 8] = Byte32Value[23] ;
            DMValue512[256*i+192+: 8] = Byte32Value[24] ;
            DMValue512[256*i+200+: 8] = Byte32Value[25] ;
            DMValue512[256*i+208+: 8] = Byte32Value[26] ;
            DMValue512[256*i+216+: 8] = Byte32Value[27] ;
            DMValue512[256*i+224+: 8] = Byte32Value[28] ;
            DMValue512[256*i+232+: 8] = Byte32Value[29] ;
            DMValue512[256*i+240+: 8] = Byte32Value[30] ;
            DMValue512[256*i+248+: 8] = Byte32Value[31] ;
          end
        end
        3'd6: begin
          $root.TestTop.uAPE.uDM0.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte64Value); 
          DMValue512[0  +: 8] = Byte64Value[0] ;
          DMValue512[8  +: 8] = Byte64Value[1] ;
          DMValue512[16 +: 8] = Byte64Value[2] ;
          DMValue512[24 +: 8] = Byte64Value[3] ;
          DMValue512[32 +: 8] = Byte64Value[4] ;
          DMValue512[40 +: 8] = Byte64Value[5] ;
          DMValue512[48 +: 8] = Byte64Value[6] ;
          DMValue512[56 +: 8] = Byte64Value[7] ;
          DMValue512[64 +: 8] = Byte64Value[8] ;
          DMValue512[72 +: 8] = Byte64Value[9] ;
          DMValue512[80 +: 8] = Byte64Value[10] ;
          DMValue512[88 +: 8] = Byte64Value[11] ;
          DMValue512[96 +: 8] = Byte64Value[12] ;
          DMValue512[104+: 8] = Byte64Value[13] ;
          DMValue512[112+: 8] = Byte64Value[14] ;
          DMValue512[120+: 8] = Byte64Value[15] ;
          DMValue512[128+: 8] = Byte64Value[16] ;
          DMValue512[136+: 8] = Byte64Value[17] ;
          DMValue512[144+: 8] = Byte64Value[18] ;
          DMValue512[152+: 8] = Byte64Value[19] ;
          DMValue512[160+: 8] = Byte64Value[20] ;
          DMValue512[168+: 8] = Byte64Value[21] ;
          DMValue512[176+: 8] = Byte64Value[22] ;
          DMValue512[184+: 8] = Byte64Value[23] ;
          DMValue512[192+: 8] = Byte64Value[24] ;
          DMValue512[200+: 8] = Byte64Value[25] ;
          DMValue512[208+: 8] = Byte64Value[26] ;
          DMValue512[216+: 8] = Byte64Value[27] ;
          DMValue512[224+: 8] = Byte64Value[28] ;
          DMValue512[232+: 8] = Byte64Value[29] ;
          DMValue512[240+: 8] = Byte64Value[30] ;
          DMValue512[248+: 8] = Byte64Value[31] ;
          DMValue512[256+: 8] = Byte64Value[32] ;
          DMValue512[264+: 8] = Byte64Value[33] ;
          DMValue512[272+: 8] = Byte64Value[34] ;
          DMValue512[280+: 8] = Byte64Value[35] ;
          DMValue512[288+: 8] = Byte64Value[36] ;
          DMValue512[296+: 8] = Byte64Value[37] ;
          DMValue512[304+: 8] = Byte64Value[38] ;
          DMValue512[312+: 8] = Byte64Value[39] ;
          DMValue512[320+: 8] = Byte64Value[40] ;
          DMValue512[328+: 8] = Byte64Value[41] ;
          DMValue512[336+: 8] = Byte64Value[42] ;
          DMValue512[344+: 8] = Byte64Value[43] ;
          DMValue512[352+: 8] = Byte64Value[44] ;
          DMValue512[360+: 8] = Byte64Value[45] ;
          DMValue512[368+: 8] = Byte64Value[46] ;
          DMValue512[376+: 8] = Byte64Value[47] ;
          DMValue512[384+: 8] = Byte64Value[48] ;
          DMValue512[392+: 8] = Byte64Value[49] ;
          DMValue512[400+: 8] = Byte64Value[50] ;
          DMValue512[408+: 8] = Byte64Value[51] ;
          DMValue512[416+: 8] = Byte64Value[52] ;
          DMValue512[424+: 8] = Byte64Value[53] ;
          DMValue512[432+: 8] = Byte64Value[54] ;
          DMValue512[440+: 8] = Byte64Value[55] ;
          DMValue512[448+: 8] = Byte64Value[56] ;
          DMValue512[456+: 8] = Byte64Value[57] ;
          DMValue512[464+: 8] = Byte64Value[58] ;
          DMValue512[472+: 8] = Byte64Value[59] ;
          DMValue512[480+: 8] = Byte64Value[60] ;
          DMValue512[488+: 8] = Byte64Value[61] ;
          DMValue512[496+: 8] = Byte64Value[62] ;
          DMValue512[504+: 8] = Byte64Value[63] ;
        end
        default: $display("The input of CGran is invalid !\n\n");
      endcase

      if(AGran==2'b10) begin
          if(DMValue512[255:0] === ExpValue[255:0]) $display("%0t Read DM0 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
          else  begin
            $display("%0t Error @SPUSTARTPC = %h, AGran=%h, Expected Value and Real Result are :", $realtime, AGran, SPUSTARTPC);
            Mon.display_512(ExpValue);
            Mon.display_512(DMValue512);
            $display(" ");
          end
      end else if(AGran==2'b01) begin
          if(DMValue512[127:0] === ExpValue[127:0]) $display("%0t Read DM0 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
          else  begin
            $display("%0t Error @SPUSTARTPC = %h, AGran=%h, Expected Value and Real Result are :", $realtime, AGran, SPUSTARTPC);
            Mon.display_512(ExpValue);
            Mon.display_512(DMValue512);
            $display(" ");
          end
      end else if(AGran==2'b00) begin
          if(DMValue512[63:0] === ExpValue[63:0]) $display("%0t Read DM0 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
          else  begin
            $display("%0t Error @SPUSTARTPC = %h, AGran=%h, Expected Value and Real Result are :", $realtime, AGran, SPUSTARTPC);
            Mon.display_512(ExpValue);
            Mon.display_512(DMValue512);
            $display(" ");
          end
      end else begin
          if(DMValue512 === ExpValue) $display("%0t Read DM0 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
          else  begin
            $display("%0t Error @SPUSTARTPC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
            Mon.display_512(ExpValue);
            Mon.display_512(DMValue512);
            $display(" ");
          end
      end

      Byte1Value.delete();
      Byte2Value.delete();
      Byte4Value.delete();
      Byte8Value.delete();
      Byte16Value.delete();
      Byte32Value.delete();
      Byte64Value.delete();
    
  endtask
  
  task automatic CheckDM1ValueSPUCol(input int SPUSTARTPC, input int InstrCycle, input int Addr, input bit [1:0] AGran, input bit [2:0] Gran, input [3:0] Size, input [2:0] CGran, input bit [511:0] ExpValue);
      bit[511:0]   DMValue512;
      byte Byte1Value[];
      byte Byte2Value[];
      byte Byte4Value[];
      byte Byte8Value[];
      byte Byte16Value[];
      byte Byte32Value[];
      byte Byte64Value[];
      int i;

      Byte1Value  = new[1];
      Byte2Value  = new[2];
      Byte4Value  = new[4];
      Byte8Value  = new[8];
      Byte16Value  = new[16];
      Byte32Value  = new[32];
      Byte64Value  = new[64];
      
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);

      case(CGran)
        3'd0: begin
          for(i=0; i<64; i++) begin
            $root.TestTop.uAPE.uDM1.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte1Value);
            DMValue512[8*i +:8] = Byte1Value[0] ;
          end
        end
        3'd1: begin
          for(i=0; i<32; i++) begin
            $root.TestTop.uAPE.uDM1.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte2Value);
            DMValue512[16*i   +: 8] = Byte2Value[0] ;
            DMValue512[16*i+8 +: 8] = Byte2Value[1] ;
          end
        end
        3'd2: begin
          for(i=0; i<16; i++) begin
            $root.TestTop.uAPE.uDM1.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte4Value);
            DMValue512[32*i   +: 8] = Byte4Value[0] ;
            DMValue512[32*i+8 +: 8] = Byte4Value[1] ;
            DMValue512[32*i+16+: 8] = Byte4Value[2] ;
            DMValue512[32*i+24+: 8] = Byte4Value[3] ;
          end
        end
        3'd3: begin
          for(i=0; i<8; i++) begin
            $root.TestTop.uAPE.uDM1.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte8Value);
            DMValue512[64*i   +: 8] = Byte8Value[0] ;
            DMValue512[64*i+8 +: 8] = Byte8Value[1] ;
            DMValue512[64*i+16+: 8] = Byte8Value[2] ;
            DMValue512[64*i+24+: 8] = Byte8Value[3] ;
            DMValue512[64*i+32+: 8] = Byte8Value[4] ;
            DMValue512[64*i+40+: 8] = Byte8Value[5] ;
            DMValue512[64*i+48+: 8] = Byte8Value[6] ;
            DMValue512[64*i+56+: 8] = Byte8Value[7] ;
          end
        end
        3'd4: begin
          for(i=0; i<4; i++) begin
            $root.TestTop.uAPE.uDM1.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte16Value);
            DMValue512[128*i    +: 8] = Byte16Value[0] ;
            DMValue512[128*i+  8+: 8] = Byte16Value[1] ;
            DMValue512[128*i+ 16+: 8] = Byte16Value[2] ;
            DMValue512[128*i+ 24+: 8] = Byte16Value[3] ;
            DMValue512[128*i+ 32+: 8] = Byte16Value[4] ;
            DMValue512[128*i+ 40+: 8] = Byte16Value[5] ;
            DMValue512[128*i+ 48+: 8] = Byte16Value[6] ;
            DMValue512[128*i+ 56+: 8] = Byte16Value[7] ;
            DMValue512[128*i+ 64+: 8] = Byte16Value[8] ;
            DMValue512[128*i+ 72+: 8] = Byte16Value[9] ;
            DMValue512[128*i+ 80+: 8] = Byte16Value[10] ;
            DMValue512[128*i+ 88+: 8] = Byte16Value[11] ;
            DMValue512[128*i+ 96+: 8] = Byte16Value[12] ;
            DMValue512[128*i+104+: 8] = Byte16Value[13] ;
            DMValue512[128*i+112+: 8] = Byte16Value[14] ;
            DMValue512[128*i+120+: 8] = Byte16Value[15] ;
          end
        end
        3'd5: begin
          for(i=0; i<2; i++) begin
            $root.TestTop.uAPE.uDM1.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte32Value);
            DMValue512[256*i    +: 8] = Byte32Value[0] ;
            DMValue512[256*i+  8+: 8] = Byte32Value[1] ;
            DMValue512[256*i+ 16+: 8] = Byte32Value[2] ;
            DMValue512[256*i+ 24+: 8] = Byte32Value[3] ;
            DMValue512[256*i+ 32+: 8] = Byte32Value[4] ;
            DMValue512[256*i+ 40+: 8] = Byte32Value[5] ;
            DMValue512[256*i+ 48+: 8] = Byte32Value[6] ;
            DMValue512[256*i+ 56+: 8] = Byte32Value[7] ;
            DMValue512[256*i+ 64+: 8] = Byte32Value[8] ;
            DMValue512[256*i+ 72+: 8] = Byte32Value[9] ;
            DMValue512[256*i+ 80+: 8] = Byte32Value[10] ;
            DMValue512[256*i+ 88+: 8] = Byte32Value[11] ;
            DMValue512[256*i+ 96+: 8] = Byte32Value[12] ;
            DMValue512[256*i+104+: 8] = Byte32Value[13] ;
            DMValue512[256*i+112+: 8] = Byte32Value[14] ;
            DMValue512[256*i+120+: 8] = Byte32Value[15] ;
            DMValue512[256*i+128+: 8] = Byte32Value[16] ;
            DMValue512[256*i+136+: 8] = Byte32Value[17] ;
            DMValue512[256*i+144+: 8] = Byte32Value[18] ;
            DMValue512[256*i+152+: 8] = Byte32Value[19] ;
            DMValue512[256*i+160+: 8] = Byte32Value[20] ;
            DMValue512[256*i+168+: 8] = Byte32Value[21] ;
            DMValue512[256*i+176+: 8] = Byte32Value[22] ;
            DMValue512[256*i+184+: 8] = Byte32Value[23] ;
            DMValue512[256*i+192+: 8] = Byte32Value[24] ;
            DMValue512[256*i+200+: 8] = Byte32Value[25] ;
            DMValue512[256*i+208+: 8] = Byte32Value[26] ;
            DMValue512[256*i+216+: 8] = Byte32Value[27] ;
            DMValue512[256*i+224+: 8] = Byte32Value[28] ;
            DMValue512[256*i+232+: 8] = Byte32Value[29] ;
            DMValue512[256*i+240+: 8] = Byte32Value[30] ;
            DMValue512[256*i+248+: 8] = Byte32Value[31] ;
          end
        end
        3'd6: begin
          $root.TestTop.uAPE.uDM1.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte64Value); 
          DMValue512[0  +: 8] = Byte64Value[0] ;
          DMValue512[8  +: 8] = Byte64Value[1] ;
          DMValue512[16 +: 8] = Byte64Value[2] ;
          DMValue512[24 +: 8] = Byte64Value[3] ;
          DMValue512[32 +: 8] = Byte64Value[4] ;
          DMValue512[40 +: 8] = Byte64Value[5] ;
          DMValue512[48 +: 8] = Byte64Value[6] ;
          DMValue512[56 +: 8] = Byte64Value[7] ;
          DMValue512[64 +: 8] = Byte64Value[8] ;
          DMValue512[72 +: 8] = Byte64Value[9] ;
          DMValue512[80 +: 8] = Byte64Value[10] ;
          DMValue512[88 +: 8] = Byte64Value[11] ;
          DMValue512[96 +: 8] = Byte64Value[12] ;
          DMValue512[104+: 8] = Byte64Value[13] ;
          DMValue512[112+: 8] = Byte64Value[14] ;
          DMValue512[120+: 8] = Byte64Value[15] ;
          DMValue512[128+: 8] = Byte64Value[16] ;
          DMValue512[136+: 8] = Byte64Value[17] ;
          DMValue512[144+: 8] = Byte64Value[18] ;
          DMValue512[152+: 8] = Byte64Value[19] ;
          DMValue512[160+: 8] = Byte64Value[20] ;
          DMValue512[168+: 8] = Byte64Value[21] ;
          DMValue512[176+: 8] = Byte64Value[22] ;
          DMValue512[184+: 8] = Byte64Value[23] ;
          DMValue512[192+: 8] = Byte64Value[24] ;
          DMValue512[200+: 8] = Byte64Value[25] ;
          DMValue512[208+: 8] = Byte64Value[26] ;
          DMValue512[216+: 8] = Byte64Value[27] ;
          DMValue512[224+: 8] = Byte64Value[28] ;
          DMValue512[232+: 8] = Byte64Value[29] ;
          DMValue512[240+: 8] = Byte64Value[30] ;
          DMValue512[248+: 8] = Byte64Value[31] ;
          DMValue512[256+: 8] = Byte64Value[32] ;
          DMValue512[264+: 8] = Byte64Value[33] ;
          DMValue512[272+: 8] = Byte64Value[34] ;
          DMValue512[280+: 8] = Byte64Value[35] ;
          DMValue512[288+: 8] = Byte64Value[36] ;
          DMValue512[296+: 8] = Byte64Value[37] ;
          DMValue512[304+: 8] = Byte64Value[38] ;
          DMValue512[312+: 8] = Byte64Value[39] ;
          DMValue512[320+: 8] = Byte64Value[40] ;
          DMValue512[328+: 8] = Byte64Value[41] ;
          DMValue512[336+: 8] = Byte64Value[42] ;
          DMValue512[344+: 8] = Byte64Value[43] ;
          DMValue512[352+: 8] = Byte64Value[44] ;
          DMValue512[360+: 8] = Byte64Value[45] ;
          DMValue512[368+: 8] = Byte64Value[46] ;
          DMValue512[376+: 8] = Byte64Value[47] ;
          DMValue512[384+: 8] = Byte64Value[48] ;
          DMValue512[392+: 8] = Byte64Value[49] ;
          DMValue512[400+: 8] = Byte64Value[50] ;
          DMValue512[408+: 8] = Byte64Value[51] ;
          DMValue512[416+: 8] = Byte64Value[52] ;
          DMValue512[424+: 8] = Byte64Value[53] ;
          DMValue512[432+: 8] = Byte64Value[54] ;
          DMValue512[440+: 8] = Byte64Value[55] ;
          DMValue512[448+: 8] = Byte64Value[56] ;
          DMValue512[456+: 8] = Byte64Value[57] ;
          DMValue512[464+: 8] = Byte64Value[58] ;
          DMValue512[472+: 8] = Byte64Value[59] ;
          DMValue512[480+: 8] = Byte64Value[60] ;
          DMValue512[488+: 8] = Byte64Value[61] ;
          DMValue512[496+: 8] = Byte64Value[62] ;
          DMValue512[504+: 8] = Byte64Value[63] ;
        end
        default: $display("The input of CGran is invalid !\n\n");
      endcase

      if(AGran==2'b10) begin
          if(DMValue512[255:0] === ExpValue[255:0]) $display("%0t Read DM1 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
          else  begin
            $display("%0t Error @SPUSTARTPC = %h, AGran=%h, Expected Value and Real Result are :", $realtime, AGran, SPUSTARTPC);
            Mon.display_512(ExpValue);
            Mon.display_512(DMValue512);
            $display(" ");
          end
      end else if(AGran==2'b01) begin
          if(DMValue512[127:0] === ExpValue[127:0]) $display("%0t Read DM1 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
          else  begin
            $display("%0t Error @SPUSTARTPC = %h, AGran=%h, Expected Value and Real Result are :", $realtime, AGran, SPUSTARTPC);
            Mon.display_512(ExpValue);
            Mon.display_512(DMValue512);
            $display(" ");
          end
      end else if(AGran==2'b00) begin
          if(DMValue512[63:0] === ExpValue[63:0]) $display("%0t Read DM1 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
          else  begin
            $display("%0t Error @SPUSTARTPC = %h, AGran=%h, Expected Value and Real Result are :", $realtime, AGran, SPUSTARTPC);
            Mon.display_512(ExpValue);
            Mon.display_512(DMValue512);
            $display(" ");
          end
      end else begin
          if(DMValue512 === ExpValue) $display("%0t Read DM1 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
          else  begin
            $display("%0t Error @SPUSTARTPC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
            Mon.display_512(ExpValue);
            Mon.display_512(DMValue512);
            $display(" ");
          end
      end

      Byte1Value.delete();
      Byte2Value.delete();
      Byte4Value.delete();
      Byte8Value.delete();
      Byte16Value.delete();
      Byte32Value.delete();
      Byte64Value.delete();
    
  endtask
  
  task automatic CheckDM2ValueSPUCol(input int SPUSTARTPC, input int InstrCycle, input int Addr, input bit [1:0] AGran, input bit [2:0] Gran, input [3:0] Size, input [2:0] CGran, input bit [511:0] ExpValue);
      bit[511:0]   DMValue512;
      byte Byte1Value[];
      byte Byte2Value[];
      byte Byte4Value[];
      byte Byte8Value[];
      byte Byte16Value[];
      byte Byte32Value[];
      byte Byte64Value[];
      int i;

      Byte1Value  = new[1];
      Byte2Value  = new[2];
      Byte4Value  = new[4];
      Byte8Value  = new[8];
      Byte16Value  = new[16];
      Byte32Value  = new[32];
      Byte64Value  = new[64];
      
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);

      case(CGran)
        3'd0: begin
          for(i=0; i<64; i++) begin
            $root.TestTop.uAPE.uDM2.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte1Value);
            DMValue512[8*i +:8] = Byte1Value[0] ;
          end
        end
        3'd1: begin
          for(i=0; i<32; i++) begin
            $root.TestTop.uAPE.uDM2.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte2Value);
            DMValue512[16*i   +: 8] = Byte2Value[0] ;
            DMValue512[16*i+8 +: 8] = Byte2Value[1] ;
          end
        end
        3'd2: begin
          for(i=0; i<16; i++) begin
            $root.TestTop.uAPE.uDM2.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte4Value);
            DMValue512[32*i   +: 8] = Byte4Value[0] ;
            DMValue512[32*i+8 +: 8] = Byte4Value[1] ;
            DMValue512[32*i+16+: 8] = Byte4Value[2] ;
            DMValue512[32*i+24+: 8] = Byte4Value[3] ;
          end
        end
        3'd3: begin
          for(i=0; i<8; i++) begin
            $root.TestTop.uAPE.uDM2.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte8Value);
            DMValue512[64*i   +: 8] = Byte8Value[0] ;
            DMValue512[64*i+8 +: 8] = Byte8Value[1] ;
            DMValue512[64*i+16+: 8] = Byte8Value[2] ;
            DMValue512[64*i+24+: 8] = Byte8Value[3] ;
            DMValue512[64*i+32+: 8] = Byte8Value[4] ;
            DMValue512[64*i+40+: 8] = Byte8Value[5] ;
            DMValue512[64*i+48+: 8] = Byte8Value[6] ;
            DMValue512[64*i+56+: 8] = Byte8Value[7] ;
          end
        end
        3'd4: begin
          for(i=0; i<4; i++) begin
            $root.TestTop.uAPE.uDM2.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte16Value);
            DMValue512[128*i    +: 8] = Byte16Value[0] ;
            DMValue512[128*i+  8+: 8] = Byte16Value[1] ;
            DMValue512[128*i+ 16+: 8] = Byte16Value[2] ;
            DMValue512[128*i+ 24+: 8] = Byte16Value[3] ;
            DMValue512[128*i+ 32+: 8] = Byte16Value[4] ;
            DMValue512[128*i+ 40+: 8] = Byte16Value[5] ;
            DMValue512[128*i+ 48+: 8] = Byte16Value[6] ;
            DMValue512[128*i+ 56+: 8] = Byte16Value[7] ;
            DMValue512[128*i+ 64+: 8] = Byte16Value[8] ;
            DMValue512[128*i+ 72+: 8] = Byte16Value[9] ;
            DMValue512[128*i+ 80+: 8] = Byte16Value[10] ;
            DMValue512[128*i+ 88+: 8] = Byte16Value[11] ;
            DMValue512[128*i+ 96+: 8] = Byte16Value[12] ;
            DMValue512[128*i+104+: 8] = Byte16Value[13] ;
            DMValue512[128*i+112+: 8] = Byte16Value[14] ;
            DMValue512[128*i+120+: 8] = Byte16Value[15] ;
          end
        end
        3'd5: begin
          for(i=0; i<2; i++) begin
            $root.TestTop.uAPE.uDM2.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte32Value);
            DMValue512[256*i    +: 8] = Byte32Value[0] ;
            DMValue512[256*i+  8+: 8] = Byte32Value[1] ;
            DMValue512[256*i+ 16+: 8] = Byte32Value[2] ;
            DMValue512[256*i+ 24+: 8] = Byte32Value[3] ;
            DMValue512[256*i+ 32+: 8] = Byte32Value[4] ;
            DMValue512[256*i+ 40+: 8] = Byte32Value[5] ;
            DMValue512[256*i+ 48+: 8] = Byte32Value[6] ;
            DMValue512[256*i+ 56+: 8] = Byte32Value[7] ;
            DMValue512[256*i+ 64+: 8] = Byte32Value[8] ;
            DMValue512[256*i+ 72+: 8] = Byte32Value[9] ;
            DMValue512[256*i+ 80+: 8] = Byte32Value[10] ;
            DMValue512[256*i+ 88+: 8] = Byte32Value[11] ;
            DMValue512[256*i+ 96+: 8] = Byte32Value[12] ;
            DMValue512[256*i+104+: 8] = Byte32Value[13] ;
            DMValue512[256*i+112+: 8] = Byte32Value[14] ;
            DMValue512[256*i+120+: 8] = Byte32Value[15] ;
            DMValue512[256*i+128+: 8] = Byte32Value[16] ;
            DMValue512[256*i+136+: 8] = Byte32Value[17] ;
            DMValue512[256*i+144+: 8] = Byte32Value[18] ;
            DMValue512[256*i+152+: 8] = Byte32Value[19] ;
            DMValue512[256*i+160+: 8] = Byte32Value[20] ;
            DMValue512[256*i+168+: 8] = Byte32Value[21] ;
            DMValue512[256*i+176+: 8] = Byte32Value[22] ;
            DMValue512[256*i+184+: 8] = Byte32Value[23] ;
            DMValue512[256*i+192+: 8] = Byte32Value[24] ;
            DMValue512[256*i+200+: 8] = Byte32Value[25] ;
            DMValue512[256*i+208+: 8] = Byte32Value[26] ;
            DMValue512[256*i+216+: 8] = Byte32Value[27] ;
            DMValue512[256*i+224+: 8] = Byte32Value[28] ;
            DMValue512[256*i+232+: 8] = Byte32Value[29] ;
            DMValue512[256*i+240+: 8] = Byte32Value[30] ;
            DMValue512[256*i+248+: 8] = Byte32Value[31] ;
          end
        end
        3'd6: begin
          $root.TestTop.uAPE.uDM2.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte64Value); 
          DMValue512[0  +: 8] = Byte64Value[0] ;
          DMValue512[8  +: 8] = Byte64Value[1] ;
          DMValue512[16 +: 8] = Byte64Value[2] ;
          DMValue512[24 +: 8] = Byte64Value[3] ;
          DMValue512[32 +: 8] = Byte64Value[4] ;
          DMValue512[40 +: 8] = Byte64Value[5] ;
          DMValue512[48 +: 8] = Byte64Value[6] ;
          DMValue512[56 +: 8] = Byte64Value[7] ;
          DMValue512[64 +: 8] = Byte64Value[8] ;
          DMValue512[72 +: 8] = Byte64Value[9] ;
          DMValue512[80 +: 8] = Byte64Value[10] ;
          DMValue512[88 +: 8] = Byte64Value[11] ;
          DMValue512[96 +: 8] = Byte64Value[12] ;
          DMValue512[104+: 8] = Byte64Value[13] ;
          DMValue512[112+: 8] = Byte64Value[14] ;
          DMValue512[120+: 8] = Byte64Value[15] ;
          DMValue512[128+: 8] = Byte64Value[16] ;
          DMValue512[136+: 8] = Byte64Value[17] ;
          DMValue512[144+: 8] = Byte64Value[18] ;
          DMValue512[152+: 8] = Byte64Value[19] ;
          DMValue512[160+: 8] = Byte64Value[20] ;
          DMValue512[168+: 8] = Byte64Value[21] ;
          DMValue512[176+: 8] = Byte64Value[22] ;
          DMValue512[184+: 8] = Byte64Value[23] ;
          DMValue512[192+: 8] = Byte64Value[24] ;
          DMValue512[200+: 8] = Byte64Value[25] ;
          DMValue512[208+: 8] = Byte64Value[26] ;
          DMValue512[216+: 8] = Byte64Value[27] ;
          DMValue512[224+: 8] = Byte64Value[28] ;
          DMValue512[232+: 8] = Byte64Value[29] ;
          DMValue512[240+: 8] = Byte64Value[30] ;
          DMValue512[248+: 8] = Byte64Value[31] ;
          DMValue512[256+: 8] = Byte64Value[32] ;
          DMValue512[264+: 8] = Byte64Value[33] ;
          DMValue512[272+: 8] = Byte64Value[34] ;
          DMValue512[280+: 8] = Byte64Value[35] ;
          DMValue512[288+: 8] = Byte64Value[36] ;
          DMValue512[296+: 8] = Byte64Value[37] ;
          DMValue512[304+: 8] = Byte64Value[38] ;
          DMValue512[312+: 8] = Byte64Value[39] ;
          DMValue512[320+: 8] = Byte64Value[40] ;
          DMValue512[328+: 8] = Byte64Value[41] ;
          DMValue512[336+: 8] = Byte64Value[42] ;
          DMValue512[344+: 8] = Byte64Value[43] ;
          DMValue512[352+: 8] = Byte64Value[44] ;
          DMValue512[360+: 8] = Byte64Value[45] ;
          DMValue512[368+: 8] = Byte64Value[46] ;
          DMValue512[376+: 8] = Byte64Value[47] ;
          DMValue512[384+: 8] = Byte64Value[48] ;
          DMValue512[392+: 8] = Byte64Value[49] ;
          DMValue512[400+: 8] = Byte64Value[50] ;
          DMValue512[408+: 8] = Byte64Value[51] ;
          DMValue512[416+: 8] = Byte64Value[52] ;
          DMValue512[424+: 8] = Byte64Value[53] ;
          DMValue512[432+: 8] = Byte64Value[54] ;
          DMValue512[440+: 8] = Byte64Value[55] ;
          DMValue512[448+: 8] = Byte64Value[56] ;
          DMValue512[456+: 8] = Byte64Value[57] ;
          DMValue512[464+: 8] = Byte64Value[58] ;
          DMValue512[472+: 8] = Byte64Value[59] ;
          DMValue512[480+: 8] = Byte64Value[60] ;
          DMValue512[488+: 8] = Byte64Value[61] ;
          DMValue512[496+: 8] = Byte64Value[62] ;
          DMValue512[504+: 8] = Byte64Value[63] ;
        end
        default: $display("The input of CGran is invalid !\n\n");
      endcase

      if(AGran==2'b10) begin
          if(DMValue512[255:0] === ExpValue[255:0]) $display("%0t Read DM2 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
          else  begin
            $display("%0t Error @SPUSTARTPC = %h, AGran=%h, Expected Value and Real Result are :", $realtime, AGran, SPUSTARTPC);
            Mon.display_512(ExpValue);
            Mon.display_512(DMValue512);
            $display(" ");
          end
      end else if(AGran==2'b01) begin
          if(DMValue512[127:0] === ExpValue[127:0]) $display("%0t Read DM2 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
          else  begin
            $display("%0t Error @SPUSTARTPC = %h, AGran=%h, Expected Value and Real Result are :", $realtime, AGran, SPUSTARTPC);
            Mon.display_512(ExpValue);
            Mon.display_512(DMValue512);
            $display(" ");
          end
      end else if(AGran==2'b00) begin
          if(DMValue512[63:0] === ExpValue[63:0]) $display("%0t Read DM2 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
          else  begin
            $display("%0t Error @SPUSTARTPC = %h, AGran=%h, Expected Value and Real Result are :", $realtime, AGran, SPUSTARTPC);
            Mon.display_512(ExpValue);
            Mon.display_512(DMValue512);
            $display(" ");
          end
      end else begin
          if(DMValue512 === ExpValue) $display("%0t Read DM2 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
          else  begin
            $display("%0t Error @SPUSTARTPC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
            Mon.display_512(ExpValue);
            Mon.display_512(DMValue512);
            $display(" ");
          end
      end

      Byte1Value.delete();
      Byte2Value.delete();
      Byte4Value.delete();
      Byte8Value.delete();
      Byte16Value.delete();
      Byte32Value.delete();
      Byte64Value.delete();
    
  endtask


  task automatic CheckDM3ValueSPUCol(input int SPUSTARTPC, input int InstrCycle, input int Addr, input bit [1:0] AGran, input bit [2:0] Gran, input [3:0] Size, input [2:0] CGran, input bit [511:0] ExpValue);
      bit[511:0]   DMValue512;
      byte Byte1Value[];
      byte Byte2Value[];
      byte Byte4Value[];
      byte Byte8Value[];
      byte Byte16Value[];
      byte Byte32Value[];
      byte Byte64Value[];
      int i;

      Byte1Value  = new[1];
      Byte2Value  = new[2];
      Byte4Value  = new[4];
      Byte8Value  = new[8];
      Byte16Value  = new[16];
      Byte32Value  = new[32];
      Byte64Value  = new[64];
      
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);

      case(CGran)
        3'd0: begin
          for(i=0; i<64; i++) begin
            $root.TestTop.uAPE.uDM3.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte1Value);
            DMValue512[8*i +:8] = Byte1Value[0] ;
          end
        end
        3'd1: begin
          for(i=0; i<32; i++) begin
            $root.TestTop.uAPE.uDM3.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte2Value);
            DMValue512[16*i   +: 8] = Byte2Value[0] ;
            DMValue512[16*i+8 +: 8] = Byte2Value[1] ;
          end
        end
        3'd2: begin
          for(i=0; i<16; i++) begin
            $root.TestTop.uAPE.uDM3.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte4Value);
            DMValue512[32*i   +: 8] = Byte4Value[0] ;
            DMValue512[32*i+8 +: 8] = Byte4Value[1] ;
            DMValue512[32*i+16+: 8] = Byte4Value[2] ;
            DMValue512[32*i+24+: 8] = Byte4Value[3] ;
          end
        end
        3'd3: begin
          for(i=0; i<8; i++) begin
            $root.TestTop.uAPE.uDM3.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte8Value);
            DMValue512[64*i   +: 8] = Byte8Value[0] ;
            DMValue512[64*i+8 +: 8] = Byte8Value[1] ;
            DMValue512[64*i+16+: 8] = Byte8Value[2] ;
            DMValue512[64*i+24+: 8] = Byte8Value[3] ;
            DMValue512[64*i+32+: 8] = Byte8Value[4] ;
            DMValue512[64*i+40+: 8] = Byte8Value[5] ;
            DMValue512[64*i+48+: 8] = Byte8Value[6] ;
            DMValue512[64*i+56+: 8] = Byte8Value[7] ;
          end
        end
        3'd4: begin
          for(i=0; i<4; i++) begin
            $root.TestTop.uAPE.uDM3.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte16Value);
            DMValue512[128*i    +: 8] = Byte16Value[0] ;
            DMValue512[128*i+  8+: 8] = Byte16Value[1] ;
            DMValue512[128*i+ 16+: 8] = Byte16Value[2] ;
            DMValue512[128*i+ 24+: 8] = Byte16Value[3] ;
            DMValue512[128*i+ 32+: 8] = Byte16Value[4] ;
            DMValue512[128*i+ 40+: 8] = Byte16Value[5] ;
            DMValue512[128*i+ 48+: 8] = Byte16Value[6] ;
            DMValue512[128*i+ 56+: 8] = Byte16Value[7] ;
            DMValue512[128*i+ 64+: 8] = Byte16Value[8] ;
            DMValue512[128*i+ 72+: 8] = Byte16Value[9] ;
            DMValue512[128*i+ 80+: 8] = Byte16Value[10] ;
            DMValue512[128*i+ 88+: 8] = Byte16Value[11] ;
            DMValue512[128*i+ 96+: 8] = Byte16Value[12] ;
            DMValue512[128*i+104+: 8] = Byte16Value[13] ;
            DMValue512[128*i+112+: 8] = Byte16Value[14] ;
            DMValue512[128*i+120+: 8] = Byte16Value[15] ;
          end
        end
        3'd5: begin
          for(i=0; i<2; i++) begin
            $root.TestTop.uAPE.uDM3.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte32Value);
            DMValue512[256*i    +: 8] = Byte32Value[0] ;
            DMValue512[256*i+  8+: 8] = Byte32Value[1] ;
            DMValue512[256*i+ 16+: 8] = Byte32Value[2] ;
            DMValue512[256*i+ 24+: 8] = Byte32Value[3] ;
            DMValue512[256*i+ 32+: 8] = Byte32Value[4] ;
            DMValue512[256*i+ 40+: 8] = Byte32Value[5] ;
            DMValue512[256*i+ 48+: 8] = Byte32Value[6] ;
            DMValue512[256*i+ 56+: 8] = Byte32Value[7] ;
            DMValue512[256*i+ 64+: 8] = Byte32Value[8] ;
            DMValue512[256*i+ 72+: 8] = Byte32Value[9] ;
            DMValue512[256*i+ 80+: 8] = Byte32Value[10] ;
            DMValue512[256*i+ 88+: 8] = Byte32Value[11] ;
            DMValue512[256*i+ 96+: 8] = Byte32Value[12] ;
            DMValue512[256*i+104+: 8] = Byte32Value[13] ;
            DMValue512[256*i+112+: 8] = Byte32Value[14] ;
            DMValue512[256*i+120+: 8] = Byte32Value[15] ;
            DMValue512[256*i+128+: 8] = Byte32Value[16] ;
            DMValue512[256*i+136+: 8] = Byte32Value[17] ;
            DMValue512[256*i+144+: 8] = Byte32Value[18] ;
            DMValue512[256*i+152+: 8] = Byte32Value[19] ;
            DMValue512[256*i+160+: 8] = Byte32Value[20] ;
            DMValue512[256*i+168+: 8] = Byte32Value[21] ;
            DMValue512[256*i+176+: 8] = Byte32Value[22] ;
            DMValue512[256*i+184+: 8] = Byte32Value[23] ;
            DMValue512[256*i+192+: 8] = Byte32Value[24] ;
            DMValue512[256*i+200+: 8] = Byte32Value[25] ;
            DMValue512[256*i+208+: 8] = Byte32Value[26] ;
            DMValue512[256*i+216+: 8] = Byte32Value[27] ;
            DMValue512[256*i+224+: 8] = Byte32Value[28] ;
            DMValue512[256*i+232+: 8] = Byte32Value[29] ;
            DMValue512[256*i+240+: 8] = Byte32Value[30] ;
            DMValue512[256*i+248+: 8] = Byte32Value[31] ;
          end
        end
        3'd6: begin
          $root.TestTop.uAPE.uDM3.DMReadBytes(Addr+((1<<Size)*64)*i, Gran, Size, Byte64Value); 
          DMValue512[0  +: 8] = Byte64Value[0] ;
          DMValue512[8  +: 8] = Byte64Value[1] ;
          DMValue512[16 +: 8] = Byte64Value[2] ;
          DMValue512[24 +: 8] = Byte64Value[3] ;
          DMValue512[32 +: 8] = Byte64Value[4] ;
          DMValue512[40 +: 8] = Byte64Value[5] ;
          DMValue512[48 +: 8] = Byte64Value[6] ;
          DMValue512[56 +: 8] = Byte64Value[7] ;
          DMValue512[64 +: 8] = Byte64Value[8] ;
          DMValue512[72 +: 8] = Byte64Value[9] ;
          DMValue512[80 +: 8] = Byte64Value[10] ;
          DMValue512[88 +: 8] = Byte64Value[11] ;
          DMValue512[96 +: 8] = Byte64Value[12] ;
          DMValue512[104+: 8] = Byte64Value[13] ;
          DMValue512[112+: 8] = Byte64Value[14] ;
          DMValue512[120+: 8] = Byte64Value[15] ;
          DMValue512[128+: 8] = Byte64Value[16] ;
          DMValue512[136+: 8] = Byte64Value[17] ;
          DMValue512[144+: 8] = Byte64Value[18] ;
          DMValue512[152+: 8] = Byte64Value[19] ;
          DMValue512[160+: 8] = Byte64Value[20] ;
          DMValue512[168+: 8] = Byte64Value[21] ;
          DMValue512[176+: 8] = Byte64Value[22] ;
          DMValue512[184+: 8] = Byte64Value[23] ;
          DMValue512[192+: 8] = Byte64Value[24] ;
          DMValue512[200+: 8] = Byte64Value[25] ;
          DMValue512[208+: 8] = Byte64Value[26] ;
          DMValue512[216+: 8] = Byte64Value[27] ;
          DMValue512[224+: 8] = Byte64Value[28] ;
          DMValue512[232+: 8] = Byte64Value[29] ;
          DMValue512[240+: 8] = Byte64Value[30] ;
          DMValue512[248+: 8] = Byte64Value[31] ;
          DMValue512[256+: 8] = Byte64Value[32] ;
          DMValue512[264+: 8] = Byte64Value[33] ;
          DMValue512[272+: 8] = Byte64Value[34] ;
          DMValue512[280+: 8] = Byte64Value[35] ;
          DMValue512[288+: 8] = Byte64Value[36] ;
          DMValue512[296+: 8] = Byte64Value[37] ;
          DMValue512[304+: 8] = Byte64Value[38] ;
          DMValue512[312+: 8] = Byte64Value[39] ;
          DMValue512[320+: 8] = Byte64Value[40] ;
          DMValue512[328+: 8] = Byte64Value[41] ;
          DMValue512[336+: 8] = Byte64Value[42] ;
          DMValue512[344+: 8] = Byte64Value[43] ;
          DMValue512[352+: 8] = Byte64Value[44] ;
          DMValue512[360+: 8] = Byte64Value[45] ;
          DMValue512[368+: 8] = Byte64Value[46] ;
          DMValue512[376+: 8] = Byte64Value[47] ;
          DMValue512[384+: 8] = Byte64Value[48] ;
          DMValue512[392+: 8] = Byte64Value[49] ;
          DMValue512[400+: 8] = Byte64Value[50] ;
          DMValue512[408+: 8] = Byte64Value[51] ;
          DMValue512[416+: 8] = Byte64Value[52] ;
          DMValue512[424+: 8] = Byte64Value[53] ;
          DMValue512[432+: 8] = Byte64Value[54] ;
          DMValue512[440+: 8] = Byte64Value[55] ;
          DMValue512[448+: 8] = Byte64Value[56] ;
          DMValue512[456+: 8] = Byte64Value[57] ;
          DMValue512[464+: 8] = Byte64Value[58] ;
          DMValue512[472+: 8] = Byte64Value[59] ;
          DMValue512[480+: 8] = Byte64Value[60] ;
          DMValue512[488+: 8] = Byte64Value[61] ;
          DMValue512[496+: 8] = Byte64Value[62] ;
          DMValue512[504+: 8] = Byte64Value[63] ;
        end
        default: $display("The input of CGran is invalid !\n\n");
      endcase

      if(AGran==2'b10) begin
          if(DMValue512[255:0] === ExpValue[255:0]) $display("%0t Read DM3 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
          else  begin
            $display("%0t Error @SPUSTARTPC = %h, AGran=%h, Expected Value and Real Result are :", $realtime, AGran, SPUSTARTPC);
            Mon.display_512(ExpValue);
            Mon.display_512(DMValue512);
            $display(" ");
          end
      end else if(AGran==2'b01) begin
          if(DMValue512[127:0] === ExpValue[127:0]) $display("%0t Read DM3 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
          else  begin
            $display("%0t Error @SPUSTARTPC = %h, AGran=%h, Expected Value and Real Result are :", $realtime, AGran, SPUSTARTPC);
            Mon.display_512(ExpValue);
            Mon.display_512(DMValue512);
            $display(" ");
          end
      end else if(AGran==2'b00) begin
          if(DMValue512[63:0] === ExpValue[63:0]) $display("%0t Read DM3 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
          else  begin
            $display("%0t Error @SPUSTARTPC = %h, AGran=%h, Expected Value and Real Result are :", $realtime, AGran, SPUSTARTPC);
            Mon.display_512(ExpValue);
            Mon.display_512(DMValue512);
            $display(" ");
          end
      end else begin
          if(DMValue512 === ExpValue) $display("%0t Read DM3 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
          else  begin
            $display("%0t Error @SPUSTARTPC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
            Mon.display_512(ExpValue);
            Mon.display_512(DMValue512);
            $display(" ");
          end
      end

      Byte1Value.delete();
      Byte2Value.delete();
      Byte4Value.delete();
      Byte8Value.delete();
      Byte16Value.delete();
      Byte32Value.delete();
      Byte64Value.delete();
    
  endtask

   //CGran = Gran || CGran = 6
   task automatic CheckDM0ValueSPUSTARTPC(input int SPUSTARTPC, input int InstrCycle, input int Addr,input logic[511:0] ExpValue);
      bit[511:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[64];
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle); 
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM0.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[ 15: 8] = Byte4Value[1] ;
      DMValue[ 23: 16] = Byte4Value[2] ;
      DMValue[ 31: 24] = Byte4Value[3] ;
      DMValue[ 39: 32] = Byte4Value[4] ;
      DMValue[ 47: 40] = Byte4Value[5] ;
      DMValue[ 55: 48] = Byte4Value[6] ;
      DMValue[ 63: 56] = Byte4Value[7] ;
      DMValue[ 71: 64] = Byte4Value[8] ;
      DMValue[ 79: 72] = Byte4Value[9] ;
      DMValue[ 87: 80] = Byte4Value[10] ;
      DMValue[ 95: 88] = Byte4Value[11] ;
      DMValue[ 103: 96] = Byte4Value[12] ;
      DMValue[ 111: 104] = Byte4Value[13] ;
      DMValue[ 119: 112] = Byte4Value[14] ;
      DMValue[ 127: 120] = Byte4Value[15] ;
      DMValue[ 135: 128] = Byte4Value[16] ;
      DMValue[ 143: 136] = Byte4Value[17] ;
      DMValue[ 151: 144] = Byte4Value[18] ;
      DMValue[ 159: 152] = Byte4Value[19] ;
      DMValue[ 167: 160] = Byte4Value[20] ;
      DMValue[ 175: 168] = Byte4Value[21] ;
      DMValue[ 183: 176] = Byte4Value[22] ;
      DMValue[ 191: 184] = Byte4Value[23] ;
      DMValue[ 199: 192] = Byte4Value[24] ;
      DMValue[ 207: 200] = Byte4Value[25] ;
      DMValue[ 215: 208] = Byte4Value[26] ;
      DMValue[ 223: 216] = Byte4Value[27] ;
      DMValue[ 231: 224] = Byte4Value[28] ;
      DMValue[ 239: 232] = Byte4Value[29] ;
      DMValue[ 247: 240] = Byte4Value[30] ;
      DMValue[ 255: 248] = Byte4Value[31] ;
      DMValue[ 263: 256] = Byte4Value[32] ;
      DMValue[ 271: 264] = Byte4Value[33] ;
      DMValue[ 279: 272] = Byte4Value[34] ;
      DMValue[ 287: 280] = Byte4Value[35] ;
      DMValue[ 295: 288] = Byte4Value[36] ;
      DMValue[ 303: 296] = Byte4Value[37] ;
      DMValue[ 311: 304] = Byte4Value[38] ;
      DMValue[ 319: 312] = Byte4Value[39] ;
      DMValue[ 327: 320] = Byte4Value[40] ;
      DMValue[ 335: 328] = Byte4Value[41] ;
      DMValue[ 343: 336] = Byte4Value[42] ;
      DMValue[ 351: 344] = Byte4Value[43] ;
      DMValue[ 359: 352] = Byte4Value[44] ;
      DMValue[ 367: 360] = Byte4Value[45] ;
      DMValue[ 375: 368] = Byte4Value[46] ;
      DMValue[ 383: 376] = Byte4Value[47] ;
      DMValue[ 391: 384] = Byte4Value[48] ;
      DMValue[ 399: 392] = Byte4Value[49] ;
      DMValue[ 407: 400] = Byte4Value[50] ;
      DMValue[ 415: 408] = Byte4Value[51] ;
      DMValue[ 423: 416] = Byte4Value[52] ;
      DMValue[ 431: 424] = Byte4Value[53] ;
      DMValue[ 439: 432] = Byte4Value[54] ;
      DMValue[ 447: 440] = Byte4Value[55] ;
      DMValue[ 455: 448] = Byte4Value[56] ;
      DMValue[ 463: 456] = Byte4Value[57] ;
      DMValue[ 471: 464] = Byte4Value[58] ;
      DMValue[ 479: 472] = Byte4Value[59] ;
      DMValue[ 487: 480] = Byte4Value[60] ;
      DMValue[ 495: 488] = Byte4Value[61] ;
      DMValue[ 503: 496] = Byte4Value[62] ; 
      DMValue[ 511: 504] = Byte4Value[63] ; 
      if(DMValue == ExpValue)
         $display("%0t Read DM0 OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         Mon.display_512(ExpValue);
         Mon.display_512(DMValue);
      end
      Byte4Value.delete();
   endtask 

   task automatic CheckDM0Value256(input int SPUSTARTPC, input int InstrCycle, input int Addr,input logic[255:0] ExpValue);
      bit[255:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[32];
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle); 
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM0.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[ 15: 8] = Byte4Value[1] ;
      DMValue[ 23: 16] = Byte4Value[2] ;
      DMValue[ 31: 24] = Byte4Value[3] ;
      DMValue[ 39: 32] = Byte4Value[4] ;
      DMValue[ 47: 40] = Byte4Value[5] ;
      DMValue[ 55: 48] = Byte4Value[6] ;
      DMValue[ 63: 56] = Byte4Value[7] ;
      DMValue[ 71: 64] = Byte4Value[8] ;
      DMValue[ 79: 72] = Byte4Value[9] ;
      DMValue[ 87: 80] = Byte4Value[10] ;
      DMValue[ 95: 88] = Byte4Value[11] ;
      DMValue[ 103: 96] = Byte4Value[12] ;
      DMValue[ 111: 104] = Byte4Value[13] ;
      DMValue[ 119: 112] = Byte4Value[14] ;
      DMValue[ 127: 120] = Byte4Value[15] ;
      DMValue[ 135: 128] = Byte4Value[16] ;
      DMValue[ 143: 136] = Byte4Value[17] ;
      DMValue[ 151: 144] = Byte4Value[18] ;
      DMValue[ 159: 152] = Byte4Value[19] ;
      DMValue[ 167: 160] = Byte4Value[20] ;
      DMValue[ 175: 168] = Byte4Value[21] ;
      DMValue[ 183: 176] = Byte4Value[22] ;
      DMValue[ 191: 184] = Byte4Value[23] ;
      DMValue[ 199: 192] = Byte4Value[24] ;
      DMValue[ 207: 200] = Byte4Value[25] ;
      DMValue[ 215: 208] = Byte4Value[26] ;
      DMValue[ 223: 216] = Byte4Value[27] ;
      DMValue[ 231: 224] = Byte4Value[28] ;
      DMValue[ 239: 232] = Byte4Value[29] ;
      DMValue[ 247: 240] = Byte4Value[30] ;
      DMValue[ 255: 248] = Byte4Value[31] ;       
      if(DMValue == ExpValue)
         $display("%0t Read DM0 OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
   endtask

   task automatic CheckDM0Value256_NStall(input int SPUSTARTPC, input int InstrCycle, input int Addr,input logic[255:0] ExpValue);
      bit[255:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[32];
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC )
            break;
      end
      WaitSPUCycles_NStall(InstrCycle); 
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM0.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[ 15: 8] = Byte4Value[1] ;
      DMValue[ 23: 16] = Byte4Value[2] ;
      DMValue[ 31: 24] = Byte4Value[3] ;
      DMValue[ 39: 32] = Byte4Value[4] ;
      DMValue[ 47: 40] = Byte4Value[5] ;
      DMValue[ 55: 48] = Byte4Value[6] ;
      DMValue[ 63: 56] = Byte4Value[7] ;
      DMValue[ 71: 64] = Byte4Value[8] ;
      DMValue[ 79: 72] = Byte4Value[9] ;
      DMValue[ 87: 80] = Byte4Value[10] ;
      DMValue[ 95: 88] = Byte4Value[11] ;
      DMValue[ 103: 96] = Byte4Value[12] ;
      DMValue[ 111: 104] = Byte4Value[13] ;
      DMValue[ 119: 112] = Byte4Value[14] ;
      DMValue[ 127: 120] = Byte4Value[15] ;
      DMValue[ 135: 128] = Byte4Value[16] ;
      DMValue[ 143: 136] = Byte4Value[17] ;
      DMValue[ 151: 144] = Byte4Value[18] ;
      DMValue[ 159: 152] = Byte4Value[19] ;
      DMValue[ 167: 160] = Byte4Value[20] ;
      DMValue[ 175: 168] = Byte4Value[21] ;
      DMValue[ 183: 176] = Byte4Value[22] ;
      DMValue[ 191: 184] = Byte4Value[23] ;
      DMValue[ 199: 192] = Byte4Value[24] ;
      DMValue[ 207: 200] = Byte4Value[25] ;
      DMValue[ 215: 208] = Byte4Value[26] ;
      DMValue[ 223: 216] = Byte4Value[27] ;
      DMValue[ 231: 224] = Byte4Value[28] ;
      DMValue[ 239: 232] = Byte4Value[29] ;
      DMValue[ 247: 240] = Byte4Value[30] ;
      DMValue[ 255: 248] = Byte4Value[31] ;       
      if(DMValue == ExpValue)
         $display("%0t Read DM0 OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
   endtask

   task automatic CheckDM0Value128(input int SPUSTARTPC, input int InstrCycle, input int Addr,input logic[127:0] ExpValue);
      bit[127:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[16];
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle); 
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM0.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[ 15: 8] = Byte4Value[1] ;
      DMValue[ 23: 16] = Byte4Value[2] ;
      DMValue[ 31: 24] = Byte4Value[3] ;
      DMValue[ 39: 32] = Byte4Value[4] ;
      DMValue[ 47: 40] = Byte4Value[5] ;
      DMValue[ 55: 48] = Byte4Value[6] ;
      DMValue[ 63: 56] = Byte4Value[7] ;
      DMValue[ 71: 64] = Byte4Value[8] ;
      DMValue[ 79: 72] = Byte4Value[9] ;
      DMValue[ 87: 80] = Byte4Value[10] ;
      DMValue[ 95: 88] = Byte4Value[11] ;
      DMValue[ 103: 96] = Byte4Value[12] ;
      DMValue[ 111: 104] = Byte4Value[13] ;
      DMValue[ 119: 112] = Byte4Value[14] ;
      DMValue[ 127: 120] = Byte4Value[15] ; 

      if(DMValue == ExpValue)
         $display("%0t Read DM0 OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
   endtask

   task automatic CheckDM0Value128_NStall(input int SPUSTARTPC, input int InstrCycle, input int Addr,input logic[127:0] ExpValue);
      bit[127:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[16];
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC)
            break;
      end
      WaitSPUCycles_NStall(InstrCycle); 
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM0.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[ 15: 8] = Byte4Value[1] ;
      DMValue[ 23: 16] = Byte4Value[2] ;
      DMValue[ 31: 24] = Byte4Value[3] ;
      DMValue[ 39: 32] = Byte4Value[4] ;
      DMValue[ 47: 40] = Byte4Value[5] ;
      DMValue[ 55: 48] = Byte4Value[6] ;
      DMValue[ 63: 56] = Byte4Value[7] ;
      DMValue[ 71: 64] = Byte4Value[8] ;
      DMValue[ 79: 72] = Byte4Value[9] ;
      DMValue[ 87: 80] = Byte4Value[10] ;
      DMValue[ 95: 88] = Byte4Value[11] ;
      DMValue[ 103: 96] = Byte4Value[12] ;
      DMValue[ 111: 104] = Byte4Value[13] ;
      DMValue[ 119: 112] = Byte4Value[14] ;
      DMValue[ 127: 120] = Byte4Value[15] ; 

      if(DMValue == ExpValue)
         $display("%0t Read DM0 OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
   endtask

   task automatic CheckDM0Value64(input int SPUSTARTPC, input int InstrCycle, input int Addr,input logic[63:0] ExpValue);
      bit[63:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[8];
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle); 
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM0.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[ 15: 8] = Byte4Value[1] ;
      DMValue[ 23: 16] = Byte4Value[2] ;
      DMValue[ 31: 24] = Byte4Value[3] ;
      DMValue[ 39: 32] = Byte4Value[4] ;
      DMValue[ 47: 40] = Byte4Value[5] ;
      DMValue[ 55: 48] = Byte4Value[6] ;
      DMValue[ 63: 56] = Byte4Value[7] ;
       
      if(DMValue == ExpValue)
         $display("%0t Read DM0 OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
   endtask

   task automatic CheckDM0Value64_NStall(input int SPUSTARTPC, input int InstrCycle, input int Addr,input logic[63:0] ExpValue);
      bit[63:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[8];
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC)
            break;
      end
      WaitSPUCycles_NStall(InstrCycle); 
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM0.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[ 15: 8] = Byte4Value[1] ;
      DMValue[ 23: 16] = Byte4Value[2] ;
      DMValue[ 31: 24] = Byte4Value[3] ;
      DMValue[ 39: 32] = Byte4Value[4] ;
      DMValue[ 47: 40] = Byte4Value[5] ;
      DMValue[ 55: 48] = Byte4Value[6] ;
      DMValue[ 63: 56] = Byte4Value[7] ;
       
      if(DMValue == ExpValue)
         $display("%0t Read DM0 OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
   endtask
   

   //CGran = Gran || CGran = 6
   task automatic CheckDM0Value32(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
      bit[31:0]   DMValue;
      byte Byte4Value[];

      Byte4Value  = new[4];
      
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC&& !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);
      
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM0.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[15: 8] = Byte4Value[1] ;
      DMValue[23:16] = Byte4Value[2] ;
      DMValue[31:24] = Byte4Value[3] ;
      
      if(DMValue === ExpValue)
         $display("%0t Read DM0 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPUSTARTPC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end

      Byte4Value.delete();
   endtask

   task automatic CheckDM0Value32_NStall(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
      bit[31:0]   DMValue;
      byte Byte4Value[];

      Byte4Value  = new[4];
      
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC)
            break;
      end
      WaitSPUCycles_NStall(InstrCycle);
      
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM0.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[15: 8] = Byte4Value[1] ;
      DMValue[23:16] = Byte4Value[2] ;
      DMValue[31:24] = Byte4Value[3] ;
      
      if(DMValue === ExpValue)
         $display("%0t Read DM0 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPUSTARTPC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end

      Byte4Value.delete();
   endtask

   //CGran = Gran || CGran = 6
   task automatic CheckDM0Value16(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
      bit[15:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[2];

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM0.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[15: 8] = Byte4Value[1] ;
      if(DMValue === ExpValue)
         $display("%0t Read DM0 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPUSTARTPC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
   endtask
  
   //CGran = Gran || CGran = 6
   task automatic CheckDM0Value8(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
      bit[15:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[1];

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM0.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      if(DMValue === ExpValue)
         $display("%0t Read DM0 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPUSTARTPC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
   endtask

   //CGran = Gran || CGran = 6
   task automatic CheckDM1ValueSPUSTARTPC(input int SPUSTARTPC, input int InstrCycle, input int Addr,input logic[511:0] ExpValue);
      bit[511:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[64];

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle); 
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM1.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[ 15: 8] = Byte4Value[1] ;
      DMValue[ 23: 16] = Byte4Value[2] ;
      DMValue[ 31: 24] = Byte4Value[3] ;
      DMValue[ 39: 32] = Byte4Value[4] ;
      DMValue[ 47: 40] = Byte4Value[5] ;
      DMValue[ 55: 48] = Byte4Value[6] ;
      DMValue[ 63: 56] = Byte4Value[7] ;
      DMValue[ 71: 64] = Byte4Value[8] ;
      DMValue[ 79: 72] = Byte4Value[9] ;
      DMValue[ 87: 80] = Byte4Value[10] ;
      DMValue[ 95: 88] = Byte4Value[11] ;
      DMValue[ 103: 96] = Byte4Value[12] ;
      DMValue[ 111: 104] = Byte4Value[13] ;
      DMValue[ 119: 112] = Byte4Value[14] ;
      DMValue[ 127: 120] = Byte4Value[15] ;
      DMValue[ 135: 128] = Byte4Value[16] ;
      DMValue[ 143: 136] = Byte4Value[17] ;
      DMValue[ 151: 144] = Byte4Value[18] ;
      DMValue[ 159: 152] = Byte4Value[19] ;
      DMValue[ 167: 160] = Byte4Value[20] ;
      DMValue[ 175: 168] = Byte4Value[21] ;
      DMValue[ 183: 176] = Byte4Value[22] ;
      DMValue[ 191: 184] = Byte4Value[23] ;
      DMValue[ 199: 192] = Byte4Value[24] ;
      DMValue[ 207: 200] = Byte4Value[25] ;
      DMValue[ 215: 208] = Byte4Value[26] ;
      DMValue[ 223: 216] = Byte4Value[27] ;
      DMValue[ 231: 224] = Byte4Value[28] ;
      DMValue[ 239: 232] = Byte4Value[29] ;
      DMValue[ 247: 240] = Byte4Value[30] ;
      DMValue[ 255: 248] = Byte4Value[31] ;
      DMValue[ 263: 256] = Byte4Value[32] ;
      DMValue[ 271: 264] = Byte4Value[33] ;
      DMValue[ 279: 272] = Byte4Value[34] ;
      DMValue[ 287: 280] = Byte4Value[35] ;
      DMValue[ 295: 288] = Byte4Value[36] ;
      DMValue[ 303: 296] = Byte4Value[37] ;
      DMValue[ 311: 304] = Byte4Value[38] ;
      DMValue[ 319: 312] = Byte4Value[39] ;
      DMValue[ 327: 320] = Byte4Value[40] ;
      DMValue[ 335: 328] = Byte4Value[41] ;
      DMValue[ 343: 336] = Byte4Value[42] ;
      DMValue[ 351: 344] = Byte4Value[43] ;
      DMValue[ 359: 352] = Byte4Value[44] ;
      DMValue[ 367: 360] = Byte4Value[45] ;
      DMValue[ 375: 368] = Byte4Value[46] ;
      DMValue[ 383: 376] = Byte4Value[47] ;
      DMValue[ 391: 384] = Byte4Value[48] ;
      DMValue[ 399: 392] = Byte4Value[49] ;
      DMValue[ 407: 400] = Byte4Value[50] ;
      DMValue[ 415: 408] = Byte4Value[51] ;
      DMValue[ 423: 416] = Byte4Value[52] ;
      DMValue[ 431: 424] = Byte4Value[53] ;
      DMValue[ 439: 432] = Byte4Value[54] ;
      DMValue[ 447: 440] = Byte4Value[55] ;
      DMValue[ 455: 448] = Byte4Value[56] ;
      DMValue[ 463: 456] = Byte4Value[57] ;
      DMValue[ 471: 464] = Byte4Value[58] ;
      DMValue[ 479: 472] = Byte4Value[59] ;
      DMValue[ 487: 480] = Byte4Value[60] ;
      DMValue[ 495: 488] = Byte4Value[61] ;
      DMValue[ 503: 496] = Byte4Value[62] ;
      DMValue[ 511: 504] = Byte4Value[63] ;
      if(DMValue == ExpValue)
         $display("%0t Read DM1 OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         Mon.display_512(ExpValue);
         Mon.display_512(DMValue);
      end
      Byte4Value.delete();
   endtask

   task automatic CheckDM1Value256(input int SPUSTARTPC, input int InstrCycle, input int Addr,input logic[255:0] ExpValue);
      bit[255:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[32];
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle); 
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM1.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[ 15: 8] = Byte4Value[1] ;
      DMValue[ 23: 16] = Byte4Value[2] ;
      DMValue[ 31: 24] = Byte4Value[3] ;
      DMValue[ 39: 32] = Byte4Value[4] ;
      DMValue[ 47: 40] = Byte4Value[5] ;
      DMValue[ 55: 48] = Byte4Value[6] ;
      DMValue[ 63: 56] = Byte4Value[7] ;
      DMValue[ 71: 64] = Byte4Value[8] ;
      DMValue[ 79: 72] = Byte4Value[9] ;
      DMValue[ 87: 80] = Byte4Value[10] ;
      DMValue[ 95: 88] = Byte4Value[11] ;
      DMValue[ 103: 96] = Byte4Value[12] ;
      DMValue[ 111: 104] = Byte4Value[13] ;
      DMValue[ 119: 112] = Byte4Value[14] ;
      DMValue[ 127: 120] = Byte4Value[15] ;
      DMValue[ 135: 128] = Byte4Value[16] ;
      DMValue[ 143: 136] = Byte4Value[17] ;
      DMValue[ 151: 144] = Byte4Value[18] ;
      DMValue[ 159: 152] = Byte4Value[19] ;
      DMValue[ 167: 160] = Byte4Value[20] ;
      DMValue[ 175: 168] = Byte4Value[21] ;
      DMValue[ 183: 176] = Byte4Value[22] ;
      DMValue[ 191: 184] = Byte4Value[23] ;
      DMValue[ 199: 192] = Byte4Value[24] ;
      DMValue[ 207: 200] = Byte4Value[25] ;
      DMValue[ 215: 208] = Byte4Value[26] ;
      DMValue[ 223: 216] = Byte4Value[27] ;
      DMValue[ 231: 224] = Byte4Value[28] ;
      DMValue[ 239: 232] = Byte4Value[29] ;
      DMValue[ 247: 240] = Byte4Value[30] ;
      DMValue[ 255: 248] = Byte4Value[31] ;       
      if(DMValue == ExpValue)
         $display("%0t Read DM1 OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
   endtask

   task automatic CheckDM1Value256_NStall(input int SPUSTARTPC, input int InstrCycle, input int Addr,input logic[255:0] ExpValue);
      bit[255:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[32];
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC)
            break;
      end
      WaitSPUCycles_NStall(InstrCycle); 
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM1.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[ 15: 8] = Byte4Value[1] ;
      DMValue[ 23: 16] = Byte4Value[2] ;
      DMValue[ 31: 24] = Byte4Value[3] ;
      DMValue[ 39: 32] = Byte4Value[4] ;
      DMValue[ 47: 40] = Byte4Value[5] ;
      DMValue[ 55: 48] = Byte4Value[6] ;
      DMValue[ 63: 56] = Byte4Value[7] ;
      DMValue[ 71: 64] = Byte4Value[8] ;
      DMValue[ 79: 72] = Byte4Value[9] ;
      DMValue[ 87: 80] = Byte4Value[10] ;
      DMValue[ 95: 88] = Byte4Value[11] ;
      DMValue[ 103: 96] = Byte4Value[12] ;
      DMValue[ 111: 104] = Byte4Value[13] ;
      DMValue[ 119: 112] = Byte4Value[14] ;
      DMValue[ 127: 120] = Byte4Value[15] ;
      DMValue[ 135: 128] = Byte4Value[16] ;
      DMValue[ 143: 136] = Byte4Value[17] ;
      DMValue[ 151: 144] = Byte4Value[18] ;
      DMValue[ 159: 152] = Byte4Value[19] ;
      DMValue[ 167: 160] = Byte4Value[20] ;
      DMValue[ 175: 168] = Byte4Value[21] ;
      DMValue[ 183: 176] = Byte4Value[22] ;
      DMValue[ 191: 184] = Byte4Value[23] ;
      DMValue[ 199: 192] = Byte4Value[24] ;
      DMValue[ 207: 200] = Byte4Value[25] ;
      DMValue[ 215: 208] = Byte4Value[26] ;
      DMValue[ 223: 216] = Byte4Value[27] ;
      DMValue[ 231: 224] = Byte4Value[28] ;
      DMValue[ 239: 232] = Byte4Value[29] ;
      DMValue[ 247: 240] = Byte4Value[30] ;
      DMValue[ 255: 248] = Byte4Value[31] ;       
      if(DMValue == ExpValue)
         $display("%0t Read DM1 OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
   endtask

   task automatic CheckDM1Value128(input int SPUSTARTPC, input int InstrCycle, input int Addr,input logic[127:0] ExpValue);
      bit[127:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[16];
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle); 
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM1.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[ 15: 8] = Byte4Value[1] ;
      DMValue[ 23: 16] = Byte4Value[2] ;
      DMValue[ 31: 24] = Byte4Value[3] ;
      DMValue[ 39: 32] = Byte4Value[4] ;
      DMValue[ 47: 40] = Byte4Value[5] ;
      DMValue[ 55: 48] = Byte4Value[6] ;
      DMValue[ 63: 56] = Byte4Value[7] ;
      DMValue[ 71: 64] = Byte4Value[8] ;
      DMValue[ 79: 72] = Byte4Value[9] ;
      DMValue[ 87: 80] = Byte4Value[10] ;
      DMValue[ 95: 88] = Byte4Value[11] ;
      DMValue[ 103: 96] = Byte4Value[12] ;
      DMValue[ 111: 104] = Byte4Value[13] ;
      DMValue[ 119: 112] = Byte4Value[14] ;
      DMValue[ 127: 120] = Byte4Value[15] ; 

      if(DMValue == ExpValue)
         $display("%0t Read DM1 OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
   endtask

   task automatic CheckDM1Value128_NStall(input int SPUSTARTPC, input int InstrCycle, input int Addr,input logic[127:0] ExpValue);
      bit[127:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[16];
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC)
            break;
      end
      WaitSPUCycles_NStall(InstrCycle); 
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM1.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[ 15: 8] = Byte4Value[1] ;
      DMValue[ 23: 16] = Byte4Value[2] ;
      DMValue[ 31: 24] = Byte4Value[3] ;
      DMValue[ 39: 32] = Byte4Value[4] ;
      DMValue[ 47: 40] = Byte4Value[5] ;
      DMValue[ 55: 48] = Byte4Value[6] ;
      DMValue[ 63: 56] = Byte4Value[7] ;
      DMValue[ 71: 64] = Byte4Value[8] ;
      DMValue[ 79: 72] = Byte4Value[9] ;
      DMValue[ 87: 80] = Byte4Value[10] ;
      DMValue[ 95: 88] = Byte4Value[11] ;
      DMValue[ 103: 96] = Byte4Value[12] ;
      DMValue[ 111: 104] = Byte4Value[13] ;
      DMValue[ 119: 112] = Byte4Value[14] ;
      DMValue[ 127: 120] = Byte4Value[15] ; 

      if(DMValue == ExpValue)
         $display("%0t Read DM1 OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
   endtask

   task automatic CheckDM1Value64(input int SPUSTARTPC, input int InstrCycle, input int Addr,input logic[63:0] ExpValue);
      bit[63:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[8];
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle); 
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM1.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[ 15: 8] = Byte4Value[1] ;
      DMValue[ 23: 16] = Byte4Value[2] ;
      DMValue[ 31: 24] = Byte4Value[3] ;
      DMValue[ 39: 32] = Byte4Value[4] ;
      DMValue[ 47: 40] = Byte4Value[5] ;
      DMValue[ 55: 48] = Byte4Value[6] ;
      DMValue[ 63: 56] = Byte4Value[7] ;
       
      if(DMValue == ExpValue)
         $display("%0t Read DM1 OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
   endtask

   task automatic CheckDM1Value64_NStall(input int SPUSTARTPC, input int InstrCycle, input int Addr,input logic[63:0] ExpValue);
      bit[63:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[8];
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC)
            break;
      end
      WaitSPUCycles_NStall(InstrCycle); 
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM1.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[ 15: 8] = Byte4Value[1] ;
      DMValue[ 23: 16] = Byte4Value[2] ;
      DMValue[ 31: 24] = Byte4Value[3] ;
      DMValue[ 39: 32] = Byte4Value[4] ;
      DMValue[ 47: 40] = Byte4Value[5] ;
      DMValue[ 55: 48] = Byte4Value[6] ;
      DMValue[ 63: 56] = Byte4Value[7] ;
       
      if(DMValue == ExpValue)
         $display("%0t Read DM1 OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
   endtask

   //CGran = Gran || CGran = 6
   task automatic CheckDM1Value32(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
      bit[31:0]   DMValue;
      byte Byte4Value[];

      Byte4Value  = new[4];
      
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall )
            break;
      end
      WaitSPUCycles(InstrCycle);
      
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM1.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[15: 8] = Byte4Value[1] ;
      DMValue[23:16] = Byte4Value[2] ;
      DMValue[31:24] = Byte4Value[3] ;
      
      if(DMValue === ExpValue)
         $display("%0t Read DM1 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPUSTARTPC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end

      Byte4Value.delete();
   endtask

   task automatic CheckDM1Value32_NStall(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
      bit[31:0]   DMValue;
      byte Byte4Value[];

      Byte4Value  = new[4];
      
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC  )
            break;
      end
      WaitSPUCycles_NStall(InstrCycle);
      
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM1.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[15: 8] = Byte4Value[1] ;
      DMValue[23:16] = Byte4Value[2] ;
      DMValue[31:24] = Byte4Value[3] ;
      
      if(DMValue === ExpValue)
         $display("%0t Read DM1 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPUSTARTPC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end

      Byte4Value.delete();
   endtask

   //CGran = Gran || CGran = 6
   task automatic CheckDM1Value16(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
      bit[15:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[2];

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM1.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[15: 8] = Byte4Value[1] ;
      if(DMValue === ExpValue)
         $display("%0t Read DM1 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPUSTARTPC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
   endtask

   //CGran = Gran || CGran = 6
   task automatic CheckDM1Value8(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
      bit[15:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[1];

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM1.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      if(DMValue === ExpValue)
         $display("%0t Read DM1 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
      else  begin
         $display("%0t Error @SPUSTARTPC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
   endtask

   //CGran = Gran || CGran = 6
   task automatic CheckDM2ValueSPUSTARTPC(input int SPUSTARTPC, input int InstrCycle, input int Addr,input logic[511:0] ExpValue);
      bit[511:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[64];

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle); 
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM2.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[ 15: 8] = Byte4Value[1] ;
      DMValue[ 23: 16] = Byte4Value[2] ;
      DMValue[ 31: 24] = Byte4Value[3] ;
      DMValue[ 39: 32] = Byte4Value[4] ;
      DMValue[ 47: 40] = Byte4Value[5] ;
      DMValue[ 55: 48] = Byte4Value[6] ;
      DMValue[ 63: 56] = Byte4Value[7] ;
      DMValue[ 71: 64] = Byte4Value[8] ;
      DMValue[ 79: 72] = Byte4Value[9] ;
      DMValue[ 87: 80] = Byte4Value[10] ;
      DMValue[ 95: 88] = Byte4Value[11] ;
      DMValue[ 103: 96] = Byte4Value[12] ;
      DMValue[ 111: 104] = Byte4Value[13] ;
      DMValue[ 119: 112] = Byte4Value[14] ;
      DMValue[ 127: 120] = Byte4Value[15] ;
      DMValue[ 135: 128] = Byte4Value[16] ;
      DMValue[ 143: 136] = Byte4Value[17] ;
      DMValue[ 151: 144] = Byte4Value[18] ;
      DMValue[ 159: 152] = Byte4Value[19] ;
      DMValue[ 167: 160] = Byte4Value[20] ;
      DMValue[ 175: 168] = Byte4Value[21] ;
      DMValue[ 183: 176] = Byte4Value[22] ;
      DMValue[ 191: 184] = Byte4Value[23] ;
      DMValue[ 199: 192] = Byte4Value[24] ;
      DMValue[ 207: 200] = Byte4Value[25] ;
      DMValue[ 215: 208] = Byte4Value[26] ;
      DMValue[ 223: 216] = Byte4Value[27] ;
      DMValue[ 231: 224] = Byte4Value[28] ;
      DMValue[ 239: 232] = Byte4Value[29] ;
      DMValue[ 247: 240] = Byte4Value[30] ;
      DMValue[ 255: 248] = Byte4Value[31] ;
      DMValue[ 263: 256] = Byte4Value[32] ;
      DMValue[ 271: 264] = Byte4Value[33] ;
      DMValue[ 279: 272] = Byte4Value[34] ;
      DMValue[ 287: 280] = Byte4Value[35] ;
      DMValue[ 295: 288] = Byte4Value[36] ;
      DMValue[ 303: 296] = Byte4Value[37] ;
      DMValue[ 311: 304] = Byte4Value[38] ;
      DMValue[ 319: 312] = Byte4Value[39] ;
      DMValue[ 327: 320] = Byte4Value[40] ;
      DMValue[ 335: 328] = Byte4Value[41] ;
      DMValue[ 343: 336] = Byte4Value[42] ;
      DMValue[ 351: 344] = Byte4Value[43] ;
      DMValue[ 359: 352] = Byte4Value[44] ;
      DMValue[ 367: 360] = Byte4Value[45] ;
      DMValue[ 375: 368] = Byte4Value[46] ;
      DMValue[ 383: 376] = Byte4Value[47] ;
      DMValue[ 391: 384] = Byte4Value[48] ;
      DMValue[ 399: 392] = Byte4Value[49] ;
      DMValue[ 407: 400] = Byte4Value[50] ;
      DMValue[ 415: 408] = Byte4Value[51] ;
      DMValue[ 423: 416] = Byte4Value[52] ;
      DMValue[ 431: 424] = Byte4Value[53] ;
      DMValue[ 439: 432] = Byte4Value[54] ;
      DMValue[ 447: 440] = Byte4Value[55] ;
      DMValue[ 455: 448] = Byte4Value[56] ;
      DMValue[ 463: 456] = Byte4Value[57] ;
      DMValue[ 471: 464] = Byte4Value[58] ;
      DMValue[ 479: 472] = Byte4Value[59] ;
      DMValue[ 487: 480] = Byte4Value[60] ;
      DMValue[ 495: 488] = Byte4Value[61] ;
      DMValue[ 503: 496] = Byte4Value[62] ;
      DMValue[ 511: 504] = Byte4Value[63] ;
      if(DMValue == ExpValue)
         $display("%0t Read DM2 OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         Mon.display_512(ExpValue);
         Mon.display_512(DMValue);
      end
      Byte4Value.delete();
   endtask

   task automatic CheckDM2Value256(input int SPUSTARTPC, input int InstrCycle, input int Addr,input logic[255:0] ExpValue);
      bit[255:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[32];
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle); 
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM2.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[ 15: 8] = Byte4Value[1] ;
      DMValue[ 23: 16] = Byte4Value[2] ;
      DMValue[ 31: 24] = Byte4Value[3] ;
      DMValue[ 39: 32] = Byte4Value[4] ;
      DMValue[ 47: 40] = Byte4Value[5] ;
      DMValue[ 55: 48] = Byte4Value[6] ;
      DMValue[ 63: 56] = Byte4Value[7] ;
      DMValue[ 71: 64] = Byte4Value[8] ;
      DMValue[ 79: 72] = Byte4Value[9] ;
      DMValue[ 87: 80] = Byte4Value[10] ;
      DMValue[ 95: 88] = Byte4Value[11] ;
      DMValue[ 103: 96] = Byte4Value[12] ;
      DMValue[ 111: 104] = Byte4Value[13] ;
      DMValue[ 119: 112] = Byte4Value[14] ;
      DMValue[ 127: 120] = Byte4Value[15] ;
      DMValue[ 135: 128] = Byte4Value[16] ;
      DMValue[ 143: 136] = Byte4Value[17] ;
      DMValue[ 151: 144] = Byte4Value[18] ;
      DMValue[ 159: 152] = Byte4Value[19] ;
      DMValue[ 167: 160] = Byte4Value[20] ;
      DMValue[ 175: 168] = Byte4Value[21] ;
      DMValue[ 183: 176] = Byte4Value[22] ;
      DMValue[ 191: 184] = Byte4Value[23] ;
      DMValue[ 199: 192] = Byte4Value[24] ;
      DMValue[ 207: 200] = Byte4Value[25] ;
      DMValue[ 215: 208] = Byte4Value[26] ;
      DMValue[ 223: 216] = Byte4Value[27] ;
      DMValue[ 231: 224] = Byte4Value[28] ;
      DMValue[ 239: 232] = Byte4Value[29] ;
      DMValue[ 247: 240] = Byte4Value[30] ;
      DMValue[ 255: 248] = Byte4Value[31] ;       
      if(DMValue == ExpValue)
         $display("%0t Read DM2 OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
   endtask

   task automatic CheckDM2Value256_NStall(input int SPUSTARTPC, input int InstrCycle, input int Addr,input logic[255:0] ExpValue);
      bit[255:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[32];
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC)
            break;
      end
      WaitSPUCycles_NStall(InstrCycle); 
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM2.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[ 15: 8] = Byte4Value[1] ;
      DMValue[ 23: 16] = Byte4Value[2] ;
      DMValue[ 31: 24] = Byte4Value[3] ;
      DMValue[ 39: 32] = Byte4Value[4] ;
      DMValue[ 47: 40] = Byte4Value[5] ;
      DMValue[ 55: 48] = Byte4Value[6] ;
      DMValue[ 63: 56] = Byte4Value[7] ;
      DMValue[ 71: 64] = Byte4Value[8] ;
      DMValue[ 79: 72] = Byte4Value[9] ;
      DMValue[ 87: 80] = Byte4Value[10] ;
      DMValue[ 95: 88] = Byte4Value[11] ;
      DMValue[ 103: 96] = Byte4Value[12] ;
      DMValue[ 111: 104] = Byte4Value[13] ;
      DMValue[ 119: 112] = Byte4Value[14] ;
      DMValue[ 127: 120] = Byte4Value[15] ;
      DMValue[ 135: 128] = Byte4Value[16] ;
      DMValue[ 143: 136] = Byte4Value[17] ;
      DMValue[ 151: 144] = Byte4Value[18] ;
      DMValue[ 159: 152] = Byte4Value[19] ;
      DMValue[ 167: 160] = Byte4Value[20] ;
      DMValue[ 175: 168] = Byte4Value[21] ;
      DMValue[ 183: 176] = Byte4Value[22] ;
      DMValue[ 191: 184] = Byte4Value[23] ;
      DMValue[ 199: 192] = Byte4Value[24] ;
      DMValue[ 207: 200] = Byte4Value[25] ;
      DMValue[ 215: 208] = Byte4Value[26] ;
      DMValue[ 223: 216] = Byte4Value[27] ;
      DMValue[ 231: 224] = Byte4Value[28] ;
      DMValue[ 239: 232] = Byte4Value[29] ;
      DMValue[ 247: 240] = Byte4Value[30] ;
      DMValue[ 255: 248] = Byte4Value[31] ;       
      if(DMValue == ExpValue)
         $display("%0t Read DM2 OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
   endtask

   task automatic CheckDM2Value128(input int SPUSTARTPC, input int InstrCycle, input int Addr,input logic[127:0] ExpValue);
      bit[127:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[16];
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle); 
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM2.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[ 15: 8] = Byte4Value[1] ;
      DMValue[ 23: 16] = Byte4Value[2] ;
      DMValue[ 31: 24] = Byte4Value[3] ;
      DMValue[ 39: 32] = Byte4Value[4] ;
      DMValue[ 47: 40] = Byte4Value[5] ;
      DMValue[ 55: 48] = Byte4Value[6] ;
      DMValue[ 63: 56] = Byte4Value[7] ;
      DMValue[ 71: 64] = Byte4Value[8] ;
      DMValue[ 79: 72] = Byte4Value[9] ;
      DMValue[ 87: 80] = Byte4Value[10] ;
      DMValue[ 95: 88] = Byte4Value[11] ;
      DMValue[ 103: 96] = Byte4Value[12] ;
      DMValue[ 111: 104] = Byte4Value[13] ;
      DMValue[ 119: 112] = Byte4Value[14] ;
      DMValue[ 127: 120] = Byte4Value[15] ; 

      if(DMValue == ExpValue)
         $display("%0t Read DM2 OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
   endtask

   task automatic CheckDM2Value128_NStall(input int SPUSTARTPC, input int InstrCycle, input int Addr,input logic[127:0] ExpValue);
      bit[127:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[16];
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC)
            break;
      end
      WaitSPUCycles_NStall(InstrCycle); 
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM2.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[ 15: 8] = Byte4Value[1] ;
      DMValue[ 23: 16] = Byte4Value[2] ;
      DMValue[ 31: 24] = Byte4Value[3] ;
      DMValue[ 39: 32] = Byte4Value[4] ;
      DMValue[ 47: 40] = Byte4Value[5] ;
      DMValue[ 55: 48] = Byte4Value[6] ;
      DMValue[ 63: 56] = Byte4Value[7] ;
      DMValue[ 71: 64] = Byte4Value[8] ;
      DMValue[ 79: 72] = Byte4Value[9] ;
      DMValue[ 87: 80] = Byte4Value[10] ;
      DMValue[ 95: 88] = Byte4Value[11] ;
      DMValue[ 103: 96] = Byte4Value[12] ;
      DMValue[ 111: 104] = Byte4Value[13] ;
      DMValue[ 119: 112] = Byte4Value[14] ;
      DMValue[ 127: 120] = Byte4Value[15] ; 

      if(DMValue == ExpValue)
         $display("%0t Read DM2 OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
   endtask

   task automatic CheckDM2Value64(input int SPUSTARTPC, input int InstrCycle, input int Addr,input logic[63:0] ExpValue);
      bit[63:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[8];
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle); 
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM2.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[ 15: 8] = Byte4Value[1] ;
      DMValue[ 23: 16] = Byte4Value[2] ;
      DMValue[ 31: 24] = Byte4Value[3] ;
      DMValue[ 39: 32] = Byte4Value[4] ;
      DMValue[ 47: 40] = Byte4Value[5] ;
      DMValue[ 55: 48] = Byte4Value[6] ;
      DMValue[ 63: 56] = Byte4Value[7] ;
       
      if(DMValue == ExpValue)
         $display("%0t Read DM2 OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
   endtask

   task automatic CheckDM2Value64_NStall(input int SPUSTARTPC, input int InstrCycle, input int Addr,input logic[63:0] ExpValue);
      bit[63:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[8];
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC)
            break;
      end
      WaitSPUCycles_NStall(InstrCycle); 
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM2.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[ 15: 8] = Byte4Value[1] ;
      DMValue[ 23: 16] = Byte4Value[2] ;
      DMValue[ 31: 24] = Byte4Value[3] ;
      DMValue[ 39: 32] = Byte4Value[4] ;
      DMValue[ 47: 40] = Byte4Value[5] ;
      DMValue[ 55: 48] = Byte4Value[6] ;
      DMValue[ 63: 56] = Byte4Value[7] ;
       
      if(DMValue == ExpValue)
         $display("%0t Read DM2 OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
   endtask

   //CGran = Gran || CGran = 6
   task automatic CheckDM2Value32(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
      bit[31:0]   DMValue;
      byte Byte4Value[];

      Byte4Value  = new[4];
      

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC  && !`ExeStall )
            break;
      end
      WaitSPUCycles(InstrCycle);
      
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM2.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[15: 8] = Byte4Value[1] ;
      DMValue[23:16] = Byte4Value[2] ;
      DMValue[31:24] = Byte4Value[3] ;
      
      if(DMValue === ExpValue)
         $display("%0t Read DM2 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPUSTARTPC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end

      Byte4Value.delete();
   endtask

   task automatic CheckDM2Value32_NStall(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
      bit[31:0]   DMValue;
      byte Byte4Value[];

      Byte4Value  = new[4];
      

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC )
            break;
      end
      WaitSPUCycles_NStall(InstrCycle);
      
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM2.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[15: 8] = Byte4Value[1] ;
      DMValue[23:16] = Byte4Value[2] ;
      DMValue[31:24] = Byte4Value[3] ;
      
      if(DMValue === ExpValue)
         $display("%0t Read DM2 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPUSTARTPC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end

      Byte4Value.delete();
   endtask

   //CGran = Gran || CGran = 6
   task automatic CheckDM2Value16(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
      bit[15:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[2];

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM2.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[15: 8] = Byte4Value[1] ;
      if(DMValue === ExpValue)
         $display("%0t Read DM2 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPUSTARTPC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
   endtask

   task automatic CheckDM2Value16_NStall(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
      bit[15:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[2];

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC)
            break;
      end
      WaitSPUCycles_NStall(InstrCycle);
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM2.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[15: 8] = Byte4Value[1] ;
      if(DMValue === ExpValue)
         $display("%0t Read DM2 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPUSTARTPC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
   endtask

   //CGran = Gran || CGran = 6
   task automatic CheckDM2Value8(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
      bit[15:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[1];

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM2.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      if(DMValue === ExpValue)
         $display("%0t Read DM2 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPUSTARTPC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
   endtask

   task automatic CheckDM2Value8_NStall(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
      bit[15:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[1];

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC)
            break;
      end
      WaitSPUCycles_NStall(InstrCycle);
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM2.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      if(DMValue === ExpValue)
         $display("%0t Read DM2 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPUSTARTPC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
   endtask

   //CGran = Gran || CGran = 6
   task automatic CheckDM3ValueSPUSTARTPC(input int SPUSTARTPC, input int InstrCycle, input int Addr,input logic[511:0] ExpValue);
      bit[511:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[64];

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle); 
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM3.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[ 15: 8] = Byte4Value[1] ;
      DMValue[ 23: 16] = Byte4Value[2] ;
      DMValue[ 31: 24] = Byte4Value[3] ;
      DMValue[ 39: 32] = Byte4Value[4] ;
      DMValue[ 47: 40] = Byte4Value[5] ;
      DMValue[ 55: 48] = Byte4Value[6] ;
      DMValue[ 63: 56] = Byte4Value[7] ;
      DMValue[ 71: 64] = Byte4Value[8] ;
      DMValue[ 79: 72] = Byte4Value[9] ;
      DMValue[ 87: 80] = Byte4Value[10] ;
      DMValue[ 95: 88] = Byte4Value[11] ;
      DMValue[ 103: 96] = Byte4Value[12] ;
      DMValue[ 111: 104] = Byte4Value[13] ;
      DMValue[ 119: 112] = Byte4Value[14] ;
      DMValue[ 127: 120] = Byte4Value[15] ;
      DMValue[ 135: 128] = Byte4Value[16] ;
      DMValue[ 143: 136] = Byte4Value[17] ;
      DMValue[ 151: 144] = Byte4Value[18] ;
      DMValue[ 159: 152] = Byte4Value[19] ;
      DMValue[ 167: 160] = Byte4Value[20] ;
      DMValue[ 175: 168] = Byte4Value[21] ;
      DMValue[ 183: 176] = Byte4Value[22] ;
      DMValue[ 191: 184] = Byte4Value[23] ;
      DMValue[ 199: 192] = Byte4Value[24] ;
      DMValue[ 207: 200] = Byte4Value[25] ;
      DMValue[ 215: 208] = Byte4Value[26] ;
      DMValue[ 223: 216] = Byte4Value[27] ;
      DMValue[ 231: 224] = Byte4Value[28] ;
      DMValue[ 239: 232] = Byte4Value[29] ;
      DMValue[ 247: 240] = Byte4Value[30] ;
      DMValue[ 255: 248] = Byte4Value[31] ;
      DMValue[ 263: 256] = Byte4Value[32] ;
      DMValue[ 271: 264] = Byte4Value[33] ;
      DMValue[ 279: 272] = Byte4Value[34] ;
      DMValue[ 287: 280] = Byte4Value[35] ;
      DMValue[ 295: 288] = Byte4Value[36] ;
      DMValue[ 303: 296] = Byte4Value[37] ;
      DMValue[ 311: 304] = Byte4Value[38] ;
      DMValue[ 319: 312] = Byte4Value[39] ;
      DMValue[ 327: 320] = Byte4Value[40] ;
      DMValue[ 335: 328] = Byte4Value[41] ;
      DMValue[ 343: 336] = Byte4Value[42] ;
      DMValue[ 351: 344] = Byte4Value[43] ;
      DMValue[ 359: 352] = Byte4Value[44] ;
      DMValue[ 367: 360] = Byte4Value[45] ;
      DMValue[ 375: 368] = Byte4Value[46] ;
      DMValue[ 383: 376] = Byte4Value[47] ;
      DMValue[ 391: 384] = Byte4Value[48] ;
      DMValue[ 399: 392] = Byte4Value[49] ;
      DMValue[ 407: 400] = Byte4Value[50] ;
      DMValue[ 415: 408] = Byte4Value[51] ;
      DMValue[ 423: 416] = Byte4Value[52] ;
      DMValue[ 431: 424] = Byte4Value[53] ;
      DMValue[ 439: 432] = Byte4Value[54] ;
      DMValue[ 447: 440] = Byte4Value[55] ;
      DMValue[ 455: 448] = Byte4Value[56] ;
      DMValue[ 463: 456] = Byte4Value[57] ;
      DMValue[ 471: 464] = Byte4Value[58] ;
      DMValue[ 479: 472] = Byte4Value[59] ;
      DMValue[ 487: 480] = Byte4Value[60] ;
      DMValue[ 495: 488] = Byte4Value[61] ;
      DMValue[ 503: 496] = Byte4Value[62] ;
      DMValue[ 511: 504] = Byte4Value[63] ;
      if(DMValue == ExpValue)
         $display("%0t Read DM3 OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         Mon.display_512(ExpValue);
         Mon.display_512(DMValue);
      end
      Byte4Value.delete();
   endtask

   task automatic CheckDM3Value256(input int SPUSTARTPC, input int InstrCycle, input int Addr,input logic[255:0] ExpValue);
      bit[255:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[32];
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle); 
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM3.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[ 15: 8] = Byte4Value[1] ;
      DMValue[ 23: 16] = Byte4Value[2] ;
      DMValue[ 31: 24] = Byte4Value[3] ;
      DMValue[ 39: 32] = Byte4Value[4] ;
      DMValue[ 47: 40] = Byte4Value[5] ;
      DMValue[ 55: 48] = Byte4Value[6] ;
      DMValue[ 63: 56] = Byte4Value[7] ;
      DMValue[ 71: 64] = Byte4Value[8] ;
      DMValue[ 79: 72] = Byte4Value[9] ;
      DMValue[ 87: 80] = Byte4Value[10] ;
      DMValue[ 95: 88] = Byte4Value[11] ;
      DMValue[ 103: 96] = Byte4Value[12] ;
      DMValue[ 111: 104] = Byte4Value[13] ;
      DMValue[ 119: 112] = Byte4Value[14] ;
      DMValue[ 127: 120] = Byte4Value[15] ;
      DMValue[ 135: 128] = Byte4Value[16] ;
      DMValue[ 143: 136] = Byte4Value[17] ;
      DMValue[ 151: 144] = Byte4Value[18] ;
      DMValue[ 159: 152] = Byte4Value[19] ;
      DMValue[ 167: 160] = Byte4Value[20] ;
      DMValue[ 175: 168] = Byte4Value[21] ;
      DMValue[ 183: 176] = Byte4Value[22] ;
      DMValue[ 191: 184] = Byte4Value[23] ;
      DMValue[ 199: 192] = Byte4Value[24] ;
      DMValue[ 207: 200] = Byte4Value[25] ;
      DMValue[ 215: 208] = Byte4Value[26] ;
      DMValue[ 223: 216] = Byte4Value[27] ;
      DMValue[ 231: 224] = Byte4Value[28] ;
      DMValue[ 239: 232] = Byte4Value[29] ;
      DMValue[ 247: 240] = Byte4Value[30] ;
      DMValue[ 255: 248] = Byte4Value[31] ;       
      if(DMValue == ExpValue)
         $display("%0t Read DM3 OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
   endtask

   task automatic CheckDM3Value256_NStall(input int SPUSTARTPC, input int InstrCycle, input int Addr,input logic[255:0] ExpValue);
      bit[255:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[32];
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC)
            break;
      end
      WaitSPUCycles_NStall(InstrCycle); 
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM3.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[ 15: 8] = Byte4Value[1] ;
      DMValue[ 23: 16] = Byte4Value[2] ;
      DMValue[ 31: 24] = Byte4Value[3] ;
      DMValue[ 39: 32] = Byte4Value[4] ;
      DMValue[ 47: 40] = Byte4Value[5] ;
      DMValue[ 55: 48] = Byte4Value[6] ;
      DMValue[ 63: 56] = Byte4Value[7] ;
      DMValue[ 71: 64] = Byte4Value[8] ;
      DMValue[ 79: 72] = Byte4Value[9] ;
      DMValue[ 87: 80] = Byte4Value[10] ;
      DMValue[ 95: 88] = Byte4Value[11] ;
      DMValue[ 103: 96] = Byte4Value[12] ;
      DMValue[ 111: 104] = Byte4Value[13] ;
      DMValue[ 119: 112] = Byte4Value[14] ;
      DMValue[ 127: 120] = Byte4Value[15] ;
      DMValue[ 135: 128] = Byte4Value[16] ;
      DMValue[ 143: 136] = Byte4Value[17] ;
      DMValue[ 151: 144] = Byte4Value[18] ;
      DMValue[ 159: 152] = Byte4Value[19] ;
      DMValue[ 167: 160] = Byte4Value[20] ;
      DMValue[ 175: 168] = Byte4Value[21] ;
      DMValue[ 183: 176] = Byte4Value[22] ;
      DMValue[ 191: 184] = Byte4Value[23] ;
      DMValue[ 199: 192] = Byte4Value[24] ;
      DMValue[ 207: 200] = Byte4Value[25] ;
      DMValue[ 215: 208] = Byte4Value[26] ;
      DMValue[ 223: 216] = Byte4Value[27] ;
      DMValue[ 231: 224] = Byte4Value[28] ;
      DMValue[ 239: 232] = Byte4Value[29] ;
      DMValue[ 247: 240] = Byte4Value[30] ;
      DMValue[ 255: 248] = Byte4Value[31] ;       
      if(DMValue == ExpValue)
         $display("%0t Read DM3 OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
   endtask

   task automatic CheckDM3Value128(input int SPUSTARTPC, input int InstrCycle, input int Addr,input logic[127:0] ExpValue);
      bit[127:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[16];
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle); 
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM3.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[ 15: 8] = Byte4Value[1] ;
      DMValue[ 23: 16] = Byte4Value[2] ;
      DMValue[ 31: 24] = Byte4Value[3] ;
      DMValue[ 39: 32] = Byte4Value[4] ;
      DMValue[ 47: 40] = Byte4Value[5] ;
      DMValue[ 55: 48] = Byte4Value[6] ;
      DMValue[ 63: 56] = Byte4Value[7] ;
      DMValue[ 71: 64] = Byte4Value[8] ;
      DMValue[ 79: 72] = Byte4Value[9] ;
      DMValue[ 87: 80] = Byte4Value[10] ;
      DMValue[ 95: 88] = Byte4Value[11] ;
      DMValue[ 103: 96] = Byte4Value[12] ;
      DMValue[ 111: 104] = Byte4Value[13] ;
      DMValue[ 119: 112] = Byte4Value[14] ;
      DMValue[ 127: 120] = Byte4Value[15] ; 

      if(DMValue == ExpValue)
         $display("%0t Read DM3 OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
   endtask

   task automatic CheckDM3Value128_NStall(input int SPUSTARTPC, input int InstrCycle, input int Addr,input logic[127:0] ExpValue);
      bit[127:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[16];
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC)
            break;
      end
      WaitSPUCycles_NStall(InstrCycle); 
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM3.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[ 15: 8] = Byte4Value[1] ;
      DMValue[ 23: 16] = Byte4Value[2] ;
      DMValue[ 31: 24] = Byte4Value[3] ;
      DMValue[ 39: 32] = Byte4Value[4] ;
      DMValue[ 47: 40] = Byte4Value[5] ;
      DMValue[ 55: 48] = Byte4Value[6] ;
      DMValue[ 63: 56] = Byte4Value[7] ;
      DMValue[ 71: 64] = Byte4Value[8] ;
      DMValue[ 79: 72] = Byte4Value[9] ;
      DMValue[ 87: 80] = Byte4Value[10] ;
      DMValue[ 95: 88] = Byte4Value[11] ;
      DMValue[ 103: 96] = Byte4Value[12] ;
      DMValue[ 111: 104] = Byte4Value[13] ;
      DMValue[ 119: 112] = Byte4Value[14] ;
      DMValue[ 127: 120] = Byte4Value[15] ; 

      if(DMValue == ExpValue)
         $display("%0t Read DM3 OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
   endtask

   task automatic CheckDM3Value64(input int SPUSTARTPC, input int InstrCycle, input int Addr,input logic[63:0] ExpValue);
      bit[63:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[8];
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle); 
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM3.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[ 15: 8] = Byte4Value[1] ;
      DMValue[ 23: 16] = Byte4Value[2] ;
      DMValue[ 31: 24] = Byte4Value[3] ;
      DMValue[ 39: 32] = Byte4Value[4] ;
      DMValue[ 47: 40] = Byte4Value[5] ;
      DMValue[ 55: 48] = Byte4Value[6] ;
      DMValue[ 63: 56] = Byte4Value[7] ;
       
      if(DMValue == ExpValue)
         $display("%0t Read DM3 OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
   endtask

   task automatic CheckDM3Value64_NStall(input int SPUSTARTPC, input int InstrCycle, input int Addr,input logic[63:0] ExpValue);
      bit[63:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[8];
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC)
            break;
      end
      WaitSPUCycles_NStall(InstrCycle); 
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM3.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[ 15: 8] = Byte4Value[1] ;
      DMValue[ 23: 16] = Byte4Value[2] ;
      DMValue[ 31: 24] = Byte4Value[3] ;
      DMValue[ 39: 32] = Byte4Value[4] ;
      DMValue[ 47: 40] = Byte4Value[5] ;
      DMValue[ 55: 48] = Byte4Value[6] ;
      DMValue[ 63: 56] = Byte4Value[7] ;
       
      if(DMValue == ExpValue)
         $display("%0t Read DM3 OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
   endtask

   //CGran = Gran || CGran = 6
   task automatic CheckDM3Value32(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
      bit[31:0]   DMValue;
      byte Byte4Value[];

      Byte4Value  = new[4];
      

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC  && !`ExeStall )
            break;
      end
      WaitSPUCycles(InstrCycle);
      
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM3.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[15: 8] = Byte4Value[1] ;
      DMValue[23:16] = Byte4Value[2] ;
      DMValue[31:24] = Byte4Value[3] ;
      
      if(DMValue === ExpValue)
         $display("%0t Read DM3 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPUSTARTPC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end

      Byte4Value.delete();
   endtask

   task automatic CheckDM3Value32_NStall(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
      bit[31:0]   DMValue;
      byte Byte4Value[];

      Byte4Value  = new[4];
      

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC )
            break;
      end
      WaitSPUCycles_NStall(InstrCycle);
      
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM3.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[15: 8] = Byte4Value[1] ;
      DMValue[23:16] = Byte4Value[2] ;
      DMValue[31:24] = Byte4Value[3] ;
      
      if(DMValue === ExpValue)
         $display("%0t Read DM3 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPUSTARTPC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end

      Byte4Value.delete();
   endtask

   //CGran = Gran || CGran = 6
   task automatic CheckDM3Value16(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
      bit[15:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[2];

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM3.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[15: 8] = Byte4Value[1] ;
      if(DMValue === ExpValue)
         $display("%0t Read DM3 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPUSTARTPC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
   endtask

   task automatic CheckDM3Value16_NStall(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
      bit[15:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[2];

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC)
            break;
      end
      WaitSPUCycles_NStall(InstrCycle);
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM3.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      DMValue[15: 8] = Byte4Value[1] ;
      if(DMValue === ExpValue)
         $display("%0t Read DM3 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPUSTARTPC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
   endtask

   //CGran = Gran || CGran = 6
   task automatic CheckDM3Value8(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
      bit[15:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[1];

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM3.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      if(DMValue === ExpValue)
         $display("%0t Read DM3 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPUSTARTPC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
   endtask

   task automatic CheckDM3Value8_NStall(input int SPUSTARTPC, input int InstrCycle, input int Addr, input int ExpValue);
      bit[15:0]   DMValue;
      byte Byte4Value[];
      Byte4Value  = new[1];

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC)
            break;
      end
      WaitSPUCycles_NStall(InstrCycle);
      //                                        Gran  KSize
      $root.TestTop.uAPE.uDM3.DMReadBytes(Addr, 3'h6, 4'hC, Byte4Value);
      DMValue[ 7: 0] = Byte4Value[0] ;
      if(DMValue === ExpValue)
         $display("%0t Read DM3 OK @SPUSTARTPC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPUSTARTPC = %h, Expected Value and Real Result are :", $realtime, SPUSTARTPC);
         $display("%h", ExpValue);
         $display("%h", DMValue);
         $display(" ");
      end
      Byte4Value.delete();
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

      $root.TestTop.uAPE.uIM.IMReadBytes(Addr, IMValue);

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

      $root.TestTop.uAPE.uIM.IMReadBytes(Addr, IMValue);

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

      $root.TestTop.uAPE.uIM.IMReadBytes(Addr, IMValue);

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
      $root.TestTop.uAPE.uIM.IMReadBytes(Addr, IMValue);
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

   task automatic CheckFIFOValue(input int SPUSTARTPC, input int InstrCycle, input bit[1:0] FIFOID, input logic[31:0] ExpValue); 
      logic[31:0]   FIFOValue;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
     // WaitSPUWrFIFOEnCycles();
      WaitSPUCycles(InstrCycle); 
      `TD
      FIFOValue = $root.TestTop.uAPE.uMPU.uMFetch.RFIFO[FIFOID];
      if(FIFOValue === ExpValue)
         $display("%0t Read FIFO[%0d] OK @SPU_STARTEX0_PC = %h!!", $realtime, FIFOID, SPUSTARTPC);
      else   
         begin
            $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are : %h, %h\n", $realtime, SPUSTARTPC, ExpValue, FIFOValue);
            $display(" ");
         end
   endtask

   task automatic CheckSEQIntEn(int SPUSTARTPC, input int InstrCycle, input logic ExpValue); 
      logic SEQIntEn;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTDC_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);
      
      SEQIntEn = $root.TestTop.uAPE.uSPU.uSEQ.rIntEn;

      if(SEQIntEn === ExpValue)
         $display("%0t Read SEQ IntEn OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :%h ,%h\n", $realtime, SPUSTARTPC, ExpValue, SEQIntEn);
   endtask

   task automatic CheckCallM(input int SPUSTARTPC, input int CallEn, input int CallAddr);
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall && `CALLEN == CallEn)
            break;
      end
      // wait(`SYNStall);   
      //if( `CALLEN !== CallEn  ) $display( "%0t Error @DP_PC = %h, ExpectedCallEn = %h , ResltCallEn = %h", $realtime, SPUSTARTPC, CallEn, `CALLEN);  
      //wait(`CALLEN == CallEn ); 
      if(`CALL_ADDR == CallAddr)
         $display("%0t CallM right @SPU_STARTEX0_PC = %h, CALL_ADDR = %h", $realtime, SPUSTARTPC, CallAddr); 
      else
         $display("%0t Error @SPU_STARTEX0_PC = %h, ExpectedCallAddr = %h , ResltCallAddr = %h", $realtime, SPUSTARTPC, CallAddr, `CALL_ADDR);
   endtask

   task automatic CheckMCValueSPUSTARTPC(input int SPUSTARTPC, input int InstrCycle, input bit[4:0] MCID, input logic[23:0] ExpValue); 
      logic[23:0]  MCValue;
      
      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUSYNStalledCycles(InstrCycle);

      case(MCID[4:1])
         4'b0000:  MCValue = ~MCID[0] ? {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[0][3][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[0][2][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[0][1][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[0][0][5:0]}
                                     : {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[0][7][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[0][6][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[0][5][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[0][4][5:0]};
         4'b0001:  MCValue = ~MCID[0] ? {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[1][3][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[1][2][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[1][1][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[1][0][5:0]}
                                     : {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[1][7][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[1][6][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[1][5][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[1][4][5:0]};
         4'b0010:  MCValue = ~MCID[0] ? {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[2][3][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[2][2][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[2][1][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[2][0][5:0]}
                                     : {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[2][7][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[2][6][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[2][5][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[2][4][5:0]};
         4'b0011:  MCValue = ~MCID[0] ? {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[3][3][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[3][2][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[3][1][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[3][0][5:0]}
                                     : {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[3][7][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[3][6][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[3][5][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[3][4][5:0]};
         4'b0100:  MCValue = ~MCID[0] ? {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[4][3][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[4][2][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[4][1][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[4][0][5:0]}
                                     : {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[4][7][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[4][6][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[4][5][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[4][4][5:0]};
         4'b0101:  MCValue = ~MCID[0] ? {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[5][3][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[5][2][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[5][1][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[5][0][5:0]}
                                     : {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[5][7][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[5][6][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[5][5][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[5][4][5:0]};
         4'b1000:  MCValue = ~MCID[0] ? {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[6][3][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[6][2][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[6][1][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[6][0][5:0]}
                                     : {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[6][7][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[6][6][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[6][5][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[6][4][5:0]};
         4'b1001:  MCValue = ~MCID[0] ? {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[7][3][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[7][2][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[7][1][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[7][0][5:0]}
                                     : {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[7][7][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[7][6][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[7][5][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[7][4][5:0]};
         4'b1010:  MCValue = ~MCID[0] ? {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[8][3][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[8][2][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[8][1][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[8][0][5:0]}
                                     : {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[8][7][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[8][6][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[8][5][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[8][4][5:0]};
         4'b1011:  MCValue = ~MCID[0] ? {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[9][3][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[9][2][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[9][1][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[9][0][5:0]}
                                     : {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[9][7][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[9][6][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[9][5][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[9][4][5:0]};
         4'b1100:  MCValue = ~MCID[0] ? {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[10][3][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[10][2][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[10][1][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[10][0][5:0]}
                                     : {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[10][7][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[10][6][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[10][5][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[10][4][5:0]};
         default:  MCValue = 24'hxxx;
      endcase

      if(MCValue === ExpValue)
         $display("%0t Read MC[%0d] OK @SPU_STARTEX0_PC = %h!!", $realtime, MCID, SPUSTARTPC);
      else   
         begin
            $display("%0t @SPU_STARTEX0_PC = %h, Read MC[%0d] Error Expected Value and Real Result are :%h ,%h\n", $realtime, SPUSTARTPC, MCID, ExpValue, MCValue);
            $display(" ");
         end
   endtask

   task automatic CheckMCValueSPU(input int SPUSTARTPC, input int InstrCycle, input bit[4:0] MCID, input logic[31:0] ExpValue); 
      logic[23:0]  MCValue;
      logic[31:0]  MCValue_Mask;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUSYNStalledCycles(InstrCycle);

      case(MCID[4:1])
         4'b0000:  MCValue = ~MCID[0] ? {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[0][3][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[0][2][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[0][1][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[0][0][5:0]}
                                     : {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[0][7][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[0][6][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[0][5][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[0][4][5:0]};
         4'b0001:  MCValue = ~MCID[0] ? {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[1][3][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[1][2][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[1][1][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[1][0][5:0]}
                                     : {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[1][7][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[1][6][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[1][5][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[1][4][5:0]};
         4'b0010:  MCValue = ~MCID[0] ? {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[2][3][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[2][2][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[2][1][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[2][0][5:0]}
                                     : {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[2][7][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[2][6][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[2][5][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[2][4][5:0]};
         4'b0011:  MCValue = ~MCID[0] ? {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[3][3][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[3][2][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[3][1][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[3][0][5:0]}
                                     : {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[3][7][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[3][6][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[3][5][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[3][4][5:0]};
         4'b1000:  MCValue = ~MCID[0] ? {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[4][3][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[4][2][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[4][1][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[4][0][5:0]}
                                     : {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[4][7][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[4][6][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[4][5][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[4][4][5:0]};
         4'b1001:  MCValue = ~MCID[0] ? {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[5][3][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[5][2][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[5][1][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[5][0][5:0]}
                                     : {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[5][7][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[5][6][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[5][5][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[5][4][5:0]};
         4'b1010:  MCValue = ~MCID[0] ? {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[6][3][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[6][2][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[6][1][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[6][0][5:0]}
                                     : {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[6][7][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[6][6][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[6][5][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[6][4][5:0]};
         4'b1011:  MCValue = ~MCID[0] ? {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[7][3][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[7][2][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[7][1][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[7][0][5:0]}
                                     : {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[7][7][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[7][6][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[7][5][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[7][4][5:0]};
         4'b1100:  MCValue = ~MCID[0] ? {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[8][3][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[8][2][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[8][1][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[8][0][5:0]}
                                     : {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[8][7][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[8][6][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[8][5][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[8][4][5:0]};
        /* 4'b1011:  MCValue = ~MCID[0] ? {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[9][3][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[9][2][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[9][1][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[9][0][5:0]}
                                     : {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[9][7][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[9][6][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[9][5][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[9][4][5:0]};
         4'b1100:  MCValue = ~MCID[0] ? {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[10][3][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[10][2][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[10][1][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[10][0][5:0]}
                                     : {$root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[10][7][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[10][6][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[10][5][5:0],
                                        $root.TestTop.uAPE.uMPU.uMRegCtrl.rMC[10][4][5:0]};*/
         default:  MCValue = 24'hxxx;
      endcase

		MCValue_Mask = {2'b00,MCValue[23:18],2'b00,MCValue[17:12],2'b00,MCValue[11:6],2'b00,MCValue[5:0]};
		ExpValue = ExpValue & 32'h3f3f3f3f;

      if(MCValue_Mask === ExpValue)
         $display("%0t Read MC[%0d] OK @SPU_STARTEX0_PC = %h!!", $realtime, MCID, SPUSTARTPC);
      else   
         begin
            $display("%0t @SPU_STARTEX0_PC = %h, Read MC[%0d] Error Expected Value and Real Result are :%h ,%h\n", $realtime, SPUSTARTPC, MCID, ExpValue, MCValue);
            $display(" ");
         end
   endtask

   
   task automatic CheckMPUPCValue(input int SPUSTARTPC, input int InstrCycle, input logic[15:0] ExpValue); 
      logic[15:0]   MPUPC;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);
      
      if(`MPU_DC_PC === ExpValue)
         $display("%0t Interrupt OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else begin
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :%h ,%h\n", $realtime, SPUSTARTPC, ExpValue, `MPU_DC_PC);
      end
   endtask

   task automatic CheckSYNFlag(int SPUSTARTPC, input int InstrCycle, input logic[1:0] ExpValue);
      logic[1:0] FlagValue;

      while(1) begin
         @(iCvSmpIF.APECB)
         if(`SPU_STARTEX0_PC === SPUSTARTPC && !`ExeStall)
            break;
      end
      WaitSPUCycles(InstrCycle);

      FlagValue = $root.TestTop.uAPE.uSPU.uSYN.rFlag;

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

      FlagValue = $root.TestTop.uAPE.uSPU.uSYN.rFlag;

      if(FlagValue[1] === ExpValue[1])
         $display("%0t Read SYN Flag OK @SPU_STARTEX0_PC = %h!!", $realtime, SPUSTARTPC);
      else
         $display("%0t Error @SPU_STARTEX0_PC = %h, Expected Value and Real Result are :%h ,%h\n", $realtime, SPUSTARTPC, ExpValue, FlagValue);
   endtask

`undef SPU_STARTDC_PC
`undef SPU_STARTEX0_PC
`undef MPU_DC_PC
`undef MPU_STARTDC_PC
`undef MFetchValid
`undef MPUStall
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
          wait( $root.TestTop.FPGA_Top_inst.uAPE.uSPU.oSPUStat[0]== 1'b1);
        `else
          wait( $root.TestTop.uAPE.uSPU.oSPUStat[0]== 1'b1);
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



