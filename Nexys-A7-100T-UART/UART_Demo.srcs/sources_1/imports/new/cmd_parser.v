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
        input wire [7:0] uart_rx_byte,
        output reg uart_rx_rd_en,
        input wire uart_rx_full,
        input wire uart_rx_empty,
        input wire uart_rx_valid,
        input wire [9:0] uart_rx_dc,
        
        output reg [7:0] tx_byte,
        output reg tx_wr_en, 
        input tx_full,
        input tx_empty,
        input [9:0] tx_dc,

        output reg cmd_valid,
        output wire [(5*8)-1:0] cmd_apdu,
        output wire [(14*8)-1:0] cmd_apsm1,
        output wire [(14*8)-1:0] cmd_apsm2,
        output wire [(20*8)-1:0] cmd_cpsm,
        // output cmd_apdu_4,
        // output cmd_apdu_3,
        // output cmd_apdu_2,
        // output cmd_apdu_1,
        // output cmd_apdu_0,
        // output cmd_apsm1_7,
        // output cmd_apsm1_6,
        // output cmd_apsm1_5,
        // output cmd_apsm1_4,
        // output cmd_apsm1_3,
        // output cmd_apsm1_2,
        // output cmd_apsm1_1,
        // output cmd_apsm1_0,
        // output cmd_apsm2_7,
        // output cmd_apsm2_6,
        // output cmd_apsm2_5,
        // output cmd_apsm2_4,
        // output cmd_apsm2_3,
        // output cmd_apsm2_2,
        // output cmd_apsm2_1,
        // output cmd_apsm2_0,
        output reg [15:0] debug
    );

    reg [7:0] cmd_apdu_p[4:0];
    reg [7:0] cmd_apsm1_p[13:0];
    reg [7:0] cmd_apsm2_p[13:0];
    reg [7:0] cmd_cpsm_p[19:0];

    genvar i;
    generate 
    for (i = 0; i < 5; i = i + 1) begin : flat_array
        assign cmd_apdu[(i*8)+7:(i*8)] = cmd_apdu_p[i];
    end
    endgenerate
    generate 
    for (i = 0; i < 14; i = i + 1) begin : flat_array1
        assign cmd_apsm1[(i*8)+7:(i*8)] = cmd_apsm1_p[i];
        assign cmd_apsm2[(i*8)+7:(i*8)] = cmd_apsm2_p[i];
    end
    endgenerate
    generate 
    for (i = 0; i < 20; i = i + 1) begin : flat_array2
        assign cmd_cpsm[(i*8)+7:(i*8)] = cmd_cpsm_p[i];
    end
    endgenerate

    // assign cmd_apdu_4 =  cmd_apdu_p[4];
    // assign cmd_apdu_3 =  cmd_apdu_p[3];
    // assign cmd_apdu_2 =  cmd_apdu_p[2];
    // assign cmd_apdu_1 =  cmd_apdu_p[1];
    // assign cmd_apdu_0 =  cmd_apdu_p[0];
    // assign cmd_apsm1_7 = cmd_apsm1_p[7];
    // assign cmd_apsm1_6 = cmd_apsm1_p[6];
    // assign cmd_apsm1_5 = cmd_apsm1_p[5];
    // assign cmd_apsm1_4 = cmd_apsm1_p[4];
    // assign cmd_apsm1_3 = cmd_apsm1_p[3];
    // assign cmd_apsm1_2 = cmd_apsm1_p[2];
    // assign cmd_apsm1_1 = cmd_apsm1_p[1];
    // assign cmd_apsm1_0 = cmd_apsm1_p[0];
    // assign cmd_apsm2_7 = cmd_apsm2_p[7];
    // assign cmd_apsm2_6 = cmd_apsm2_p[6];
    // assign cmd_apsm2_5 = cmd_apsm2_p[5];
    // assign cmd_apsm2_4 = cmd_apsm2_p[4];
    // assign cmd_apsm2_3 = cmd_apsm2_p[3];
    // assign cmd_apsm2_2 = cmd_apsm2_p[2];
    // assign cmd_apsm2_1 = cmd_apsm2_p[1];
    // assign cmd_apsm2_0 = cmd_apsm2_p[0];


    // localparam APDU_REG_COUNT = 16;

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
                    if(~uart_rx_empty) begin
                        receive_timeout <= 1'b0;
                        timer_state <= TIMER_COUNT;
                    end
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
    
    reg [3:0] packet_parser_state;
    reg [7:0] checksum_calculated;
    reg [7:0] checksum_received;
    reg [7:0] buffer [128:0];
    reg [15:0] buffer_counter;

    localparam PACKET_PARSER_IDLE = 0;
    localparam PACKET_PARSER_CHECK_START = 1;
    localparam PACKET_PARSER_EXTRACT_CMD = 2;
    localparam PACKET_PARSER_EXTRACT_LENGTH_0 = 3;
    localparam PACKET_PARSER_EXTRACT_LENGTH_1 = 4;
    localparam PACKET_PARSER_EXTRACT_APDU = 5;
    localparam PACKET_PARSER_EXTRACT_APSM1 = 6;
    localparam PACKET_PARSER_EXTRACT_APSM2 = 7;
    localparam PACKET_PARSER_EXTRACT_CPSM = 8;
    localparam PACKET_PARSER_CHECK_CRC = 9;
    localparam PACKET_PARSER_FAIL = 10;

    localparam PACKET_CMD_RESET = 8'h03;    
    localparam PACKET_CMD_ON = 8'h13;

    localparam CMD_ID = 8'h68;

    reg [15:0] data_length;
    reg [15:0] byte_counter;
    reg [7:0] crc;
    reg [7:0] cmd;
    integer ii;

//    assign debug[3:0] = packet_parser_state[3:0];

    always @ (posedge(clk) or negedge(nrst)) begin
        if(~nrst) begin
            packet_parser_state <= PACKET_PARSER_IDLE;
            checksum_calculated <= 0;
            checksum_received <= 0;
            buffer_counter <= 0;

            uart_rx_rd_en <= 0;
            crc <= 0;
            cmd <= 0;
            byte_counter <= 0;
            data_length <= 0;

            cmd_valid <= 0;
            for (ii=0;ii<5;ii=ii+1) begin
                cmd_apdu_p[ii] <= 0;
            end
            for (ii=0;ii<14;ii=ii+1) begin
                cmd_apsm1_p[ii] <= 0;
                cmd_apsm2_p[ii] <= 0;
            end
            for (ii=0;ii<20;ii=ii+1) begin
                cmd_cpsm_p[ii] <= 0;
            end
            debug <= 0;

        end else begin
            debug[3:0] <= packet_parser_state[3:0];
            // debug[15:8] <= cmd_apdu_p[4];
            case(packet_parser_state)
                PACKET_PARSER_IDLE: begin
                    uart_rx_rd_en <= 0;
                    byte_counter <= 0;
                    data_length <= 0;
                    crc <= 0;
                    if(~uart_rx_empty) begin
                        packet_parser_state <= PACKET_PARSER_CHECK_START;
                        uart_rx_rd_en <= 1'b1;//read enable
                    end
                end
                PACKET_PARSER_CHECK_START: begin
                    //read rx_byte
                    if(uart_rx_valid && uart_rx_byte == CMD_ID) begin //uart_rx_byte is 0x7A and data is on fifo
                        crc <= uart_rx_byte;
                        packet_parser_state <= PACKET_PARSER_EXTRACT_CMD;
                    end else begin
                        if(receive_timeout) begin
                            packet_parser_state <= PACKET_PARSER_IDLE;
                        end
                    end
                end
                PACKET_PARSER_EXTRACT_CMD: begin
                    if(uart_rx_valid) begin
                        crc <= crc + uart_rx_byte;
                        byte_counter <= 0;
                        cmd <= uart_rx_byte;
                        packet_parser_state <= PACKET_PARSER_EXTRACT_LENGTH_0;
                    end else begin
                        if(receive_timeout) begin
                            packet_parser_state <= PACKET_PARSER_IDLE;
                        end
                    end
                end
                PACKET_PARSER_EXTRACT_LENGTH_0: begin  // 00 01
                    if(uart_rx_valid) begin
                        crc <= crc + uart_rx_byte;
                        byte_counter <= byte_counter + 1;

                        data_length[15:8] <= uart_rx_byte;
                        packet_parser_state <= PACKET_PARSER_EXTRACT_LENGTH_1;
                    end else begin
                        if(receive_timeout) begin
                            packet_parser_state <= PACKET_PARSER_IDLE;
                        end
                    end
                end
                PACKET_PARSER_EXTRACT_LENGTH_1: begin  // 00 01
                    if(uart_rx_valid) begin
                        crc <= crc + uart_rx_byte;
                        data_length[7:0] <= uart_rx_byte;
                        byte_counter <= 0;
                        case(cmd)
                            PACKET_CMD_RESET: begin // RESET
                                packet_parser_state <= PACKET_PARSER_EXTRACT_APDU;
                            end
                            PACKET_CMD_ON: begin // ON 
                                packet_parser_state <= PACKET_PARSER_EXTRACT_APDU;
                            end
                            default: begin
                                packet_parser_state <= PACKET_PARSER_FAIL;
                            end
                        endcase
                    end else begin
                        if(receive_timeout) begin
                            packet_parser_state <= PACKET_PARSER_IDLE;
                        end
                    end
                end
                PACKET_PARSER_EXTRACT_APDU: begin  // 00 01
                    if(uart_rx_valid) begin
                        crc <= crc + uart_rx_byte;
                        byte_counter <= byte_counter + 1;
                        case(cmd)
                            PACKET_CMD_RESET: begin // RESET
                                cmd_apdu_p[byte_counter] <= uart_rx_byte;
                                byte_counter <= 0;
                                packet_parser_state <= PACKET_PARSER_EXTRACT_APSM1;
                            end
                            PACKET_CMD_ON: begin // ON 
                                cmd_apdu_p[byte_counter] <= uart_rx_byte;
                                if (byte_counter == 4) begin // 5 bytes
                                    byte_counter <= 0;
                                    packet_parser_state <= PACKET_PARSER_EXTRACT_APSM1;
                                end
                            end
                            default: begin
                                packet_parser_state <= PACKET_PARSER_FAIL;
                            end
                        endcase
                    end else begin
                        if(receive_timeout) begin
                            packet_parser_state <= PACKET_PARSER_IDLE;
                        end
                    end
                end
                
                PACKET_PARSER_EXTRACT_APSM1: begin  // 00 01
                    if(uart_rx_valid) begin
                        crc <= crc + uart_rx_byte;
                        byte_counter <= byte_counter + 1;
                        // case(cmd)
                        //     PACKET_CMD_RESET,PACKET_CMD_ON : begin // RESET, ON
                        // don't need to watch the cmd value, previous stage already check
                        cmd_apsm1_p[byte_counter] <= uart_rx_byte;
                        if (byte_counter == 13) begin // 14 bytes
                            byte_counter <= 0;
                            packet_parser_state <= PACKET_PARSER_EXTRACT_APSM2;
                        end
                        //     end
                        //     default: begin
                        //         packet_parser_state <= PACKET_PARSER_FAIL;
                        //     end
                        // endcase
                    end else begin
                        if(receive_timeout) begin
                            packet_parser_state <= PACKET_PARSER_IDLE;
                        end
                    end
                end

                PACKET_PARSER_EXTRACT_APSM2: begin  // 00 01
                    if(uart_rx_valid) begin
                        crc <= crc + uart_rx_byte;
                        byte_counter <= byte_counter + 1;
                        cmd_apsm2_p[byte_counter] <= uart_rx_byte;
                        if (byte_counter == 13) begin // 14 bytes
                            byte_counter <= 0;
                            packet_parser_state <= PACKET_PARSER_EXTRACT_CPSM;
                        end
                    end else begin
                        if(receive_timeout) begin
                            packet_parser_state <= PACKET_PARSER_IDLE;
                        end
                    end
                end

                PACKET_PARSER_EXTRACT_CPSM: begin  // 00 01
                    if(uart_rx_valid) begin
                        crc <= crc + uart_rx_byte;
                        byte_counter <= byte_counter + 1;
                        case(cmd)
                            PACKET_CMD_RESET: begin // RESET
                                cmd_cpsm_p[byte_counter] <= uart_rx_byte;
                                byte_counter <= 0;
                                packet_parser_state <= PACKET_PARSER_CHECK_CRC;
                            end
                            PACKET_CMD_ON: begin // ON 
                                cmd_cpsm_p[byte_counter] <= uart_rx_byte;
                                if (byte_counter == 19) begin // 20 bytes
                                    byte_counter <= 0;
                                    packet_parser_state <= PACKET_PARSER_CHECK_CRC;
                                end
                            end
                            default: begin
                                packet_parser_state <= PACKET_PARSER_FAIL;
                            end
                        endcase
                    end else begin
                        if(receive_timeout) begin
                            packet_parser_state <= PACKET_PARSER_IDLE;
                        end
                    end
                end
                PACKET_PARSER_CHECK_CRC: begin
                    if(uart_rx_valid) begin
                        debug[15:8] <= crc;
                        packet_parser_state <= PACKET_PARSER_IDLE;
                        if(crc == uart_rx_byte) begin
                            cmd_valid <= 1;
                            debug[4] <= 1;
                        end else begin
                            cmd_valid <= 0;
                            debug[4] <= 0;
                        end
                    end else begin
                        if(receive_timeout) begin
                            packet_parser_state <= PACKET_PARSER_IDLE;
                        end
                    end
                end
                
                PACKET_PARSER_FAIL: begin
                    if(uart_rx_empty) begin
                        packet_parser_state <= PACKET_PARSER_IDLE;
                    end else begin
                        if(uart_rx_valid) begin
                            crc <= uart_rx_byte; // for only dummy data processing, no meaning for crc
                        end else begin
                            if(receive_timeout) begin
                                packet_parser_state <= PACKET_PARSER_IDLE;
                            end
                        end
                    end
                end
                // MAIN_SEND_SOMETHING: begin
                //     if(buffer_counter > 0) begin
                //         tx_wr_en <= 1'b1;
                //         tx_byte <= buffer[buffer_counter - 1];
                //         buffer_counter <= buffer_counter - 1'b1;
                //     end else begin
                //         tx_wr_en <= 1'b0;
                //         packet_parser_state <= PACKET_PARSER_IDLE;
                //     end
                // end
            endcase
        end
    end
endmodule
