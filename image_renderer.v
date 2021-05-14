module image_renderer #(
	parameter BIRD_SIZE_X,
	parameter BIRD_SIZE_Y,
	parameter SCALE
)(
	input VGA_clk, GAME_clk, ANI_clk, rst, display_on, flap,
	input [3:0] game_state,
	input [15:0] X, Y, birdX, birdY,
	output reg [23:0] RGB
);

localparam DISPLAY_SIZE_X = 640, DISPLAY_SIZE_Y = 480;
localparam BG_SIZE_X = 214*SCALE, BG_SIZE_Y = 40*SCALE;
localparam BG_Y = 300;
localparam FLOOR_SIZE_X = 214*SCALE, FLOOR_SIZE_Y = 10*SCALE; 
localparam FLOOR_Y = BG_SIZE_Y + BG_Y - 2;

wire [23:0] bg_colour [3:0];

reg [15:0] X_ofs = 0;
always @(posedge GAME_clk)
begin
	if (X_ofs != 640)
		X_ofs <= X_ofs + 1;
	else
		X_ofs <= 0;
end

localparam	FLAP_1 			= 4'b0001,
				FLAP_2			= 4'b0010,
				FLAP_3 			= 4'b0100,
				FLAP_4 			= 4'b1000;
				
reg [3:0] bird_state = FLAP_1;

always @(posedge ANI_clk)
begin
	case (bird_state)
		FLAP_1:
			if (flap)
				bird_state <= FLAP_2;
			else
				bird_state <= FLAP_1;
		
		FLAP_2:
				bird_state <= FLAP_3;
		
		FLAP_3:
				bird_state <= FLAP_4;
		
		FLAP_4:
			bird_state <= FLAP_1;
			
		default:
			bird_state <= FLAP_1;
	endcase
end

///////////////////////////////////////////////////////////////////////////////////

always @(posedge VGA_clk or posedge rst)
begin
	if (rst) begin
		RGB <= 24'h000000;
	end else begin
		case(game_state)
			4'h0: RGB <= 24'h000000;
				// start screen
				
			4'h1: begin
				if (display_on) begin
					if			(bird_state == FLAP_1 && bird_gfx && bird_colour[0] != 24'hFF0096)				RGB <= bird_colour[0];
					else if	(bird_state == (FLAP_2||FLAP_4) && bird_gfx && bird_colour[1] != 24'hFF0096)	RGB <= bird_colour[1];
					else if	(bird_state == FLAP_3 && bird_gfx && bird_colour[2] != 24'hFF0096)				RGB <= bird_colour[2];
		
					else if 	(bg0_gfx && bg_colour[0] != 24'hFF0096)	RGB <= bg_colour[0];
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

///////////////////////////////////////////////////////////////////////////////////

wire bird_gfx = (X - birdX-1 < BIRD_SIZE_X) && (Y - birdY < BIRD_SIZE_Y);
wire [23:0] bird_colour [2:0];
flap_1_rom bird1
(
	.clk				( VGA_clk ),
	.row				( (Y - birdY)/SCALE ),
	.col				( (X - birdX)/SCALE ),
	.colour_data 	( bird_colour[0] )
);

flap_2_rom bird2
(
	.clk				( VGA_clk ),
	.row				( (Y - birdY)/SCALE ),
	.col				( (X - birdX)/SCALE ),
	.colour_data 	( bird_colour[1] )
);

flap_3_rom bird3
(
	.clk				( VGA_clk ),
	.row				( (Y - birdY)/SCALE ),
	.col				( (X - birdX)/SCALE ),
	.colour_data 	( bird_colour[2] )
);


///////////////////////////////////////////////////////////////////////////////////


wire bg0_gfx = (Y <= BG_Y);
assign bg_colour [0] = 24'h70C5CE;

wire bg1_gfx = (X < BG_SIZE_X) && (Y - (BG_Y) < BG_SIZE_Y);
background_rom bg
(
	.clk				( VGA_clk ),
	.row				( (Y-BG_Y)/SCALE ),
	.col				( ((X + X_ofs)%DISPLAY_SIZE_X)/SCALE ),
	.colour_data 	( bg_colour[1] )
);

wire bg2_gfx = (X < FLOOR_SIZE_X) && (Y - (FLOOR_Y) < FLOOR_SIZE_Y);
floor_rom floor
(
	.clk				( VGA_clk ),
	.row				( (Y-FLOOR_Y)/SCALE ),
	.col				( ((X + X_ofs)%DISPLAY_SIZE_X)/SCALE ),
	.colour_data 	( bg_colour[2] )
);

wire bg3_gfx = (Y > FLOOR_Y + FLOOR_SIZE_Y -1);
assign bg_colour [3] = 24'hDED895;
endmodule
		