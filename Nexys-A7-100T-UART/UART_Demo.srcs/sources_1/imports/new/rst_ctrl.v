`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/26 10:18:36
// Design Name: 
// Module Name: rst_ctrl
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


module rst_ctrl(
    input wire clk,
    input wire nrst,
    output reg sys_rst_n
    );
    
    localparam S_RST_IDLE = 0;
    localparam S_RST_START_DELAY = 1;
    localparam S_RST_ASSERT = 2;
    
    reg [1:0] rst_state = S_RST_IDLE;
    reg [31:0] rst_delay_counter = 0;
    reg [31:0] rst_assert_counter = 0;
    
    reg [31:0] por_counter = 0;
    reg por_rst = 0;
    
    wire main_rst;
    assign main_rst = por_rst & nrst;
    
    always @ (posedge(clk)) begin
        if(por_counter < 100_000) begin//1ms max
            por_counter <= por_counter + 1;
            por_rst <= 0;
        end else begin
            por_rst <= 1;
        end
    end
    
    always @ (posedge(clk) or negedge(main_rst)) begin
        if(~main_rst) begin
            rst_state = S_RST_START_DELAY;
            rst_delay_counter <= 0;
            rst_assert_counter <= 0;
            sys_rst_n <= 1'b1;
        end else begin
            case(rst_state)
                S_RST_IDLE: begin
                    sys_rst_n <= 1'b1;
                    rst_delay_counter <= 0;
                    rst_assert_counter <= 0;
                end
                S_RST_START_DELAY: begin //wait for 1ms
                    if(rst_delay_counter == 100_000) begin 
                        rst_state <= S_RST_ASSERT;
                        sys_rst_n <= 1'b0;//assert system reset
                    end else begin
                        rst_delay_counter <= rst_delay_counter + 1;
                        rst_state <= S_RST_START_DELAY;
                    end 
                end
                
                S_RST_ASSERT: begin //wait for 1ms with reset assert state
                    if(rst_assert_counter == 100_000) begin
                        rst_state <= S_RST_IDLE;
                        sys_rst_n <= 1'b1;//deassert system reset
                    end else begin
                       rst_assert_counter <= rst_assert_counter + 1;
                       rst_state <= S_RST_ASSERT;
                    end
                end
            endcase
        end
    end
endmodule
