                                                      
`timescale 1 ns/100 ps

module score_display_tb;

reg clk, rst;

reg [31:0] score_count;
	
wire [11:0] score_BCD, hiscore_BCD;
wire [41:0] seven_seg;

score_display dut
(
	.rst				( rst				),
	.score_count	( score_count	),
	.score_BCD		( score_BCD		),
	.hiscore_BCD	( hiscore_BCD	),
	.seven_seg		( seven_seg		)
);

// Initialise clk
initial begin
	clk = 0;
	rst = 1;
	repeat(1) @(posedge clk);
	rst = 0;
end

// Alternate clk every 10ns
always #10 clk = ~clk;

integer i;

initial begin
	
	$monitor("%d ns \score = %d \score_BCD = %h \hiscore_BCD = %h \7seg = %b",$time,score_count,score_BCD,hiscore_BCD,seven_seg);
	
	for (i = 0; i < 100; i = i + 1) begin
	
		score_count = ($urandom % 100);
		repeat(1) @(posedge clk);
		
	end
	
	$stop;
end

endmodule
