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
	
	(* chip_pin = "V18, V17, W16, V16" *)
	output [3:0] led
);


localparam [6:0] PLAYER_SIZE_X = 37-1, PLAYER_SIZE_Y = 42;

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

wire [15:0] playerX, playerY;

wire direction, move, jump, pause;
keyboard_input kb
(
	.clk			( clk ),
	.rst			( rst ),
	.PS2_clk		( PS2_clk ),
	.PS2_data	( PS2_data ),
	.direction	( direction ),
	.move			( move ),
	.jump			( jump ),
	.pause		( pause )
);

assign led = {grounded, direction, move, jump};

reg grounded;
reg [15:0] groundedY;

always @(posedge clk)
begin
	if (playerY >= 480 - PLAYER_SIZE_Y -1) begin
		grounded <= 1;
		groundedY <= 480 - PLAYER_SIZE_Y;
	end else
		grounded <= 0;
end

character_physics phys
(
	.GAME_clk		( GAME_clk ),
	.rst				( rst ),
	.grounded		( grounded ),
	.groundedY		( groundedY ),
	.direction		( direction ),
	.move				( move ),
	.jump				( jump ),
	.playerX			( playerX ),
	.playerY			( playerY ),
	.player_state	( )
);

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
