/*
 * ELEC5566 MINI-PROJECT:
 * KEY-PRESS FILTER
 * ---------------------------------
 * For: University of Leeds
 * Date: 10/3/2021
 *
 * Description
 * ---------------------------------
 * Module to filter button presses
 * preventing buttons from being held high
 *
 */

module key_filter
(
	input clk, key,

	output p_key
); 

reg delay;

// delay the signal by 1 clock cycle
always @(posedge clk) begin
	
	// delay is 1 if any key is pressed, preventing
	// multiple key presses
	delay <= key;

end

// signal resulting from this operation remains high for 
// one clock cycle when key transitions low -> high, then 
// returns low what the delayed signal also transitions
assign p_key = key & ~delay;

endmodule
