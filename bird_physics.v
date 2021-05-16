module bird_physics#(
	parameter BIRD_SIZE_X,
	parameter BIRD_SIZE_Y
)(
	input GAME_clk, rst, flap, 
	input [3:0] game_state,
	output reg signed [31:0] birdY,
	output reg [1:0] bird_state
);

integer Y_acc=3, Y_vel_max=20;
reg signed [15:0] Y_vel, prev_Y_vel;
//reg [31:0] Y_load_time;

reg [3:0] prev_state;

reg down;

//localparam TIME_START_Y      =   100000;  // starting time to load when beginning to jump up
//localparam TIME_STEP_Y       =     8000;  // increment/decrement value to time loaded to jump_t_reg after position update
//localparam TIME_MAX_Y        =   600000;  // maximum time reached at peak of jump
//localparam TIME_TERM_Y       =   250000;  // terminal time reached when jumping down


localparam	START_SCREEN 	= 4'b0001,
				IN_GAME			= 4'b0010,
				PAUSE 			= 4'b0100,
				END_SCREEN 		= 4'b1000;		


always @(posedge GAME_clk or posedge rst)
begin
	if (rst) begin
		Y_vel <= 0;
		birdY <= (480 - BIRD_SIZE_Y)/2;
		down <= 0;
	end else begin
		case (game_state)
		
			START_SCREEN: begin
				if (birdY > 10 + (480 - BIRD_SIZE_Y)/2)
					down <= 0;
				else if (birdY < -10 + (480 - BIRD_SIZE_Y)/2)
					down <= 1;
				Y_vel <= down? 3:-3;
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

//always @(posedge clk or posedge rst)
//begin
//	if (rst) begin
//		Y


localparam	FLAP_1 			= 2'd0,
				FLAP_2			= 2'd1,
				FLAP_3 			= 2'd2;

always @(posedge GAME_clk)
begin

	case (game_state)
		START_SCREEN: begin
			if (birdY > 10 + (480 - BIRD_SIZE_Y)/2)
				bird_state <= FLAP_3;
			else if (birdY == (480 - BIRD_SIZE_Y)/2 && !down)
				bird_state <= FLAP_2;
			else if (birdY < -10 + (480 - BIRD_SIZE_Y)/2)
				bird_state <= FLAP_1;
		end
				
		IN_GAME: begin
			if (Y_vel < -10)
				bird_state <= FLAP_3;
			else if (Y_vel > -10 && Y_vel < 10)
				bird_state <= FLAP_2;
			else if (Y_vel > 10)
				bird_state <= FLAP_1;
		end
				
		default: bird_state <= FLAP_1;
		
	endcase
end



endmodule
		