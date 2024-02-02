`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/02 13:45:48
// Design Name: 
// Module Name: cmd_parser
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


module cmd_parser(
        input clk,
        input nrst,
        
        //rx
        input [7:0] rx_byte,
        output reg rx_rd_en,
        input rx_full,
        input rx_empty,
        input rx_valid,
        input [9:0] rx_dc,
        
        output reg [7:0] tx_byte,
        output reg tx_wr_en, 
        input tx_full,
        input tx_empty,
        input [9:0] tx_dc,
    
        output wire [15:0] debug
    );
    
    reg [31:0] time_counter;
    reg [3:0] timer_state;
    reg time_out;

    localparam TIMER_IDLE = 0;
    localparam TIMER_COUNT = 1;
    
    assign debug[2:0] = main_state[2:0];
    //timer
    always @ (posedge(clk) or negedge(nrst)) begin
        if(~nrst) begin
            time_counter <= 0;
            time_out <= 1'b1;
        end else begin
            case(timer_state)
                TIMER_IDLE: begin
                    if(~rx_empty) begin
                        time_out <= 1'b0;
                        timer_state <= TIMER_COUNT;
                    end
                end
                TIMER_COUNT: begin
                    if(time_counter <= 100_000_001) begin // 0.1 sec
                        time_counter <= time_counter + 1'b1;
                    end else begin
                        time_out <= 1'b1;
                        time_counter <= 0;
                        timer_state <= TIMER_IDLE;
                    end
                end
            endcase
        end
    end
    
    reg [3:0] main_state;
    reg [7:0] checksum_calculated;
    reg [7:0] checksum_received;
    reg [7:0] buffer [128:0];
    reg [15:0] buffer_counter;

    localparam MAIN_INIT = 0;
    localparam MAIN_IDLE = 1;
    localparam MAIN_RECV = 2;
    localparam MAIN_DO_SOMETHING = 3;
    localparam MAIN_SEND_SOMETHING = 4;
    

    always @ (posedge(clk) or negedge(nrst)) begin
        if(~nrst) begin
            main_state <= MAIN_INIT;
            checksum_calculated <= 0;
            checksum_received <= 0;
            buffer_counter <= 0;
        end else begin
            case(main_state)
                MAIN_INIT: begin
                    main_state <= MAIN_IDLE;
                end
                MAIN_IDLE: begin
                    if(~rx_empty) begin
                        rx_rd_en <= 1'b1;//read enable
                        main_state <= MAIN_RECV;
                    end
                end
                MAIN_RECV: begin
                    //read rx_byte
                    if(rx_valid) begin
                        buffer[buffer_counter] = rx_byte;
                        checksum_calculated <= checksum_calculated + rx_byte;
                        buffer_counter <= buffer_counter + 1'b1;
                    end else begin
                        if(time_out) begin//there is no data
                            main_state <= MAIN_DO_SOMETHING;
                            rx_rd_en <= 1'b0;
                            checksum_received <= buffer[buffer_counter];
                        end
                    end
                end
                MAIN_DO_SOMETHING: begin
                    if (time_out) begin 
                        main_state <= MAIN_SEND_SOMETHING;
                    end
                end
                MAIN_SEND_SOMETHING: begin
                    if(buffer_counter > 0) begin
                        tx_wr_en <= 1'b1;
                        tx_byte <= buffer[buffer_counter - 1];
                        buffer_counter <= buffer_counter - 1'b1;
                    end else begin
                        tx_wr_en <= 1'b0;
                        main_state <= MAIN_IDLE;
                    end
                end
            endcase            
        end
    end
    

    
endmodule
