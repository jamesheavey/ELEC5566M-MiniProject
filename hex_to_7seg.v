/*
 * ELEC5566 MINI-PROJECT:
 * HEX TO 7SEG CONVERTER
 * ---------------------------------
 * For: University of Leeds
 * Date: 19/5/2021
 *
 * Description
 * ---------------------------------
 * This module takes a 4-bit, single
 * digit number, and converts it to
 * the required format for display on
 * the 7segmnets.
 *
 */
 
module hex_to_7seg 
( 
	// INPUT
	input			[3:0] hex,
	
	// OUTPUT
	output reg	[6:0] seven_seg
);

always @(*) begin

	case(hex)
	
		4'h0: seven_seg = ~7'b0000000;  // no need to represent 0
		
		4'h1: seven_seg = ~7'b0000110; // 1
		4'h2: seven_seg = ~7'b1011011; // 2
		4'h3: seven_seg = ~7'b1001111; // 3
		4'h4: seven_seg = ~7'b1100110; // 4
		4'h5: seven_seg = ~7'b1101101; // 5
		4'h6: seven_seg = ~7'b1111101; // 6
		4'h7: seven_seg = ~7'b1000111; // 7
		4'h8: seven_seg = ~7'b1111111; // 8
		4'h9: seven_seg = ~7'b1101111; // 9
		
		default: seven_seg = 7'b0000000;
		
	endcase
end

endmodule
