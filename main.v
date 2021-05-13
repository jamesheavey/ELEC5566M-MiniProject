module main
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
	
	(* chip_pin = "V17, W16, V16" *)
	output [2:0] led
);


localparam [6:0] PLAYER_SIZE_X = 37, PLAYER_SIZE_Y = 42;

wire VGA_clk;
clk_divider VGA (clk, VGA_clk);

wire GAME_clk;
clk_divider #(2000000-1) GAME (clk, GAME_clk); // 25 Hz


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

wire direction, move, jump, pause;
keyboard_input kb
(
	.PS2_clk		( PS2_clk ),
	.PS2_data	( PS2_data ),
	.direction	( direction ),
	.move			( move ),
	.jump			( jump ),
	.pause		( pause )
);

assign led = {direction, move, jump};

always @(posedge GAME_clk or posedge rst)
begin
	if (rst) begin
		playerX <= 0;
		playerY <= 480 - 42;
	end else begin
		if (direction && move) begin
			playerX <= playerX + 5;
		end else if (move) begin
			playerX <= playerX - 5;
		end
	end
end


image_renderer #(
	.PLAYER_SIZE_X	( PLAYER_SIZE_X ),
	.PLAYER_SIZE_Y	( PLAYER_SIZE_Y )
) disp (
	.VGA_clk			( VGA_clk ),
	.rst				( rst ),
	.player_dir		( direction ),
	.display_on		( display_on ),
	.game_state		( game_state ),
	.player_state	( ),
	.X					( X ),
	.Y					( Y ),
	.playerX			( playerX ),
	.playerY			( playerY ),
	.RGB				( {R,G,B} )
);

endmodule
