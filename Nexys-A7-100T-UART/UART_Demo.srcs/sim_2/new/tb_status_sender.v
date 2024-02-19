`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/19 09:26:06
// Design Name: 
// Module Name: tb_status_sender
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


module tb_status_sender(
    );
    reg CLK100MHZ;
    reg sys_rst_n;
    wire [7:0] tx_byte;
    wire [7:0] rx_byte;
    wire tx_wr_en;
    reg tx_full;
    reg tx_empty;

    wire arbiter_req;
    reg arbiter_grant = 1'b1;
    wire ext_wen;
    wire [15:0] ext_addr;
    wire [7:0] ext_data;
    wire ext_rst;
    wire [31:0] cmd_parser_io_set;
    wire cmd_parser_io_wr;
    
    wire ss_arbiter_req;
    reg ss_arbiter_grant = 1'b1;
    wire ss_ext_wen;
    wire [15:0] ss_ext_addr;
    reg [7:0] ss_ext_data;
    wire [15:0] ss_debug;
    wire [5:0] adc_address;   //register address: total 64 channel
    wire adc_rd;           //rd enable
    reg [15:0] adc_data; //conversion data out 16 bit
    wire scrd;
    wire [3:0] psu_ond;
    wire [31:0] ext_io_set;
    wire [31:0] ext_io_disable;
    wire ext_io_wr;
    
    wire ena = ss_ext_en;
    wire wea = 1'b0;
    wire [10:0] addra = ss_ext_addr[10:0];
    reg [7:0] dina;
    wire [7:0] douta;
    // blk_mem_gen_0 blk_mem_inst(
    //     .clka(CLK100MHZ), //: IN STD_LOGIC;
    //     .ena(ena), //: IN STD_LOGIC;
    //     .wea(wea), //: IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    //     .addra(addra), //: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    //     .dina(dina), //: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    //     .douta(douta) //: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    // );   
    // �???1. `timescale 1ns/ 1ps 문장?�� ?��?�� delay 간격?�� 1ns�???, precision?�� 1ps�??? ?��?��?�� �????��.

    initial begin // 5. ﻿initial 문장?�� ?��?��?��?��.

        CLK100MHZ = 0; 
        sys_rst_n = 0;
        adc_data = 0;
        ss_arbiter_grant = 1;
        tx_empty = 1;
        tx_full = 0;
        ss_ext_data = 0;
        #1000;
        sys_rst_n = 1;
        adc_data = 8'h01;
        ss_ext_data = 8'h01;
        #1000;
        adc_data = 8'h02;
        ss_ext_data = 8'h02;
        #1000;
        adc_data = 8'h03;
        ss_ext_data = 8'h03;
        // $finish; // ﻿system task $finish;�??? ?��?��?��.
    end

    //generate clock(100MHz)
    always
    // always
        #5 CLK100MHZ = ~CLK100MHZ; // �???6. always�??? clock?�� ?��?��?�� �????��

    //timer
    always @ (posedge(CLK100MHZ) or negedge(sys_rst_n)) begin
        if(~sys_rst_n) begin
            dina <= 0;
        end else begin
            dina <= dina + 1;
        end
    end

    integer ii;

    status_sender status_sender_inst(
        .clk(CLK100MHZ),
        .nrst(sys_rst_n),
        
        .tx_byte(tx_byte),
        .tx_wr_en(tx_wr_en), 
        .tx_full(tx_full),
        .tx_empty(tx_empty),
        .tx_dc(),

        //to adc_ctrl
        // output reg [5:0] adc_address,   //register address: total 64 channel
        // output reg adc_rd,           //rd enable
        // input wire [15:0] adc_data, //conversion data out 16 bit
        .adc_address(adc_address),   //register address: total 64 channel
        .adc_rd(adc_rd),           //rd enable
        .adc_data(adc_data), //conversion data out 16 bit

        .ext_io_set(ext_io_set),
        .ext_io_disable(ext_io_disable),
        .ext_io_wr(ext_io_wr),

        .cmd_parser_io_set(cmd_parser_io_set),
        .cmd_parser_io_wr(cmd_parser_io_wr),

        .arbiter_req(ss_arbiter_req),
        .arbiter_grant(ss_arbiter_grant),
        .ext_en(ss_ext_en),
        .ext_addr(ss_ext_addr),
        // .ext_data(ss_ext_data),
        .ext_data(douta),

        .scrd(scrd),
        .psu_ond(psu_ond),

        .debug(ss_debug)
    );

//  <-----Cut code below this line---->
   // xpm_memory_spram: Single Port RAM
   // Xilinx Parameterized Macro, version 2023.2
    xpm_memory_spram #(
      .ADDR_WIDTH_A(11),              // DECIMAL
      .AUTO_SLEEP_TIME(0),           // DECIMAL
      .BYTE_WRITE_WIDTH_A(8),       // DECIMAL
      .CASCADE_HEIGHT(0),            // DECIMAL
      .ECC_BIT_RANGE("7:0"),         // String
      .ECC_MODE("no_ecc"),           // String
      .ECC_TYPE("none"),             // String
      .IGNORE_INIT_SYNTH(0),         // DECIMAL
      .MEMORY_INIT_FILE("none"),     // String
      .MEMORY_INIT_PARAM("0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f,0"),       // String
      .MEMORY_OPTIMIZATION("true"),  // String
      .MEMORY_PRIMITIVE("auto"),     // String
      .MEMORY_SIZE(2048),            // DECIMAL
      .MESSAGE_CONTROL(0),           // DECIMAL
      .RAM_DECOMP("auto"),           // String
      .READ_DATA_WIDTH_A(8),        // DECIMAL
      .READ_LATENCY_A(1),            // DECIMAL
      .READ_RESET_VALUE_A("0"),      // String
      .RST_MODE_A("SYNC"),           // String
      .SIM_ASSERT_CHK(0),            // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .USE_MEM_INIT(1),              // DECIMAL
      .USE_MEM_INIT_MMI(0),          // DECIMAL
      .WAKEUP_TIME("disable_sleep"), // String
      .WRITE_DATA_WIDTH_A(8),       // DECIMAL
      .WRITE_MODE_A("write_first"),   // String
      .WRITE_PROTECT(1)              // DECIMAL
    ) 
    xpm_memory_spram_inst (
      .dbiterra(dbiterra),             // 1-bit output: Status signal to indicate double bit error occurrence
                                       // on the data output of port A.

      .douta(douta),                   // READ_DATA_WIDTH_A-bit output: Data output for port A read operations.
      .sbiterra(sbiterra),             // 1-bit output: Status signal to indicate single bit error occurrence
                                       // on the data output of port A.

      .addra(addra),                   // ADDR_WIDTH_A-bit input: Address for port A write and read operations.
      .clka(CLK100MHZ),                     // 1-bit input: Clock signal for port A.
      .dina(dina),                     // WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
      .ena(ena),                       // 1-bit input: Memory enable signal for port A. Must be high on clock
                                       // cycles when read or write operations are initiated. Pipelined
                                       // internally.

      .injectdbiterra(1'b0), // 1-bit input: Controls double bit error injection on input data when
                                       // ECC enabled (Error injection capability is not available in
                                       // "decode_only" mode).

      .injectsbiterra(1'b0), // 1-bit input: Controls single bit error injection on input data when
                                       // ECC enabled (Error injection capability is not available in
                                       // "decode_only" mode).

      .regcea(1'b1),                 // 1-bit input: Clock Enable for the last register stage on the output
                                       // data path.

      .rsta(1'b0),                // 1-bit input: Reset signal for the final port A output register stage.
                                       // Synchronously resets output port douta to the value specified by
                                       // parameter READ_RESET_VALUE_A.

      .sleep(1'b0),                   // 1-bit input: sleep signal to enable the dynamic power saving feature.
      .wea(wea)                        // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector
                                       // for port A input data port dina. 1 bit wide when word-wide writes are
                                       // used. In byte-wide write configurations, each bit controls the
                                       // writing one byte of dina to address addra. For example, to
                                       // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A
                                       // is 32, wea would be 4'b0010.

    );
   // End of xpm_memory_spram_inst instantiation
endmodule
