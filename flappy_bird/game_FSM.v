/*
 * ELEC5566 MINI-PROJECT:
 * GAME FSM
 * ---------------------------------
 * For: University of Leeds
 * Date: 19/5/2021
 *
 * Description
 * ---------------------------------
 * This module contains a FSM that determines the current 
 * state of the game at the top-level. The game-state is
 * output and used as an input for other modules to drive
 * logic. This FSM is the parent module for game functionality.
 *
 */

module game_FSM
(
	// INPUTS
	input clk, rst, collision, pause, flap,
	
	// OUTPUT
	output reg [3:0] game_state
);

// Symbolic state definitions
localparam	START_SCREEN 	= 4'b0001,
		IN_GAME		= 4'b0010,
		PAUSE 		= 4'b0100,
		END_SCREEN 	= 4'b1000;
				

always @(posedge clk or posedge rst) begin

	if (rst) begin
	
		game_state <= START_SCREEN;
		
	end else begin
		case (game_state)
		  
			START_SCREEN:
				if (flap)
					game_state <= IN_GAME;
				else
					game_state <= START_SCREEN;
	
			IN_GAME: 
				if (collision)
					game_state <= END_SCREEN;
				else if (pause)
					game_state <= PAUSE;
				else
					game_state <= IN_GAME;

			PAUSE:
				if (pause)
					game_state <= IN_GAME;
				else
					game_state <= PAUSE;
			
			END_SCREEN:
				if (pause)
					game_state <= START_SCREEN;
				else
					game_state <= END_SCREEN;
	
			default:
				game_state <= START_SCREEN;
					
		endcase
	end
end
				
endmodule
