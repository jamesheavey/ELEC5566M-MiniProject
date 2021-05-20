/*
 * ELEC5566 MINI-PROJECT:
 * BIRD PHYSICS
 * ---------------------------------
 * For: University of Leeds
 * Date: 19/5/2021
 *
 * Description
 * ---------------------------------
 * This module defines the movement
 * characteristics of the bird player
 * sprite. A FSM simulating movement under 
 * gravity was defined
 * 
 * In each motion state, a flapping bird 
 * state and bird angle is output, determining
 * the sprite selection in the image rendering
 * module
 *
 */
 
module bird_physics#(
	// PARAMETERS
	parameter BIRD_SIZE_X,
	parameter BIRD_SIZE_Y
)(
	// INPUTS
	input clk, rst, flap, 
	input [3:0] game_state,
	
	// OUTPUTS
	output reg [31:0] birdY,
	output reg [1:0] bird_state, bird_angle
);

// Symbolic game FSM state definitions 
localparam	START_SCREEN 	= 4'b0001,
		IN_GAME		= 4'b0010,
		PAUSE 		= 4'b0100,
		END_SCREEN 	= 4'b1000;

// Symbolic bird motion state definitions 
localparam	TOP		= 4'b0001,
		DOWN		= 4'b0010,
		UP		= 4'b0100,
		STOP		= 4'b1000;

// Symbolic bird flapping state definitions 
localparam	FLAP_1 		= 2'd0,
		FLAP_2		= 2'd1,
		FLAP_3 		= 2'd2;

// Symbolic bird angle state definitions 
localparam	HORZ 		= 2'd0,
		POS_45		= 2'd1,
		NEG_45 		= 2'd2;
				
// Constant definitions dictating the motion of the bird under 'gravity'			
localparam TIME_START      	=  25000;  // starting time to load when beginning to flap up
localparam TIME_STEP       	=   5000;  // value to decrement or incremnt start time until above or below MAX or TERMINAL
localparam TIME_MAX        	= 475000;  // start time for fall, end time for rise
localparam TIME_TERMINAL   	= 150000;  // terminal time reached when falling down

reg [3:0] motion_state, prev_state;
reg [31:0] flap_elapsed, flap_start;

always @(posedge clk or posedge rst)
begin
	if (rst) begin
		motion_state 	<= DOWN;
		prev_state	<= DOWN;
		flap_elapsed 	<= TIME_MAX;
		flap_start	<= TIME_MAX;
		bird_state 	<= FLAP_1;
		bird_angle 	<= HORZ;
		birdY 		<= (480 - BIRD_SIZE_Y)/2;
	end else begin
		case (motion_state)

			TOP: begin
				// set bird state and angle
				bird_angle	<= HORZ;
				bird_state 	<= FLAP_2;
				
				// reset time registers to max value
				flap_elapsed 	<= TIME_MAX;
				flap_start 	<= TIME_MAX;
				
				// always transition to DOWN state
				motion_state 	<= DOWN;
			end
			
			DOWN: begin
				// set bird state and angle based on the elapsed time since motion start
				bird_state 	<= (flap_start >= (TIME_MAX/5)*3) ? FLAP_2 : FLAP_1;
				bird_angle	<= (flap_start >= (TIME_MAX/5)*4) ? HORZ : POS_45;
				
				if (game_state == PAUSE || game_state == END_SCREEN) begin
					// If paused or game over, stop motion
					prev_state 	<= DOWN;
					motion_state	<= STOP;
				end
				
				// decrement the elapsed time counter
				flap_elapsed 	<= flap_elapsed - 1;
				
				if (flap_elapsed == 0) begin
					// if elapsed time reaches 0, move the bird downwards 1 pixel,
					// and decrease the starting load value, decreasing the amount of time
					// before elapsed time reaches 0 again, thereby simulating downward acceleration.
					if (flap_start > TIME_TERMINAL) begin
						flap_start 	<= flap_start - TIME_STEP;
						flap_elapsed 	<= flap_start;
					end else begin
						flap_elapsed 	<= TIME_TERMINAL;
					end
					
					birdY <= birdY + 1;
				end
				
				if (flap || (game_state == START_SCREEN && birdY > 250 && !(birdY >= 480))) begin
					// if user input flap is high, transition to UP state. This is forced in the 
					// START_SCREEN game state
					motion_state 	<= UP;
					flap_start 	<= TIME_START;
					flap_elapsed 	<= TIME_START;
					bird_state 	<= FLAP_3;
				end
			end
			
			UP: begin
				// set bird state and angle based on the elapsed time since motion start
				bird_state 	<= (flap_start <= (TIME_MAX/5)*3) ? FLAP_3 : FLAP_2;
				bird_angle	<= (flap_start <= (TIME_MAX/5)*4) ? NEG_45 : HORZ;
				
				if (game_state == PAUSE || game_state == END_SCREEN) begin
					// If paused or game over, stop motion
					prev_state 	<= UP;
					motion_state	<= STOP;
				end
				
				// decrement the elapsed time counter
				flap_elapsed <= flap_elapsed - 1;
				
				if (flap_elapsed == 0) begin
					// if elapsed time reaches 0, move the bird upwards 1 pixel,
					// and decrease the starting load value, decreasing the amount of time
					// before elapsed time reaches 0 again, thereby simulating downward acceleration.
					if (flap_start <= TIME_MAX) begin
						flap_start 	<= flap_start + TIME_STEP;
						flap_elapsed 	<= flap_start;
						birdY 		<= birdY - 1;
					end else begin
						motion_state 	<= TOP;
					end
				end				
			end
			
			STOP: begin
				if (game_state == START_SCREEN || game_state == IN_GAME) begin
					// wait in STOP state until game state updates then return to
					// the previous state
					motion_state <= prev_state;
				end
			end
			
			default:	birdY <= birdY;
			
		endcase
	end
end

endmodule
		
