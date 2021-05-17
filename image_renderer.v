module image_renderer #(
	parameter BIRD_SIZE_X,
	parameter BIRD_SIZE_Y,
	parameter SCALE,
	parameter PIPE_GAP,
	parameter NUM_PIPES
)(
	input VGA_clk, GAME_clk, FL_clk, rst, display_on, flap,
	input [3:0] game_state,
	input [2:0] bird_state,
	input [31:0] X, Y, birdX, birdY,
	input [31:0] pipeX_1, pipeX_2, pipeX_3, pipeX_4,
	input [31:0] pipeY_1, pipeY_2, pipeY_3, pipeY_4,
	input [11:0] score_BCD, hiscore_BCD,
	output reg [23:0] RGB
);

localparam NO_COLOUR = 24'h000000;
localparam IGNORE_COLOUR = 24'hFF0096;
localparam HALF_COLOUR = 24'hF0F0F0;

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

///////////////////////////////////////////////////////////////////////////////////
/////										DISPLAY LOGIC											/////
///////////////////////////////////////////////////////////////////////////////////

localparam	START_SCREEN 	= 4'b0001,
				IN_GAME			= 4'b0010,
				PAUSE 			= 4'b0100,
				END_SCREEN 		= 4'b1000;

always @(posedge VGA_clk or posedge rst)
begin
	if (rst) begin
		RGB <= NO_COLOUR;
	end else begin
		case(game_state)
			START_SCREEN: begin
				if (display_on) begin
					if			(title_gfx)	RGB <= title_colour;
					
					else if	(bird_gfx && bird_colour[bird_state] != IGNORE_COLOUR)	RGB <= bird_colour[bird_state];
		
					else if 	(bg0_gfx)	RGB <= bg_colour[0];
					else if 	(bg1_gfx)	RGB <= bg_colour[1];
					else if 	(bg2_gfx)	RGB <= bg_colour[2];
					else if 	(bg3_gfx)	RGB <= bg_colour[3];
					
					else RGB <= NO_COLOUR;
				end else begin
					RGB <= NO_COLOUR;
				end end
				
			IN_GAME: begin
				if (display_on) begin
					if			(bird_gfx && bird_colour[bird_state] != IGNORE_COLOUR)	RGB <= bird_colour[bird_state];
					
					else if	(|{pipe_btm_gfx, pipe_top_gfx} && pipe_colour != IGNORE_COLOUR && !bg2_gfx && !bg3_gfx)	RGB <= pipe_colour;
//					else if	(|{pipe_btm_gfx, pipe_top_gfx} && pipe_colour != IGNORE_COLOUR)	RGB <= pipe_colour;
					
					else if 	(bg0_gfx)	RGB <= bg_colour[0];
					else if 	(bg1_gfx)	RGB <= bg_colour[1];
					else if 	(bg2_gfx)	RGB <= bg_colour[2];
					else if 	(bg3_gfx)	RGB <= bg_colour[3];

//					else RGB <= 24'h70C5CE;
					else RGB <= NO_COLOUR;
				end else begin
					RGB <= NO_COLOUR;
				end end
				
			PAUSE: begin
				if (display_on) begin
					if			(pause_gfx)	RGB <= pause_colour;
					
					else if	(bird_gfx && bird_colour[bird_state] != IGNORE_COLOUR)	RGB <= (bird_colour[bird_state] & HALF_COLOUR) >> 2;
					
					else if	(|{pipe_btm_gfx, pipe_top_gfx} && pipe_colour != IGNORE_COLOUR && !bg2_gfx && !bg3_gfx)	RGB <= (pipe_colour & HALF_COLOUR) >> 2;
					
					else if 	(bg0_gfx)	RGB <= (bg_colour[0] & HALF_COLOUR) >> 2;
					else if 	(bg1_gfx)	RGB <= (bg_colour[1] & HALF_COLOUR) >> 2;
					else if 	(bg2_gfx)	RGB <= (bg_colour[2] & HALF_COLOUR) >> 2;
					else if 	(bg3_gfx)	RGB <= (bg_colour[3] & HALF_COLOUR) >> 2;

					else RGB <= NO_COLOUR;
				end else begin
					RGB <= NO_COLOUR;
				end end
				
			END_SCREEN: begin
				if (display_on) begin
					if			(game_over_gfx)	RGB <= over_colour;
					
					else if	(score_gfx)			RGB <= score_colour;
					
					// add dead bird sprite?
					else if	(bird_gfx && bird_colour[bird_state] != IGNORE_COLOUR)	RGB <= bird_colour[bird_state];
					
					else if	(|{pipe_btm_gfx, pipe_top_gfx} && pipe_colour != IGNORE_COLOUR && !bg2_gfx && !bg3_gfx)	RGB <= pipe_colour;
					
					else if 	(bg0_gfx)	RGB <= bg_colour[0];
					else if 	(bg1_gfx)	RGB <= bg_colour[1];
					else if 	(bg2_gfx)	RGB <= bg_colour[2];
					else if 	(bg3_gfx)	RGB <= bg_colour[3];

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
wire [23:0] bird_colour [2:0];
flap_1_rom bird1
(
	.clk				( VGA_clk 				),
	.row				( (Y - birdY)/SCALE 	),
	.col				( (X - birdX)/SCALE 	),
	.colour_data 	( bird_colour[0] 		)
);

flap_2_rom bird2
(
	.clk				( VGA_clk 				),
	.row				( (Y - birdY)/SCALE 	),
	.col				( (X - birdX)/SCALE	),
	.colour_data 	( bird_colour[1] 		)
);

flap_3_rom bird3
(
	.clk				( VGA_clk 				),
	.row				( (Y - birdY)/SCALE 	),
	.col				( (X - birdX)/SCALE 	),
	.colour_data 	( bird_colour[2] 		)
);



///////////////////////////////////////////////////////////////////////////////////
/////										TITLE														/////
///////////////////////////////////////////////////////////////////////////////////

wire title_gfx = (X - TITLE_X-1 < TITLE_SIZE_X) && (Y - TITLE_Y < TITLE_SIZE_Y) && (title_colour != IGNORE_COLOUR);
wire [23:0] title_colour;
title_rom title
(
	.clk				( VGA_clk 					),
	.row				( (Y - TITLE_Y)/SCALE	),
	.col				( (X - TITLE_X)/SCALE 	),
	.colour_data	( title_colour 			)
);


///////////////////////////////////////////////////////////////////////////////////
/////										PAUSE														/////
///////////////////////////////////////////////////////////////////////////////////

wire pause_gfx = (X - PAUSE_X-1 < PAUSE_SIZE_X) && (Y - PAUSE_Y < PAUSE_SIZE_Y) && (pause_colour != IGNORE_COLOUR);
wire [23:0] pause_colour;
pause_rom pause_icon
(
	.clk				( VGA_clk 					),
	.row				( (Y - PAUSE_Y)/SCALE 	),
	.col				( (X - PAUSE_X)/SCALE 	),
	.colour_data	( pause_colour 			)
);


///////////////////////////////////////////////////////////////////////////////////
/////										BACKGROUND												/////
///////////////////////////////////////////////////////////////////////////////////

reg [15:0] X_ofs_bg = 0, X_ofs_fl = 0;
always @(posedge GAME_clk) begin
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

wire bg0_gfx = (Y <= BG_Y);
assign bg_colour [0] = 24'h70C5CE;

wire bg1_gfx = (X < BG_SIZE_X) && (Y - (BG_Y) < BG_SIZE_Y) && (bg_colour[1] != IGNORE_COLOUR);
background_rom bg
(
	.clk				( VGA_clk 											),
	.row				( (Y-BG_Y)/SCALE 									),
	.col				( ((X + X_ofs_bg)%DISPLAY_SIZE_X)/SCALE 	),
	.colour_data 	( bg_colour[1] 									)
);

wire bg2_gfx = (X < FLOOR_SIZE_X) && (Y - (FLOOR_Y) < FLOOR_SIZE_Y) && (bg_colour[1] != IGNORE_COLOUR);
floor_rom floor
(
	.clk				( VGA_clk 											),
	.row				( (Y-FLOOR_Y)/SCALE 								),
	.col				( ((X + X_ofs_fl)%DISPLAY_SIZE_X)/SCALE 	),
	.colour_data 	( bg_colour[2] 									)
);

wire bg3_gfx = (Y > FLOOR_Y + FLOOR_SIZE_Y -1);
assign bg_colour [3] = 24'hDED895;



///////////////////////////////////////////////////////////////////////////////////
/////										PIPES														/////
///////////////////////////////////////////////////////////////////////////////////
									
reg [3:0] pipe_btm_gfx, pipe_top_gfx;

wire [23:0] pipe_colour;
reg [31:0] pipe_row=0, pipe_col=0;

wire [31:0] pipeX [NUM_PIPES-1:0];
wire [31:0] pipeY [NUM_PIPES-1:0];

assign {pipeX[3], pipeX[2], pipeX[1], pipeX[0]} = {pipeX_4, pipeX_3, pipeX_2, pipeX_1};
assign {pipeY[3], pipeY[2], pipeY[1], pipeY[0]} = {pipeY_4, pipeY_3, pipeY_2, pipeY_1};
 
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

wire game_over_gfx = (X - OVER_X-1 < OVER_SIZE_X) && (Y - OVER_Y < OVER_SIZE_Y) && (over_colour != IGNORE_COLOUR);
wire [23:0] over_colour;
game_over_rom over
(
	.clk				( VGA_clk 				),
	.row				( (Y-OVER_Y)/SCALE 	),
	.col				( (X-OVER_X)/SCALE 	),
	.colour_data 	( over_colour			)
);

wire score_gfx = (X - SCORE_X-1 < SCORE_SIZE_X) && (Y - SCORE_Y < SCORE_SIZE_Y) && (score_colour != IGNORE_COLOUR);
wire [23:0] score_colour;
score_rom scr
(
	.clk				( VGA_clk 				),
	.row				( (Y-SCORE_Y)/SCALE 	),
	.col				( (X-SCORE_X)/SCALE 	),
	.colour_data 	( score_colour			)
);


endmodule
