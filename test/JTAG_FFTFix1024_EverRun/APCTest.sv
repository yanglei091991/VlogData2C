//File Name    :  APCTest.sv
//Creating Date:  2014-01-20
//Author       :  tao.wang@ia.ac.cn
//Description  :  The TestCase the Test the System Start/Stop
//Last Commit  :  $Id: APCTest.sv 1385 2012-12-06 04:50:55Z yinlz $
program APCTest(

  input  bit              iSPUClk,          //The SPU Clock
  input  bit              iSoCClk,          //The SoC Clock
  input  bit              iMainRst_n,       //The SoC Reset

  AXIBusIF.TestSlave      iSMBus0,           //The SM Bus port.
  AXIBusIF.TestMaster     iExtToCSU0,        //The ExtToCSU port.
  AXIBusIF.TestSlave      iCSU0ToExt,        //The CSU Master to CBus.

  AXIBusIF.TestSlave      iSMBus1,           //The SM Bus port.
  AXIBusIF.TestMaster     iExtToCSU1,        //The ExtToCSU port.
  AXIBusIF.TestSlave      iCSU1ToExt,        //The CSU Master to CBus.
  CovSampleIF             iCvSmpIF           //The interface for coverpoint
);

  `include "TestLib.sv"
  `include "SPUDef.v"
  `include "MPUDef.v"
  `include "MACCDef.v" 
  `include "APEDef.v"

  localparam  DDRSize =32'h400000;

  `define EX1_PC  $root.TestTop.uAPC.uAPE0.uMPU.uMFetch.nMIAddr
  // Virtual Componets of MaPU
  ARM                                               hARM;    // [Optional]
  ShareMem #(.BASE(32'h7000000),.SIZE(32'h20000))   hSM;     // [Optional]
  DDR      #(.BASE(`DDR_ADDR_BASE),.SIZE(DDRSize))  hDDR;    // [Optional]

  // Verification Componets of APC
  Environment  cEnv;
  Monitor      Mon;
  integer i       ;
  bit[511:0]   Temp;
  
  integer HandSDA0DM0,HandSDA0DM1,HandSDA1DM0,HandSDA1DM1,HandSDA2DM0,HandSDA2DM1;
  integer    RealData ;
  bit[31:0]  Real,Image, RealTemp, ImageTemp  ;
  parameter DM_LENGTH = 18 ;
  
  initial begin
    cEnv =new();
    Mon  =new();
    `ifdef PLATFORM_Net
      #10;
    `endif
    // Initilize the APE0 Memory: IM and MIMX and MIMY
    APE0InitInstrMem();
    APE0InitDataMem();

    ResetAndStartSPU();        //Start the SPU
    //$display("====================================");   // 288 ns
    `ifndef PLATFORM_Net 
     fork
       // Run the Verification Environment
       cEnv.run();
       // Run the performance counter.
       Profile("FloatFFT64",2);
     join_none
     
    // initialize the M RegFile
    // for Sim version, write the MBankData; for SYN version, write the single reg
    fork
       for(i=0; i<128; i++)  Mon.M_Write(i,i);     
    join_none
    `endif
     
    // initialize the M RegFile
    // for Sim version, write the MBankData; for SYN version, write the single reg
    //fork
    //  for(i=0; i<128; i++)  Mon.M_Write(i,i);     
    //join_none
    // add your code here
    #100; 
  
    $display("====================================");  
    //CheckFixFFTResult(32'h28ae/41,32'h4,32'h0,32'h4,"Ep0StdRes.dat",32'd1024); 
    CheckFixFFTResult(32'h4e7a/41,32'h0,32'h1,32'h4,"Ep1StdRes.dat",32'd1024);   
    CheckFixFFTResult(32'h6256/41,32'h4,32'h2,32'h2,"Ep2StdRes.dat",32'd1024); 
    #1 ;  
   
       
    // count the coverage of the CoverGroup
    //cEnv.wrap_up();

    `ifdef SAIF_GEN
      $toggle_stop;
      $toggle_report("FFTFix1024.saif", 1e-12, "$root.TestTop.uAPC.uAPE0");    
    `endif 
    
  end

 ///////////////////////////////////////////////
  //Chechk the regisiter value. 
  `ifdef PLATFORM_Net 
    `define APE_STAT  $root.TestTop.uAPC.uAPE0.uCSU.iAPEStat[0]
  `else  
    `define EX1_PC  $root.TestTop.uAPC.uAPE0.uMPU.uMFetch.nMIAddr
  `endif
  // `define Debug  1
   
   task automatic CheckFixFFTResult(
                                 input int PC,               // the current Algorithm instruction's address  
                                 input int SDANumber,        // the Destination SDA
                                 input int EpochNum,         // the epoch number
                                 input int StageNum,         // the stage number in the epoch
                                 input string StdResultAddr, // the result standard result address
                                 input int Length            // the Result Length   
                                 );  
                                 
     /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //In every data format, the SDA is organized as the following.
    //     Format        Width             BankSize
    //      Byte          1              0x40000/64=0x1000
    //      Short         2              0x40000/32=0x2000
    //      Word          4              0x40000/16=0x4000
    //      Double        8              0x40000/8 =0x8000
    //
    // In float FFT, a complex data is Double word format with both the real and image part are word.
    // To balanced float FFT, the SDA is divided into 8 Banks.
    // To unbalanced float FFT in the last epoch, the Bank numbers is related to the stage number,
    // BankNum = 8/(2^(4 - StageNum))
    //
    //The FFT result is stored in the SDA in projection mode.
    //The Vector data in the SDA stored in projection mode is address by the vector index i
    //Addr = StartAddr + BankIndex*BankSize + BankOffset * Width
    //     = StartAddr + (i%BankNum)*BankSize + (i/BankNum)*Width
    //     = StartAddr + (i%(64/Width))*BankSize + (i/(64/Width))*Width
    //
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
       
    
    int     i   ;                   // index for length 
    int     Addr;                   // Address for the FFT result in SDA       
    int     error = 0   ;    
    int     BankNum     ; 
    int     SDASize     ;
    int     BankSize    ;    
    int     Width       ;    
    
    int     BankIndex   ;   // Index of the Bank
    int     BankOffset  ;   // Offset in Bank
    
    int unsigned RealDiff = 0    ;
    int unsigned ImageDiff= 0    ;       
    byte        StdResult[] ;                 // read the Standard FFT result from input file
    
    byte        DMResult[]     = new[4];       // read the FFT result from DM    
    shortint         DMReal,DMImage      ;          // the real and image part of FFT result in DM
    shortint         StdReal,StdImage    ;          // the real and image part of FFT result in input file
    
    ////////////////////////////////////////////////////////////////   
    // for debug
    integer HandResult ; 
    `ifdef Debug	 
        HandResult = $fopen("./out.dat");  
    `endif
    //  
    ////////////////////////////////////////////////////////////////

    $readmemh(StdResultAddr,StdResult);     
                 
    `ifdef PLATFORM_Net 
      #100 ;
      wait(`APE_STAT == 0);
    `else
      wait(`EX1_PC == PC );
    `endif 

      BankNum    = (16 >> (4 - StageNum)); 
      SDASize    = 32'h40000             ;
      BankSize   = SDASize / BankNum     ;    
      Width      = 4                     ;         
    
    for(i=0; i<Length; i++) begin
      //get the BankIndex and BankOffset according the StageNum  
       case(StageNum) 
        32'd4 : begin
          BankIndex  = i[3:0]   ;
          BankOffset = i[31:4]  ;
        end

        32'd3 : begin
          BankIndex  = i[3:1]   ;
          BankOffset = i[31:4] *2 +i[0] ;
        end
        
        32'd2 : begin
          BankIndex  = i[3:2];
          BankOffset = i[31:4]*4 + i[1:0] ;
        end
        
        32'd1 : begin
          BankIndex  = i[3] ;
          BankOffset = i[31:4] *8 + i[2:0] ;
        end
        
        default: $display("StageNum error.");
      endcase        
    
      Addr = BankIndex*BankSize + BankOffset* Width ;      
      
      `ifdef PLATFORM_Net 
        case(SDANumber)
          3'd0 :  APE0SDA0DM0ReadBytes(Addr,DMResult) ;
          3'd1 :  APE0SDA0DM1ReadBytes(Addr,DMResult) ;
          3'd2 :  APE0SDA1DM0ReadBytes(Addr,DMResult) ;
          3'd3 :  APE0SDA1DM1ReadBytes(Addr,DMResult) ;
          3'd4 :  APE0SDA2DM0ReadBytes(Addr,DMResult) ;
          3'd5 :  APE0SDA2DM1ReadBytes(Addr,DMResult) ;
          default : $display("Destination SDA error");
        endcase  
      `else
        case(SDANumber)
          3'd0 :  TestTop.uAPC.uAPE0.uSDA0DM0.DMReadBytes(Addr,DMResult) ;
          3'd1 :  TestTop.uAPC.uAPE0.uSDA0DM1.DMReadBytes(Addr,DMResult) ;
          3'd2 :  TestTop.uAPC.uAPE0.uSDA1DM0.DMReadBytes(Addr,DMResult) ;
          3'd3 :  TestTop.uAPC.uAPE0.uSDA1DM1.DMReadBytes(Addr,DMResult) ;
          3'd4 :  TestTop.uAPC.uAPE0.uSDA2DM0.DMReadBytes(Addr,DMResult) ;
          3'd5 :  TestTop.uAPC.uAPE0.uSDA2DM1.DMReadBytes(Addr,DMResult) ;
          default : $display("Destination SDA error");
        endcase 
      `endif    
            
      //read the real and image part of FFT result in DM
      DMReal  = {DMResult[1],DMResult[0]};
      DMImage = {DMResult[3],DMResult[2]};
      
      //read the real and image part of standard result in inpu file      
      StdReal       = {StdResult[4*i+1],StdResult[4*i+0]};
      StdImage      = {StdResult[4*i+3],StdResult[4*i+2]};
           
      RealDiff = (DMReal-StdReal)*(DMReal-StdReal)     ;
      ImageDiff= (DMImage -StdImage) * (DMImage -StdImage)  ; 

      //////////////////////////////////////////////////////////////////////////////////////////////////////////////
      //check the FFT result
      `ifdef Debug
          $fdisplay(HandResult,"i=%d,Addr=%h,StdResult=%h,%h \n\
                            DMResult =%h,%h",i,Addr,StdReal,StdImage,DMReal,DMImage);
      `endif
     
      //////////////////////////////////////////////////////////////////////////////////////////////////////////////
      if((RealDiff >4096) || (ImageDiff >4096))  begin
        error = 1 ;
        $display("----------------------------------------------------------------");
        $display("Attention:error");
        $display("@PC=%h,index=%h,Addr=%h,Fix FFT failed,StdResult=%h,%h,DMResult=%h,%h",PC,i,Addr,StdImage,StdReal,DMImage,DMReal);
        //break ;
      end
    end    
    
    if(error == 0) $display("%d points Fix FFT test at Epoch=%0h Passed",Length,EpochNum);  

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // for debug
    `ifdef debug
        $fclose(HandResult);
    `endif
    //
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
  endtask   
 
  `undef EX1_PC
endprogram
