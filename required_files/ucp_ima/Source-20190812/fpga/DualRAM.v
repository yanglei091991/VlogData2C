`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/21 19:01:33
// Design Name: 
// Module Name: DualRAM_FPGA
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

module DualRAM_FPGA#(parameter DATA_WIDITH=32) (
    input clka,
    input ena,
    input wea,
    input [5:0] addra,
    input [DATA_WIDITH-1 : 0] dina,
    input clkb,
    input enb,
    input [5:0] addrb,
    output [DATA_WIDITH-1 : 0] doutb
    );

localparam MEM_DEPTH = 1<<6;      
reg [DATA_WIDITH - 1 : 0]    memory [MEM_DEPTH - 1 : 0]; /* synthesis syn_ramstyle = "block_ram" */
reg [DATA_WIDITH - 1:0]  DataOutReg;
    
    assign doutb = DataOutReg;//
    always@(posedge clka)begin
        if(ena) begin
            if (wea) begin
                 memory[addra] <= dina;
            end
        end
    end
    
    always@(posedge clkb)begin
        if(enb) begin
            DataOutReg <= memory[addrb];//read first
        end
        /*dout data hold*/
        //else begin
            //DataOutReg <=  'h0;
        //end
    end    

endmodule
