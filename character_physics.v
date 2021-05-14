module character_physics
(
	input GAME_clk, rst, grounded, direction, move, jump,
	input [15:0] groundedY,
	output reg [15:0] playerX, playerY,
	output reg jumpup,
	output [3:0] player_state
);

integer X_acc=2, Y_acc=2, X_vel_max=10, Y_vel_min=-20;
reg signed [15:0] X_vel, Y_vel;

reg LEFT_MAX, RIGHT_MAX;

always @(playerX)
begin
	
	if (playerX <= 15) 
		LEFT_MAX = 1;
	else
		LEFT_MAX = 0;
		
	if (playerX >= 640 - 37 - 15)
		RIGHT_MAX <= 1;
	else
		RIGHT_MAX = 0;
end

always @(posedge GAME_clk or posedge rst)
begin
	if (rst) begin
		X_vel <= 0;
		playerX <= (640 - 36)/2;
	end else begin
		
		if (LEFT_MAX && direction) 
			X_vel <= 0;
		else if (direction && move) 
			X_vel <= (X_vel > -X_vel_max) ? X_vel-X_acc : -X_vel_max;
		
		if (RIGHT_MAX && !direction) 
			X_vel <= 0;
		else if (!direction && move)
			X_vel <= (X_vel < X_vel_max) ? X_vel+X_acc : X_vel_max;
			
		if (!move && X_vel != 0)
			X_vel <= (X_vel < 0) ? X_vel + X_acc : X_vel - X_acc;
		
		playerX <= playerX + X_vel;
		
	end
end

always @(posedge GAME_clk or posedge rst)
begin
	if (rst) begin
		Y_vel <= 0;
		playerY <= 480 - 42;
	end else begin
		
		if (grounded) 
			Y_vel <= 0;
			playerY <= groundedY;
		
		if (grounded && jump)
			Y_vel <= -20;
			
		
		if (!grounded)
			Y_vel <= (Y_vel > -Y_vel_min) ? Y_vel + Y_acc : -Y_vel_min;

		
		playerY <= playerY + Y_vel;
		
	end
end

always @(Y_vel)
begin
	if (Y_vel > 0)
		jumpup = 1;
	else
		jumpup = 0;
end

endmodule
		