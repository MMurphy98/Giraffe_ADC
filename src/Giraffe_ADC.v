module Giraffe_ADC #(
    // Parameters for UART
    parameter BAUDRATE = 256000,            // Maximum: 256000
    parameter FREQ = 50_000_000,
    parameter N_start = 1,
    parameter N_data = 8,
    parameter N_stop = 1,
    
    // Number of Sub-ADC bit
    parameter N_bit = 6,

    // Clock divider
    parameter NUM_DIV = 5_00,

    // Number of Sampled Points
    parameter NUM_Sampled = 102400
)
(


    //  FPGA Board
    input                   clk_50M,
    input                   nrst,
    input                   calib_ena_FPGA,
    input  [8:0]            sw_NOWA,

//    input                   system_ena,
    output	[3:0]	        LED_out,
    output [17:0]           LED_cnt_send,
    output [3:0]            LED_state,

    // UART TX
    output                  tx2M,
	 input						 rxfM,
	 
    // Control the ADC
    output                  rstn_adc,
    output                  clk_adc,
	 output					    clk_ultra,
    output                  calib_ena_adc,
	output				    adc_ena,
    output  [8:0]           NOWA_adc,
    input                   adc_ack,
    input                   adc_ack_sub,
    input   [N_bit-1:0]     dout_adc,

    // To caparray
    output                  cap_rstn
    // output                  cap_comp_ena,
    // output                  cap_wena,
    // output                  cap_rena,
    // output                  cap_sh_vin,
    // output  [4:0]           cap_position,
    // output  [2:0]           cap_coefficent_in,
    // output                  cap_read_ack
);

    // assign the digital control IO of Cap Array
    assign cap_rstn = nrst_reg;
    // assign cap_comp_ena = 1'd0;
    // assign cap_wena = 1'd0;
    // assign cap_rena = 1'd0;
    // assign cap_sh_vin = 1'd0;
    // assign cap_position = 5'd0;
    // assign cap_coefficent_in = 3'd0;
    // assign cap_read_ack = 1'd0;



    
    wire ack_unit = (adc_ack) | (adc_ack_sub);
    reg adc_ena_reg;
      
    
  



    wire uart_wreq;
    wire [N_data-1:0] uart_wdata;
    // wire [N_data-1:0]   sample_data;
    wire sample_trigger;
	 
	reg [N_data-1:0]		uart_wdata_reg;
	reg 		            uart_wreq_reg;

    assign uart_wreq = uart_wreq_reg;
    assign uart_wdata = uart_wdata_reg;
    
	my_PLL2 u_my_PLL (
        .areset                 (~nrst),
        .inclk0                 (clk_50M),
        .c0                     (clk_adc),      // 50MHz
        .c1					    (clk_uart)      // 50MHz
    );
//
//    PLL_up inst_PLL_up (
//        .areset                 (~nrst),
//        .inclk0                 (clk_50M),
//        .c0                     (clk_adc)
//    );

  	uart_tx #(
        .BAUDRATE               (BAUDRATE), 
        .FREQ                   (FREQ), 
        .N_start                (N_start), 
        .N_data                 (N_data), 
        .N_stop                 (N_stop)) 
	u_uart_tx (
        .clk                    (clk_uart),
        .nrst                   (nrst),
        .wreq	                (uart_wreq),
        .tx		                (tx2M),
        .wdata	                (uart_wdata),
        .rdy                    (uart_rdy)

    );
	 
	uart_rx #(
		.BAUDRATE(BAUDRATE), 
		.FREQ(FREQ), 
		.N_start(N_start), 
		.N_data(N_data), 
		.N_stop(N_stop))
	Inst_uart_rx (
	 		.clk    (clk_uart),
	 		.nrst   (nrst),
	 		.rx     (rxfM),
	 		.rdata  (rdata),
			.vld	(vld)           // reset whole A/D system via UART host;
	   );
    
	 
	 
	 
    reg [7:0] cnt_ena_period;
//    reg [7:0] cnt_ena;            // set bit-width of cnt_ena = 8 for debug;
    reg [31:0] cnt_ena;
    
    reg leds_ena;

    reg [3:0]   cs,ns;
    // IDLE -> RESET -> SAMPLE -> SEND -> HOLD 
    parameter IDLE = 4'd0;          
    parameter SAMPLE = 4'd1;        // sample the digital data from Chip
    parameter SEND = 4'd2;          // sending the data to PC by UART
    parameter HOLD = 4'd3;          // hold the data and wait for reset
    parameter RESET = 4'd4;         // reset all devices beforem sample

    // one sampled data would be tranmiitted to FPGA in 4 times
    localparam memory_deepth = NUM_Sampled*4;       
    
    localparam uart_period = FREQ / BAUDRATE;
    localparam RESET_PERIOD = 1_000;

    // Assign reg my_memory as M9K block memory 
	(* regstyle = "M9K" *) reg [5:0] my_memory [memory_deepth-1:0];

    // ********************** FSM **********************
    // always @(posedge clk_adc or negedge nrst) begin
    //     if (!nrst) begin
    //         cs <= IDLE;
    //     end else if (clk_adc) begin
    //         cs <= ns;
    //     end
    // end

    always @(posedge clk_adc or negedge nrst) begin
        if (!nrst) begin
            cs <= IDLE;
        end 
//        else if (vld) begin
//            cs <= IDLE;
//        end 
        else if (clk_adc) begin
            cs <= ns;
        end
    end

    // **** IDLE -> RESET: after 1 clock;
    // **** RESET -> SAMPLE: after RESET_PERIOD clocks;
    // **** SAMPLE -> SEND: after sending NUM_Sampled enas to Chip 
    // ******** and reviceed memory_deepth acks from Chip
    // **** SEND -> HOLD: after sending memory_deepth data to PC
    // **** HOLD: waiting for reset 
    always @(cs, nrst, cnt_ena, cnt_received, uart_cnt_send, cnt_reset, vld) begin
        if (!nrst) begin
            ns = IDLE;
        end 
        else begin
            // if (vld) begin
            //     ns = IDLE;
            // end
//            //else begin
                case (cs)
                    IDLE :
                            ns = RESET;

                    RESET :
                        if (cnt_reset == RESET_PERIOD)
                            ns = SAMPLE;
                        else
                            ns = RESET;
                    
                    SAMPLE :
                        if (cnt_ena == (NUM_Sampled ) && cnt_received == (memory_deepth))
                            ns = SEND;
                        else
                            ns = SAMPLE;
                    
                    SEND :
                        if (uart_cnt_send == (memory_deepth))
                            ns = HOLD;
                        else
                            ns = SEND;
                    
                    HOLD :
                        if (vld) 
                            ns = IDLE;
                        else
                            ns = HOLD;

                    default : ns = ns;
                endcase
            end
    end

    reg [31:0]  uart_cnt_clk;
    // reg [31:0]  uart_index;
    reg [31:0]  uart_cnt_send;
    reg leds_uart;

    //  Control the output signal to UART by FSM(SEND)
    // always @(posedge clk_adc or negedge nrst) begin
    //     if (!nrst) begin
    //         uart_cnt_clk <= 32'd0; 
    //         uart_wdata_reg <= 8'd0;
    //         uart_wreq_reg <= 1'd0;
    //         // uart_index <= 32'd0;
    //         uart_cnt_send <= 32'd0;
    //         leds_uart <= 1'd0;
    //     end 
    //     else if (ns == SEND) begin
    //         if (uart_cnt_send < memory_deepth ) begin
    //             if (uart_cnt_clk == uart_period * 11) begin
    //                 uart_wdata_reg <= {2'b00,my_memory[uart_cnt_send]};
    //                 uart_cnt_clk <= uart_cnt_clk + 32'd1;
    //                 uart_wreq_reg <= 1'd0;
    //             end else if (uart_cnt_clk == uart_period * 12) begin
    //                 uart_wreq_reg <= 1'd1;
    //                 uart_cnt_send <= uart_cnt_send + 32'd1; 
    //                 uart_cnt_clk <= 32'd0;               
    //             end else begin
    //                 uart_cnt_clk <= uart_cnt_clk + 32'd1;
    //                 uart_wreq_reg <= 1'd0;
    //             end
    //         end else begin
    //             uart_wreq_reg <= 1'd0;
    //             uart_cnt_clk <= uart_cnt_clk;
    //             uart_cnt_send <= uart_cnt_send;
    //             leds_uart <= 1'd1;  
    //         end
    //     end else if (ns == HOLD) begin
    //             uart_wreq_reg <= 1'd0;
    //             uart_cnt_clk <= uart_cnt_clk;
    //             uart_cnt_send <= uart_cnt_send;
    //             leds_uart <= 1'd1;           
    //     end
    // end

    // genearte wreq and wdata for uart_tx
    always @(posedge clk_uart or negedge nrst) begin

        if (!nrst) begin
            uart_cnt_clk <= 32'd0; 
            uart_wdata_reg <= 8'd0;
            uart_wreq_reg <= 1'd0;
            // uart_index <= 32'd0;
            uart_cnt_send <= 32'd0;
            leds_uart <= 1'd0;
        end 
        else if (vld) begin
            uart_cnt_clk <= 32'd0; 
            uart_wdata_reg <= 8'd0;
            uart_wreq_reg <= 1'd0;
            // uart_index <= 32'd0;
            uart_cnt_send <= 32'd0;
            leds_uart <= 1'd0;
        end 
        else if (ns == SEND) begin
            if (uart_cnt_send < memory_deepth ) begin
                if (uart_cnt_clk == uart_period * 11) begin
                    uart_wdata_reg <= {2'b00,my_memory[uart_cnt_send]};
                    uart_cnt_clk <= uart_cnt_clk + 32'd1;
                    uart_wreq_reg <= 1'd0;
                end else if (uart_cnt_clk == uart_period * 12) begin
                    uart_wreq_reg <= 1'd1;
                    uart_cnt_send <= uart_cnt_send + 32'd1; 
                    uart_cnt_clk <= 32'd0;               
                end else begin
                    uart_cnt_clk <= uart_cnt_clk + 32'd1;
                    uart_wreq_reg <= 1'd0;
                end
            end else begin
                uart_wreq_reg <= 1'd0;
                uart_cnt_clk <= uart_cnt_clk;
                uart_cnt_send <= uart_cnt_send;
                leds_uart <= 1'd1;  
            end
        end else if (ns == HOLD) begin
                uart_wreq_reg <= 1'd0;
                uart_cnt_clk <= uart_cnt_clk;
                uart_cnt_send <= uart_cnt_send;
                leds_uart <= 1'd1;           
        end
    end

    reg nrst_reg;
    reg [31:0] cnt_reset;
    reg leds_reset;
    // always @(posedge clk_adc or negedge nrst) begin
    //     if (!nrst) begin
    //         cnt_reset <= 32'd0;
    //         nrst_reg <= 1'd1;
    //         leds_reset <= 1'd0;
    //     end else if (ns == RESET) begin
    //         if (cnt_reset < RESET_PERIOD) begin
    //             cnt_reset <= cnt_reset + 32'd1;
    //             nrst_reg <= 1'd0;
    //             leds_reset <= 1'd1;
    //         end else begin
    //             cnt_reset <= cnt_reset;
    //             nrst_reg <= 1'd1;
    //             leds_reset <= 1'd0;
    //         end
    //     end else begin
    //         cnt_reset <= cnt_reset;
    //         nrst_reg <= 1'd1; 
    //         leds_reset <= 1'd0;           
    //     end
    // end

    // reset system before A/D;
    always @(posedge clk_adc or negedge nrst) begin
        if (!nrst) begin
            cnt_reset <= 32'd0;
            nrst_reg <= 1'd1;
            leds_reset <= 1'd0;
        end 
        else if (vld) begin
            cnt_reset <= 32'd0;
            nrst_reg <= 1'd1;
            leds_reset <= 1'd0;        
        end
        else if (ns == RESET) begin
            if (cnt_reset < RESET_PERIOD) begin
                cnt_reset <= cnt_reset + 32'd1;
                nrst_reg <= 1'd0;
                leds_reset <= 1'd1;
            end else begin
                cnt_reset <= cnt_reset;
                nrst_reg <= 1'd1;
                leds_reset <= 1'd0;
            end
        end else begin
            cnt_reset <= cnt_reset;
            nrst_reg <= 1'd1; 
            leds_reset <= 1'd0;           
        end
    end

    //  Control the output signal to Chip by FSM(SAMPLE)
	//  always @(posedge clk_adc or negedge nrst) begin
	// 	if (!nrst ) begin
	// 		cnt_ena_period <= 8'd0;
	// 		adc_ena_reg <= 1'd0;
    //         cnt_ena <= 32'd0;	
    //         leds_ena <= 1'd0;	
	// 	end else if (ns == SAMPLE) begin
    //         if (cnt_ena < NUM_Sampled) begin
    //             if (cnt_ena_period == 8'd24) begin
    //                 cnt_ena_period <= 8'd0;
    //                 adc_ena_reg <= 1'd1;
    //                 cnt_ena <= cnt_ena + 32'd1;
            
    //             end else begin
    //                 cnt_ena_period <= cnt_ena_period + 8'd1;
    //                 adc_ena_reg <= 1'd0;
    //                 cnt_ena <= cnt_ena;
    //             end
    //         end else begin
    //             adc_ena_reg <= 1'd0;
    //             cnt_ena <= cnt_ena;
    //             cnt_ena_period <= cnt_ena_period;
    //             leds_ena <= 1'd1;

    //         end
    //     end 
	// end

    // send the adc_ena periodically and count the number
    always @(posedge clk_adc or negedge nrst) begin
		if (!nrst ) begin
			cnt_ena_period <= 8'd0;
			adc_ena_reg <= 1'd0;
            cnt_ena <= 32'd0;	
            leds_ena <= 1'd0;	
		end 
        else if (vld) begin
			cnt_ena_period <= 8'd0;
			adc_ena_reg <= 1'd0;
            cnt_ena <= 32'd0;	
            leds_ena <= 1'd0;        
        end
        else if (ns == SAMPLE) begin
            if (cnt_ena < NUM_Sampled) begin
                if (cnt_ena_period == 8'd24) begin
                    cnt_ena_period <= 8'd0;
                    adc_ena_reg <= 1'd1;
                    cnt_ena <= cnt_ena + 32'd1;
            
                end else begin
                    cnt_ena_period <= cnt_ena_period + 8'd1;
                    adc_ena_reg <= 1'd0;
                    cnt_ena <= cnt_ena;
                end
            end else begin
                adc_ena_reg <= 1'd0;
                cnt_ena <= cnt_ena;
                cnt_ena_period <= cnt_ena_period;
                leds_ena <= 1'd1;

            end
        end 
	end

    // delay module to capture the posedge of ack;
    // *_delay2 is unused;
    reg ack_unit_delay, adc_ack_delay;
	reg ack_unit_delay2, adc_ack_delay2;
    always @(posedge clk_adc or negedge nrst) begin
        if (!nrst) begin
            ack_unit_delay <= 1'd0;
            adc_ack_delay <= 1'd0;

        end 
        else if (vld) begin
            ack_unit_delay <= 1'd0;
            adc_ack_delay <= 1'd0;        
        end
        else begin
            ack_unit_delay <= ack_unit;
            adc_ack_delay <= adc_ack;
        end
    end

    always @(posedge clk_adc or negedge nrst) begin
        if (!nrst) begin
            ack_unit_delay2 <= 1'd0;
            adc_ack_delay2 <= 1'd0;
        end 
        else if (vld) begin
            ack_unit_delay2 <= 1'd0;
            adc_ack_delay2 <= 1'd0;        
        end
        else begin
            ack_unit_delay2 <= ack_unit_delay;
            adc_ack_delay2 <= adc_ack_delay;
        end
    end

    // use the delay block to catch the ack signal 
    assign sample_trigger = (~ack_unit_delay) & ack_unit;


    reg [31:0] cnt_received;
    reg leds_received; 

    //  Control the output signal to Chip by FSM(SAMPLE)
    // always @(posedge clk_adc or negedge nrst) begin
    //     if (!nrst) begin
    //         cnt_received <= 32'd0;
    //         leds_received <= 1'd0;

    //     end else if (ns == SAMPLE) begin
    //         if (sample_trigger == 1) begin
    //             if (cnt_received < memory_deepth) begin
    //                 cnt_received <= cnt_received + 32'd1;
    //                 if (adc_ack) begin
    //                     // use the highest bit 11 to represent the fourth data
    //                     my_memory[cnt_received] <= {dout_adc};
    //                 end else begin
    //                     my_memory[cnt_received] <= {dout_adc};
    //                 end
    //                 leds_received <= 1'd1;
                        
    //             end else begin
    //                 cnt_received <= cnt_received;
    //             end
    //         end
    //     end else begin
    //         leds_received <= 1'd0;
    //     end
    // end

    //  count number of received ack and store the dout of adc
    always @(posedge clk_adc or negedge nrst) begin
        if (!nrst) begin
            cnt_received <= 32'd0;
            leds_received <= 1'd0;

        end 
        else if (vld) begin
            cnt_received <= 32'd0;
            leds_received <= 1'd0;
        end
        else if (ns == SAMPLE) begin
            if (sample_trigger == 1) begin
                if (cnt_received < memory_deepth) begin
                    cnt_received <= cnt_received + 32'd1;
                    if (adc_ack) begin
                        // use the highest bit 11 to represent the fourth data
                        my_memory[cnt_received] <= {dout_adc};
                    end else begin
                        my_memory[cnt_received] <= {dout_adc};
                    end
                    leds_received <= 1'd1;
                        
                end else begin
                    cnt_received <= cnt_received;
                end
            end
        end else begin
            leds_received <= 1'd0;
        end
    end


    // Number of wait control
    reg [8:0]   NOWA_adc_reg;
    always @(posedge clk_adc or negedge nrst) begin
        if (!nrst) begin
            NOWA_adc_reg <= 9'd0;
        end else begin
            NOWA_adc_reg <= sw_NOWA;
        end
    end



    // output assignments
    assign LED_out = {leds_reset, leds_uart, leds_received, leds_ena};
    assign LED_cnt_send = cnt_received;

    assign  rstn_adc = nrst_reg;
    assign  calib_ena_adc = calib_ena_FPGA;
    assign adc_ena = adc_ena_reg; 
    assign LED_state = cs;

    assign NOWA_adc = NOWA_adc_reg;

endmodule