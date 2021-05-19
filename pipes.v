module pipes #(
	parameter NUM_PIPES 
)(
	input clk, FL_clk, rst,
	input [3:0] game_state,
	input [31:0] birdX,
	
	output [(32*NUM_PIPES)-1:0] pipeX_flat, pipeY_flat,
	output reg [31:0] score_count
);

wire [23:0] randY;
random_number_gen rand (clk, randY);

localparam PIPE_SIZE_X = 78;
localparam PIPE_SEPARATION = 250;
localparam CENTRE = (420-128)/2; // (play area - maximum random value)/2

localparam	START_SCREEN 	= 4'b0001,
				IN_GAME			= 4'b0010,
				PAUSE 			= 4'b0100,
				END_SCREEN 		= 4'b1000;

reg signed [31:0] pipeX [NUM_PIPES-1:0];
reg signed [31:0] pipeY [NUM_PIPES-1:0];
reg [31:0] pipeX_reset [NUM_PIPES-1:0];

integer i;
initial begin
	for (i=0; i<NUM_PIPES; i=i+1) begin
		pipeX_reset[i] <= 700 +(i*PIPE_SEPARATION);
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
				for (i = 0; i < NUM_PIPES; i = i+1) begin
					pipeX[i] <= pipeX_reset[i];
					pipeY[i] <= CENTRE + (randY[(23-6*(i))-:6]);
				end
				score_count <= 0;
				
			end
			
			IN_GAME: begin
				for (i = 0; i < NUM_PIPES; i = i+1) begin
					pipeX[i] <= pipeX[i] - 1;
					if (pipeX[i] + PIPE_SIZE_X <= 0) begin
						pipeX[i] <= pipeX[(i+NUM_PIPES-1)%NUM_PIPES] + PIPE_SEPARATION;
						pipeY[i] <= CENTRE + (randY[(23-6*(i))-:6]);
					end
					
					if (pipeX[i] + PIPE_SIZE_X == birdX) begin
						score_count <= score_count + 1;
					end
				end
				
			end
		endcase
		
	end
end

genvar z;
generate
	for (z = 0; z < NUM_PIPES; z = z + 1) begin : pipe_assignment
		assign pipeX_flat[32*(z+1)-1-:32] = pipeX[z];
		assign pipeY_flat[32*(z+1)-1-:32] = pipeY[z];
	end
endgenerate
		
endmodule
			