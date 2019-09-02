/*
 * ===================================================================
 *
 *        Filename:  TestTop.sv
 *
 *         Created:  2017-09-06 12:34:53 PM
 *   Last Modified:  2019-04-10 11:26:21 AM
 *          Author:  Lipeng YANG , lipeng.yang@ia.ac.cn
 *    Organization:  National ASIC Design Engineering Center, IACAS
 *
 *     Description:  Top for ape integration testbench
 *
 *
 * ===================================================================
 */
`timescale 1ns/1ps
`include "DBGDef.v"
module TestTop;

  bit CClk;
  bit iSoCClk;
  bit Rst_n;
  bit iSoCRst_n;
  bit iDbgMode;
  bit iTck;
  bit iTrst;
  bit iTdi ;
  bit iTms ;
  bit oTdo ;
  bit oRtck;

  initial begin
    `ifdef OCD_DBG
      iDbgMode = 1;
    `else
      iDbgMode = 0;
    `endif
//    CClk=1;
  end
`ifdef OCD_DBG  import "DPI" function int init_fifo_server();
  initial begin
    init_fifo_server();
//    #0 Rst_n = 0;
//    #((`SOC_CLK_PERIOD+`SPU_CLK_PERIOD)*2) Rst_n = 1;
  end
`endif
    
  AXIBusIF #(.ID_WIDTH( 7), .ADDR_WIDTH(32), .DATA_WITH(32))  iSMBus    (iSoCClk);
  AXIBusIF #(.ID_WIDTH(10), .ADDR_WIDTH(32), .DATA_WITH(32))  iExtToCSU (iSoCClk);
  AXIBusIF #(.ID_WIDTH( 1), .ADDR_WIDTH(32), .DATA_WITH(128))  iCSUToExt (iSoCClk);

  CovSampleIF iCvSmpIF(.iSoCClk  (iSoCClk), .CClk  (CClk));

  APCTest uAPCTest(
  	 .CClk		  (CClk		 ),
	 .Rst_n		  (Rst_n     ),
    .iSoCClk     (iSoCClk   ),
    .iSoCRst_n	  (iSoCRst_n ),
    
    .iSMBus      (iSMBus    ),
    .iExtToCSU   (iExtToCSU ),
    .iCSUToExt   (iCSUToExt ),

    .iCvSmpIF   (iCvSmpIF )
  );

  wire [`DBG_SEL_WIDTH -1 : 0]     Dbg_Sel          ;
  wire [`DBG_ADDR_WIDTH-1 : 0]     Dbg_Addr         ;
  wire [`DBG_DATA_WIDTH-1 : 0]     Dbg_Data         ;
  wire [`DBG_LEN_WIDTH -1 : 0]     Dbg_Len          ;
  wire [`DBG_ADDR_WIDTH-1 : 0]     Dbg_UpAddr       ;
  
  wire [`DBG_DATA_WIDTH-1 : 0]     Dbg_PCtrlRD      ;
  wire [`DBG_DATA_WIDTH-1 : 0]     Dbg_LMonRD       ;
  wire [`DBG_SEL_WIDTH -1 : 0]     Trigger_lat      ;

  wire                             Dbg_PCtrlWen     ;
  wire                             Dbg_PCtrlRen     ;
  wire                             Dbg_LMonWen      ;
  wire                             Dbg_LMonRen      ;
  wire                             Dbg_Rdy          ;

  wire                             nDSel0           ;
  wire    [`DBG_ADDR_WIDTH-1 : 0]  nDAddr0          ;
  wire    [`DBG_DATA_WIDTH-1 : 0]  nDData0          ;
  wire    [`DBG_LEN_WIDTH -1 : 0]  nDLen0           ;
  wire    [`DBG_ADDR_WIDTH-1 : 0]  nDUpAddr0        ;
  wire                             nDPCtrlWen0      ;
  wire                             nDLMonRen0       ;
  wire                             nDPCtrlRen0      ;
  wire                             nDLMonWen0       ;
  wire    [`DBG_DATA_WIDTH-1 : 0]  nDPCtrlRD0       ;
  wire    [`DBG_DATA_WIDTH-1 : 0]  nDLMonRD0        ;
  wire                             nDRdy0           ;
  wire                             nDTrigger_lat0   ;

  wire                             nDSel1           ;
  wire    [`DBG_ADDR_WIDTH-1 : 0]  nDAddr1          ;
  wire    [`DBG_DATA_WIDTH-1 : 0]  nDData1          ;
  wire    [`DBG_LEN_WIDTH -1 : 0]  nDLen1           ;
  wire    [`DBG_ADDR_WIDTH-1 : 0]  nDUpAddr1        ;
  wire                             nDPCtrlWen1      ;
  wire                             nDLMonRen1       ;
  wire                             nDPCtrlRen1      ;
  wire                             nDLMonWen1       ;
  wire    [`DBG_DATA_WIDTH-1 : 0]  nDPCtrlRD1       ;
  wire    [`DBG_DATA_WIDTH-1 : 0]  nDLMonRD1        ;
  wire                             nDRdy1           ;
  wire                             nDTrigger_lat1   ;

  wire                             nDSel2           ;
  wire    [`DBG_ADDR_WIDTH-1 : 0]  nDAddr2          ;
  wire    [`DBG_DATA_WIDTH-1 : 0]  nDData2          ;
  wire    [`DBG_LEN_WIDTH -1 : 0]  nDLen2           ;
  wire    [`DBG_ADDR_WIDTH-1 : 0]  nDUpAddr2        ;
  wire                             nDPCtrlWen2      ;
  wire                             nDLMonRen2       ;
  wire                             nDPCtrlRen2      ;
  wire                             nDLMonWen2       ;
  wire    [`DBG_DATA_WIDTH-1 : 0]  nDPCtrlRD2       ;
  wire    [`DBG_DATA_WIDTH-1 : 0]  nDLMonRD2        ;
  wire                             nDRdy2           ;
  wire                             nDTrigger_lat2   ;

  wire                             nDSel3           ;
  wire    [`DBG_ADDR_WIDTH-1 : 0]  nDAddr3          ;
  wire    [`DBG_DATA_WIDTH-1 : 0]  nDData3          ;
  wire    [`DBG_LEN_WIDTH -1 : 0]  nDLen3           ;
  wire    [`DBG_ADDR_WIDTH-1 : 0]  nDUpAddr3        ;
  wire                             nDPCtrlWen3      ;
  wire                             nDLMonRen3       ;
  wire                             nDPCtrlRen3      ;
  wire                             nDLMonWen3       ;
  wire    [`DBG_DATA_WIDTH-1 : 0]  nDPCtrlRD3       ;
  wire    [`DBG_DATA_WIDTH-1 : 0]  nDLMonRD3        ;
  wire                             nDRdy3           ;
  wire                             nDTrigger_lat3   ;

  RFM uRFM(
    .CClk	          (CClk        	        ), 
	 .Rst_n				 (Rst_n					  ), 
    .iSoCClk          (iSoCClk              ), 
    .iSoCRst_n        (iSoCRst_n   		     ), 
    .iDbgMode         (iDbgMode             ), 

    .iARMIntReq       (8'h0                 ), 
    .oARMIntReq       (                     ), 

    .oSMAWADDR        (iSMBus.AWADDR        ), 
    .oSMAWSIZE        (iSMBus.AWSIZE        ), 
    .oSMAWLEN         (iSMBus.AWLEN         ), 
    .oSMAWBURST       (iSMBus.AWBURST       ), 
    .oSMAWLOCK        (iSMBus.AWLOCK        ), 
    .oSMAWVALID       (iSMBus.AWVALID       ), 
    .iSMAWREADY       (iSMBus.AWREADY       ), 

    .oSMWDATA         (iSMBus.WDATA         ), 
    .oSMWSTRB         (iSMBus.WSTRB         ), 
    .oSMWLAST         (iSMBus.WLAST         ), 
    .oSMWVALID        (iSMBus.WVALID        ), 
    .iSMWREADY        (iSMBus.WREADY        ), 

    .iSMBRESP         (iSMBus.BRESP         ), 
    .iSMBVALID        (iSMBus.BVALID        ), 
    .oSMBREADY        (iSMBus.BREADY        ), 

    .oSMARADDR        (iSMBus.ARADDR        ), 
    .oSMARSIZE        (iSMBus.ARSIZE        ), 
    .oSMARLEN         (iSMBus.ARLEN         ), 
    .oSMARBURST       (iSMBus.ARBURST       ), 
    .oSMARLOCK        (iSMBus.ARLOCK        ), 
    .oSMARVALID       (iSMBus.ARVALID       ), 
    .iSMARREADY       (iSMBus.ARREADY       ), 

    .iSMRDATA         (iSMBus.RDATA         ), 
    .iSMRRESP         (iSMBus.RRESP         ), 
    .iSMRLAST         (iSMBus.RLAST         ), 
    .iSMRVALID        (iSMBus.RVALID        ), 
    .oSMRREADY        (iSMBus.RREADY        ), 

    .iExt2CSUAWID     (iExtToCSU.AWID       ), 
    .iExt2CSUAWADDR   (iExtToCSU.AWADDR     ), 
    .iExt2CSUAWSIZE   (iExtToCSU.AWSIZE     ), 
    .iExt2CSUAWLEN    (iExtToCSU.AWLEN      ), 
    .iExt2CSUAWBURST  (iExtToCSU.AWBURST    ), 
    .iExt2CSUAWLOCK   (iExtToCSU.AWLOCK     ), 
    .iExt2CSUAWVALID  (iExtToCSU.AWVALID    ), 
    .oExt2CSUAWREADY  (iExtToCSU.AWREADY    ), 
                                          
    .iExt2CSUWID      (iExtToCSU.WID        ), 
    .iExt2CSUWDATA    (iExtToCSU.WDATA      ), 
    .iExt2CSUWSTRB    (iExtToCSU.WSTRB      ), 
    .iExt2CSUWLAST    (iExtToCSU.WLAST      ), 
    .iExt2CSUWVALID   (iExtToCSU.WVALID     ), 
    .oExt2CSUWREADY   (iExtToCSU.WREADY     ), 
                                          
    .oExt2CSUBID      (iExtToCSU.BID        ), 
    .oExt2CSUBRESP    (iExtToCSU.BRESP      ), 
    .oExt2CSUBVALID   (iExtToCSU.BVALID     ), 
    .iExt2CSUBREADY   (iExtToCSU.BREADY     ), 
                                          
    .iExt2CSUARID     (iExtToCSU.ARID       ), 
    .iExt2CSUARADDR   (iExtToCSU.ARADDR     ), 
    .iExt2CSUARSIZE   (iExtToCSU.ARSIZE     ), 
    .iExt2CSUARLEN    (iExtToCSU.ARLEN      ), 
    .iExt2CSUARBURST  (iExtToCSU.ARBURST    ), 
    .iExt2CSUARLOCK   (iExtToCSU.ARLOCK     ), 
    .iExt2CSUARVALID  (iExtToCSU.ARVALID    ), 
    .oExt2CSUARREADY  (iExtToCSU.ARREADY    ), 
                                          
    .oExt2CSURID      (iExtToCSU.RID        ), 
    .oExt2CSURDATA    (iExtToCSU.RDATA      ), 
    .oExt2CSURRESP    (iExtToCSU.RRESP      ), 
    .oExt2CSURLAST    (iExtToCSU.RLAST      ), 
    .oExt2CSURVALID   (iExtToCSU.RVALID     ), 
    .iExt2CSURREADY   (iExtToCSU.RREADY     ), 

    .oCSU2Ext0AWID     (iCSUToExt.AWID       ), 
    .oCSU2Ext0AWADDR   (iCSUToExt.AWADDR     ), 
    .oCSU2Ext0AWSIZE   (iCSUToExt.AWSIZE     ), 
    .oCSU2Ext0AWLEN    (iCSUToExt.AWLEN      ), 
    .oCSU2Ext0AWBURST  (iCSUToExt.AWBURST    ), 
    .oCSU2Ext0AWLOCK   (iCSUToExt.AWLOCK     ), 
    .oCSU2Ext0AWVALID  (iCSUToExt.AWVALID    ), 
    .iCSU2Ext0AWREADY  (iCSUToExt.AWREADY    ), 

    .oCSU2Ext0WID      (iCSUToExt.WID        ), 
    .oCSU2Ext0WDATA    (iCSUToExt.WDATA      ), 
    .oCSU2Ext0WSTRB    (iCSUToExt.WSTRB      ), 
    .oCSU2Ext0WLAST    (iCSUToExt.WLAST      ), 
    .oCSU2Ext0WVALID   (iCSUToExt.WVALID     ), 
    .iCSU2Ext0WREADY   (iCSUToExt.WREADY     ), 

    .iCSU2Ext0BID      (iCSUToExt.BID        ), 
    .iCSU2Ext0BRESP    (iCSUToExt.BRESP      ), 
    .iCSU2Ext0BVALID   (iCSUToExt.BVALID     ), 
    .oCSU2Ext0BREADY   (iCSUToExt.BREADY     ), 

    .oCSU2Ext0ARID     (iCSUToExt.ARID       ), 
    .oCSU2Ext0ARADDR   (iCSUToExt.ARADDR     ), 
    .oCSU2Ext0ARSIZE   (iCSUToExt.ARSIZE     ), 
    .oCSU2Ext0ARLEN    (iCSUToExt.ARLEN      ), 
    .oCSU2Ext0ARBURST  (iCSUToExt.ARBURST    ), 
    .oCSU2Ext0ARLOCK   (iCSUToExt.ARLOCK     ), 
    .oCSU2Ext0ARVALID  (iCSUToExt.ARVALID    ), 
    .iCSU2Ext0ARREADY  (iCSUToExt.ARREADY    ), 

    .iCSU2Ext0RID      (iCSUToExt.RID        ), 
    .iCSU2Ext0RDATA    (iCSUToExt.RDATA      ), 
    .iCSU2Ext0RRESP    (iCSUToExt.RRESP      ), 
    .iCSU2Ext0RLAST    (iCSUToExt.RLAST      ), 
    .iCSU2Ext0RVALID   (iCSUToExt.RVALID     ), 
    .oCSU2Ext0RREADY   (iCSUToExt.RREADY     ), 

    .iDSel            (nDSel0               ), 
    .iDAddr           (nDAddr0              ), 
    .iDData           (nDData0              ), 
    .iDLen            (nDLen0               ), 
    .iDUpAddr         (nDUpAddr0            ), 
    .iDPCtrlWen       (nDPCtrlWen0          ), 
    .iDLMonRen        (nDLMonRen0           ), 
    .iDPCtrlRen       (nDPCtrlRen0          ), 
    .iDLMonWen        (nDLMonWen0           ), 
    .oDPCtrlRD        (nDPCtrlRD0           ), 
    .oDLMonRD         (nDLMonRD0            ), 
    .oDRdy            (nDRdy0               ),  
    .oDTrigger_lat    (nDTrigger_lat0       )  
  );

  DBBus uDBBus(
    .oPCtrlRD           (Dbg_PCtrlRD          ),  
    .oLMonRD            (Dbg_LMonRD           ),  
    .oRdy               (Dbg_Rdy              ),  
    .oTrigger_lat       (Trigger_lat          ),
    .iSel               (Dbg_Sel              ),  
    .iAddr              (Dbg_Addr             ),  
    .iData              (Dbg_Data             ),  
    .iLen               (Dbg_Len              ),  
    .iUpAddr            (Dbg_UpAddr           ),  
    .iPCtrlWen          (Dbg_PCtrlWen         ),  
    .iPCtrlRen          (Dbg_PCtrlRen         ),  
    .iLMonWen           (Dbg_LMonWen          ),  
    .iLMonRen           (Dbg_LMonRen          ),  

    .iPCtrlRD0          (nDPCtrlRD0           ),
    .iLMonRD0           (nDLMonRD0            ),
    .iRdy0              (nDRdy0               ),
    .iTrigger_lat0      (nDTrigger_lat0       ),
    .oSel0              (nDSel0               ),
    .oAddr0             (nDAddr0              ),
    .oData0             (nDData0              ),
    .oLen0              (nDLen0               ),
    .oUpAddr0           (nDUpAddr0            ),
    .oPCtrlWen0         (nDPCtrlWen0          ),
    .oPCtrlRen0         (nDPCtrlRen0          ),
    .oLMonWen0          (nDLMonWen0           ),
    .oLMonRen0          (nDLMonRen0           ),

    .iPCtrlRD1          (32'b0                ),
    .iLMonRD1           (32'b0                ),
    .iRdy1              (1'b0                 ),
    .iTrigger_lat1      (1'b0                 ),
    .oSel1              (nDSel1               ),
    .oAddr1             (nDAddr1              ),
    .oData1             (nDData1              ),
    .oLen1              (nDLen1               ),
    .oUpAddr1           (nDUpAddr1            ),
    .oPCtrlWen1         (nDPCtrlWen1          ),
    .oPCtrlRen1         (nDPCtrlRen1          ),
    .oLMonWen1          (nDLMonWen1           ),
    .oLMonRen1          (nDLMonRen1           ),

    .iPCtrlRD2          (32'b0                ),
    .iLMonRD2           (32'b0                ),
    .iRdy2              (1'b0                 ),
    .iTrigger_lat2      (1'b0                 ),
    .oSel2              (nDSel2               ),
    .oAddr2             (nDAddr2              ),
    .oData2             (nDData2              ),
    .oLen2              (nDLen2               ),
    .oUpAddr2           (nDUpAddr2            ),
    .oPCtrlWen2         (nDPCtrlWen2          ),
    .oPCtrlRen2         (nDPCtrlRen2          ),
    .oLMonWen2          (nDLMonWen2           ),
    .oLMonRen2          (nDLMonRen2           ),

    .iPCtrlRD3          (32'b0                ),
    .iLMonRD3           (32'b0                ),
    .iRdy3              (1'b0                 ),
    .iTrigger_lat3      (1'b0                 ),
    .oSel3              (nDSel3               ),
    .oAddr3             (nDAddr3              ),
    .oData3             (nDData3              ),
    .oLen3              (nDLen3               ),
    .oUpAddr3           (nDUpAddr3            ),
    .oPCtrlWen3         (nDPCtrlWen3          ),
    .oPCtrlRen3         (nDPCtrlRen3          ),
    .oLMonWen3          (nDLMonWen3           ),
    .oLMonRen3          (nDLMonRen3           )
  );

  DAP uDAP(
    .iTck							  (iTck	            ),
    .iTrst						  (iTrst            ),
    .iTdi							  (iTdi	            ),
    .iTms							  (iTms	            ), 
    .oTdo							  (oTdo	            ),
    .oRtck						  (oRtck            ),
    .iMainClk					  (iSoCClk          ),
    .iMainRst_n				  (Rst_n       ),

    .iPCtrlRD					  (Dbg_PCtrlRD		  ),	
    .iLMonRD					  (Dbg_LMonRD			  ),
    .iRdy							  (Dbg_Rdy				  ),	
    .iTrigger_lat			  (Trigger_lat	    ),
    .oSel							  (Dbg_Sel				  ),	
    .oAddr						  (Dbg_Addr				  ),
    .oData						  (Dbg_Data				  ),
    .oLen							  (Dbg_Len				  ),	
    .oUpAddr					  (Dbg_UpAddr			  ),
    .oPCtrlWen				  (Dbg_PCtrlWen		  ),
    .oPCtrlRen				  (Dbg_PCtrlRen		  ),
    .oLMonWen					  (Dbg_LMonWen		  ),	
    .oLMonRen           (Dbg_LMonRen      ) 
  );

  initial begin
    CClk = 0;
    iSoCClk = 0;
    Rst_n = 0;
    iSoCRst_n = 0;

    $timeformat(-9, 1, "ns", 10);
  end

  initial forever #357ps     CClk = ~CClk;	    // 1.4G
  initial forever #1000ps    iSoCClk = ~iSoCClk;

  `ifdef  DUMP_WAVES
    initial begin
      $vcdpluson;
      $vcdplusmemon;
    end
  `endif

  `ifdef  DUMP_SAIF
    initial begin
      $set_gate_level_monitoring("on", "mda");
      $set_toggle_region(TestTop.uAPE);

      wait (TestTop.uAPE.uSPU.uSEQ.oSPUStopEn === 1'b1);
      @(CClk iff(TestTop.uAPE.uSPU.uSEQ.oSPUStopEn === 1'b0));

      $toggle_start;

      wait (TestTop.uAPE.uSPU.uSEQ.oSPUStopEn === 1'b0);
      @(CClk iff((TestTop.uAPE.uSPU.uSEQ.oSPUStopEn === 1'b1) && (TestTop.uAPE.uMPU.uMFetch.oMPUStopStall === 1'b1)));

      $toggle_stop;
      $toggle_report("APE.saif", 1e-09, TestTop.uAPE);
    end
  `endif

endmodule
