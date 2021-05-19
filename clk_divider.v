module clk_divider #(
	parameter DIVISOR = 0
)(
	input in_clk,
	
	output reg out_clk = 0
);

reg [31:0] count = 0;

always @(posedge in_clk) begin
	if (count < DIVISOR) begin
		count <= count + 1;
	end else begin
		count <= 0;
		out_clk = ~out_clk;
	end
end
	
endmodule
