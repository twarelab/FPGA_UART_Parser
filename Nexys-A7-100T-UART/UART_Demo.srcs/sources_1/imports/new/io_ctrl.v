`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/26 08:52:22
// Design Name: 
// Module Name: io_ctrl
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


module io_ctrl(
    input wire clk,
    input wire nrst,
    input wire [31:0] io_set,
    input wire [31:0] io_disable,
    input wire io_wr,
    output wire [31:0] io_out
    );
    
    reg [31:0] io_reg;
    assign io_out = io_reg & ~io_disable;
    
    always @(posedge(clk) or negedge(nrst)) begin
        if(~nrst) begin
            io_reg <= 32'b0;
        end else begin
            if(io_wr) begin
                io_reg <= io_set;
            end
        end
    end
    
endmodule
