module character_physics
(
	input GAME_clk, rst, grounded, direction, move, jump,
	output reg [15:0] playerX, playerY,
	output [3:0] player_state
);

integer h_acc=5, v_acc=2;
integer h_vel_max=10, v_vel_min=-20;
reg signed [4:0] player_h_vel, player_v_vel;

always @(posedge GAME_clk or rst)
begin
	if (rst) begin
	
		player_h_vel <= 0;
		player_v_vel <= 0;
		playerX <= (640-36)/2;
		playerY <= 480 - 42;
		
	end else begin

		if (direction && move && player_h_vel < h_vel_max)
			player_h_vel <= player_h_vel + h_acc;
		
		if (!direction && move && player_h_vel > -1*h_vel_max)
			player_h_vel <= player_h_vel - h_acc;
			
		if (direction && !move && player_h_vel != 0)
			player_h_vel <= player_h_vel - h_acc;
		
		if (!direction && !move && player_h_vel != 0)
			player_h_vel <= player_h_vel + h_acc;
			
		if (grounded && jump)
			player_v_vel <= -v_vel_min; // 110 pixel max jump
		
		if (!grounded && player_v_vel > v_vel_min)
			player_v_vel <= player_v_vel - v_acc;
		
		playerX <= playerX + player_h_vel;
		playerY <= playerY + player_v_vel;
		
	end
end

endmodule
		