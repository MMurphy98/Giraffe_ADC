module Giraffe_ADC #(
    // Parameters for UART
    parameter BAUDRATE = 115200,
    parameter FREQ = 50_000_000,
    parameter N_start = 1,
    parameter N_data = 8,
    parameter N_stop = 1,
    
    // Number of Sub-ADC bit
    parameter N_bit = 6,

    // Clock divider
    parameter NUM_DIV = 5_00,

    // Number of Sampled Points
    parameter NUM_Sampled = 1024
)
(
    //  FPGA Board
    input                   clk_50M,
    input                   nrst,
    input                   calib_ena_FPGA,
//    input                   system_ena,
    output	[3:0]	        LED_out,
    output [17:0]           LED_cnt_send,

    
    // UART TX
    output                  tx2M,

	 
	 
    // Control the ADC
    output                  rstn_adc,
    output                  clk_adc,
    output                  calib_ena_adc,
	output				    adc_ena,
    input                   adc_ack,
    input                   adc_ack_sub,
    input   [N_bit-1:0]     dout_adc


);
    wire ack_unit = (adc_ack) | (adc_ack_sub);
    reg adc_ena_reg;
      
    
    assign LED_out = {leds_uart, leds_received, leds_ena};
  
    assign adc_ena = adc_ena_reg;
    assign  rstn_adc = nrst;
    assign  calib_ena_adc = calib_ena_FPGA;

    wire uart_wreq;
    wire [N_data-1:0] uart_wdata;
    // wire [N_data-1:0]   sample_data;
    wire sample_trigger;
	 
	reg [N_data-1:0]		uart_wdata_reg;
	reg 		            uart_wreq_reg;

    assign uart_wreq = uart_wreq_reg;
    
    
    assign uart_wdata = uart_wdata_reg;
    assign LED_cnt_send = cnt_received[17:0];
    
//	assign LED_out = uart_wdata;
    clk_div #(
        .NUM_DIV ( NUM_DIV ))
    u_clk_div (
        .clk_50M                 ( clk_50M   ),
        .nrst                    ( nrst      ),

        .clk_out                 ( clk_adc   )
    );

  	uart_tx #(
        .BAUDRATE               (BAUDRATE), 
        .FREQ                   (FREQ), 
        .N_start                (N_start), 
        .N_data                 (N_data), 
        .N_stop                 (N_stop)) 
	u_uart_tx (
        .clk                    (clk_50M),
        .nrst                   (nrst),
        .wreq	                (uart_wreq),
        .tx		                (tx2M),
        .wdata	                (uart_wdata),
        .rdy                    (uart_rdy)

    );
	 

    
    reg [7:0] cnt_ena_period;
    reg [31:0] cnt_ena;
    
    reg leds_ena;


    reg [3:0]   cs,ns;
    parameter IDLE = 4'd0;
    parameter SAMPLE = 4'd1;
    parameter SEND = 4'd2;
    parameter HOLD = 4'd3;

    localparam memory_deepth = NUM_Sampled*4;
    localparam uart_period = FREQ / BAUDRATE;
	(* regstyle = "M9K" *) reg [7:0] my_memory [memory_deepth-1:0];
//    reg [7:0] my_memory [memory_deepth-1:0];
    always @(posedge clk_50M or negedge nrst) begin
        if (!nrst) begin
            cs <= IDLE;
        end else if (clk_50M) begin
            cs <= ns;
        end
    end

    always @(cs, nrst, cnt_ena, cnt_received, uart_cnt_send) begin
        if (!nrst) begin
            ns = IDLE;
        end else begin
            case (cs)
                IDLE :
                        ns = SAMPLE;
                
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
                        ns = HOLD;

                default : ns = ns;
            endcase
        end
    end

    reg [31:0]  uart_cnt_clk;
    // reg [31:0]  uart_index;
    reg [31:0]  uart_cnt_send;
    reg leds_uart;
    always @(posedge clk_50M or negedge nrst) begin
        if (!nrst) begin
            uart_cnt_clk <= 32'd0; 
            uart_wdata_reg <= 8'd0;
            uart_wreq_reg <= 1'd0;
            // uart_index <= 32'd0;
            uart_cnt_send <= 32'd0;
            leds_uart <= 1'd0;
        end else if (ns == SEND) begin
            if (uart_cnt_send < memory_deepth ) begin
                if (uart_cnt_clk == uart_period * 11) begin
                    uart_wdata_reg <= my_memory[uart_cnt_send];
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


        //     if (uart_cnt_clk == uart_period * 12) begin
        //         uart_cnt_clk <= 32'd0;
        //         if (uart_cnt_send < memory_deepth - 1 ) begin
        //             uart_wreq_reg <= 1'd1;
        //             uart_cnt_send <= uart_cnt_send + 32'd1;
        //         end else begin
        //             uart_wreq_reg <= 1'd0;
        //             leds_uart <= 1'd1;
        //         end
        //     end else if (uart_cnt_clk == uart_period * 11) begin
        //         if (uart_cnt_send < memory_deepth - 1 ) begin
        //             uart_wdata_reg <= my_memory[uart_cnt_send];
        //             uart_cnt_clk <= uart_cnt_clk + 32'd1;
        //         end else begin
        //             uart_wdata_reg <= 1'd0;
        //         end
        //     end else begin
        //         uart_cnt_clk <= uart_cnt_clk + 32'd1;
        //         uart_wdata_reg <= uart_wdata_reg;
        //         uart_wreq_reg <= 1'd0;
        //     end
        // end else begin
        //     uart_cnt_clk <= uart_cnt_clk; 
        //     uart_wdata_reg <= uart_wdata_reg;
        //     uart_wreq_reg <= uart_wreq_reg;
        //     uart_cnt_send <= uart_cnt_send; 
        //     leds_uart <= leds_uart;  
        // end
            
    end


	 always @(posedge clk_adc or negedge nrst) begin
		if (!nrst ) begin
			cnt_ena_period <= 8'd0;
			adc_ena_reg <= 1'd0;
            cnt_ena <= 32'd0;	
            leds_ena <= 1'd0;	
		end else begin
            if (cnt_ena < NUM_Sampled) begin
                if (cnt_ena_period == 8'd50) begin
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
	 

    reg ack_unit_delay, adc_ack_delay;
	reg ack_unit_delay2, adc_ack_delay2;
    always @(posedge clk_50M or negedge nrst) begin
        if (!nrst) begin
            ack_unit_delay <= 1'd0;
            adc_ack_delay <= 1'd0;

        end else begin
            ack_unit_delay <= ack_unit;
            adc_ack_delay <= adc_ack;
        end
    end

    always @(posedge clk_50M or negedge nrst) begin
        if (!nrst) begin
            ack_unit_delay2 <= 1'd0;
            adc_ack_delay2 <= 1'd0;
        end else begin
            ack_unit_delay2 <= ack_unit_delay;
            adc_ack_delay2 <= adc_ack_delay;
        end
    end

    assign sample_trigger = (~ack_unit_delay) & ack_unit;

    // assign sample_data = (ack_unit_delay2 & adc_ack_delay2)? {2'b11, dout_adc} : {2'b00, dout_adc};

    reg [31:0] cnt_received;
    reg leds_received; 
    always @(posedge clk_50M or negedge nrst) begin
        if (!nrst) begin
            cnt_received <= 32'd0;
            leds_received <= 1'd0;

        end else if (ns == SAMPLE) begin
            if (sample_trigger == 1) begin
                if (cnt_received < memory_deepth) begin
                    cnt_received <= cnt_received + 32'd1;
                    if (adc_ack) begin
                        my_memory[cnt_received] <= {2'b11, dout_adc};
                    end else begin
                        my_memory[cnt_received] <= {2'b00, dout_adc};
                    end
                    leds_received <= 1'd1;
                        
                end else begin
                    cnt_received <= cnt_received;
                end
            end
        end
    end

//     integer k;
//     always @(posedge clk_50M or negedge nrst) begin
//         if (!nrst) begin
//             cnt_received <= 32'd0;
//             leds_received <= 1'd0;
// //            for (k=0; k<memory_deepth-1; k=k+1) begin
// //                my_memory[k] = 8'd0;
// //            end
//         end else if (sample_trigger == 1) begin
//             if (cnt_received < memory_deepth-1) begin
//                 cnt_received <= cnt_received + 32'd1;
//                 if (adc_ack_delay2)
//                     my_memory[cnt_received] <= {2'b11, dout_adc};
//                 else
//                     my_memory[cnt_received] <= {2'b00, dout_adc};
//             end else begin
//                 cnt_received <= cnt_received;
//                 leds_received <= 1'd1;
//             end
//         end
//     end

endmodule