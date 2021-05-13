module image_renderer #(
	parameter PLAYER_SIZE_X = 37,
	parameter PLAYER_SIZE_Y = 42
)(
	input VGA_clk, rst, display_on, player_dir,
	input [3:0] game_state, player_state,
	input [15:0] X, Y, playerX, playerY,
	output reg [23:0] RGB
);

//wire [23:0] bg_colour [2:0];
//wire bg1_gfx = (X < 265) && (Y - (480-156) > 156);
//bg_1_rom bottom_left
//(
//	.clk	(VGA_clk),
//	.row	(Y-(480-156)),
//	.col	(X-265),
//	.colour_data (bg_colour[0])
//);
//
//wire bg2_gfx = (X - (640-111) > 111) && (Y - (480-146) > 146);
//bg_2_rom bottom_right
//(
//	.clk	(VGA_clk),
//	.row	(Y-(480-146)),
//	.col	(X-(640-111)),
//	.colour_data (bg_colour[1])
//);
//
//wire bg3_gfx = (X - 310 > 138) && (Y - 110 > 19);
//bg_3_rom sky_bar
//(
//	.clk	(VGA_clk),
//	.row	(Y-110),
//	.col	(X-310),
//	.colour_data (bg_colour[2])
//);


wire player_gfx = (X - playerX < PLAYER_SIZE_X) && (Y - playerY < PLAYER_SIZE_Y);
wire [23:0] player_colour;
sonic_stand_rom sonic_stand
(
	.clk	(VGA_clk),
	.row	(Y - playerY),
	.col	( player_dir ? (X - playerX):PLAYER_SIZE_X-(X - playerX) ),
	.colour_data (player_colour)
);

always @(posedge VGA_clk or posedge rst)
begin
	if (rst) begin
		RGB <= 24'h000000;
	end else begin
		case(game_state)
			4'h0: RGB <= 24'h000000;
				// start screen
				
			4'h1: begin
				if (display_on && player_gfx && player_colour != 24'hFF0096) begin
					RGB <= player_colour;
				end else if (display_on) begin
					RGB <= 24'h2222EE;
//					if 		(bg1_gfx && bg_colour[0] != 24'hFF0096)	RGB <= bg_colour[0];
//					else if 	(bg2_gfx && bg_colour[1] != 24'hFF0096)	RGB <= bg_colour[1];
//					else if 	(bg3_gfx && bg_colour[2] != 24'hFF0096)	RGB <= bg_colour[2];
//					else																RGB <= 24'h2222EE;
				end else begin
					RGB <= 24'h000000;
				end end
				
			4'h2: RGB <= 24'h000000;
				// pause
				
			4'h3: RGB <= 24'h000000;
				// WIN
				
			4'h4: RGB <= 24'h000000;
				// LOSE
			
			default: RGB <= 24'h000000;
		endcase
	end
end

endmodule
		