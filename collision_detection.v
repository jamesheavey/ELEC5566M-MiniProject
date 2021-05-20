/*
 * ELEC5566 MINI-PROJECT:
 * COLLISION DETECTION
 * ---------------------------------
 * For: University of Leeds
 * Date: 19/5/2021
 *
 * Description
 * ---------------------------------
 * This module monitors the bird position
 * relative to the ground y-plane and the 
 * pipe obstacles. If the bird sprite overlaps
 * with any of these hitboxes, collision goe high.
 *
 */
 
module collision_detection #(
	// PARAMETERS
	parameter BIRD_SIZE_X,
	parameter BIRD_SIZE_Y,
	parameter PIPE_GAP,
	parameter NUM_PIPES
)(
	// INPUTS
	input clk, 
	input [31:0] birdY, birdX,
	input [(32*NUM_PIPES)-1:0] pipeX_flat, pipeY_flat,
	
	// OUTPUTS
	output reg collision
);

localparam FLOOR_Y 		= 418;
localparam PIPE_SIZE_X 	=  78;

// 2D array to store pipe coordinates
wire signed [31:0] pipeX [NUM_PIPES-1:0]; 
wire signed [31:0] pipeY [NUM_PIPES-1:0];

// Unpack flat pipe coordinate arrays
genvar z;
generate
	for (z = 0; z < NUM_PIPES; z = z + 1) begin : pipe_assignment
		assign pipeX[z] = pipeX_flat[32*(z+1)-1-:32];
		assign pipeY[z] = pipeY_flat[32*(z+1)-1-:32];
	end
endgenerate

integer i;

always @(posedge clk)
begin
	collision <= 0;
	
	// Floor collision detection, excluding coordinate wrap range if bird
	// goes above screen limit
	if (birdY + BIRD_SIZE_Y >= FLOOR_Y && birdY + BIRD_SIZE_Y <= 480)
		collision <= 1;
	
	// Pipe collision detection. Hitboxes adjusted for sprite padding/scaling
	for (i = 0; i < NUM_PIPES; i = i + 1) begin
		if ( (birdX + BIRD_SIZE_X-6 >= pipeX[i]) && (birdX+6 <= pipeX[i] + PIPE_SIZE_X) ) begin
			if ( (birdY + BIRD_SIZE_Y-6 >= pipeY[i] + PIPE_GAP) || (birdY+6 <= pipeY[i] - PIPE_GAP) ) begin
				collision <= 1;
			end
		end
	end
end

endmodule
