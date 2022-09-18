module Giraffe_FSM #(
    parameter N_bit  = 6,
    parameter N_data = 8
)
(
    input                   clk,
    input                   nrst,
    input                   adc_ack,
    input                   adc_ack_sub,
    input   [N_bit-1:0]     dout_adc,
    
    input                   uart_rdy,

    output                  wreq,
    output  [N_data-1:0]    wdata

);
    wire adc_ack_unit;
    assign adc_ack_unit = adc_ack | adc_ack_sub;

    reg wreq_reg;
    reg [N_data-1:0] wdata_reg;
    assign  wreq = wreq_reg;
    assign  wdata = wdata_reg;

    reg [2:0] cs, ns;

    parameter IDLE  = 3'd0; 
    parameter SEND  = 3'd1;
    parameter HOLD  = 3'd2;
    parameter SEND_Next = 3'd3;

    always @(clk or negedge nrst) begin : ss_tran
        if (!nrst) begin
            cs <= IDLE;
        end else if (clk) begin
            cs <= ns;
        end
    end

    always @(cs, nrst, adc_ack_unit, uart_rdy) begin
        if (!nrst) begin
            ns = IDLE;
        end else begin
            case(cs)
                IDLE :
                    if (adc_ack_unit == 1 && uart_rdy == 1)
                        ns = SEND;
                    else
                        ns = IDLE;
                
                SEND : 
                    ns = SEND_Next;
                
                SEND_Next:

                    if (uart_rdy == 1)
                        ns = HOLD;
                    else
                        ns = SEND;
                
                HOLD :
                    if (adc_ack_unit == 1 && uart_rdy == 1)
                        ns = SEND;
                    else
                        ns = HOLD;

                default : ns = ns;
            endcase
        end
    end

    always @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            wreq_reg <= 1'd0;
            wdata_reg <= 8'd0;
        end else begin
            case (ns)
                IDLE: begin
                    wreq_reg <= 1'd0;
                    wdata_reg <= 8'd0;
                end

                SEND: begin
                    if (adc_ack_sub == 1 & adc_ack == 0) begin
                        wreq_reg <= 1'd1;
                        wdata_reg <= {2'b00, dout_adc};
                    end else if (adc_ack == 1) begin
                        wreq_reg <= 1'd1;
                        wdata_reg <= {2'b11, dout_adc};
                    end
                end

                SEND_Next: 
                    wreq_reg <= 1'd0;

                HOLD: begin
                    wreq_reg <= 1'd0;
                    wdata_reg <= 8'd0;
                end
                
                default: begin
                    wreq_reg <= 1'd0;
                    wdata_reg <= 8'd0;
                end
            endcase
        end
    end
    
endmodule