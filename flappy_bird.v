module flappy_bird
(	
	(* chip_pin = "AF14" *)
	input clk,
	
	(* chip_pin = "AB12" *)
	input rst,
	
//	(* chip_pin = "Y16, W15, AA15, AA14" *)
//	input [3:0] key,
	
	(* chip_pin = "AD7" *)
	input PS2_clk,
	
	(* chip_pin = "AE7" *)
	input PS2_data,
	
	(* chip_pin = "B11" *) 
	output h_sync,
	
	(* chip_pin = "D11" *) 
	output v_sync,
	
	(* chip_pin = "A11" *)
	output v_clk,
	
	(* chip_pin = "F10" *)
	output display_on,
	
	(* chip_pin = "C10" *)
	output sync_n,
	
	(* chip_pin = "F13, E12, D12, C12, B12, E13, C13, A13" *)
	output [7:0] R,
	
	(* chip_pin = "E11, F11, G12, G11, G10, H12, J10, J9" *)	
	output [7:0] G,
	
	(* chip_pin = "J14, G15, F15, H14, F14, H13, G13, B13" *)
	output [7:0] B,
	
	(* chip_pin = "Y21, W21, W20, Y19, W19, W17, V18, V17, W16, V16" *)
	output [9:0] led
);

localparam [6:0] SCALE = 3;
localparam [6:0] BIRD_SIZE_X = 18*SCALE, BIRD_SIZE_Y = 12*SCALE;
localparam PIPE_GAP = 70;
localparam NUM_PIPES = 4;

wire VGA_clk;
clk_divider VGA (clk, VGA_clk);

wire GAME_clk;
clk_divider #(1666666-1) GAME (clk, GAME_clk); // 30 Hz

wire FL_clk;
clk_divider #(200000-1) FLOOR (clk, FL_clk);


wire [3:0] game_state;
wire [2:0] bird_state;

wire signed [31:0] X, Y, birdX=150, birdY;
wire [31:0] score_count;
wire signed [31:0] pipeX [NUM_PIPES-1:0];
wire signed [31:0] pipeY [NUM_PIPES-1:0];


wire flap, pause, collision;

vga_gen vga
(
	.clk				( VGA_clk 		),
	.rst				( rst 			),
	.h_sync			( h_sync 		),
	.v_sync			( v_sync 		),
	.v_clk			( v_clk 			),
	.display_on		( display_on 	),
	.sync_n			( sync_n 		),
	.h_pos			( X 				),
	.v_pos			( Y 				)
);

keyboard_input kb
(
	.clk				( clk 			),
	.rst				( rst 			),
	.PS2_clk			( PS2_clk 		),
	.PS2_data		( PS2_data 		),
	.flap				( flap 			),
	.pause			( pause 			)
);

game_FSM FSM
(
	.clk				( clk 			),
	.rst				( rst 			),
	.collision		( collision 	),
	.pause			( pause 			),
	.flap				( flap 			),
	.game_state		( game_state 	)
);

bird_physics #(
	.BIRD_SIZE_X	( BIRD_SIZE_X 	),
	.BIRD_SIZE_Y	( BIRD_SIZE_Y 	)
) phys (
	.GAME_clk		( GAME_clk 		),
	.rst				( rst				),
	.game_state		( game_state 	),
	.flap				( flap 			),
	.birdY			( birdY 			),
	.bird_state		( bird_state 	)
);

collision_detection #(
	.BIRD_SIZE_X	( BIRD_SIZE_X 	),
	.BIRD_SIZE_Y	( BIRD_SIZE_Y 	),
	.PIPE_GAP		( PIPE_GAP		),
	.NUM_PIPES		( NUM_PIPES		)
) coll (
	.clk				( clk 			),
	.birdX			( birdX 			),
	.birdY			( birdY 			),
	.pipeX_1			( pipeX[0]		),
	.pipeX_2			( pipeX[1]		),
	.pipeX_3			( pipeX[2]		),
	.pipeX_4			( pipeX[3]		),
	.pipeY_1			( pipeY[0]		),
	.pipeY_2			( pipeY[1]		),
	.pipeY_3			( pipeY[2]		),
	.pipeY_4			( pipeY[3]		),
	.collision		( collision		)
);

pipes #(
	.NUM_PIPES		( NUM_PIPES		)
) pipe_shift (
	.clk				( clk 			),
	.FL_clk			( FL_clk			),
	.rst				( rst				),
	.game_state 	( game_state	),
	.pipeX_1			( pipeX[0]		),
	.pipeX_2			( pipeX[1]		),
	.pipeX_3			( pipeX[2]		),
	.pipeX_4			( pipeX[3]		),
	.pipeY_1			( pipeY[0]		),
	.pipeY_2			( pipeY[1]		),
	.pipeY_3			( pipeY[2]		),
	.pipeY_4			( pipeY[3]		),
	.score_count	( score_count	)
);

score_counter scr
(
	.clk				( cLK 			),
	.rst				( rst				),
	.game_state 	( game_state	),
	.score_count	( score_count	),
	.score_BCD		( score_BCD		),
	.hiscore_BCD	( hiscore_BCD	),
	.scoreX			( scoreX			),
	.scoreY			( scoreY			),
	.seven_seg		( seven_seg		)
);
	
image_renderer #(
	.BIRD_SIZE_X	( BIRD_SIZE_X 	),
	.BIRD_SIZE_Y	( BIRD_SIZE_Y 	),
	.SCALE			( SCALE 			),
	.PIPE_GAP		( PIPE_GAP		),
	.NUM_PIPES		( NUM_PIPES		)
) display (
	.VGA_clk			( VGA_clk 		),
	.GAME_clk		( GAME_clk 		),
	.FL_clk			( FL_clk			),
	.rst				( rst 			),
	.display_on		( display_on 	),
	.game_state		( game_state 	),
	.bird_state		( bird_state 	),
	.flap				( flap 			),
	.X					( X 				),
	.Y					( Y 				),
	.birdX			( birdX 			),
	.birdY			( birdY 			),
	.pipeX_1			( pipeX[0]		),
	.pipeX_2			( pipeX[1]		),
	.pipeX_3			( pipeX[2]		),
	.pipeX_4			( pipeX[3]		),
	.pipeY_1			( pipeY[0]		),
	.pipeY_2			( pipeY[1]		),
	.pipeY_3			( pipeY[2]		),
	.pipeY_4			( pipeY[3]		),
	.RGB				( {R,G,B} 		)
);

//assign led = {collision, pause, flap};
assign led = score_count;

endmodule
