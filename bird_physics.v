module bird_physics#(
	parameter BIRD_SIZE_X,
	parameter BIRD_SIZE_Y
)(
	input GAME_clk, rst, flap, 
	input [3:0] game_state,
	output reg [15:0] birdY,
	output reg [3:0] bird_state
);

integer Y_acc=2, Y_vel_min=-20;
reg signed [15:0] Y_vel;

always @(posedge GAME_clk or posedge rst)
begin
	if (rst) begin
		Y_vel <= 0;
		birdY <= (480 - BIRD_SIZE_Y)/2;
	end else begin
		if (game_state == 1) begin
			birdY <= birdY + Y_vel;
			
		end else if (game_state == 0)
			birdY <= (480 - BIRD_SIZE_Y)/2;
	end
end

endmodule
		