`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/02 13:45:48
// Design Name: 
// Module Name: status_sender
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


module status_sender(
        input clk,
        input nrst,
        
        output reg [7:0] tx_byte,
        output reg tx_wr_en, 
        input tx_full,
        input tx_empty,
        input [9:0] tx_dc,

        output reg arbiter_req,
        input arbiter_grant,
        output reg ext_en,
        output reg [15:0] ext_addr,
        input [7:0] ext_data,
        output reg [15:0] debug
    );
    // genvar i;
    // generate 
    // for (i = 0; i < 5; i = i + 1) begin : flat_array
    //     assign cmd_apdu[(i*8)+7:(i*8)] = cmd_apdu_p[i];
    // end
    // endgenerate
    // generate 
    // for (i = 0; i < 14; i = i + 1) begin : flat_array1
    //     assign cmd_apsm1[(i*8)+7:(i*8)] = cmd_apsm1_p[i];
    // end
    // endgenerate

    reg [31:0] time_counter;
    reg [3:0] timer_state;
    reg receive_timeout;

    localparam TIMER_IDLE = 0;
    localparam TIMER_COUNT = 1;
    
    //timer
    always @ (posedge(clk) or negedge(nrst)) begin
        if(~nrst) begin
            time_counter <= 0;
            receive_timeout <= 1'b1;
        end else begin
            case(timer_state)
                TIMER_IDLE: begin
                    receive_timeout <= 1'b0;
                    timer_state <= TIMER_COUNT;
                end
                TIMER_COUNT: begin
                    if(time_counter <= 100_000_000) begin // 0.1 sec
                        time_counter <= time_counter + 1'b1;
                    end else begin
                        receive_timeout <= 1'b1;
                        time_counter <= 0;
                        timer_state <= TIMER_IDLE;
                    end
                end
            endcase
        end
    end
    
    reg [7:0] status_sender_state;

    localparam CNT_APDU_FAULT_DATA = 8;
    localparam CNT_APDU_ADC_DATA = 17*2;
    localparam CNT_APSM1_DATA_SS = 12*14;
    localparam CNT_APSM2_DATA_SS = 22*14;
    localparam CNT_CPSM_DATA_SS = 107;

    localparam BASE_APSM1_DATA_SS = 16'h0000;
    localparam BASE_APSM2_DATA_SS = 16'h1000;
    localparam BASE_CPSM_DATA_SS = 16'h2000;
    
    reg [7:0] fault_apdu_p[CNT_APDU_FAULT_DATA-1:0];
    reg [7:0] adc_apdu_p[CNT_APDU_ADC_DATA-1:0];

    integer ii;
//    assign debug[3:0] = status_sender_state[3:0];
    always @ (posedge(clk) or negedge(nrst)) begin
        if(~nrst) begin
            for (ii=0;ii<CNT_APDU_FAULT_DATA;ii=ii+1) begin
                fault_apdu_p[ii] <= 0;
            end
            for (ii=0;ii<CNT_APDU_ADC_DATA;ii=ii+1) begin
                adc_apdu_p[ii] <= 0;
            end
        end else begin
            for (ii=0;ii<CNT_APDU_FAULT_DATA;ii=ii+1) begin
                fault_apdu_p[ii] <= ii;
            end
            for (ii=0;ii<CNT_APDU_ADC_DATA;ii=ii+1) begin
                adc_apdu_p[ii] <= ii;
            end
        end
    end


    localparam STATUS_SENDER_IDLE = 0;
    localparam STATUS_SENDER_CHECK_START = 1;
    localparam STATUS_SENDER_OP = 2;
    localparam STATUS_SENDER_EXTRACT_LENGTH_0 = 3;
    localparam STATUS_SENDER_EXTRACT_LENGTH_1 = 4;
    localparam STATUS_SENDER_EXTRACT_APDU = 5;
    localparam STATUS_SENDER_EXTRACT_APDU_ADC = 6;
    localparam STATUS_SENDER_EXTRACT_APSM1 = 7;
    localparam STATUS_SENDER_EXTRACT_APSM2 = 8;
    localparam STATUS_SENDER_EXTRACT_CPSM = 9;
    localparam STATUS_SENDER_CHECK_CRC = 10;
    // localparam STATUS_SENDER_END = 11;

    localparam PACKET_CMD = 8'h86;
    localparam PACKET_OP = 8'hD3;    
    localparam PACKET_LEN_0 = 8'h02; // 625
    localparam PACKET_LEN_1 = 8'h71;

    reg [15:0] byte_counter;
    reg [7:0] crc;
    reg [31:0] sec_timer;

    always @ (posedge(clk) or negedge(nrst)) begin
        if(~nrst) begin

            tx_wr_en <= 0; 
            tx_byte <= 0;
            byte_counter <= 0;
            crc <= 0;
            arbiter_req <= 0;
            ext_en <= 0;
            ext_addr <= 0;
            debug <= 0;
            sec_timer <= 0;
            status_sender_state <= STATUS_SENDER_IDLE;

        end else begin
            case(status_sender_state)
                STATUS_SENDER_IDLE: begin
                    tx_wr_en <= 1'b0;
                    tx_byte <= 0;
                    byte_counter <= 0;
                    crc <= 0;
                    arbiter_req <= 0;
                    ext_en <= 0;
                    ext_addr <= 0;

                    if(sec_timer <= 100_000_000) begin // 1 sec
                        sec_timer <= sec_timer + 1'b1;
                    end else begin
                        sec_timer <= 0;
                        arbiter_req <= 1;
                        status_sender_state <= STATUS_SENDER_CHECK_START;
                    end
                end

                STATUS_SENDER_CHECK_START: begin
                    if (arbiter_grant == 1'b1) begin
                        if (tx_empty == 1'b1) begin
                            tx_wr_en <= 1'b1;
                            tx_byte <= PACKET_CMD;
                            crc <= PACKET_CMD;
                            status_sender_state <= STATUS_SENDER_OP;
                        end
                    end else begin
                        status_sender_state <= STATUS_SENDER_IDLE;
                    end
                end

                STATUS_SENDER_OP: begin
                    if (arbiter_grant == 1'b1) begin
                        tx_byte <= PACKET_OP;
                        crc <= crc + PACKET_OP;
                        status_sender_state <= STATUS_SENDER_EXTRACT_LENGTH_0;
                    end else begin
                        status_sender_state <= STATUS_SENDER_IDLE;
                    end
                end

                STATUS_SENDER_EXTRACT_LENGTH_0: begin 
                    if (arbiter_grant == 1'b1) begin
                        tx_byte <= PACKET_LEN_0;
                        crc <= crc + PACKET_LEN_0;
                        status_sender_state <= STATUS_SENDER_EXTRACT_LENGTH_1;
                    end else begin
                        status_sender_state <= STATUS_SENDER_IDLE;
                    end
                end
                STATUS_SENDER_EXTRACT_LENGTH_1: begin 
                    if (arbiter_grant == 1'b1) begin
                        tx_byte <= PACKET_LEN_1;
                        crc <= crc + PACKET_LEN_1;
                        byte_counter <= 0;
                        status_sender_state <= STATUS_SENDER_EXTRACT_APDU;
                    end else begin
                        status_sender_state <= STATUS_SENDER_IDLE;
                    end
                end

                STATUS_SENDER_EXTRACT_APDU: begin
                    if (arbiter_grant == 1'b1) begin
                        tx_byte <= fault_apdu_p[byte_counter];
                        crc <= crc + fault_apdu_p[byte_counter];
                        byte_counter <= byte_counter + 1;
                        if (byte_counter == CNT_APDU_FAULT_DATA-1) begin // 8 bytes
                            byte_counter <= 0;
                            status_sender_state <= STATUS_SENDER_EXTRACT_APDU_ADC;
                        end
                    end else begin
                        status_sender_state <= STATUS_SENDER_IDLE;
                    end
                end

                STATUS_SENDER_EXTRACT_APDU_ADC: begin
                    if (arbiter_grant == 1'b1) begin
                        tx_byte <= adc_apdu_p[byte_counter];
                        crc <= crc + adc_apdu_p[byte_counter];
                        byte_counter <= byte_counter + 1;
                        if (byte_counter == CNT_APDU_ADC_DATA-1) begin // 17*2 bytes
                            byte_counter <= 0;
                            ext_addr <= BASE_APSM1_DATA_SS;
                            status_sender_state <= STATUS_SENDER_EXTRACT_APSM1;
                        end
                    end else begin
                        status_sender_state <= STATUS_SENDER_IDLE;
                    end
                end
                
                STATUS_SENDER_EXTRACT_APSM1: begin
                    if (arbiter_grant == 1'b1) begin
                        tx_byte <= ext_data;
                        crc <= crc + ext_data;
                        ext_addr <= ext_addr + 1;
                        byte_counter <= byte_counter + 1;
                        if (byte_counter == CNT_APSM1_DATA_SS-1) begin // 12*14 bytes
                            byte_counter <= 0;
                            ext_addr <= BASE_APSM2_DATA_SS;
                            status_sender_state <= STATUS_SENDER_EXTRACT_APSM2;
                        end
                    end else begin
                        status_sender_state <= STATUS_SENDER_IDLE;
                    end
                end

                STATUS_SENDER_EXTRACT_APSM2: begin  
                    if (arbiter_grant == 1'b1) begin
                        tx_byte <= ext_data;
                        crc <= crc + ext_data;
                        ext_addr <= ext_addr + 1;
                        byte_counter <= byte_counter + 1;
                        if (byte_counter == CNT_APSM2_DATA_SS-1) begin // 22*14 bytes
                            byte_counter <= 0;
                            ext_addr <= BASE_CPSM_DATA_SS;
                            status_sender_state <= STATUS_SENDER_EXTRACT_CPSM;
                            // status_sender_state <= STATUS_SENDER_CHECK_CRC;
                        end
                    end else begin
                        status_sender_state <= STATUS_SENDER_IDLE;
                    end
                end

                STATUS_SENDER_EXTRACT_CPSM: begin 
                    if (arbiter_grant == 1'b1) begin
                        tx_byte <= ext_data;
                        crc <= crc + ext_data;
                        ext_addr <= ext_addr + 1;
                        byte_counter <= byte_counter + 1;
                        if (byte_counter == CNT_CPSM_DATA_SS-1) begin // 107 bytes
                            byte_counter <= 0;
                            ext_addr <= 0;
                            status_sender_state <= STATUS_SENDER_CHECK_CRC;
                        end
                    end else begin
                        status_sender_state <= STATUS_SENDER_IDLE;
                    end
                end
                
                STATUS_SENDER_CHECK_CRC: begin
                    tx_byte <= crc;
                    // tx_byte <= 8'h77;
                    status_sender_state <= STATUS_SENDER_IDLE;
                end

                // STATUS_SENDER_END: begin
                //     tx_wr_en <= 1'b0;
                //     status_sender_state <= STATUS_SENDER_IDLE;
                // end
            endcase
        end
    end
endmodule
