module main
(	
	(* chip_pin = "AF14" *)
	input clk,
	
	(* chip_pin = "AB12" *)
	input rst,
	
	(* chip_pin = "Y16, W15, AA15, AA14" *)
	input [3:0] key,
	
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
	output [7:0] B
);


localparam [5:0] PLAYER_SIZE = 20;

wire VGA_clk;
clk_divider VGA (clk, VGA_clk);

wire GAME_clk;
clk_divider #(2000000-1) GAME (clk, GAME_clk); // 25 Hz

wire [3:0]edge_key;
key_filter filter (clk, ~key, edge_key);


wire [15:0] X, Y;
vga_gen vga
(
	.clk			( VGA_clk ),
	.rst			( rst ),
	.h_sync		( h_sync ),
	.v_sync		( v_sync ),
	.v_clk		( v_clk ),
	.display_on	( display_on ),
	.sync_n		( sync_n ),
	.h_pos		( X ),
	.v_pos		( Y )
);

wire [3:0] game_state = 4'h1;

reg [15:0] playerX, playerY;
reg [3:0] direction;

always @(posedge clk or posedge rst)
begin
	if (rst) begin
		direction <= 4'h0;
	end else begin
		if (edge_key[3] && direction != 4'h8) begin						// R
			direction <= 4'h1;
		end else if (edge_key[2] && direction != 4'h4) begin			// D
			direction <= 4'h2;
		end else if (edge_key[0] && direction != 4'h1) begin			// L
			direction <= 4'h8;
		end else if (edge_key[1] && direction != 4'h2) begin			// U
			direction <= 4'h4;
		end
	end
end

always @(posedge GAME_clk or posedge rst)
begin
	if (rst) begin
		playerX <= 0;
		playerY <= 0;
	end else begin
		if (direction == 4'h1) begin
			playerX <= playerX - 5;
		end else if (direction == 4'h2) begin
			playerY <= playerY - 5;
		end else if (direction == 4'h8) begin
			playerX <= playerX + 5;
		end else if (direction == 4'h4) begin
			playerY <= playerY + 5;
		end
	end
end


image_renderer #(
	.PLAYER_SIZE	( PLAYER_SIZE )
) disp (
	.VGA_clk			( VGA_clk ),
	.rst				( rst ),
	.display_on		( display_on ),
	.game_state		( game_state ),
	.X					( X ),
	.Y					( Y ),
	.playerX			( playerX ),
	.playerY			( playerY ),
	.RGB				( {R,G,B} )
);

endmodule
