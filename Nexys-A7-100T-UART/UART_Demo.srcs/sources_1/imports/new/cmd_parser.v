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

        output reg arbiter_req,
        input arbiter_grant,
        output reg ext_wen,
        output reg [15:0] ext_addr,
        output reg [7:0] ext_data,


        output reg cmd_valid,
        output wire [(5*8)-1:0] cmd_apdu,
        output wire [(14*8)-1:0] cmd_apsm1,
        output wire [(14*3*8)-1:0] cmd_apsm2,
        output wire [(20*8)-1:0] cmd_cpsm,
        output reg [15:0] debug
    );

    localparam CNT_APDU_DATA = 5;
    localparam CNT_APSM1_DATA = 14;
    localparam CNT_APSM2_DATA_RESET = 14;
    localparam CNT_APSM2_DATA_ON = 14*3;
    localparam CNT_CPSM_DATA = 20;

    localparam BASE_APSM1_DATA = 16'h0800;
    localparam BASE_APSM2_DATA = 16'h1800;
    localparam BASE_CPSM_DATA = 16'h2800;
    

    reg [7:0] cmd_apdu_p[CNT_APDU_DATA-1:0];
    reg [7:0] cmd_apsm1_p[CNT_APSM1_DATA-1:0];
    reg [7:0] cmd_apsm2_p[CNT_APSM2_DATA_ON-1:0];
    reg [7:0] cmd_cpsm_p[CNT_CPSM_DATA-1:0];

    genvar i;
    generate 
    for (i = 0; i < 5; i = i + 1) begin : flat_array
        assign cmd_apdu[(i*8)+7:(i*8)] = cmd_apdu_p[i];
    end
    endgenerate
    generate 
    for (i = 0; i < 14; i = i + 1) begin : flat_array1
        assign cmd_apsm1[(i*8)+7:(i*8)] = cmd_apsm1_p[i];
    end
    endgenerate
    generate 
    for (i = 0; i < 14*3; i = i + 1) begin : flat_array12
        assign cmd_apsm2[(i*8)+7:(i*8)] = cmd_apsm2_p[i];
    end
    endgenerate
    generate 
    for (i = 0; i < 20; i = i + 1) begin : flat_array2
        assign cmd_cpsm[(i*8)+7:(i*8)] = cmd_cpsm_p[i];
    end
    endgenerate

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
    localparam PACKET_PARSER_ARBITER = 10;
    localparam PACKET_PARSER_SET_APSM1_COMMAND_FLAG = 11;
    localparam PACKET_PARSER_SET_APSM1_COMMAND = 12;
    localparam PACKET_PARSER_SET_APSM1_DATA = 13;
    localparam PACKET_PARSER_SET_APSM2_COMMAND_FLAG = 14;
    localparam PACKET_PARSER_SET_APSM2_COMMAND = 15;
    localparam PACKET_PARSER_SET_APSM2_DATA = 16;
    localparam PACKET_PARSER_SET_CPSM_COMMAND_FLAG = 17;
    localparam PACKET_PARSER_SET_CPSM_COMMAND = 18;
    localparam PACKET_PARSER_SET_CPSM_DATA = 19;
    localparam PACKET_PARSER_FAIL = 20;

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


            arbiter_req <= 0;
            ext_wen <= 0;
            ext_addr <= 0;
            ext_data <= 0;

            cmd_valid <= 0;
            for (ii=0;ii<CNT_APDU_DATA;ii=ii+1) begin
                cmd_apdu_p[ii] <= 0;
            end
            for (ii=0;ii<CNT_APSM1_DATA;ii=ii+1) begin
                cmd_apsm1_p[ii] <= 0;
            end
            for (ii=0;ii<CNT_APSM2_DATA_ON;ii=ii+1) begin
                cmd_apsm2_p[ii] <= 0;
            end
            for (ii=0;ii<CNT_CPSM_DATA;ii=ii+1) begin
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
                    
                    arbiter_req <= 0;
                    ext_wen <= 0;
                    ext_addr <= 0;
                    ext_data <= 0;

                    cmd_valid <= 0;
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
                            packet_parser_state <= PACKET_PARSER_FAIL;
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
                            packet_parser_state <= PACKET_PARSER_FAIL;
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
                            packet_parser_state <= PACKET_PARSER_FAIL;
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
                            packet_parser_state <= PACKET_PARSER_FAIL;
                        end
                    end
                end
                PACKET_PARSER_EXTRACT_APDU: begin  // 00 01
                    if(uart_rx_valid) begin
                        crc <= crc + uart_rx_byte;
                        byte_counter <= byte_counter + 1;
                        cmd_apdu_p[byte_counter] <= uart_rx_byte;
                        case(cmd)
                            PACKET_CMD_RESET: begin // RESET
                                byte_counter <= 0;
                                packet_parser_state <= PACKET_PARSER_EXTRACT_APSM1;
                            end
                            PACKET_CMD_ON: begin // ON 
                                if (byte_counter == CNT_APDU_DATA-1) begin // 5 bytes
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
                            packet_parser_state <= PACKET_PARSER_FAIL;
                        end
                    end
                end
                
                PACKET_PARSER_EXTRACT_APSM1: begin  // 00 01
                    if(uart_rx_valid) begin
                        crc <= crc + uart_rx_byte;
                        byte_counter <= byte_counter + 1;
                        cmd_apsm1_p[byte_counter] <= uart_rx_byte;
                        if (byte_counter == CNT_APSM1_DATA-1) begin // 14 bytes
                            byte_counter <= 0;
                            packet_parser_state <= PACKET_PARSER_EXTRACT_APSM2;
                        end
                    end else begin
                        if(receive_timeout) begin
                            packet_parser_state <= PACKET_PARSER_FAIL;
                        end
                    end
                end

                PACKET_PARSER_EXTRACT_APSM2: begin  // 00 01
                    if(uart_rx_valid) begin
                        crc <= crc + uart_rx_byte;
                        byte_counter <= byte_counter + 1;
                        cmd_apsm2_p[byte_counter] <= uart_rx_byte;
                        case(cmd)
                            PACKET_CMD_RESET: begin // RESET
                                if (byte_counter == CNT_APSM2_DATA_RESET-1) begin // 14 bytes
                                    byte_counter <= 0;
                                    packet_parser_state <= PACKET_PARSER_EXTRACT_CPSM;
                                end
                            end
                            PACKET_CMD_ON: begin // ON 
                                if (byte_counter == CNT_APSM2_DATA_ON-1) begin // 14*3 bytes
                                    byte_counter <= 0;
                                    packet_parser_state <= PACKET_PARSER_EXTRACT_CPSM;
                                end
                            end
                            default: begin
                                packet_parser_state <= PACKET_PARSER_FAIL;
                            end
                        endcase
                    end else begin
                        if(receive_timeout) begin
                            packet_parser_state <= PACKET_PARSER_FAIL;
                        end
                    end
                end

                PACKET_PARSER_EXTRACT_CPSM: begin  // 00 01
                    if(uart_rx_valid) begin
                        crc <= crc + uart_rx_byte;
                        byte_counter <= byte_counter + 1;
                        cmd_cpsm_p[byte_counter] <= uart_rx_byte;
                        case(cmd)
                            PACKET_CMD_RESET: begin // RESET
                                byte_counter <= 0;
                                packet_parser_state <= PACKET_PARSER_CHECK_CRC;
                            end
                            PACKET_CMD_ON: begin // ON 
                                if (byte_counter == CNT_CPSM_DATA-1) begin // 20 bytes
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
                            packet_parser_state <= PACKET_PARSER_FAIL;
                        end
                    end
                end
                
                PACKET_PARSER_CHECK_CRC: begin
                    if(uart_rx_valid) begin
                        debug[15:8] <= crc;
                        if(crc == uart_rx_byte) begin
                            packet_parser_state <= PACKET_PARSER_ARBITER;
                            cmd_valid <= 1;
                            debug[4] <= 1;
                            arbiter_req <= 1;
                            ext_wen <= 0;
                            ext_addr <= 0;
                            ext_data <= 0;
                        end else begin
                            packet_parser_state <= PACKET_PARSER_IDLE;
                            cmd_valid <= 0;
                            debug[4] <= 0;
                        end
                    end else begin
                        if(receive_timeout) begin
                            packet_parser_state <= PACKET_PARSER_IDLE;
                        end
                    end
                end
                
                PACKET_PARSER_ARBITER: begin
                    if (arbiter_grant == 1'b1) begin
                        packet_parser_state <= PACKET_PARSER_SET_APSM1_COMMAND_FLAG;
                    end
                end

                PACKET_PARSER_SET_APSM1_COMMAND_FLAG: begin
                    if (arbiter_grant == 1'b1) begin
                        ext_wen <= 1;
                        ext_addr <= BASE_APSM1_DATA;
                        ext_data <= 1;
                        packet_parser_state <= PACKET_PARSER_SET_APSM1_COMMAND;
                    end else begin
                        packet_parser_state <= PACKET_PARSER_IDLE;
                    end
                end

                PACKET_PARSER_SET_APSM1_COMMAND: begin
                    if (arbiter_grant == 1'b1) begin
                        ext_addr <= ext_addr + 1;
                        ext_data <= cmd;
                        byte_counter <= 0;
                        packet_parser_state <= PACKET_PARSER_SET_APSM1_DATA;
                    end else begin
                        packet_parser_state <= PACKET_PARSER_IDLE;
                    end
                end

                PACKET_PARSER_SET_APSM1_DATA: begin
                    if (arbiter_grant == 1'b1) begin
                        ext_addr <= ext_addr + 1;
                        ext_data <= cmd_apsm1_p[byte_counter];
                        byte_counter <= byte_counter + 1;
                        if (byte_counter == CNT_APSM1_DATA-1) begin // 14 bytes
                            byte_counter <= 0;
                            packet_parser_state <= PACKET_PARSER_SET_APSM2_COMMAND_FLAG;
                        end
                    end else begin
                        packet_parser_state <= PACKET_PARSER_IDLE;
                    end
                end

                PACKET_PARSER_SET_APSM2_COMMAND_FLAG: begin
                    if (arbiter_grant == 1'b1) begin
                        ext_addr <= BASE_APSM2_DATA;
                        ext_data <= 1;
                        packet_parser_state <= PACKET_PARSER_SET_APSM2_COMMAND;
                    end else begin
                        packet_parser_state <= PACKET_PARSER_IDLE;
                    end
                end

                PACKET_PARSER_SET_APSM2_COMMAND: begin
                    if (arbiter_grant == 1'b1) begin
                        ext_addr <= ext_addr + 1;
                        ext_data <= cmd;
                        byte_counter <= 0;
                        packet_parser_state <= PACKET_PARSER_SET_APSM2_DATA;
                    end else begin
                        packet_parser_state <= PACKET_PARSER_IDLE;
                    end
                end

                PACKET_PARSER_SET_APSM2_DATA: begin
                    if (arbiter_grant == 1'b1) begin
                        ext_addr <= ext_addr + 1;
                        ext_data <= cmd_apsm2_p[byte_counter];
                        byte_counter <= byte_counter + 1;
                        case(cmd)
                            PACKET_CMD_RESET: begin // RESET
                                if (byte_counter == CNT_APSM2_DATA_RESET-1) begin // 14 bytes
                                    byte_counter <= 0;
                                    packet_parser_state <= PACKET_PARSER_SET_CPSM_COMMAND_FLAG;
                                end
                            end
                            PACKET_CMD_ON: begin // ON 
                                if (byte_counter == CNT_APSM2_DATA_ON-1) begin // 14*3 bytes
                                    byte_counter <= 0;
                                    packet_parser_state <= PACKET_PARSER_SET_CPSM_COMMAND_FLAG;
                                end
                            end
                            default: begin
                                packet_parser_state <= PACKET_PARSER_IDLE;
                            end
                        endcase
                    end else begin
                        packet_parser_state <= PACKET_PARSER_IDLE;
                    end
                end

                PACKET_PARSER_SET_CPSM_COMMAND_FLAG: begin
                    if (arbiter_grant == 1'b1) begin
                        ext_addr <= BASE_CPSM_DATA;
                        ext_data <= 1;
                        packet_parser_state <= PACKET_PARSER_SET_CPSM_COMMAND;
                    end else begin
                        packet_parser_state <= PACKET_PARSER_IDLE;
                    end
                end

                PACKET_PARSER_SET_CPSM_COMMAND: begin
                    if (arbiter_grant == 1'b1) begin
                        ext_addr <= ext_addr + 1;
                        ext_data <= cmd;
                        byte_counter <= 0;
                        packet_parser_state <= PACKET_PARSER_SET_CPSM_DATA;
                    end else begin
                        packet_parser_state <= PACKET_PARSER_IDLE;
                    end
                end

                PACKET_PARSER_SET_CPSM_DATA: begin
                    if (arbiter_grant == 1'b1) begin
                        ext_addr <= ext_addr + 1;
                        ext_data <= cmd_cpsm_p[byte_counter];
                        byte_counter <= byte_counter + 1;
                        case(cmd)
                            PACKET_CMD_RESET: begin // RESET
                                byte_counter <= 0;
                                packet_parser_state <= PACKET_PARSER_IDLE;
                            end
                            PACKET_CMD_ON: begin // ON 
                                if (byte_counter == CNT_CPSM_DATA-1) begin // 20 bytes
                                    byte_counter <= 0;
                                    packet_parser_state <= PACKET_PARSER_IDLE;
                                end
                            end
                            default: begin
                                packet_parser_state <= PACKET_PARSER_IDLE;
                            end
                        endcase
                    end else begin
                        packet_parser_state <= PACKET_PARSER_IDLE;
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
