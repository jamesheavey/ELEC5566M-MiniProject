                                                      
`timescale 1 ns/100 ps

module key_filter_tb;

reg clk;

reg key;

wire p_key;

key_filter filter (

	.clk		( clk ),
	
	.key		( key ),
	.p_key	( p_key )
	
);

// Initialise clk
initial begin
	clk = 0;
end

// Alternate clk every 10ns
always #10 clk = ~clk;


always begin
	
	key <= 4'h0;
	
	repeat(1) @(posedge clk);
	
	key <= 4'h7;
	
	repeat(2) @(posedge clk);
	
	key <= 4'hF;
	
	repeat(2) @(posedge clk);
	
	key <= 4'h0;
	
	repeat(2) @(posedge clk);
	
	key <= 4'hF;
	
	repeat(6) @(posedge clk);
	
	$stop;
	
end

endmodule
