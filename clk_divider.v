module clk_divider
(
	input clk, //50MHz clock
	output reg div_clk = 0//25MHz clock
);

always @(posedge clk) begin
	div_clk <= ~div_clk;
end
	
endmodule
