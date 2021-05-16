module collision_detection #(
	parameter BIRD_SIZE_X,
	parameter BIRD_SIZE_Y
)(
	input GAME_clk, rst, 
	input signed [31:0] birdY, birdX,
	output reg collision
);

localparam FLOOR_Y = 418;

always @(posedge GAME_clk or posedge rst)
begin
	if (rst) begin
		collision <= 0;
	end else begin
		if (birdY + BIRD_SIZE_Y >= FLOOR_Y && birdY + BIRD_SIZE_Y <= 480)
			collision <= 1;
		else
			collision <= 0;
	end
end

endmodule
