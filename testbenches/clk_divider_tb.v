
`timescale 1 ns/100 ps

module clk_divider_tb;

reg in_clk = 0;

wire out_clk;

clk_divider #(
	.DIVISOR		( 10-1		)
) dut (
	.in_clk		( in_clk 	),
	.out_clk		( out_clk 	)
);

// Alternate clock every 10ns
always #10 in_clk = ~in_clk;

reg num_cycles = 0;

always @(posedge in_clk) begin
	$monitor("%d ns \in = %d \out = %d",$time,in_clk,out_clk);
	num_cycles = num_cycles + 1;
	if (num_cycles >= 5000) $stop;
end

integer in_count = 0, out_count = 0;

always @(posedge in_clk) begin
	in_count = in_count + 1;
end

always @(posedge out_clk) begin
	out_count = out_count + 1;
end

endmodule
