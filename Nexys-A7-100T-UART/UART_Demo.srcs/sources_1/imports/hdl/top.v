// Company: twareLAB Co.,Ltd.
// Engineer: Peter, BJ
// 
// Create Date: 02/02/2024 
// Design Name: XADCdemo
// Module Name: XADCdemo 
// Target Devices: Nexys-A7-100T
// Tool Versions: Vivado 2021.1
// Description: Top level design for UART loopback of Nexys FPGA
// 
// Dependencies: 
// 
// Revision: 
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//MIT License

//Copyright (c) 2017 Digilent

//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:

//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.

//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.
//////////////////////////////////////////////////////////////////////////////////
//
// Purpose: This project is a Vivado demo used for reading voltage levels between 0 and 1 Volt are read of the JXADC header
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module UARTdemo(
    input CLK100MHZ,
    output[3:1] JC,
    input [1:0] sw,
    output [15:0] LED,
    
    input RXD,
    output TXD,
    
    output LED16_B,
    output LED17_R,
    input CPU_RESETN,
    input BTNC,
    input BTNU
);
    
    wire enable;
    wire ready;
    wire [15:0] adc_ctrl_data;
    wire [5:0] adc_ctrl_addr;
    reg [6:0] Address_in;
    reg [32:0] decimal;
    reg [11:0] decimal_reg_in;
    reg [3:0] dig0;
    reg [3:0] dig1;
    reg [3:0] dig2;
    reg [3:0] dig3;
    reg [3:0] dig4;
    reg [3:0] dig5;
    reg [3:0] dig6;
    parameter COUNTER_WIDTH = 32;
    reg [COUNTER_WIDTH-1:0] count = {COUNTER_WIDTH{1'b0}};
    
    wire rst_n, sys_rst_n;
    wire LED16_B, LED17_R;
    assign LED16_B = sys_rst_n;
    
    rst_ctrl rst_ctrl_inst (
        .clk(CLK100MHZ),
        .nrst(CPU_RESETN),
        .sys_rst_n(sys_rst_n)
    );
    
    wire [7:0] tx_byte;
    wire [7:0] rx_byte;
    
    //460800 bps
    uart_module uart_inst (
        //default
        .clk(CLK100MHZ),
        .nrst(sys_rst_n),
        
        //External
        .rxd(RXD),
        .txd(TXD),
        
        //Internal rx
        .rx_byte(rx_byte),
        .rx_rd_en(rx_rd_en),
        .rx_full(),
        .rx_empty(rx_empty),
        .rx_valid(rx_valid),
        .rx_dc(),
        
        //Internal tx
        .tx_byte(tx_byte),
        .tx_wr_en(tx_wr_en),
        .tx_full(tx_full),
        .tx_empty(),
        .tx_dc(),
        .rts(RTS)
    
//    .rx_data(LED[15:8])
    );
    

    // wire cmd_valid;
    // wire [(5*8)-1:0] cmd_apdu;
    // wire [(14*8)-1:0] cmd_apsm1;
    // wire [(14*3*8)-1:0] cmd_apsm2;
    // wire [(20*8)-1:0] cmd_cpsm;

    wire arbiter_req;
    reg arbiter_grant = 1'b1;
    wire ext_wen;
    wire [15:0] ext_addr;
    wire [7:0] ext_data;
    wire ext_rst;
    wire [31:0] ext_io_set;
    wire [31:0] ext_io_disable;
    wire ext_io_wr;

    cmd_parser cmd_parset_inst(
        .clk(CLK100MHZ),
        .nrst(sys_rst_n),
        
        //rx
        .uart_rx_byte(rx_byte),
        .uart_rx_rd_en(rx_rd_en),
        .uart_rx_full(),
        .uart_rx_empty(rx_empty),
        .uart_rx_valid(rx_valid),
        .uart_rx_dc(),
        
        .tx_byte(tx_byte),
        .tx_wr_en(tx_wr_en), 
        .tx_full(),
        .tx_empty(),
        .tx_dc(),

        .arbiter_req(arbiter_req),
        .arbiter_grant(arbiter_grant),
        .ext_wen(ext_wen),
        .ext_addr(ext_addr),
        .ext_data(ext_data),

        .ext_rst(ext_rst),
        .ext_io_set(ext_io_set),
        .ext_io_disable(ext_io_disable),
        .ext_io_wr(ext_io_wr),

        // .cmd_valid(cmd_valid),
        // .cmd_apdu(cmd_apdu),
        // .cmd_apsm1(cmd_apsm1),
        // .cmd_apsm2(cmd_apsm2),
        // .cmd_cpsm(cmd_cpsm),
        .debug(LED)
        // .debug()
    );
    
    // assign LED = cmd_apsm1[111:96]; 
    // assign LED = {ext_wen,ext_addr[6:0],ext_data[7:0]}; 
    // assign LED = {cmd_cpsm[7:0],cmd_apsm1[8*14-1:7*8]}; 
    // assign LED = {ext_io_set[7:0],cmd_apdu[7:0]}; 


    reg [8:0] memAddr;
    reg [31:0] memDI;
    wire [31:0] memDO;
    reg memEn, memWen, cfgLoad, cfgStore;
    wire cfgBusy;


    //io_ctrl
    wire [31:0] io_ctrl_set;              // to slave main
    wire [31:0] io_ctrl_disable;    // to slave main ? or top register
    wire io_ctrl_wr;                // to slave main
    wire [31:0] io_ctrl_out;      // CHIP OUT

    // assign LED[12] = 1'b1;
    io_ctrl io_ctrl_inst(
        .clk(CLK100MHZ),//input wire clk,
        .nrst(sys_rst_n),//input wire rst_n,
        .io_set(io_ctrl_set),//input wire d_in,
        .io_disable(io_ctrl_disable),//input wire [31:0] enable_n,
        .io_wr(io_ctrl_wr),//input wire wr,
        .io_out(io_ctrl_out)//output wire [31:0] d_out
    );

endmodule
