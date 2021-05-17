module score_counter
(
	input clk, rst, 
	input [3:0] game_state,
	input	[31:0] score_count,
	output [31:0] score_BCD, hiscore_BCD,
	output [42:0] seven_seg,
	output scoreX, scoreY		// varies from top right in game state to middle at endscreen
);

localparam	START_SCREEN 	= 4'b0001,
				IN_GAME			= 4'b0010,
				PAUSE 			= 4'b0100,
				END_SCREEN 		= 4'b1000;		

reg [31:0] hiscore, score;


endmodule
