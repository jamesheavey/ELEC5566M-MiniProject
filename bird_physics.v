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

reg [3:0] prev_state;

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
		down <= 0;
	end else begin
		case (game_state)
		
			START_SCREEN: begin
				if (birdY < -10 + (480 - BIRD_SIZE_Y)/2 || birdY + BIRD_SIZE_Y >= 480)
					down <= 1;
				else if (birdY > 10 + (480 - BIRD_SIZE_Y)/2)
					down <= 0;
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

//module bird_physics#(
//	parameter BIRD_SIZE_X,
//	parameter BIRD_SIZE_Y
//)(
//	input GAME_clk, rst, flap, 
//	input [3:0] game_state,
//	output reg [31:0] birdY,
//	output reg [1:0] bird_state
//);
//
//localparam	START_SCREEN 	= 4'b0001,
//				IN_GAME			= 4'b0010,
//				PAUSE 			= 4'b0100,
//				END_SCREEN 		= 4'b1000;
//
//localparam	TOP			 	= 4'b0001,
//				DOWN				= 4'b0010,
//				UP		 			= 4'b0100,
//				STOP				= 4'b1000;
//
//localparam	FLAP_1 			= 2'd0,
//				FLAP_2			= 2'd1,
//				FLAP_3 			= 2'd2;
//				
//				
//localparam TIME_START      =    8;  // starting time to load when beginning to flap up
//localparam TIME_STEP       =    2;  // increment/decrement value to time loaded to flap_t_reg after position update
//localparam TIME_MAX        =   30;  // maximum time reached at peak of flap
//localparam TIME_TERM       =   15;  // terminal time reached when falling down
//
//reg [3:0] motion_state, prev_state;
//reg [31:0] flap_elapsed, flap_start;
//
//always @(posedge GAME_clk or posedge rst)
//begin
//	if (rst) begin
//		motion_state 	<= DOWN;
//		prev_state	 	<= DOWN;
//		flap_elapsed 	<= TIME_MAX;
//		flap_start		<= TIME_MAX;
//		bird_state 		<= FLAP_1;
//		birdY 			<= (480 - BIRD_SIZE_Y)/2;
//	end else begin
//		case (motion_state)
//		
//			TOP: begin
//				prev_state 		<= TOP;
//				bird_state 		<= FLAP_2;
//				
//				flap_elapsed 	<= TIME_MAX;
//				flap_start 		<= TIME_MAX;
//				
//				if (game_state != START_SCREEN || game_state != IN_GAME) begin
//					motion_state <= STOP;
//				end
//				
//				motion_state 	<= DOWN;
//			end
//			
//			DOWN: begin
//				prev_state	 	<= DOWN;
//				bird_state 		<= FLAP_1;
//				
//				if (game_state != START_SCREEN || game_state != IN_GAME) begin
//					motion_state <= STOP;
//				end
//				
//				flap_elapsed 	<= flap_elapsed - 1;
//				
//				if (flap_elapsed == 0) begin					
//					if (flap_start > TIME_TERM) begin
//						flap_start 		<= flap_start - TIME_STEP;
//						flap_elapsed 	<= flap_start;
//					end else begin
//						flap_elapsed 	<= TIME_TERM;
//					end
//					
//					birdY <= birdY + 1;
//				end
//				
//				if (flap || (game_state == START_SCREEN && birdY > 280)) begin
//					motion_state 	<= UP;
//					flap_start 		<= TIME_START;
//					flap_elapsed 	<= TIME_START;
//				end
//			end
//			
//			UP: begin
//				prev_state 		<= UP;
//				bird_state 		<= FLAP_3;
//				
//				if (game_state != START_SCREEN || game_state != IN_GAME) begin
//					motion_state <= STOP;
//				end
//				
//				flap_elapsed 	<= flap_elapsed - 1;
//				
//				if (flap_elapsed == 0) begin					
//					if (flap_start <= TIME_MAX) begin
//						flap_start 		<= flap_start + TIME_STEP;
//						flap_elapsed 	<= flap_start;
//						birdY <= birdY - 1;
//					end else begin
//						motion_state <= TOP;
//					end
//				end
//			end
//			
//			STOP: begin
//				birdY <= birdY;
//				if (game_state == START_SCREEN || game_state == IN_GAME) begin
//					motion_state <= prev_state;
//				end
//			end
//			
//			default:	birdY <= birdY;
//			
//		endcase
//	end
//end
//
//endmodule
//		


endmodule
		