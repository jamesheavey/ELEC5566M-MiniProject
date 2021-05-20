/*
 * ELEC5566 MINI-PROJECT:
 * FLAPPY BIRD
 * ---------------------------------
 * For: University of Leeds
 * Date: 19/5/2021
 *
 * Description
 * ---------------------------------
 * This module represents the Top-level design
 * file defining the function of a simple
 * recreation of the popular iOS game
 * "Flappy Bird".
 *
 * Use
 * ---------------------------------
 * This module was designed for implementation
 * on the DE1-SoC board with pin assignments 
 * detailed in "pin_config.csv". A VGA monitor/
 * TV must be connected to the board for image
 * display, along with a PS2 keyboard for character
 * control.
 *
 */

module flappy_bird
(	
	// INPUTS
	input clk, rst,
	input PS2_clk, PS2_data,
	
	// OUTPUTS
	output h_sync, v_sync,
	output v_clk, display_on, sync_n,
	output [7:0] R, G, B,
	output [9:0] LED,
	output [41:0] seven_seg
);


// PARAMETERS
localparam SCALE 		=   3;
localparam PIPE_GAP 	=  75;
localparam NUM_PIPES =   4;
localparam PIPE_SEP	= 250;
localparam BIRD_SIZE_X = 18*SCALE, BIRD_SIZE_Y = 15*SCALE;
localparam BIRD_X		= 150;


// 25MHz clk required by VGA 640x480 timing 
wire VGA_clk;
clk_divider VGA (clk, VGA_clk);

// 30Hz clk used to scroll background textures
wire BG_clk;
clk_divider #(1666666-1) BG (clk, BG_clk);

// 250Hz clk used to scroll the floor texture and move the pipes
wire FL_clk;
clk_divider #(200000-1) FLOOR (clk, FL_clk);


// Wire definitions, connecting instantiated modules
wire [3:0] game_state;
wire [1:0] bird_state, bird_angle;

wire [31:0] X, Y, birdX=BIRD_X, birdY, score_count;
wire [(32*NUM_PIPES)-1:0] pipeX_flat, pipeY_flat;
wire [11:0] score_BCD, hiscore_BCD;

wire flap, pause, collision;


// Instantiation of the vga generator module.
// This module outputs the relevant VGA port outputs 
// as well as the current update pixel coordinates (X,Y).
// These coordinates are used by the image renderer to time
// sprite display.
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


// Instantiation of the PS2 keyboard input module.
// This module reads the output from a connected PS2
// keyboard and decodes the signal into 2 keypresses:
// space = "flap", esc = "pause".
keyboard_input kb
(
	.clk				( clk 			),
	.rst				( rst 			),
	.PS2_clk			( PS2_clk 		),
	.PS2_data		( PS2_data 		),
	.flap				( flap 			),
	.pause			( pause 			)
);


// Instantiation of the game FSM module.
// This module defines the current game state
// and transitions based on user inputs or game
// events. The current game state is output to 
// determine functions within other modules.
game_FSM FSM
(
	.clk				( clk 			),
	.rst				( rst 			),
	.collision		( collision 	),
	.pause			( pause 			),
	.flap				( flap 			),
	.game_state		( game_state 	)
);


// Instantiation of the bird physics module.
// This module defines the motion of the bird
// character. The bird Y coordinate is output 
// for use in image rendering and collision.
bird_physics #(
	.BIRD_SIZE_X	( BIRD_SIZE_X 	),
	.BIRD_SIZE_Y	( BIRD_SIZE_Y 	)
) physics (
	.clk				( clk 			),
	.rst				( rst				),
	.game_state		( game_state 	),
	.flap				( flap 			),
	.birdY			( birdY 			),
	.bird_state		( bird_state 	),
	.bird_angle		( bird_angle	)
);


// Instantiation of the collision detetcion module.
// This module uses the current bird and pipe coordinates
// to determine if any sprites overlap. if they do,
// collision goes high.
collision_detection #(
	.BIRD_SIZE_X	( BIRD_SIZE_X 	),
	.BIRD_SIZE_Y	( BIRD_SIZE_Y 	),
	.PIPE_GAP		( PIPE_GAP		),
	.NUM_PIPES		( NUM_PIPES		)
) detect (
	.clk				( clk 			),
	.birdX			( birdX 			),
	.birdY			( birdY 			),
	.pipeX_flat		( pipeX_flat	),
	.pipeY_flat		( pipeY_flat	),
	.collision		( collision		)
);


// Instantiation of the pipe controller module.
// This module creates and moves the pipe obstacles
// for the game. The number and separation of pipes
// are defined as input params.
pipes #(
	.NUM_PIPES		( NUM_PIPES		),
	.PIPE_SEP		( PIPE_SEP		)
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


// Instantiation of the score counter module.
// This module tracks the current score and hiscore,
// transforming them to BCD for display on the screen
// and 7 segments.
score_display score
(
	.rst				( rst				),
	.score_count	( score_count	),
	.score_BCD		( score_BCD		),
	.hiscore_BCD	( hiscore_BCD	),
	.seven_seg		( seven_seg		)
);


// Instantiation of the image renderer module.
// This module outs a 24-bit RGB pixel colour at
// every VGA clk cycle. The colour is selected via
// logic using the VGA pixel coordinates (X,Y),
// the object positions and sizes, and the display
// priority of each sprite.
image_rendering #(
	.BIRD_SIZE_X	( BIRD_SIZE_X 	),
	.BIRD_SIZE_Y	( BIRD_SIZE_Y 	),
	.SCALE			( SCALE 			),
	.PIPE_GAP		( PIPE_GAP		),
	.NUM_PIPES		( NUM_PIPES		)
) display (
	.VGA_clk			( VGA_clk 		),
	.BG_clk			( BG_clk 		),
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

// Upon collision, the LEDs flash
assign LED = FL_clk ? {9{collision}} : 0;

endmodule
