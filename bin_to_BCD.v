/*
 * ELEC5566 MINI-PROJECT:
 * BINARY TO BCD
 * ---------------------------------
 * For: University of Leeds
 * Date: 19/5/2021
 *
 * Description
 * ---------------------------------
 * This module converts a 10-bit binary
 * number (up to 999) to 3, 4-bit hex
 * values representing each of the decimal units.
 * This module uses the shift-add-3 rule.
 *
 */
module bin_to_BCD
(
	// INPUT
	input [9:0] bin,

	// OUTPUT
	output [11:0] BCD
);

// register to store the 3, 4bit units
reg [3:0] units [2:0];

integer i, j;
always @(bin)
begin
	// reset the units to 0
	for (j = 2; j >= 0; j = j - 1)
		units[j] = 0;

	// reverse iterate through all binary values
	for (i = 9; i >= 0; i = i - 1) begin

		// add 3 to a unit if it exceeds 5
		for (j = 2; j >= 0; j = j - 1) begin
			if (units[j] >= 5)
				units[j] = units[j] + 3;
		end
		
		// else shift the unit and replace the LSB
		// with the MSB of the previous unit
		for (j = 2; j >= 0; j = j - 1) begin
			units[j] = units[j] << 1;
			
			if (j == 0)
				// if the 1's unit, replace the LSB
				// with the current MSB of the binary input
				units[j][0] = bin[i];
			else
				units[j][0] = units[j-1][3];
		end
	end
end

// assign the 3 units to the full 12 bit BCD output
genvar z;
generate
	for (z = 0; z < 3; z = z + 1) begin : assign_BCD
		assign BCD[4*(z+1)-1-:4] = units[z];
	end
endgenerate

endmodule
