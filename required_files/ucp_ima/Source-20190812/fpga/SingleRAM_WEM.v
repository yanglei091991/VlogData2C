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


module SingleRAM_WEM_FPGA #(parameter ADDR_WIDTH=11, DATA_WIDITH=32) (
    input clk,
    input en,
    input we,
    input [DATA_WIDITH/8 - 1:0] wem, 
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
        DataOutReg <= memory[addr];//write first
    end
    else begin
        DataOutReg <=  'h0;
    end
end

always@(posedge clk)begin
	DataOutReg1 <= DataOutReg;
end

genvar i ;
generate
	for (i = 0;i < DATA_WIDITH/8;i = i+1) begin
		always@(posedge clk)begin
			if(en&&we) begin
				if(wem[i])begin
					memory[addr][8*i+:8] <= din[8*i+:8];
				end
			end
		end
	end
endgenerate

endmodule
