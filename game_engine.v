module game_engine
(	
	(* chip_pin = "AF14" *)
	input clk,
	
	(* chip_pin = "AB12" *)
	input rst,
	
	input [3:0] key,
	
	(* chip_pin = "B11" *) 
	output hSync,
	
	(* chip_pin = "D11" *) 
	output vSync,
	
	(* chip_pin = "F13, E12, D12, C12, B12, E13, C13, A13" *)
	output reg [7:0] R,
	
	(* chip_pin = "E11, F11, G12, G11, G10, H12, J10, J9" *)	
	output reg [7:0] G,
	
	(* chip_pin = "J14, G15, F15, H14, F14, H13, G13, B13" *)
	output reg [7:0] B,
	
	(* chip_pin = "A11" *)
	output vCLK,
	
	(* chip_pin = "F10" *)
	output BLANK,
	
	(* chip_pin = "C10" *)
	output SYNC
);

wire pixel_clk;
clk_divider div (clk, pixel_clk);

wire [15:0] X, Y;

VGA vga_gen
(
	.clk			( pixel_clk ),
	.rst			( rst ),
	.hSync		( hSync ),
	.vSync		( vSync ),
	.vCLK			( vCLK ),
	.BLANK		( BLANK ),
	.SYNC			( SYNC ),
	.hPos			( X ),
	.vPos			( Y )
);


always @(posedge pixel_clk or posedge rst)
begin
	if (rst) begin
		R <= 8'h00;
		G <= 8'h00;
		B <= 8'h00;
	end else begin
		if (BLANK) begin
			R <= 8'hFF;
			G <= 8'hFF;
			B <= 8'hFF;
		end else begin
			R <= 8'h00;
			G <= 8'h00;
			B <= 8'h00;
		end
	end
end

endmodule
