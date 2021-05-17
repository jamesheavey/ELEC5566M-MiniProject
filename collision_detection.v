module collision_detection #(
	parameter BIRD_SIZE_X,
	parameter BIRD_SIZE_Y,
	parameter PIPE_GAP,
	parameter NUM_PIPES
)(
	input clk, 
	input signed [31:0] birdY, birdX,
	input signed [32*NUM_PIPES-1:0] pipeX, pipeY,
	output reg collision
);

localparam FLOOR_Y = 418;
localparam PIPE_SIZE_X = 78;

integer i;

always @(posedge clk)
begin
	
	collision <= 0;
	
	if (birdY + BIRD_SIZE_Y >= FLOOR_Y && birdY + BIRD_SIZE_Y <= 480)
		collision <= 1;
		
	for (i=0; i<NUM_PIPES; i=i+1) begin
		if ((birdX + BIRD_SIZE_X >= pipeX[(32*(i+1))-1-:31]) && 
			(birdX <= pipeX[(32*(i+1))-1-:31] + PIPE_SIZE_X) ) begin
			
			if ((birdY + BIRD_SIZE_Y >= pipeY[(32*(i+1))-1-:31] + PIPE_GAP) || 
				(birdY <= pipeY[(32*(i+1))-1-:31] - PIPE_GAP)) begin
				collision <= 1;
			end
		end
	end
	
end

endmodule
