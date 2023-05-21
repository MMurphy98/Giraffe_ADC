`timescale  1ns / 1ps

module tb_Giraffe_ADC;

// Giraffe_ADC Parameters
parameter PERIOD       = 20        ;
parameter BAUDRATE     = 115200    ;
parameter FREQ         = 50_000_000;
parameter N_start      = 1         ;
parameter N_data       = 8         ;
parameter N_stop       = 1         ;
parameter N_bit        = 6         ;
parameter NUM_DIV      = 1     ;
parameter NUM_Sampled  = 32      ;


// Giraffe_ADC Inputs
reg   clk_50M                              = 0 ;
reg   nrst                                 = 0 ;
reg   calib_ena_FPGA                       = 0 ;
reg   system_ena                           = 1 ;
reg   adc_ack                              = 0 ;
reg   adc_ack_sub                          = 0 ;
reg   [N_bit-1:0]  dout_adc                = 0 ;

// Giraffe_ADC Outputs
wire  [3:0]  LED_out                       ;
wire  tx2M                                 ;
wire  rstn_adc                             ;
wire  clk_adc                              ;
wire  calib_ena_adc                        ;
wire  adc_ena                              ;


initial
begin
    forever #(PERIOD/2)  clk_50M=~clk_50M;
end

initial
begin
    #(PERIOD*2) nrst  =  1;
end

Giraffe_ADC #(
    .BAUDRATE    ( BAUDRATE    ),
    .FREQ        ( FREQ        ),
    .N_start     ( N_start     ),
    .N_data      ( N_data      ),
    .N_stop      ( N_stop      ),
    .N_bit       ( N_bit       ),
    .NUM_DIV     ( NUM_DIV     ),
    .NUM_Sampled ( NUM_Sampled ))
 u_Giraffe_ADC (
    .clk_50M                 ( clk_50M                     ),  
    .nrst                    ( nrst                        ),  
    .calib_ena_FPGA          ( calib_ena_FPGA              ),  
//    .system_ena              ( system_ena                  ),  
    .adc_ack                 ( adc_ack                     ),  
    .adc_ack_sub             ( adc_ack_sub                 ),  
    .dout_adc                ( dout_adc        [N_bit-1:0] ),  

    .LED_out                 ( LED_out         [3:0]       ),  
    .tx2M                    ( tx2M                        ),  
    .rstn_adc                ( rstn_adc                    ),  
    .clk_adc                 ( clk_adc                     ),  
    .calib_ena_adc           ( calib_ena_adc               ),  
    .adc_ena                 ( adc_ena                     )   
);

initial
begin

    $finish;
end
reg [7:0] cnt_ack, cnt_ack_sub;
always @(posedge clk_adc or negedge rstn_adc) begin
    if (!rstn_adc) begin
        cnt_ack_sub <= 8'd0;
        cnt_ack <= 8'd0;
    end else begin
        if (cnt_ack < 8'd39) begin
            cnt_ack <= cnt_ack + 8'd1;
            adc_ack <= 1'd0;
        end else begin
            cnt_ack <= 8'd0;
            adc_ack <= 1'd1;
        end

        if (cnt_ack_sub < 8'd9) begin
            cnt_ack_sub <= cnt_ack_sub + 8'd1;
            adc_ack_sub <= 1'd0;
        end else begin
            cnt_ack_sub <= 8'd0;
            adc_ack_sub <= 1'd1;
        end
    end
end
endmodule