`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/15 00:33:32
// Design Name: 
// Module Name: TB_Giraffe_FSM
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


`timescale  1ns / 1ps    

module tb_Giraffe_FSM;   

// Giraffe_FSM Parameters
parameter PERIOD  = 20  ;
parameter N_bit   = 6   ;
parameter N_data  = 8   ;
parameter IDLE    = 3'd0;
parameter SEND    = 3'd1;
parameter HOLD    = 3'd2;

// Giraffe_FSM Inputs
reg   clk                                  = 0 ;
reg   nrst                                 = 0 ;
reg   adc_ack                              = 0 ;
reg   adc_ack_sub                          = 0 ;
reg   [N_bit-1:0]  dout_adc                = 0 ;
reg   uart_rdy                             = 1 ;

// Giraffe_FSM Outputs
wire  wreq                                 ;
wire  [N_data-1:0]  wdata                  ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) nrst  =  1;
end

Giraffe_FSM #(
    .N_bit  ( N_bit  ),
    .N_data ( N_data )
)
 u_Giraffe_FSM (
    .clk                     ( clk                       ),
    .nrst                    ( nrst                      ),
    .adc_ack                 ( adc_ack                   ),
    .adc_ack_sub             ( adc_ack_sub               ),
    .dout_adc                ( dout_adc     [N_bit-1:0]  ),
    .uart_rdy                ( uart_rdy                  ),

    .wreq                    ( wreq                      ),
    .wdata                   ( wdata        [N_data-1:0] )
);

initial
begin

    $finish;
end
reg [7:0] cnt_ack, cnt_ack_sub;

always @(posedge clk or negedge nrst) begin
    if (!nrst) begin
        cnt_ack <= 8'd0;
        cnt_ack_sub <= 8'd0;
    end
    else begin
        if (cnt_ack_sub == 8'd4) begin
            cnt_ack_sub <= 8'd0;
            adc_ack_sub <= 8'd1;
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

always @(  posedge clk ) begin
    if ( wreq == 1) 
        uart_rdy <= 1'd0;
    else
        uart_rdy <= 1'd1;
end

endmodule