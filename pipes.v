module pipes #(
	parameter NUM_PIPES 
)(
	input clk, FL_clk, rst,
	input [3:0] game_state,
	input [31:0] birdX,
	output [31:0] pipeX_1, pipeX_2, pipeX_3, pipeX_4,
	output [31:0] pipeY_1, pipeY_2, pipeY_3, pipeY_4,
	output reg [31:0] score_count
);

wire [31:0] randY;
random_number_generator rand (clk, randY);

localparam PIPE_SIZE_X = 78;
localparam PIPE_SEPARATION = 250;
localparam CENTRE = (420-128)/2; // (play area - maximum random value)/2

localparam	START_SCREEN 	= 4'b0001,
				IN_GAME			= 4'b0010,
				PAUSE 			= 4'b0100,
				END_SCREEN 		= 4'b1000;

reg [31:0] pipeX [NUM_PIPES-1:0];
reg [31:0] pipeY [NUM_PIPES-1:0];
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
			pipeY[i] <= CENTRE + (randY[(28-7*(i))-:7]);
		end
		score_count <= 0;
		
	end else begin
	
		case (game_state)
			START_SCREEN: begin
				for (i = 0; i < NUM_PIPES; i = i+1) begin
					pipeX[i] <= pipeX_reset[i];
					pipeY[i] <= CENTRE + (randY[(28-7*(i))-:7]);
				end
				score_count <= 0;
				
			end
			
			IN_GAME: begin
				for (i = 0; i < NUM_PIPES; i = i+1) begin
					pipeX[i] <= pipeX[i] - 1;
					if (pipeX[i] + PIPE_SIZE_X <= 0) begin
						pipeX[i] <= pipeX[(i+NUM_PIPES-1)%NUM_PIPES] + PIPE_SEPARATION;
						pipeY[i] <= CENTRE + (randY[(28-7*(i))-:7]);
					end
					
					if (pipeX[i] + PIPE_SIZE_X == birdX) begin
						score_count <= score_count + 1;
					end
					// Add slight y oscillation
				end
				
			end
		endcase
		
	end	
end

assign {pipeX_4, pipeX_3, pipeX_2, pipeX_1} = {pipeX[3], pipeX[2], pipeX[1], pipeX[0]};
assign {pipeY_4, pipeY_3, pipeY_2, pipeY_1} = {pipeY[3], pipeY[2], pipeY[1], pipeY[0]};
		
endmodule
			