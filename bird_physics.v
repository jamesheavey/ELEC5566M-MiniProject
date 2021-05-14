module bird_physics#(
	parameter BIRD_SIZE_X,
	parameter BIRD_SIZE_Y
)(
	input GAME_clk, rst, flap, 
	input [3:0] game_state,
	output reg [15:0] birdY,
	output reg [3:0] bird_state
);

integer Y_acc=2, Y_vel_max=20;
reg signed [15:0] Y_vel;

reg down;

localparam	START_SCREEN 	= 4'b0001,
				IN_GAME			= 4'b0010,
				PAUSE 			= 4'b0100,
				END_SCREEN 		= 4'b1000;

always @(posedge GAME_clk or posedge rst)
begin
	if (rst) begin
		Y_vel <= 0;
		birdY <= (480 - BIRD_SIZE_Y)/2;
	end else begin
		case (game_state)
		
			START_SCREEN: begin
				if (birdY > 10 + (480 - BIRD_SIZE_Y)/2)
					down <= 0;
				else if (birdY < -10 + (480 - BIRD_SIZE_Y)/2)
					down <= 1;
				Y_vel <= down? 2:-2;
			end
			
			IN_GAME: begin
				Y_vel <= Y_vel < Y_vel_max ? Y_vel + Y_acc:Y_vel_max;
				if (flap) 
					Y_vel <= -20;
			end
			
			default: Y_vel <= 0;
		endcase
		
		birdY <= birdY + Y_vel;
		
	end
end

endmodule
		