
                                                      
`timescale 1 ns/100 ps

module vga_gen_tb;

reg clk, rst;

wire h_sync, v_sync, v_clk, sync_n, display_on;

wire [15:0] X, Y;

vga_gen dut
(
	.clk				( clk 			),
	.rst				( rst 			),
	.h_sync			( h_sync 		),
	.v_sync			( v_sync 		),
	.v_clk			( v_clk 			),
	.display_on		( display_on 	),
	.sync_n			( sync_n 		),
	.h_pos			( X 				),
	.v_pos			( Y 				)
);

// Alternate clock every 10ns
always #10 clk = ~clk;

reg num_cycles = 0;

always @(posedge clk) begin
	num_cycles = num_cycles + 1;
	if (num_cycles == 5000) $stop;
end

endmodule
