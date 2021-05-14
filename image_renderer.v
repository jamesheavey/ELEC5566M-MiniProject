module image_renderer #(
	parameter PLAYER_SIZE_X,
	parameter PLAYER_SIZE_Y,
	parameter SCALE
)(
	input VGA_clk, ANI_clk, rst, display_on, player_dir,
	input [3:0] game_state, player_state,
	input [15:0] X, Y, playerX, playerY,
	output reg [23:0] RGB
);

localparam DISPLAY_SIZE_X = 640, DISPLAY_SIZE_Y = 480;
localparam BG_SIZE_X = 140*SCALE, BG_SIZE_Y = 40*SCALE;
localparam BG_Y = 300;
localparam FLOOR_SIZE_X = 140*SCALE, FLOOR_SIZE_Y = 10*SCALE; 
localparam FLOOR_Y = BG_SIZE_Y + BG_Y - 2;

wire [23:0] bg_colour [3:0];

wire bg0_gfx = (Y <= BG_Y);
assign bg_colour [0] = 24'h70C5CE;

wire bg1_gfx = (X < BG_SIZE_X) && (Y - (BG_Y) < BG_SIZE_Y);
background_rom bg
(
	.clk				( VGA_clk ),
	.row				( (Y-BG_Y)/SCALE ),
	.col				( X/SCALE ),
	.colour_data 	( bg_colour[1] )
);

wire bg2_gfx = (X < FLOOR_SIZE_X) && (Y - (FLOOR_Y) < FLOOR_SIZE_Y);
floor_rom floor
(
	.clk				( VGA_clk ),
	.row				( (Y-FLOOR_Y)/SCALE ),
	.col				( X/SCALE ),
	.colour_data 	( bg_colour[2] )
);

wire bg3_gfx = (Y > FLOOR_Y + FLOOR_SIZE_Y -1);
assign bg_colour [3] = 24'hDED895;

wire player_gfx = (X - playerX-1 < PLAYER_SIZE_X) && (Y - playerY < PLAYER_SIZE_Y);
wire [23:0] player_colour;
flap_1_rom bird1
(
	.clk				( VGA_clk ),
	.row				( (Y - playerY)/SCALE ),
	.col				( (X - playerX)/SCALE ),
	.colour_data 	( player_colour )
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
					if 		(bg0_gfx && bg_colour[0] != 24'hFF0096)	RGB <= bg_colour[0];
					else if 	(bg1_gfx && bg_colour[1] != 24'hFF0096)	RGB <= bg_colour[1];
					else if 	(bg2_gfx && bg_colour[2] != 24'hFF0096)	RGB <= bg_colour[2];
					else if 	(bg3_gfx && bg_colour[3] != 24'hFF0096)	RGB <= bg_colour[3];
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
		