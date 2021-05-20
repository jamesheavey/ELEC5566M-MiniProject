/*
 * ELEC5566 MINI-PROJECT:
 * PIPE SHIFTING
 * ---------------------------------
 * For: University of Leeds
 * Date: 19/5/2021
 *
 * Description
 * ---------------------------------
 * This module generates and shifts the
 * pipe obstacles during the IN_GAME state.
 * pipes are represented by a single X,Y 
 * coordinate.
 *
 * The game score is also incremented in this
 * module whenever a pipe passes the birdX
 * coordinate.
 *
 */
 
module pipes #(
	// PARAMETERS
	parameter NUM_PIPES,
	parameter PIPE_SEP
)(
	// INPUTS
	input clk, FL_clk, rst,
	input [3:0] game_state,
	input [31:0] birdX,
	
	// OUTPUTS
	output [(32*NUM_PIPES)-1:0] pipeX_flat, pipeY_flat,
	output reg [31:0] score_count
);

localparam PIPE_SIZE_X = 78;
localparam CENTRE = (420-128)/2; // (play area - maximum random value)/2

// Symbolic game FSM state definitions
localparam	START_SCREEN 	= 4'b0001,
		IN_GAME		= 4'b0010,
		PAUSE 		= 4'b0100,
		END_SCREEN 	= 4'b1000;
				
// Instatiate a LFSR random number generator to determine pipe Y offsets
wire [23:0] randY;
random_number_gen rand (clk, randY);

// 2D wires to store all wire coordinates
reg signed [31:0] pipeX [NUM_PIPES-1:0];
reg signed [31:0] pipeY [NUM_PIPES-1:0];
reg [31:0] pipeX_reset [NUM_PIPES-1:0];

// initialise pipes off screen
integer i;
initial begin
	for (i=0; i<NUM_PIPES; i=i+1) begin
		pipeX_reset[i] <= 700 +(i*PIPE_SEP);
	end
end


always @(posedge FL_clk or posedge rst)
begin
	if (rst) begin
	
		for (i = 0; i < NUM_PIPES; i = i+1) begin
			pipeX[i] <= pipeX_reset[i];
			pipeY[i] <= CENTRE + (randY[(23-6*(i))-:6]);
		end
		score_count <= 0;
		
	end else begin
	
		case (game_state)
			START_SCREEN: begin
				// reset the pipes to offscreen position, randomise Y coordinates
				for (i = 0; i < NUM_PIPES; i = i+1) begin
					pipeX[i] <= pipeX_reset[i];
					pipeY[i] <= CENTRE + (randY[(23-6*(i))-:6]);
				end
				score_count <= 0;
				
			end
			
			IN_GAME: begin
				for (i = 0; i < NUM_PIPES; i = i+1) begin
				
					// shift pipes 1 pixel every clock tick
					pipeX[i] <= pipeX[i] - 1;
					
					// if pipe goes off the left side of the screen, place
					// after the last pipe and randomise Y coordinate
					if (pipeX[i] + PIPE_SIZE_X <= 0) begin
						pipeX[i] <= pipeX[(i+NUM_PIPES-1)%NUM_PIPES] + PIPE_SEP;
						pipeY[i] <= CENTRE + (randY[(23-6*(i))-:6]);
					end
					
					// if pipe passes the last bird pixel, increment the score
					if (pipeX[i] + PIPE_SIZE_X == birdX) begin
						score_count <= score_count + 1;
					end
				end
				
			end
		endcase
		
	end
end

// pack the 2D coordinate arrays into flat output arrays
genvar z;
generate
	for (z = 0; z < NUM_PIPES; z = z + 1) begin : pipe_assignment
		assign pipeX_flat[32*(z+1)-1-:32] = pipeX[z];
		assign pipeY_flat[32*(z+1)-1-:32] = pipeY[z];
	end
endgenerate
		
endmodule
			
