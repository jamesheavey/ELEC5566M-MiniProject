module game_FSM
(
	input clk, rst, collision, pause, flap, 
	output reg [3:0] game_state
);

localparam	START_SCREEN 	= 4'b0001,
				IN_GAME			= 4'b0010,
				PAUSE 			= 4'b0100,
				END_SCREEN 		= 4'b1000;
				

always @(posedge clk or posedge rst) begin

	if (rst) begin
	
		game_state	<= START_SCREEN;
		
	end else begin
		case (game_state)
		  
			START_SCREEN:
				if (flap)
					game_state	<= IN_GAME;
				else
					game_state	<= START_SCREEN;
	
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
				if (flap)
					game_state <= START_SCREEN;
				else
					game_state <= END_SCREEN;
	
			default:	game_state	<= START_SCREEN;
					
		endcase
	end
end
				
endmodule
