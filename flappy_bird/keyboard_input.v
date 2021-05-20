/*
 * ELEC5566 MINI-PROJECT:
 * PS2 KEYBOARD
 * ---------------------------------
 * For: University of Leeds
 * Date: 19/5/2021
 *
 * Description
 * ---------------------------------
 * This module decodes a PS2 keyboard,
 * generating 2 output commands:
 * 
 * SPACE = flap
 * ESC	= pause
 *
 */

module keyboard_input
(
	// INPUTS
	input clk, rst, PS2_clk, PS2_data,
	
	// OUTPUTS
	output wire pause,
	output reg flap
);

// Registers to store PS2 codes
reg [7:0] code, next_code, prev_code;
reg [10:0] key;

reg raw_pause;

integer count = 0;

// PS2 clock always high when key not pressed.
// When a key is pressed, the keyboard sends 3x 11-bit 
// codes. [8:1] represent the key data, the other bits
// include a start, stop and parity bit.
always@(negedge PS2_clk)
begin
	// Store the PS2 data value on each negative clock edge
	key[count] = PS2_data;
	count = count + 1;
	
	// If the number of data bits received is equal to 11
	// the receieved key code is finished
	if(count == 11) begin

		next_code = key[8:1];
		
		if(next_code != 8'hF0) begin
			if (next_code == code && prev_code == 8'hF0)
				code = 0;
			else
				// output the code of the pressed key
				code = key[8:1];				
		end
		
		prev_code = key[8:1];
		count = 0;
	end
end

always @(code or rst)
begin
	if (rst) begin
		flap = 0;
		raw_pause = 0;
	end else begin
		flap = 0;
		raw_pause = 0;
		
		// space code
		if (code == 8'h29)
			flap 	= 1;
			
		// esc code
		else if (code == 8'h76)
			raw_pause = 1;
	end
end

key_filter p_edge (clk, raw_pause, pause);

endmodule
