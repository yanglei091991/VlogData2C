//File Name: AXIInterface.sv
//Creating Date: 2012-4.9
//Creating Author: zijun.liu@ia.ac.cn
//Description: VPE external Bus interface 
//Last Commit: $Id: AXIBusIF.sv 799 2012-07-25 08:24:18Z wangt $

`timescale  1ns/1ps
interface AXIBusIF #(ID_WIDTH=4,ADDR_WIDTH=32,DATA_WITH=512) (input iSoCClk_reg);

  wire[ID_WIDTH-1:0]         AWID    ;
  wire[ADDR_WIDTH-1:0]       AWADDR  ;
  wire[2:0]                  AWSIZE  ;
  wire[3:0]                  AWLEN   ;
  wire[1:0]                  AWBURST ;
  wire[1:0]                  AWLOCK  ;
  wire                       AWVALID ;
  wire                       AWREADY ;
                                       
  wire[ID_WIDTH-1:0]         WID     ;
  wire[DATA_WITH-1:0]        WDATA   ;
  wire[DATA_WITH/8-1:0]      WSTRB   ;
  wire                       WLAST   ;
  wire                       WVALID  ;
  wire                       WREADY  ;
                                       
  wire[ID_WIDTH-1:0]         BID     ;
  wire[1:0]                  BRESP   ;
  wire                       BVALID  ;
  wire                       BREADY  ;
                                       
  wire[ID_WIDTH-1:0]         ARID    ;
  wire[ADDR_WIDTH-1:0]       ARADDR  ;
  wire[2:0]                  ARSIZE  ;
  wire[3:0]                  ARLEN   ;
  wire[1:0]                  ARBURST ;
  wire[1:0]                  ARLOCK  ;
  wire                       ARVALID ;
  wire                       ARREADY ;
                                       
  wire[ID_WIDTH-1:0]         RID     ;
  wire[DATA_WITH-1:0]        RDATA   ;
  wire[1:0]                  RRESP   ;
  wire                       RLAST   ;
  wire                       RVALID  ;
  wire                       RREADY  ;

  
  //Master  .
  modport OutPort( 
    output   AWID    ,AWADDR  , AWSIZE  ,AWLEN   ,AWBURST , AWLOCK , AWVALID , input AWREADY,
    output   WID     ,WDATA   , WSTRB   ,WLAST   ,WVALID  ,                    input WREADY,
    output   ARID    ,ARADDR  , ARSIZE  ,ARLEN   ,ARBURST , ARLOCK , ARVALID , input ARREADY,
    input    BID     ,BRESP   , BVALID  ,                                      output BREADY,
    input    RID     ,RDATA   , RRESP   ,RLAST   ,RVALID  ,                    output RREADY
    );
  //Slave.        
  modport InPort( 
    input   AWID    ,AWADDR  , AWSIZE  ,AWLEN   ,AWBURST , AWLOCK , AWVALID , output AWREADY,
    input   WID     ,WDATA   , WSTRB   ,WLAST   ,WVALID  ,                    output WREADY,
    input   ARID    ,ARADDR  , ARSIZE  ,ARLEN   ,ARBURST , ARLOCK , ARVALID , output ARREADY,
    output  BID     ,BRESP   , BVALID  ,                                      input BREADY,
    output  RID     ,RDATA   , RRESP   ,RLAST   ,RVALID  ,                    input RREADY
    );

  //translate off
  //clocling block for test.
  clocking oCB@( posedge iSoCClk_reg );
    default input #1step output #1; //sample the input @posedge, drive output 1ns later to posedge
    output   AWID    ,AWADDR  , AWSIZE  ,AWLEN   ,AWBURST , AWLOCK , AWVALID ; input AWREADY;
    output   WID     ,WDATA   , WSTRB   ,WLAST   ,WVALID  ;                    input WREADY;
    output   ARID    ,ARADDR  , ARSIZE  ,ARLEN   ,ARBURST , ARLOCK , ARVALID ; input ARREADY;
    input    BID     ,BRESP   , BVALID  ;                                      output BREADY;
    input    RID     ,RDATA   , RRESP   ,RLAST   ,RVALID  ;                    output RREADY;
  endclocking
               
  clocking iCB@( posedge iSoCClk_reg );
    default input #1step output #1;//sample the input @posedge, drive output 1ns later to posedge
    input   AWID    ,AWADDR  , AWSIZE  ,AWLEN   ,AWBURST , AWLOCK , AWVALID ; output AWREADY;
    input   WID     ,WDATA   , WSTRB   ,WLAST   ,WVALID  ;                    output WREADY;
    input   ARID    ,ARADDR  , ARSIZE  ,ARLEN   ,ARBURST , ARLOCK , ARVALID ; output ARREADY;
    output  BID     ,BRESP   , BVALID  ;                                      input BREADY;
    output  RID     ,RDATA   , RRESP   ,RLAST   ,RVALID  ;                    input RREADY;
  endclocking
 
  modport TestMaster(clocking oCB );
  modport TestSlave (clocking iCB );              
  //translate on
endinterface
