/*
 * ELEC5566 MINI-PROJECT:
 * CLOCK DIVIDER
 * ---------------------------------
 * For: University of Leeds
 * Date: 19/5/2021
 *
 * Description
 * ---------------------------------
 * This module generates a range of new 
 * clk frequencies by dividing the original
 * 50MHz board clk by a DIVISOR.
 *
 * out_clk = in_clk/(DIVISOR+1).
 *
 */

module clk_divider #(
	// PARAMETER
	parameter DIVISOR = 0
)(
	// INPUT
	input in_clk,
	
	// OUTPUT
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
