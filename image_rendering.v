/*
 * ELEC5566 MINI-PROJECT:
 * IMAGE RENDERING
 * ---------------------------------
 * For: University of Leeds
 * Date: 19/5/2021
 *
 * Description
 * ---------------------------------
 * This module determines the pixel colour
 * output based on the current VGA X,Y coordinates
 * in relation to sprite locations.
 *
 */

module image_rendering #(
	// PARAMETERS
	parameter BIRD_SIZE_X,
	parameter BIRD_SIZE_Y,
	parameter SCALE,
	parameter PIPE_GAP,
	parameter NUM_PIPES
)(
	// INPUTS
	input VGA_clk, BG_clk, FL_clk, rst, display_on,
	input [3:0] game_state,
	input [1:0] bird_state, bird_angle,
	input [31:0] X, Y, birdX, birdY,
	input [(32*NUM_PIPES)-1:0] pipeX_flat, pipeY_flat,
	input [11:0] score_BCD, hiscore_BCD,
	
	// OUTPUT
	output reg [23:0] RGB
);

// Symbolic game FSM state definitions 
localparam	START_SCREEN 	= 4'b0001,
				IN_GAME			= 4'b0010,
				PAUSE 			= 4'b0100,
				END_SCREEN 		= 4'b1000;
				
// RGB24 colour definitions
localparam NO_COLOUR 		= 24'h000000;	// RGB off
localparam IGNORE_COLOUR 	= 24'hFF0096;	// Preset RGB colour to ignore in sprite maps
localparam HALF_COLOUR 		= 24'hF0F0F0;	// RGB colour used to half the colour output via right shift


// SPRITE LOCATION & SIZE DEFINITIONS

localparam DISPLAY_SIZE_X = 640, DISPLAY_SIZE_Y = 480;

localparam BG_SIZE_X = 214*SCALE, BG_SIZE_Y = 40*SCALE;
localparam BG_Y = 300;

localparam FLOOR_SIZE_X = 214*SCALE, FLOOR_SIZE_Y = 10*SCALE; 
localparam FLOOR_Y = BG_SIZE_Y + BG_Y - 2;

localparam TITLE_SIZE_X = 96*SCALE, TITLE_SIZE_Y = 22*SCALE;
localparam TITLE_X = (DISPLAY_SIZE_X-TITLE_SIZE_X)/2, TITLE_Y = 50;

localparam PAUSE_SIZE_X = 13*SCALE, PAUSE_SIZE_Y = 13*SCALE; 
localparam PAUSE_X = (DISPLAY_SIZE_X-PAUSE_SIZE_X)/2, PAUSE_Y = (DISPLAY_SIZE_Y-PAUSE_SIZE_Y)/2;

localparam PIPE_SIZE_X = 26*SCALE, PIPE_SIZE_Y = 120*SCALE;

localparam OVER_SIZE_X = 96*SCALE, OVER_SIZE_Y = 22*SCALE;
localparam OVER_X = (DISPLAY_SIZE_X-OVER_SIZE_X)/2, OVER_Y = 50;

localparam SCORE_SIZE_X = 112*SCALE, SCORE_SIZE_Y = 56*SCALE;
localparam SCORE_X = (DISPLAY_SIZE_X-SCORE_SIZE_X)/2, SCORE_Y = 150;

localparam NUM_SIZE_X = 7*SCALE, NUM_SIZE_Y = 10*SCALE;
localparam NUM_SPACING = 5;

localparam MEDAL_SIZE_X = 22*SCALE, MEDAL_SIZE_Y = 22*SCALE;


///////////////////////////////////////////////////////////////////////////////////
/////										DISPLAY LOGIC											/////
///////////////////////////////////////////////////////////////////////////////////

// Logic block determining the display priority of the relevant sprites in each top-level game state

always @(posedge VGA_clk or posedge rst)
begin
	if (rst) begin
		RGB <= NO_COLOUR;
	end else begin
		case(game_state)
			START_SCREEN: begin
				if (display_on) begin
					if			(title_gfx)	RGB <= title_colour;
					
					else if	(bird_gfx && bird_colour[bird_state][bird_angle] != IGNORE_COLOUR)	RGB <= bird_colour[bird_state][bird_angle];
		
					else if 	(bg_0_gfx)	RGB <= bg_colour[0];
					else if 	(bg_1_gfx)	RGB <= bg_colour[1];
					else if 	(bg_2_gfx)	RGB <= bg_colour[2];
					else if 	(bg_3_gfx)	RGB <= bg_colour[3];
					
					else RGB <= NO_COLOUR;
				end else begin
					RGB <= NO_COLOUR;
				end end
				
			IN_GAME: begin
				if (display_on) begin
					if			(bird_gfx && bird_colour[bird_state][bird_angle] != IGNORE_COLOUR)	RGB <= bird_colour[bird_state][bird_angle];
					
					else if (num_gfx && num_colour != IGNORE_COLOUR) RGB <= num_colour;
					
					else if	(|{pipe_btm_gfx, pipe_top_gfx} && pipe_colour != IGNORE_COLOUR && !bg_2_gfx && !bg_3_gfx)	RGB <= pipe_colour;
					
					else if 	(bg_0_gfx)	RGB <= bg_colour[0];
					else if 	(bg_1_gfx)	RGB <= bg_colour[1];
					else if 	(bg_2_gfx)	RGB <= bg_colour[2];
					else if 	(bg_3_gfx)	RGB <= bg_colour[3];

					else RGB <= NO_COLOUR;
				end else begin
					RGB <= NO_COLOUR;
				end end
				
			PAUSE: begin
				if (display_on) begin
					if			(pause_gfx)	RGB <= pause_colour;
					
					else if (num_gfx && num_colour != IGNORE_COLOUR) RGB <= num_colour;
					
					else if	(bird_gfx && bird_colour[bird_state][bird_angle] != IGNORE_COLOUR)	RGB <= (bird_colour[bird_state][bird_angle] & HALF_COLOUR) >> 2;
					
					else if	(|{pipe_btm_gfx, pipe_top_gfx} && pipe_colour != IGNORE_COLOUR && !bg_2_gfx && !bg_3_gfx)	RGB <= (pipe_colour & HALF_COLOUR) >> 2;
					
					else if 	(bg_0_gfx)	RGB <= (bg_colour[0] & HALF_COLOUR) >> 2;
					else if 	(bg_1_gfx)	RGB <= (bg_colour[1] & HALF_COLOUR) >> 2;
					else if 	(bg_2_gfx)	RGB <= (bg_colour[2] & HALF_COLOUR) >> 2;
					else if 	(bg_3_gfx)	RGB <= (bg_colour[3] & HALF_COLOUR) >> 2;

					else RGB <= NO_COLOUR;
				end else begin
					RGB <= NO_COLOUR;
				end end
				
			END_SCREEN: begin
				if (display_on) begin
					if			(game_over_gfx)	RGB <= over_colour;
					
					else if (num_gfx && num_colour != IGNORE_COLOUR) 	RGB <= num_colour;
					
					else if (medal_gfx && medal_colour != IGNORE_COLOUR) 	RGB <= medal_colour;
					
					else if	(score_gfx)		RGB <= score_colour;
					
					else if	(bird_gfx && bird_colour[bird_state][bird_angle] != IGNORE_COLOUR)	RGB <= bird_colour[bird_state][bird_angle];
					
					else if	(|{pipe_btm_gfx, pipe_top_gfx} && pipe_colour != IGNORE_COLOUR && !bg_2_gfx && !bg_3_gfx)	RGB <= pipe_colour;
					
					else if 	(bg_0_gfx)	RGB <= bg_colour[0];
					else if 	(bg_1_gfx)	RGB <= bg_colour[1];
					else if 	(bg_2_gfx)	RGB <= bg_colour[2];
					else if 	(bg_3_gfx)	RGB <= bg_colour[3];

					else RGB <= NO_COLOUR;
				end else begin
					RGB <= NO_COLOUR;
				end end
			
			default: RGB <= NO_COLOUR;
		endcase
	end
end


///////////////////////////////////////////////////////////////////////////////////
/////										BIRD														/////
///////////////////////////////////////////////////////////////////////////////////

wire bird_gfx = (X - birdX-1 < BIRD_SIZE_X) && (Y - birdY < BIRD_SIZE_Y);
wire [23:0] bird_colour [2:0][2:0];
flap_1_rom bird1
(
	.clk				( VGA_clk 				),
	.row				( (Y-birdY)/SCALE 	),
	.col				( (X-birdX)/SCALE 	),
	.colour_data 	( bird_colour[0][0] 	)
);

flap_1_pos45_rom bird1_pos
(
	.clk				( VGA_clk 				),
	.row				( (Y-birdY)/SCALE 	),
	.col				( (X-birdX)/SCALE 	),
	.colour_data 	( bird_colour[0][1]	)
);

flap_1_neg45_rom bird1_neg
(
	.clk				( VGA_clk 				),
	.row				( (Y-birdY)/SCALE 	),
	.col				( (X-birdX)/SCALE 	),
	.colour_data 	( bird_colour[0][2]	)
);

flap_2_rom bird2
(
	.clk				( VGA_clk 				),
	.row				( (Y-birdY)/SCALE 	),
	.col				( (X-birdX)/SCALE	),
	.colour_data 	( bird_colour[1][0]	)
);

flap_2_pos45_rom bird2_pos
(
	.clk				( VGA_clk 				),
	.row				( (Y-birdY)/SCALE 	),
	.col				( (X-birdX)/SCALE	),
	.colour_data 	( bird_colour[1][1]	)
);

flap_2_neg45_rom bird2_neg
(
	.clk				( VGA_clk 				),
	.row				( (Y-birdY)/SCALE 	),
	.col				( (X-birdX)/SCALE	),
	.colour_data 	( bird_colour[1][2]	)
);

flap_3_rom bird3
(
	.clk				( VGA_clk 				),
	.row				( (Y-birdY)/SCALE 	),
	.col				( (X-birdX)/SCALE 	),
	.colour_data 	( bird_colour[2][0]	)
);

flap_3_pos45_rom bird3_pos
(
	.clk				( VGA_clk 				),
	.row				( (Y-birdY)/SCALE 	),
	.col				( (X-birdX)/SCALE 	),
	.colour_data 	( bird_colour[2][1]	)
);

flap_3_neg45_rom bird3_neg
(
	.clk				( VGA_clk 				),
	.row				( (Y-birdY)/SCALE 	),
	.col				( (X-birdX)/SCALE 	),
	.colour_data 	( bird_colour[2][2]	)
);


///////////////////////////////////////////////////////////////////////////////////
/////										TITLE														/////
///////////////////////////////////////////////////////////////////////////////////

wire title_gfx = (X-TITLE_X-1 < TITLE_SIZE_X) && (Y-TITLE_Y < TITLE_SIZE_Y) && (title_colour != IGNORE_COLOUR);
wire [23:0] title_colour;
title_rom title
(
	.clk				( VGA_clk 				),
	.row				( (Y-TITLE_Y)/SCALE	),
	.col				( (X-TITLE_X)/SCALE 	),
	.colour_data	( title_colour 		)
);


///////////////////////////////////////////////////////////////////////////////////
/////										PAUSE														/////
///////////////////////////////////////////////////////////////////////////////////

wire pause_gfx = (X-PAUSE_X-1 < PAUSE_SIZE_X) && (Y-PAUSE_Y < PAUSE_SIZE_Y) && (pause_colour != IGNORE_COLOUR);
wire [23:0] pause_colour;
pause_rom pause_icon
(
	.clk				( VGA_clk 				),
	.row				( (Y-PAUSE_Y)/SCALE 	),
	.col				( (X-PAUSE_X)/SCALE 	),
	.colour_data	( pause_colour 		)
);


///////////////////////////////////////////////////////////////////////////////////
/////										BACKGROUND												/////
///////////////////////////////////////////////////////////////////////////////////

reg [15:0] X_ofs_bg = 0, X_ofs_fl = 0;
always @(posedge BG_clk) begin
	if (game_state != PAUSE && game_state != END_SCREEN) begin
		if (X_ofs_bg != 640)
			X_ofs_bg <= X_ofs_bg + 1;
		else
			X_ofs_bg <= 0;
	end
end

always @(posedge FL_clk) begin
	if (game_state != PAUSE && game_state != END_SCREEN) begin
		if (X_ofs_fl != 640)
			X_ofs_fl <= X_ofs_fl + 1;
		else
			X_ofs_fl <= 0;
	end
end

wire [23:0] bg_colour [3:0];

wire bg_0_gfx = (Y <= BG_Y);
wire bg_1_gfx = (X < BG_SIZE_X) && (Y - (BG_Y) < BG_SIZE_Y) && (bg_colour[1] != IGNORE_COLOUR);
wire bg_2_gfx = (X < FLOOR_SIZE_X) && (Y - (FLOOR_Y) < FLOOR_SIZE_Y) && (bg_colour[1] != IGNORE_COLOUR);
wire bg_3_gfx = (Y > FLOOR_Y + FLOOR_SIZE_Y -1);

assign bg_colour [0] = 24'h70C5CE;

background_rom bg
(
	.clk				( VGA_clk 											),
	.row				( (Y-BG_Y)/SCALE 									),
	.col				( ((X + X_ofs_bg)%DISPLAY_SIZE_X)/SCALE 	),
	.colour_data 	( bg_colour[1] 									)
);

floor_rom floor
(
	.clk				( VGA_clk 											),
	.row				( (Y-FLOOR_Y)/SCALE 								),
	.col				( ((X + X_ofs_fl)%DISPLAY_SIZE_X)/SCALE 	),
	.colour_data 	( bg_colour[2] 									)
);

assign bg_colour [3] = 24'hDED895;


///////////////////////////////////////////////////////////////////////////////////
/////										PIPES														/////
///////////////////////////////////////////////////////////////////////////////////
									
reg [3:0] pipe_btm_gfx, pipe_top_gfx;
reg [31:0] pipe_row, pipe_col;

wire [23:0] pipe_colour;
wire signed [31:0] pipeX [NUM_PIPES-1:0];
wire signed [31:0] pipeY [NUM_PIPES-1:0];

// Unpack flat pipe coordinate arrays
genvar z;
generate
	for (z = 0; z < NUM_PIPES; z = z + 1) begin : pipe_assignment
		assign pipeX[z] = pipeX_flat[32*(z+1)-1-:32];
		assign pipeY[z] = pipeY_flat[32*(z+1)-1-:32];
	end
endgenerate
 
pipe_rom pipe
(
	.clk				( VGA_clk 		),
	.row				( |{pipe_btm_gfx, pipe_top_gfx} ? pipe_row : 16 ),
	.col				( |{pipe_btm_gfx, pipe_top_gfx} ? pipe_col : 25 ),
	.colour_data 	( pipe_colour	)
);

integer i;
always @(X or Y)
begin
	for (i = 0; i < NUM_PIPES; i = i + 1) begin
		pipe_btm_gfx[i] <= 	(X - (pipeX[i]) < PIPE_SIZE_X) &&
									(Y - (pipeY[i]+PIPE_GAP) < PIPE_SIZE_Y);
									
		pipe_top_gfx[i] <=	(X - (pipeX[i]) < PIPE_SIZE_X) && 
									(-Y + (pipeY[i]-PIPE_GAP) < PIPE_SIZE_Y);
		
		if (pipe_btm_gfx[i]) begin
			pipe_row <= (Y - pipeY[i] - PIPE_GAP)/SCALE;
			pipe_col <= (X - pipeX[i])/SCALE;
		
		end else if (pipe_top_gfx[i]) begin
			pipe_row <= (-Y + pipeY[i] - PIPE_GAP)/SCALE;
			pipe_col <= (X - pipeX[i])/SCALE;
			
		end
	end
end


///////////////////////////////////////////////////////////////////////////////////
/////										END SCREEN												/////
///////////////////////////////////////////////////////////////////////////////////

wire game_over_gfx = (X-OVER_X-1 < OVER_SIZE_X) && (Y-OVER_Y < OVER_SIZE_Y) && (over_colour != IGNORE_COLOUR);
wire [23:0] over_colour;
game_over_rom over
(
	.clk				( VGA_clk 				),
	.row				( (Y-OVER_Y)/SCALE 	),
	.col				( (X-OVER_X)/SCALE 	),
	.colour_data 	( over_colour			)
);

wire score_gfx = (X-SCORE_X-1 < SCORE_SIZE_X) && (Y-SCORE_Y < SCORE_SIZE_Y) && (score_colour != IGNORE_COLOUR);
wire [23:0] score_colour;
score_rom scr
(
	.clk				( VGA_clk 				),
	.row				( (Y-SCORE_Y)/SCALE 	),
	.col				( (X-SCORE_X)/SCALE 	),
	.colour_data 	( score_colour			)
);


///////////////////////////////////////////////////////////////////////////////////
/////										SCORE														/////
///////////////////////////////////////////////////////////////////////////////////

reg [31:0] num_col, num_row, medal_col, medal_row;
reg num_gfx, medal_gfx;
wire [23:0] num_colour, medal_colour;
numbers_rom num
(
	.clk				( VGA_clk 					),
	.row				( num_gfx ? num_row: 11	),
	.col				( num_gfx ? num_col: 0 	),
	.colour_data 	( num_colour				)
);

medals_rom medal
(
	.clk				( VGA_clk 				),
	.row				( medal_row 			),
	.col				( medal_col 			),
	.colour_data 	( medal_colour			)
);

always@(X or Y)
begin
	
	{num_row, num_col, num_gfx, medal_row, medal_col, medal_gfx} = 0;
	
	case (game_state)
		IN_GAME, PAUSE: begin
			
			for (i = 0; i < 3; i = i + 1) begin
			
				if (X >= (550 + i*(NUM_SPACING+NUM_SIZE_X)) 
					&& X < (550 + i*(NUM_SPACING+NUM_SIZE_X)) + NUM_SIZE_X 
					&& Y >= 16 
					&& Y < 16 + NUM_SIZE_Y) 
					begin
					
					if (!(i < 2 && score_BCD[4*(3-i)-1-:4] == 0)) begin
						num_col = (X - (550 + i*(NUM_SPACING+NUM_SIZE_X))) /SCALE;
						num_row = (Y - 16 + (score_BCD[4*(3-i)-1-:4] * NUM_SIZE_Y)) /SCALE;
						num_gfx = 1;
					end
				end
				
			end
		end
		
		END_SCREEN: begin
			
			for (i = 0; i < 3; i = i + 1) begin
			
				if (X >= (SCORE_X + 230 + i*(NUM_SPACING+NUM_SIZE_X)) 
					&& X < (SCORE_X + 230 + i*(NUM_SPACING+NUM_SIZE_X)) + NUM_SIZE_X 
					&& Y >= SCORE_Y + 50 && Y < SCORE_Y + 50 + NUM_SIZE_Y) 
					begin
					
					if (!(i < 2 && score_BCD[4*(3-i)-1-:4] == 0)) begin
						num_col = (X - (SCORE_X + 230 + i*(NUM_SPACING+NUM_SIZE_X))) /SCALE;
						num_row = (Y - (SCORE_Y + 50) + (score_BCD[4*(3-i)-1-:4] * NUM_SIZE_Y)) /SCALE;
						num_gfx = 1;
					end
				end
	
				if (X >= (SCORE_X + 230 + i*(NUM_SPACING+NUM_SIZE_X)) 
					&& X < (SCORE_X + 230 + i*(NUM_SPACING+NUM_SIZE_X)) + NUM_SIZE_X 
					&& Y >= SCORE_Y + 110 
					&& Y < SCORE_Y + 110 + NUM_SIZE_Y) 
					begin
				
					if (!(i < 2 && hiscore_BCD[4*(3-i)-1-:4] == 0)) begin
						num_col = (X - (SCORE_X + 230 + i*(NUM_SPACING+NUM_SIZE_X))) /SCALE;
						num_row = (Y - (SCORE_Y + 110) + (hiscore_BCD[4*(3-i)-1-:4] * NUM_SIZE_Y)) /SCALE;
						num_gfx = 1;
					end
				end
				
			end

			if (X >= (SCORE_X+36) 
				&& X < (SCORE_X+36) + MEDAL_SIZE_X 
				&& Y >= (SCORE_Y+60) 
				&& Y < (SCORE_Y+60) + MEDAL_SIZE_Y) 
				begin
			
				if (score_BCD[7:4] > 1) begin
					// GOLD
					medal_col = (X - (SCORE_X+36))/SCALE;
					medal_row = (Y - (SCORE_Y+60))/SCALE;
					medal_gfx = 1;
				
				end else if (score_BCD[7:4] > 0) begin
					// SILVER
					medal_col = (X - (SCORE_X+36))/SCALE;
					medal_row = (Y - (SCORE_Y+60) + (MEDAL_SIZE_Y))/SCALE;
					medal_gfx = 1;
				
				end else begin
					// BROnZE
					medal_col = (X - (SCORE_X+36))/SCALE;
					medal_row = (Y - (SCORE_Y+60) + (2*MEDAL_SIZE_Y))/SCALE;
					medal_gfx = 1;
				end
				
			end
			
		end
	endcase

end
		
endmodule
