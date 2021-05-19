module collision_detection #(
	parameter BIRD_SIZE_X,
	parameter BIRD_SIZE_Y,
	parameter PIPE_GAP,
	parameter NUM_PIPES
)(
	input clk, 
	input [31:0] birdY, birdX,
	input [(32*NUM_PIPES)-1:0] pipeX_flat, pipeY_flat,
	output reg collision
);

localparam FLOOR_Y = 418;
localparam PIPE_SIZE_X = 78;

wire signed [31:0] pipeX [NUM_PIPES-1:0]; 
wire signed [31:0] pipeY [NUM_PIPES-1:0];

integer i;

always @(posedge clk)
begin
	collision <= 0;
	
	if (birdY + BIRD_SIZE_Y >= FLOOR_Y && birdY + BIRD_SIZE_Y <= 480)
		collision <= 1;
	
	// hitboxes adjusted for sprite padding
	for (i = 0; i < NUM_PIPES; i = i + 1) begin
		if ( (birdX + BIRD_SIZE_X-6 >= pipeX[i]) && (birdX+6 <= pipeX[i] + PIPE_SIZE_X) ) begin
			if ( (birdY + BIRD_SIZE_Y-3 >= pipeY[i] + PIPE_GAP) || (birdY+3 <= pipeY[i] - PIPE_GAP) ) begin
				collision <= 1;
			end
		end
	end
	
end

genvar z;
generate
	for (z = 0; z < NUM_PIPES; z = z + 1) begin : pipe_assignment
		assign pipeX[z] = pipeX_flat[32*(z+1)-1-:32];
		assign pipeY[z] = pipeY_flat[32*(z+1)-1-:32];
	end
endgenerate

endmodule
