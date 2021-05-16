module pipes #(
	parameter NUM_PIPES = 4
)(
	input clk, FL_clk, rst,
	input [3:0] game_state,
	output signed [31:0] pipeX_1, pipeX_2, pipeX_3, pipeX_4,
	output signed [31:0] pipeY_1, pipeY_2, pipeY_3, pipeY_4
);

wire signed [4:0] randY;
random_number_gen gen (clk, rst, randY);

localparam	START_SCREEN 	= 4'b0001,
				IN_GAME			= 4'b0010,
				PAUSE 			= 4'b0100,
				END_SCREEN 		= 4'b1000;

localparam PIPE_SIZE_X = 78;

localparam CENTRE = 420/2;

reg signed [31:0] pipeX [NUM_PIPES-1:0];
reg signed [31:0] pipeY [NUM_PIPES-1:0];

reg [31:0] pipeX_reset [NUM_PIPES-1:0];
initial begin
	pipeX_reset[0] = 660;
	pipeX_reset[1] = 840;
	pipeX_reset[2] = 1020;
	pipeX_reset[3] = 1200;
end

integer i;

always @(posedge FL_clk or posedge rst)
begin
	if (rst) begin
	
		for (i = 0; i < NUM_PIPES; i = i+1) begin
			pipeX[i] <= pipeX_reset[i];
			pipeY[i] <= CENTRE + (randY << 1);
		end
		
	end else begin
	
		case (game_state)
			START_SCREEN: begin
				for (i = 0; i < NUM_PIPES; i = i+1) begin
					pipeX[i] <= pipeX_reset[i];
					pipeY[i] <= CENTRE;
				end
			end
			
			IN_GAME: begin
				for (i = 0; i < NUM_PIPES; i = i+1) begin
					pipeX[i] <= pipeX[i] - 1;
					if (pipeX[i] + PIPE_SIZE_X <= 0) begin
						pipeX[i] <= pipeX[(i+NUM_PIPES-1)%NUM_PIPES] + 180;
						pipeY[i] <= CENTRE + (randY << 1);
					end
				end
			end
		endcase
		
	end	
end

assign {pipeX_4, pipeX_3, pipeX_2, pipeX_1} = {pipeX[3], pipeX[2], pipeX[1], pipeX[0]};
assign {pipeY_4, pipeY_3, pipeY_2, pipeY_1} = {pipeY[3], pipeY[2], pipeY[1], pipeY[0]};
		
endmodule
				