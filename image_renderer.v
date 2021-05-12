module image_renderer #(
	parameter PLAYER_SIZE = 20
)(
	input VGA_clk, rst, display_on,
	input [3:0] game_state,
	input [15:0] X, Y, playerX, playerY,
	output reg [23:0] RGB
);

wire bgX_gfx = (X) < 256;
wire bgY_gfx = (Y) < 256;

wire bg_gfx = bgX_gfx && bgY_gfx;
wire [23:0] colour;
mario_background_rom
(
	.clk	(VGA_clk),
	.row	(Y),
	.col	(X),
	.color_data (colour)
);

wire playerX_gfx = (X - playerX) < PLAYER_SIZE;
wire playerY_gfx = (Y - playerY) < PLAYER_SIZE;
wire player_gfx = playerX_gfx && playerY_gfx;

always @(posedge VGA_clk or posedge rst)
begin
	if (rst) begin
		RGB <= 24'h000000;
	end else begin
		case(game_state)
			4'h0: RGB <= 24'h000000;
				// start screen
				
			4'h1: begin
				if (display_on && player_gfx) begin
					RGB <= 24'h00FF00;
				end else if (display_on && bg_gfx) begin
					RGB <= colour;
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
		