`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/31 13:42:05
// Design Name: 
// Module Name: uart_module
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


module uart_module #(
    parameter RTS_COUNTER = 10_000 //100us
)(
    //default
    input clk,
    input nrst,
    
    //External
    input rxd,
    output txd,
    
    //Internal rx
    output [7:0] rx_byte,
    input rx_rd_en,
    output rx_full,
    output rx_empty,
    output rx_valid,
    output [9:0] rx_dc,
    
    //Internal tx
    input [7:0] tx_byte,
    input tx_wr_en, 
    output tx_full,
    output tx_empty,
    output [9:0] tx_dc,
    
    //output for rs 485 interface
    output rts
    
//    output[7:0] rx_data
    );
    
    reg rts;
        
    wire [7:0] rx_data;
    wire [7:0] tx_data;
    wire tx_valid;
    
    tiny_uart uart(
            .R(~nrst),          // asynchrony reset
            .C(clk),          // clock, rising edge
            // serial UART Interface
            .TXD(txd),          // transmit register output (START bit, DATA bits, PARITY bit, and STOP bits);     LSB First
            .RXD(rxd),          // receive data;   LSB first
            // Parallel Interface
            .RR(rx_data),                          // Receiver Holding Register Data Output
            .PE(),                          // Parity error
            .FE(),                          // Framing error
            .DR(rx_wr_en),                          // Data Received, one clock cycle high
            .TR(tx_data),                // Transmitter Holding Register Data Input
            .THRE(thre),                        // Transmitter Holding Register Empty
            .THRL(thrl),                        // Transmitter Holding Register Load, one clock cycle high
            .TRE(tre)                          // Transmitter Register Empty
    );
    
//    wire thrl = (thre&tre) & ~tx_empty;
    
    //uart rx controller
//    localparam RX_IDLE = 0;
//    localparam RX_DATA_READY = 0;
    
//    reg [1:0] rxState = RX_IDLE;
    
//    always @(posedge(clk)) begin
//        case(rxState)
//            RX_IDLE: begin
//                if(rx_wr_en) begin
//                    rxState <= RX_DATA_READY;
                    
//                end
//            end
//        endcase
//    end
    
    localparam TX_IDLE = 0;
    localparam TX_FIFO_LOAD = 1;
    localparam TX_LOAD = 2;
    localparam TX_WAIT_DONE = 3;
    localparam TX_RTS_WAIT = 4;
    
    reg [2:0] txState = TX_IDLE;
    reg tx_rd_en = 0;
    reg thrl = 0;
    reg [31:0] rts_counter;
    
    //uart tx controller
    always @ (posedge(clk) or negedge(nrst)) begin
        if(~nrst) begin
            rts <= 1'b0;
            tx_rd_en <= 0;
            thrl <= 0;
            rts_counter <= 0;
            txState <= TX_IDLE;
        end else begin
            case(txState)
                TX_IDLE:begin
                    if((thre&tre) & (~tx_empty)) begin//tx fifo is not empty and uart tx available
                        rts <= 1'b1;    //drive enble - tx mode
//                        tx_rd_en <= 1;      //read enable
                        txState <= TX_RTS_WAIT;    //to next state
                    end else begin
                        rts <= 1'b0;//drive disable - rx mode
                        txState <= TX_IDLE;
                    end
                end
                TX_RTS_WAIT: begin
                    if(rts_counter <= RTS_COUNTER) begin
                        rts_counter <= rts_counter + 1;
                    end else begin
                        rts_counter <= 0;
                        tx_rd_en <= 1;      //read enable
                        txState <= TX_FIFO_LOAD;    //to next state
                    end
                end
                TX_FIFO_LOAD:begin
                    tx_rd_en <= 0; //read disable  
                    if (tx_valid == 1'b1) begin
                        thrl <= 1;  // load tx hold register
                        txState <= TX_LOAD;
                    end
                end
                TX_LOAD:begin
                    thrl <= 0;  //trigger down
                    txState <= TX_WAIT_DONE;    //to the next state
                end
                TX_WAIT_DONE:begin
                    if(thre&tre) begin//done
                        txState <= TX_IDLE;// to idle state
                    end else begin//not done
                        txState <= TX_WAIT_DONE; //wait
                    end
                end
                default: begin
                    txState = TX_IDLE;
                end
            endcase
        end
    end
    
    
    uart_fifo tx_fifo(
        .clk(clk),
        .srst(~nrst),
        .din(tx_byte),
        .wr_en(tx_wr_en),
        .rd_en(tx_rd_en),
        .dout(tx_data),
        .full(tx_full),
        .empty(tx_empty),
        .valid(tx_valid),
        .data_count(tx_dc)
    );
    
    uart_fifo rx_fifo(
        .clk(clk),
        .srst(~nrst),
        .din(rx_data),
        .wr_en(rx_wr_en),
        .rd_en(rx_rd_en),
        .dout(rx_byte),
        .full(rx_full),
        .empty(rx_empty),
        .valid(rx_valid),
        .data_count(rx_dc)
    );
    
endmodule
