module flappy_bird
(	
	input clk, rst,
	input PS2_clk, PS2_data,

	output h_sync, v_sync,
	output v_clk, display_on, sync_n,
	output [7:0] R, G, B,
	output [9:0] LED,
	output [41:0] seven_seg
);

localparam SCALE = 3;
localparam BIRD_SIZE_X = 18*SCALE, BIRD_SIZE_Y = 15*SCALE;
localparam PIPE_GAP = 75;
localparam NUM_PIPES = 4;

wire VGA_clk;
clk_divider VGA (clk, VGA_clk);

wire GAME_clk;
clk_divider #(1666666-1) GAME (clk, GAME_clk); // 30 Hz

wire FL_clk;
clk_divider #(200000-1) FLOOR (clk, FL_clk);

wire [3:0] game_state;
wire [1:0] bird_state, bird_angle;

wire [31:0] X, Y, birdX=150, birdY, score_count;
wire [(32*NUM_PIPES)-1:0] pipeX_flat, pipeY_flat;
wire [11:0] score_BCD, hiscore_BCD;

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
	.clk				( clk 			),
	.rst				( rst				),
	.game_state		( game_state 	),
	.flap				( flap 			),
	.birdY			( birdY 			),
	.bird_state		( bird_state 	),
	.bird_angle		( bird_angle	)
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
	.pipeX_flat		( pipeX_flat	),
	.pipeY_flat		( pipeY_flat	),
	.collision		( collision		)
);

pipes #(
	.NUM_PIPES		( NUM_PIPES		)
) pipe_shift (
	.clk				( clk 			),
	.FL_clk			( FL_clk			),
	.rst				( rst				),
	.game_state 	( game_state	),
	.birdX			( birdX 			),
	.pipeX_flat		( pipeX_flat	),
	.pipeY_flat		( pipeY_flat	),
	.score_count	( score_count	)
);

score_counter scr
(
	.rst				( rst				),
	.score_count	( score_count	),
	.score_BCD		( score_BCD		),
	.hiscore_BCD	( hiscore_BCD	),
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
	.bird_angle		( bird_angle	),
	.X					( X 				),
	.Y					( Y 				),
	.birdX			( birdX 			),
	.birdY			( birdY 			),
	.pipeX_flat		( pipeX_flat	),
	.pipeY_flat		( pipeY_flat	),
	.score_BCD		( score_BCD		),
	.hiscore_BCD	( hiscore_BCD	),
	.RGB				( {R,G,B} 		)
);

assign LED = GAME_clk ? {9{collision}} : 0;

endmodule
