module clk_div #(
    parameter NUM_DIV = 5000
) 
(
    input   clk_50M,
    input   nrst,
    output  clk_out
);

    reg [15:0]  cnt;
    reg         clk_out_reg;

    assign clk_out = clk_out_reg;
    
    always @(posedge clk_50M or negedge nrst) begin
        if (!nrst) begin
            cnt <= 16'd0;
            clk_out_reg <= 1'd0;
        end
        else begin
            if (cnt == NUM_DIV / 2) begin
                cnt <= 16'd0;
                clk_out_reg <= ~clk_out_reg;
            end
            else begin
                cnt <= cnt + 16'd1;
                clk_out_reg <= clk_out_reg;
            end
        end

    end
    
endmodule