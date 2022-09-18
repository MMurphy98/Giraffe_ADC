`timescale  1ns / 1ps

module tb_Giraffe;

// Giraffe Parameters
parameter PERIOD    = 20        ;
parameter BAUDRATE  = 1_200_000 ;
parameter FREQ      = 50_000_000;
parameter N_start   = 1         ;
parameter N_data    = 8         ;
parameter N_stop    = 1         ;
parameter N_bit     = 6         ;
parameter NUM_DIV   = 5_000     ;

// Giraffe Inputs
reg   clk_50M                              = 0 ;
reg   nrst                                 = 0 ;
reg   calib_ena_FPGA                       = 0 ;
reg   adc_ack                              = 0 ;
reg   adc_ack_sub                          = 0 ;
reg   [N_bit-1:0]  dout_adc                = 0 ;

// Giraffe Outputs
wire  tx2M                                 ;
wire  rstn_adc                             ;
wire  clk_adc                              ;
wire  calib_ena_adc                        ;


initial
begin
    forever #(PERIOD/2)  clk_50M=~clk_50M;
end

initial
begin
    #(PERIOD*2) nrst  =  1;
end

Giraffe #(
    .BAUDRATE ( BAUDRATE ),
    .FREQ     ( FREQ     ),
    .N_start  ( N_start  ),
    .N_data   ( N_data   ),
    .N_stop   ( N_stop   ),
    .N_bit    ( N_bit    ),
    .NUM_DIV  ( NUM_DIV  ))
 u_Giraffe (
    .clk_50M                 ( clk_50M                     ),
    .nrst                    ( nrst                        ),
    .calib_ena_FPGA          ( calib_ena_FPGA              ),
    .adc_ack                 ( adc_ack                     ),
    .adc_ack_sub             ( adc_ack_sub                 ),
    .dout_adc                ( dout_adc        [N_bit-1:0] ),

    .tx2M                    ( tx2M                        ),
    .rstn_adc                ( rstn_adc                    ),
    .clk_adc                 ( clk_adc                     ),
    .calib_ena_adc           ( calib_ena_adc               )
);

reg [7:0] cnt_ack, cnt_ack_sub;

always @(posedge clk_adc or negedge nrst) begin
    if (!nrst) begin
        cnt_ack <= 8'd0;
        cnt_ack_sub <= 8'd0;
    end
    else begin
        if (cnt_ack_sub == 8'd4) begin
            cnt_ack_sub <= 8'd0;
            adc_ack_sub <= 8'd1;
            dout_adc <= dout_adc + 6'd1;
        end else begin
            cnt_ack_sub <= cnt_ack_sub + 8'd1;
            adc_ack_sub <= 8'd0;
        end

        if (cnt_ack == 8'd19) begin
            cnt_ack <= 8'd0;
            adc_ack <= 8'd1;
        end else begin
            cnt_ack <= cnt_ack + 8'd1;
            adc_ack <= 8'd0;
        end
    end
end


initial
begin

    $finish;
end

endmodule