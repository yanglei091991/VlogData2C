`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/21 13:39:02
// Design Name: 
// Module Name: SingleRAM_FPGA
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SingleRAM_FPGA #(parameter ADDR_WIDTH=11, DATA_WIDITH=32) (
    input clk,
    input en,
    input we,
    input [ADDR_WIDTH - 1 : 0] addr,
    input [DATA_WIDITH - 1 : 0] din,
    output  [DATA_WIDITH - 1 : 0] dout,
	input pipen
    );

localparam MEM_DEPTH = 1<<(ADDR_WIDTH);      
reg [DATA_WIDITH - 1 : 0]    memory [MEM_DEPTH - 1 : 0]; /* synthesis syn_ramstyle = "block_ram" */
reg [DATA_WIDITH - 1:0]  DataOutReg;
reg [DATA_WIDITH - 1:0]  DataOutReg1;

assign dout = pipen ? DataOutReg1 : DataOutReg;
always@(posedge clk)begin
    if(en) begin
        DataOutReg <= memory[addr];//read first
        if (we) begin
             memory[addr] <= din;
        end
    end
    else begin
        DataOutReg <=  'h0;
    end
end

always@(posedge clk)begin
	DataOutReg1 <= DataOutReg;
end

endmodule
