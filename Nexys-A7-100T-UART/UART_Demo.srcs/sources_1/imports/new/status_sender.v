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

`include "constants.vh"

module status_sender(
        input clk,
        input nrst,
        
        output reg [7:0] tx_byte,
        output reg tx_wr_en, 
        input tx_full,
        input tx_empty,
        input [9:0] tx_dc,

        //to adc_ctrl
        output reg [5:0] adc_address,   //register address: total 64 channel
        output reg adc_rd,           //rd enable
        input wire [15:0] adc_data, //conversion data out 16 bit

        // to io_ctrl
        output reg [31:0] ext_io_set,
        output reg [31:0] ext_io_disable,
        output reg ext_io_wr,

        // from cmd_parser
        input [31:0] cmd_parser_io_set,
        input cmd_parser_io_wr,

        output reg arbiter_req,
        input arbiter_grant,
        output reg ext_en,
        output reg [15:0] ext_addr,
        input [7:0] ext_data,

        output reg scrd,
        output reg [3:0] psu_ond,

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
    reg main_ready;

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
    
    
    reg div_start;
    reg divisor_valid;
    reg dividend_valid;
    wire dout_valid;
    reg[31:0] divisor;
    reg[31:0] dividend;
    wire[31:0] div_dout;
    
    div div_inst (
        .clk(clk),//input wire logic clk,    // clock
        .rst(~nrst),//input wire logic rst,    // reset
        .start(div_start),//input wire logic start,  // start calculation
        .busy(div_busy),//output     logic busy,   // calculation in progress
        .done(div_done),//output     logic done,   // calculation is complete (high for one tick)
        .valid(div_valid),//output     logic valid,  // result is valid
        .dbz(),//output     logic dbz,    // divide by zero
        .ovf(),//output     logic ovf,    // overflow
        .a(dividend),//input wire logic signed [WIDTH-1:0] a,   // dividend (numerator)
        .b(divisor),//input wire logic signed [WIDTH-1:0] b,   // divisor (denominator)
        .val(div_dout)//output     logic signed [WIDTH-1:0] val  // result value: quotient
    );
    
    reg [7:0] fault_apdu_p[CNT_APDU_FAULT_DATA-1:0];
    reg [7:0] adc_apdu_p[CNT_APDU_ADC_DATA-1:0];

    localparam OUTPUT_NUM = 7;
    localparam OUTPUT_NUM_4 = 7*2*2;
    localparam BASIC_ADC_LIMIT = 8;
    localparam MAX_ADC_LIMIT = 64-1;

    localparam ADDR_TEMPERATURE = 7;
    localparam ADDR_INPUT_270V_VOL = 1;
    localparam ADDR_INPUT_270V_AMP = 2;
    localparam ADDR_INPUT_28V_VOL = 3;
    localparam ADDR_INPUT_28V_AMP = 4;
    localparam ADDR_OUT_28V_VOL = 5;
    localparam ADDR_OUT_28V_AMP = 6;
    localparam ADDR_OUT_270V_1_VOL = 10;
    localparam ADDR_OUT_270V_1_AMP = 11;
    localparam ADDR_OUT_270V_2_VOL = 12;
    localparam ADDR_OUT_270V_2_AMP = 13;
    localparam ADDR_OUT_270V_3_VOL = 14;
    localparam ADDR_OUT_270V_3_AMP = 15;
    localparam ADDR_OUT_270V_4_VOL = 16;
    localparam ADDR_OUT_270V_4_AMP = 17;
    localparam ADDR_OUT_270V_5_VOL = 18;
    localparam ADDR_OUT_270V_5_AMP = 19;

    reg [1:0] fault_state[MAX_ADC_LIMIT:0]; // current fault state fault_state[][0]: low limit fault, fault_state[][1]: high limit fault
    reg [19:0] fault_shutdown;
    reg [31:0] fault_high_limit_counter[MAX_ADC_LIMIT:0]; //fault high limit counter
    reg [31:0] fault_low_limit_counter[MAX_ADC_LIMIT:0]; //fault low limit counter
    reg signed [15:0] measured [MAX_ADC_LIMIT:0];  //measured value

    // reg [15:0] config_register [512:0];
    // reg [31:0] io_curr;
    reg [7:0] test_message [6:0];// cmd 1, addres 2, data 4
    reg [15:0] test_message_counter;
    
    reg [7:0] message_send_counter;

    reg [1:0] cmd_done_counter;
    reg [7:0] cmd_reg;
    reg [7:0] response [148:0];
    reg [15:0] response_length;
    
    reg [8:0] address_counter;
    reg [7:0] checksum;
    
    reg [31:0] transition_delay_counter;
    wire system_fault;
    assign system_fault = fault_state[ADDR_TEMPERATURE][1] | fault_state[ADDR_INPUT_270V_VOL][0] | fault_state[ADDR_INPUT_28V_VOL][1] | fault_state[ADDR_INPUT_270V_AMP][1];
    
    parameter [7:0] OUTPUT_ORDER [0:39] = {
        ADDR_INPUT_28V_AMP, ADDR_INPUT_28V_VOL, // current | voltage
        ADDR_OUT_28V_AMP, ADDR_OUT_28V_VOL, // current | voltage
        ADDR_OUT_270V_1_AMP, ADDR_OUT_270V_1_VOL, // current | voltage
        ADDR_OUT_270V_2_AMP, ADDR_OUT_270V_2_VOL, // current | voltage
        ADDR_OUT_270V_3_AMP, ADDR_OUT_270V_3_VOL, // current | voltage
        ADDR_OUT_270V_4_AMP, ADDR_OUT_270V_4_VOL, // current | voltage
        ADDR_OUT_270V_5_AMP, ADDR_OUT_270V_5_VOL, // current | voltage
        8'hff,8'hff,
        8'hff,8'hff,
        8'hff,8'hff,
        8'hff,8'hff,
        8'hff,8'hff,
        8'hff,8'hff,
        8'hff,8'hff,
        8'hff,8'hff,
        8'hff,8'hff,
        8'hff,8'hff,
        8'hff,8'hff,
        8'hff,8'hff,
        8'hff,8'hff
    };
    
    // according to schematic
    parameter [7:0] default_config_map[0:MAX_ADC_LIMIT] = { // adc number to config map
        //0,1,7,8,9
        8'h00, 8'h01, 8'h01, 8'h00, 8'h03, 8'h04, 8'hff, 8'h02,
        8'h03, 8'h04, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff,
        8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff,
        8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff,
        8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff,
        8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff,
        8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff,
        8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff
    };
    
    parameter [15:0] default_config_register[0:29] = {
        //type | ratio | over | under | offset | adjustment
        16'd1,16'd1707,16'd60,16'd0,16'd3300,16'd200,//input current
        16'd0,16'd32886,16'd2900,16'd2500,16'd0,16'd100,//input voltage
        16'd2,16'd161,16'd950,16'd0,16'd500,16'd1,//temperature
        16'd1,16'd1920,16'd370,16'd0,16'd3300,16'd40,//output current(30VDC)
        16'd0,16'd3671,16'd350,16'd250,16'd0,16'd100//output voltage(30VDC)
    };
    
    //for scrd
    reg[31:0] startup_counter;
    reg[2:0] scrd_state;
    
    localparam SCRD_IDLE = 0;
    localparam SCRD_WAIT = 1;
    localparam SCRD_CONVERTER_ON = 2;
    localparam SCRD_DONE = 3;
    
    //for scrd to 
    always@(posedge(clk) or negedge(nrst)) begin
        if(~nrst) begin
            scrd <= 0;
            psu_ond <= 4'b0;
            startup_counter <= 0;
            scrd_state <= SCRD_IDLE;
        end else begin
            case(scrd_state)
                SCRD_IDLE: begin
                    if(measured[ADDR_INPUT_270V_VOL] > 2400) begin//turn on the input when scrd == 0 and input voltage is greater than 250.0V
                        scrd <= 1;
                        scrd_state <= SCRD_WAIT;
                    end
                end
                SCRD_WAIT: begin
                    if(startup_counter <= 1_000_000) begin //10ms
                        startup_counter <= startup_counter + 1;
                    end else begin
                        scrd_state <= SCRD_CONVERTER_ON;
                    end
                
                end
                SCRD_CONVERTER_ON: begin
                    scrd_state <= SCRD_DONE;
                end
                SCRD_DONE: begin
                    if(system_fault) begin
                        psu_ond <= 4'b0;//cpsm should shut down the all converters
                    end else begin
                        psu_ond <= 4'b1111;// on again
                    end
                end
            endcase
        end
    end

// ===============================================
// ===============================================
// start measure, falut gen
    //to adc_ctrl
    reg [3:0] updater_state;
    reg [15:0] source_type;
    reg [15:0] ratio;
    reg signed [15:0] limit_high;
    reg [15:0] limit_low;
    reg signed [15:0] offset;
    reg [15:0] adjustment;
    localparam UPDATER_INIT = 0;
    localparam UPDATER_DELAY = 1;
    localparam UPDATER_ADC_READ_CMD = 2;
    localparam UPDATER_ADC_DECIMALIZE = 3;
    localparam UPDATER_WAIT_CONFIG_STORE_GRANT = 4;
    localparam UPDATER_LOAD_CONFIG_STORE = 5; 
    localparam UPDATER_LOAD_CONFIG_DEFAULT = 6;
    localparam UPDATER_CAL_MUL_RATIO = 7;
    localparam UPDATER_CAL_DIV_HUNDRED = 8;
    localparam UPDATER_WAIT_DIV_HUNDRED = 9;
    localparam UPDATER_CAL_OFFSET = 10;
    localparam UPDATER_CAL_DIV_ADJUST = 11;
    localparam UPDATER_WAIT_DIV_ADJUST = 12;
    localparam UPDATER_UPDATE_FAULT = 13;
    localparam adc_num_input_vol = 0;
    localparam adc_num_input_amp = 1;
    localparam adc_num_temp = 5;
    localparam adc_config_offset = 16;
    localparam VOLTAGE = 0;
    localparam CURRENT = 1;
    localparam TEMPERATURE = 2;
    reg [6:0] adc_number; // 1111111 128

    reg [31:0] delay_counter;
    reg [31:0] adc_decimal;
    reg signed [31:0] signed_temp_register;
    reg [15:0] reg_cfg_addr;
    reg adc_wait_clk;

    reg [2:0] memory_access_counter;
    reg[31:0] limit_value;
    reg[15:0] init_counter;
    integer ii;

    always @(posedge(clk) or negedge(nrst)) begin
        if(~nrst) begin
            updater_state <= UPDATER_INIT;
            init_counter <= 0;
            fault_shutdown <= 1'b1 << 20;
            adc_number <= 0;
            delay_counter <= 0;
            limit_value <= 0;
            adc_decimal <= 0;
            adc_wait_clk <= 0;
            divisor_valid <= 0;
            dividend_valid <= 0;
            div_start <= 0;
            memory_access_counter <= 0;
            for (ii=0;ii<MAX_ADC_LIMIT;ii=ii+1) begin
                fault_high_limit_counter[ii] <= 0;
            end            

        end else begin
            case(updater_state)
                UPDATER_INIT: begin // delay
                    if(init_counter <= MAX_ADC_LIMIT) begin
                        init_counter <= init_counter + 1;
                        if(init_counter < BASIC_ADC_LIMIT) 
                            fault_state[init_counter] <= 1; //set the main fault
                        else
                        fault_state[init_counter] <= 0; //init fault_state

                    end else begin
                        if(main_ready) begin
                            // updater_state <= UPDATER_DELAY;
                            if(delay_counter <= 1_000_000) begin //for the initial delay 10ms
                                delay_counter <= delay_counter + 1;
                            end else begin
                                delay_counter <= 0;
                                updater_state <= UPDATER_DELAY;
                            end
                        end
                    end
                end

                UPDATER_DELAY: begin
                    updater_state <= UPDATER_ADC_READ_CMD; // no delay
                    // if(delay_counter <= 100_000) begin // update on every 0.1 sec
                    //     delay_counter <= delay_counter + 1;
                    // end else begin
                    //     delay_counter <= 0;
                    //     updater_state <= UPDATER_ADC_READ_CMD;
                    // end
                end

                UPDATER_ADC_READ_CMD: begin // read command 
                    if(adc_number <= MAX_ADC_LIMIT) begin // 0 ~ MAX_ADC_LIMIT
                        adc_address <= adc_number;
                        adc_rd <= 1'b1; //read enable
                        updater_state <= UPDATER_ADC_DECIMALIZE;
                    end else begin // 64 ~
                        adc_number <= 0;
                        adc_rd <= 1'b0;
                        updater_state <= UPDATER_DELAY;
                    end
                end

                UPDATER_ADC_DECIMALIZE: begin //read adc and decimalize;
                    //todo: original code
                    if(adc_wait_clk) begin
                        adc_wait_clk <= 0;
                        adc_rd <= 1'b0; //read disable
                        adc_decimal <= ((adc_data >> 4)*250)>>10;
                        updater_state <= UPDATER_LOAD_CONFIG_DEFAULT;
                    end else begin
                        adc_wait_clk <= 1;
                    end
                end
                UPDATER_LOAD_CONFIG_DEFAULT: begin
                    if(default_config_map[adc_number] == 8'hFF) begin
                        measured[adc_number] <= 0;
                        fault_state[adc_number] <= 2'b00;
                        fault_high_limit_counter[adc_number] <= 0;
                        fault_low_limit_counter[adc_number] <= 0;
                        adc_number <= adc_number + 1;
                        updater_state <= UPDATER_ADC_READ_CMD;
                    end else begin
                        source_type <= default_config_register[default_config_map[adc_number]*6];
                        ratio <= default_config_register[default_config_map[adc_number]*6+1];
                        limit_high <= default_config_register[default_config_map[adc_number]*6+2];
                        limit_low <= default_config_register[default_config_map[adc_number]*6+3];
                        offset <= default_config_register[default_config_map[adc_number]*6+4];
                        adjustment <= default_config_register[default_config_map[adc_number]*6+5];
                        updater_state <= UPDATER_CAL_MUL_RATIO;
                    end
                end
                UPDATER_CAL_MUL_RATIO: begin
                    //original voltage in mV Unit
                    adc_decimal <= adc_decimal * ratio; //ratio calculation
                    // temp_register = adc_decimal / 100;// mV
                    updater_state <= UPDATER_CAL_DIV_HUNDRED;
                end
                UPDATER_CAL_DIV_HUNDRED: begin
                    // adc_decimal <= adc_decimal / 100; // in unit of mV
                    dividend <= adc_decimal;
                    divisor <= 32'd100;
                    div_start <= 1;
                    updater_state <= UPDATER_WAIT_DIV_HUNDRED;
                end
                UPDATER_WAIT_DIV_HUNDRED: begin
                    div_start <= 0;
                    if(div_done) begin
                        adc_decimal <= div_dout;
                        updater_state <= UPDATER_CAL_OFFSET;
                    end
                end
                UPDATER_CAL_OFFSET: begin
                    if(source_type == 2) begin // Temperature can be negative value
                        signed_temp_register <= adc_decimal - offset;
                    end else begin
                        if(adc_decimal > offset) begin // other's are not
                            signed_temp_register <= adc_decimal - offset;
                        end else begin
                            signed_temp_register <= 0;
                        end
                    end
                    updater_state <= UPDATER_CAL_DIV_ADJUST;
                end
                UPDATER_CAL_DIV_ADJUST: begin
                    dividend <= signed_temp_register;
                    divisor <= adjustment;
                    div_start <= 1;
                    updater_state <= UPDATER_WAIT_DIV_ADJUST;
                end
                UPDATER_WAIT_DIV_ADJUST: begin
                    div_start <= 0;
                    if(div_done) begin
                        measured[adc_number] <= div_dout;//div_dout[15:0]
                        updater_state <= UPDATER_UPDATE_FAULT;
                    end
                end
                UPDATER_UPDATE_FAULT: begin //adc_number => 0 ~ 64
                    //check limit high
                    limit_value = (source_type == CURRENT) ? 2118 : 74_152; //apsm 9.44 us, adc 6.6ms => 20ms : 700ms
                    if((measured[adc_number] > limit_high) && limit_high != 0) begin //if high limit
                        if(fault_high_limit_counter[adc_number] <= limit_value) begin // if 3 times
                            if(adc_number >= BASIC_ADC_LIMIT && ext_io_set[((default_config_map[adc_number] - 3) >> 1)] == 1'b0) begin // when the output off
                               // fault_high_limit_counter[adc_number] <= 0;//clear the counter
                                fault_shutdown[((default_config_map[adc_number] - 3) >> 1)] <= 0;//clear the fault_shutdown
                            end else begin
                                fault_high_limit_counter[adc_number] <= fault_high_limit_counter[adc_number] + 1;//increase
                            end
                        end else begin
                            if(adc_number >= BASIC_ADC_LIMIT) begin
                                if(ext_io_set[((default_config_map[adc_number] - 3) >> 1)] == 1'b1) begin //if output channel
                                    fault_state[adc_number][1] = 1'b1; //limit high alarm on
                                    fault_shutdown[((default_config_map[adc_number] - 3) >> 1)] <= fault_state[adc_number][1] | fault_state[adc_number][0];//set fault shutdown
                                    fault_high_limit_counter[adc_number] <= 0;//clear the counter
                                end
                            end else begin
                                fault_high_limit_counter[adc_number] <= 0;
                            end
                        end
                    end else begin 
                        fault_high_limit_counter[adc_number] <= 0; //reset fault counter
                        //fault protection off
                        if(adc_number >= BASIC_ADC_LIMIT) begin
                            if(ext_io_set[(default_config_map[adc_number] - 3) >> 1] == 1'b1) begin
                                //if on/off command is set ext_io_set
                                fault_state[adc_number][1] = 0; //alarm off
                                fault_shutdown[((default_config_map[adc_number] - 3) >> 1)] <= fault_state[adc_number][1] | fault_state[adc_number][0];//set fault shutdown
                            end
                        end else begin
                            fault_state[adc_number][1] = 0; //alarm off
                        end
                    end
                    if(measured[adc_number] < limit_low && limit_low != 0) begin
                        if(fault_low_limit_counter[adc_number] < limit_value) begin // 
                            if(adc_number >= BASIC_ADC_LIMIT && ext_io_set[((default_config_map[adc_number] - 3) >> 1)] == 1'b0) begin
                                //fault_low_limit_counter[adc_number] <= 0; //reset the counter
                                fault_shutdown[((default_config_map[adc_number] - 3) >> 1)] <= 0;//output shutdown
                            end else begin
                                fault_low_limit_counter[adc_number] <= fault_low_limit_counter[adc_number] + 1;//increase the counter
                            end
                        end else begin//counter limit over
                            if(adc_number >= BASIC_ADC_LIMIT) begin
                                if(ext_io_set[((default_config_map[adc_number] - 3) >> 1)] == 1'b1) begin
                                    fault_state[adc_number][0] = 1'b1;//output alarm on
                                    fault_shutdown[((default_config_map[adc_number] - 3) >> 1)] <= fault_state[adc_number][1] | fault_state[adc_number][0];//set fault shutdown
                                    fault_low_limit_counter[adc_number] <= 0;
                                end
                            end else begin
                                fault_state[adc_number][0] = 1'b1;//output alarm on
                            end
                        end
                    end else begin
                        fault_low_limit_counter[adc_number] <= 0;//reset fault counter
                        //fault protection off
                        if(adc_number >= BASIC_ADC_LIMIT) begin
                            if(ext_io_set[((default_config_map[adc_number] - 3) >> 1)] == 1'b1) begin
                                fault_state[adc_number][0] = 0; //alarm off
                                fault_shutdown[((default_config_map[adc_number] - 3) >> 1)] <= fault_state[adc_number][1] | fault_state[adc_number][0];//set fault shutdown
                            end
                        end else begin
                            fault_state[adc_number][0] = 0; //alarm off
                        end
                    end
                    adc_number <= adc_number + 1;
                    updater_state <= UPDATER_ADC_READ_CMD;
                end
            endcase
        end
    end

// end measure, falut gen
// ===============================================
// ===============================================



// ===============================================
// packet send

    localparam STATUS_SENDER_IDLE = 0;
    localparam STATUS_SENDER_CHECK_START = 1;
    localparam STATUS_SENDER_OP = 2;
    localparam STATUS_SENDER_EXTRACT_LENGTH_0 = 3;
    localparam STATUS_SENDER_EXTRACT_LENGTH_1 = 4;
    localparam STATUS_SENDER_EXTRACT_INPUT_270V_FAULT = 5;
    localparam STATUS_SENDER_EXTRACT_FAULT = 6;
    localparam STATUS_SENDER_VAL_TEMP_0 = 7;
    localparam STATUS_SENDER_VAL_TEMP_1 = 8;
    localparam STATUS_SENDER_VAL_INPUT_270V_VOL = 9;
    localparam STATUS_SENDER_VAL_INPUT_270V_AMP = 10;
    localparam STATUS_SENDER_EXTRACT_APDU_ADC = 11;
    localparam STATUS_SENDER_EXTRACT_APSM1 = 12;
    localparam STATUS_SENDER_EXTRACT_APSM2 = 13;
    localparam STATUS_SENDER_EXTRACT_CPSM = 14;
    localparam STATUS_SENDER_CHECK_CRC = 15;
    // localparam STATUS_SENDER_END = 11;

    localparam PACKET_CMD = 8'h86;
    localparam PACKET_OP = 8'hD3;
    localparam PACKET_LEN_0 = 8'h02; // 625
    localparam PACKET_LEN_1 = 8'h71;

    reg [7:0] output_order_reg;
    reg [7:0] temp_byte;
    reg [15:0] byte_counter;
    reg [7:0] crc;
    reg [31:0] sec_timer;

    always @ (posedge(clk) or negedge(nrst)) begin
        if(~nrst) begin
            main_ready <= 0;
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
            temp_byte = 0;
            output_order_reg = 0;

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
                    main_ready <= 1;
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
                        status_sender_state <= STATUS_SENDER_EXTRACT_INPUT_270V_FAULT;
                    end else begin
                        status_sender_state <= STATUS_SENDER_IDLE;
                    end
                end

                STATUS_SENDER_EXTRACT_INPUT_270V_FAULT: begin
                    if (arbiter_grant == 1'b1) begin
                        temp_byte = {system_fault,fault_state[ADDR_TEMPERATURE][1], 2'b00, fault_state[ADDR_INPUT_270V_VOL],fault_state[ADDR_INPUT_270V_AMP][1],1'b0};
                        tx_byte <= temp_byte;
                        crc <= crc + temp_byte;
                        byte_counter <= 0;
                        status_sender_state <= STATUS_SENDER_EXTRACT_FAULT;
                    end else begin
                        status_sender_state <= STATUS_SENDER_IDLE;
                    end
                end

                STATUS_SENDER_EXTRACT_FAULT: begin
                    if (arbiter_grant == 1'b1) begin
                        temp_byte = {4'b0,fault_state[OUTPUT_ORDER[(byte_counter << 1)]],fault_state[OUTPUT_ORDER[(byte_counter << 1) + 1]][1],ext_io_set[byte_counter]};//[X][X][X][X][ov][uv][oc][of]
                        tx_byte <= temp_byte;
                        crc <= crc + temp_byte;
                        byte_counter <= byte_counter + 1;
                        if (byte_counter == OUTPUT_NUM - 1) begin // 7 faults
                            byte_counter <= 0;
                            status_sender_state <= STATUS_SENDER_VAL_TEMP_0;
                        end
                    end else begin
                        status_sender_state <= STATUS_SENDER_IDLE;
                    end
                end
                STATUS_SENDER_VAL_TEMP_0: begin
                    if (arbiter_grant == 1'b1) begin
                        temp_byte = measured[ADDR_TEMPERATURE][15:8]; //temperature
                        tx_byte <= temp_byte;
                        crc <= crc + temp_byte;
                        byte_counter <= 0;
                        status_sender_state <= STATUS_SENDER_VAL_TEMP_1;
                    end else begin
                        status_sender_state <= STATUS_SENDER_IDLE;
                    end
                end
                STATUS_SENDER_VAL_TEMP_1: begin
                    if (arbiter_grant == 1'b1) begin
                        temp_byte = measured[ADDR_TEMPERATURE][7:0]; //temperature
                        tx_byte <= temp_byte;
                        crc <= crc + temp_byte;
                        byte_counter <= 0;
                        status_sender_state <= STATUS_SENDER_VAL_INPUT_270V_VOL;
                    end else begin
                        status_sender_state <= STATUS_SENDER_IDLE;
                    end
                end
                STATUS_SENDER_VAL_INPUT_270V_VOL: begin
                    if (arbiter_grant == 1'b1) begin
                        byte_counter <= byte_counter + 1;
                        if (byte_counter == 0) begin // 7 faults
                            temp_byte = measured[ADDR_INPUT_270V_VOL][15:8]; //input voltage
                        end else begin
                            temp_byte = measured[ADDR_INPUT_270V_VOL][7:0]; //input voltage
                            byte_counter <= 0;
                            status_sender_state <= STATUS_SENDER_VAL_INPUT_270V_AMP;
                        end
                        tx_byte <= temp_byte;
                        crc <= crc + temp_byte;
                    end else begin
                        status_sender_state <= STATUS_SENDER_IDLE;
                    end
                end
                STATUS_SENDER_VAL_INPUT_270V_AMP: begin
                    if (arbiter_grant == 1'b1) begin
                        byte_counter <= byte_counter + 1;
                        if (byte_counter == 0) begin // 7 faults
                            temp_byte = measured[ADDR_INPUT_270V_AMP][15:8]; //input amp
                        end else begin
                            temp_byte = measured[ADDR_INPUT_270V_AMP][7:0]; //input amp
                            byte_counter <= 0;
                            status_sender_state <= STATUS_SENDER_EXTRACT_APDU_ADC;
                        end
                        tx_byte <= temp_byte;
                        crc <= crc + temp_byte;
                    end else begin
                        status_sender_state <= STATUS_SENDER_IDLE;
                    end
                end
                STATUS_SENDER_EXTRACT_APDU_ADC: begin
                    if (arbiter_grant == 1'b1) begin
                        byte_counter <= byte_counter + 1;
                        output_order_reg = OUTPUT_ORDER[byte_counter]; // voltage, current
                        if (byte_counter[0] == 0) begin
                            temp_byte = measured[output_order_reg][15:8]; // upper byte
                        end else begin
                            temp_byte = measured[output_order_reg][7:0]; // lower byte
                        end
                        tx_byte <= temp_byte;
                        crc <= crc + temp_byte;
                        if (byte_counter == OUTPUT_NUM_4 - 1) begin // 7*4
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

    // ext_io control
    always @ (posedge(clk) or negedge(nrst)) begin
        if(~nrst) begin
            ext_io_set <= 0;
            ext_io_disable <= 0;
            ext_io_wr <= 0;
        end else begin
            ext_io_disable <= 0;
            ext_io_wr <= 1;
            if (cmd_parser_io_wr == 1'b1) begin
                ext_io_set <= cmd_parser_io_set & ~(fault_shutdown[19:0]) & {32{~system_fault}}; // current io & fault shutdown & system fault
            end else begin
                ext_io_set <= ext_io_set & ~(fault_shutdown[19:0]) & {32{~system_fault}}; // current io & fault shutdown & system fault;
            end
        end
    end


endmodule
