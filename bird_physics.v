
module bird_physics#(
	parameter BIRD_SIZE_X,
	parameter BIRD_SIZE_Y
)(
	input clk, rst, flap, 
	input [3:0] game_state,
	
	output reg [31:0] birdY,
	output reg [1:0] bird_state, bird_angle
);

localparam	START_SCREEN 	= 4'b0001,
				IN_GAME			= 4'b0010,
				PAUSE 			= 4'b0100,
				END_SCREEN 		= 4'b1000;

localparam	TOP			 	= 4'b0001,
				DOWN				= 4'b0010,
				UP		 			= 4'b0100,
				STOP				= 4'b1000;

localparam	FLAP_1 			= 2'd0,
				FLAP_2			= 2'd1,
				FLAP_3 			= 2'd2;

localparam	HORZ 				= 2'd0,
				POS_45			= 2'd1,
				NEG_45 			= 2'd2;
				
				
localparam TIME_START      =    25000;  // starting time to load when beginning to flap up
localparam TIME_STEP       =     5000;  // value to decrement or incremnt start time until above or below MAX or TERMINAL
localparam TIME_MAX        =   475000;  // start time for fall, end time for rise
localparam TIME_TERMINAL   =   175000;  // terminal time reached when falling down

reg [3:0] motion_state, prev_state;
reg [31:0] flap_elapsed, flap_start;

always @(posedge clk or posedge rst)
begin
	if (rst) begin
		motion_state 	<= DOWN;
		prev_state	 	<= DOWN;
		flap_elapsed 	<= TIME_MAX;
		flap_start		<= TIME_MAX;
		bird_state 		<= FLAP_1;
		bird_angle 		<= HORZ;
		birdY 			<= (480 - BIRD_SIZE_Y)/2;
	end else begin
		case (motion_state)
		
			TOP: begin
				bird_angle		<= HORZ;
				bird_state 		<= FLAP_2;
				
				flap_elapsed 	<= TIME_MAX;
				flap_start 		<= TIME_MAX;
				
				if (game_state == PAUSE || game_state == END_SCREEN) begin
					prev_state 		<= TOP;
					motion_state	<= STOP;
				end
				
				motion_state 	<= DOWN;
			end
			
			DOWN: begin
				bird_state 	<= (flap_start >= (TIME_MAX/5)*3) ? FLAP_2 : FLAP_1;
				bird_angle	<= (flap_start >= (TIME_MAX/5)*4) ? HORZ : POS_45;
				
				if (game_state == PAUSE || game_state == END_SCREEN) begin
					prev_state 		<= DOWN;
					motion_state	<= STOP;
				end
				
				flap_elapsed 	<= flap_elapsed - 1;
				
				if (flap_elapsed == 0) begin					
					if (flap_start > TIME_TERMINAL) begin
						flap_start 		<= flap_start - TIME_STEP;
						flap_elapsed 	<= flap_start;
					end else begin
						flap_elapsed 	<= TIME_TERMINAL;
					end
					
					birdY <= birdY + 1;
				end
				
				if (flap || (game_state == START_SCREEN && birdY > 250 && !(birdY >= 480))) begin
					motion_state 	<= UP;
					flap_start 		<= TIME_START;
					flap_elapsed 	<= TIME_START;
					bird_state 		<= FLAP_3;
				end
			end
			
			UP: begin

				bird_state 	<= (flap_start <= (TIME_MAX/5)*3) ? FLAP_3 : FLAP_2;
				bird_angle	<= (flap_start <= (TIME_MAX/5)*4) ? NEG_45 : HORZ;
				
				if (game_state == PAUSE || game_state == END_SCREEN) begin
					prev_state 		<= UP;
					motion_state	<= STOP;
				end
				
				flap_elapsed <= flap_elapsed - 1;
				
				if (flap_elapsed == 0) begin					
					if (flap_start <= TIME_MAX) begin
						flap_start 		<= flap_start + TIME_STEP;
						flap_elapsed 	<= flap_start;
						birdY 			<= birdY - 1;
					end else begin
						motion_state 	<= TOP;
					end
				end				
			end
			
			STOP: begin
				if (game_state == START_SCREEN || game_state == IN_GAME) begin
					motion_state <= prev_state;
				end
			end
			
			default:	birdY <= birdY;
			
		endcase
	end
end

endmodule
		