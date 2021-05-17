module collision_detection #(
	parameter BIRD_SIZE_X,
	parameter BIRD_SIZE_Y,
	parameter PIPE_GAP,
	parameter NUM_PIPES
)(
	input clk, 
	input signed [31:0] birdY, birdX,
	input signed [31:0] pipeX_1, pipeX_2, pipeX_3, pipeX_4,
	input signed [31:0] pipeY_1, pipeY_2, pipeY_3, pipeY_4,
	output reg collision
);

localparam FLOOR_Y = 418;
localparam PIPE_SIZE_X = 78;

wire signed [31:0] pipeX [NUM_PIPES-1:0]; 
wire signed [31:0] pipeY [NUM_PIPES-1:0];

assign {pipeX[3], pipeX[2], pipeX[1], pipeX[0]} = {pipeX_4, pipeX_3, pipeX_2, pipeX_1};
assign {pipeY[3], pipeY[2], pipeY[1], pipeY[0]} = {pipeY_4, pipeY_3, pipeY_2, pipeY_1};

integer i;

always @(posedge clk)
begin
	collision <= 0;
	
	if (birdY + BIRD_SIZE_Y >= FLOOR_Y && birdY + BIRD_SIZE_Y <= 480)
		collision <= 1;
		
	for (i=0; i<NUM_PIPES; i=i+1) begin
		if( (birdX + BIRD_SIZE_X >= pipeX[i]) && (birdX <= pipeX[i] + PIPE_SIZE_X) ) begin
			if ( (birdY + BIRD_SIZE_Y >= pipeY[i] + PIPE_GAP) || (birdY <= pipeY[i] - PIPE_GAP) ) begin
				collision <= 1;
			end
		end
	end
	
end

endmodule
