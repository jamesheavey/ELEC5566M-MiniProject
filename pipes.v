module pipes #(
	parameter NUM_PIPES = 4
)(
	input clk, FL_clk, rst,
	input [3:0] game_state,
	input [31:0] birdX,
	output reg signed [32*NUM_PIPES-1:0] pipeX, pipeY,
	output reg [31:0] score_count
);

wire [31:0] randY;
random_number_generator rand (clk, randY);

localparam	START_SCREEN 	= 4'b0001,
				IN_GAME			= 4'b0010,
				PAUSE 			= 4'b0100,
				END_SCREEN 		= 4'b1000;

localparam PIPE_SIZE_X = 78;
localparam PIPE_SEPARATION = 250;

localparam CENTRE = (420-128)/2;  // (play area - maximum random value)/2

integer i;

reg [31:0] pipeX_reset [NUM_PIPES-1:0];
initial begin
	for (i=0; i<NUM_PIPES; i=i+1) begin
		pipeX_reset[i] <= 700 +(i*PIPE_SEPARATION);
	end
end

always @(posedge FL_clk or posedge rst)
begin
	if (rst) begin
	
		for (i = 0; i < NUM_PIPES; i = i+1) begin
			pipeX[(32*(i+1))-1-:31] <= pipeX_reset[i];
			pipeY[(32*(i+1))-1-:31] <= CENTRE + (randY[(28-7*(i))-:7]);
		end
		
		score_count <= 0;
		
	end else begin
	
		case (game_state)
			START_SCREEN: begin
				for (i = 0; i < NUM_PIPES; i = i+1) begin
					pipeX[(32*(i+1))-1-:31] <= pipeX_reset[i];
					pipeY[(32*(i+1))-1-:31] <= CENTRE + (randY[(28-7*(i))-:7]);
				end
				
				score_count <= 0;
			end
			
			IN_GAME: begin
				for (i = 0; i < NUM_PIPES; i = i+1) begin
					pipeX[(32*(i+1))-1-:31] <= pipeX[(32*(i+1))-1-:31] - 1;
					if (pipeX[(32*(i+1))-1-:31] + PIPE_SIZE_X <= 0) begin
						pipeX[(32*(i+1))-1-:31] <= pipeX[((32*(i+NUM_PIPES)-1)%(32*NUM_PIPES))-:31] + PIPE_SEPARATION;
						pipeY[(32*(i+1))-1-:31] <= CENTRE + (randY[(28-7*(i))-:7]);
					end
					
					if (pipeX[(32*(i+1))-1-:31] + PIPE_SIZE_X == birdX) begin
						score_count <= score_count + 1;
					end
					
				// Add slight y oscillation
				end
			end
		endcase
		
	end
end

endmodule
				