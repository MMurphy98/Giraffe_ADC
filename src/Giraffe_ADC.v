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
    parameter NUM_DIV = 5_000
)
(
    //  FPGA Board
    input                   clk_50M,
    input                   nrst,
    input                   calib_ena_FPGA,
    
    // UART TX
    output                  tx2M,

    // Control the ADC
    output                  rstn_adc,
    output                  clk_adc,
    output                  calib_ena_adc,
	 output						 adc_ena,
    input                   adc_ack,
    input                   adc_ack_sub,
    input   [N_bit-1:0]     dout_adc
//	 output	[N_data-1:0]	 LED_out


);
    wire ack_unit = (adc_ack) | (adc_ack_sub);

    assign  rstn_adc = nrst;
    assign  calib_ena_adc = calib_ena_FPGA;
    wire [N_data-1:0]   uart_wdata;
    wire uart_wreq;
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
	 
	 reg adc_ena_reg;
	 
	 assign adc_ena = adc_ena_reg;
	 
	 reg [7:0] cnt_ena;
	 
	 always @(posedge clk_adc or negedge nrst) begin
		if (!nrst) begin
			cnt_ena <= 8'd0;
			adc_ena_reg <= 1'd0;
		end else begin
			if (cnt_ena == 8'd50) begin
				cnt_ena <= 8'd0;
				adc_ena_reg <= 1'd1;
			end else begin
				cnt_ena <= cnt_ena + 8'd1;
				adc_ena_reg <= 1'd0;
			end
		end
	end
	 
    
    // Giraffe_FSM #(
    //     .N_bit                  (N_bit),
    //     .N_data                 (N_data)
    // )
    // u_Giraffe_FSM (
    //     .clk                    (clk_50M),
    //     .nrst                   (nrst),
    //     .adc_ack                (adc_ack),
    //     .adc_ack_sub            (adc_ack_sub),
    //     .dout_adc               (dout_adc),
        
    //     .uart_rdy               (uart_rdy),
    //     .wreq                   (uart_wreq),
    //     .wdata                  (uart_wdata)
    // );
    reg ack_unit_delay;
	 reg ack_unit_delay2;
    always @(posedge clk_50M or negedge nrst) begin
        if (!nrst) begin
            ack_unit_delay <= 1'd0;
        end else begin
            ack_unit_delay <= ack_unit;
        end
    end

    always @(posedge clk_50M or negedge nrst) begin
        if (!nrst) begin
            ack_unit_delay2 <= 1'd0;
        end else begin
            ack_unit_delay2 <= ack_unit_delay;
        end
    end

    assign uart_wreq = (~ack_unit_delay) & ack_unit;

    assign uart_wdata = (ack_unit & adc_ack)? {2'b11, dout_adc} : {2'b00, dout_adc};
    
endmodule