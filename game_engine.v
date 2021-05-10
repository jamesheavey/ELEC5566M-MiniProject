module game_engine
(	
	(* chip_pin = "AF14" *)
	input clk,
	
	(* chip_pin = "AB12" *)
	input rst,
	
	(* chip_pin = "Y16, W15, AA15, AA14" *)
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

localparam [5:0] head_size = 50;

wire VGA_clk;
clk_divider VGA (clk, VGA_clk);

wire GAME_clk;
clk_divider #(2000000-1) GAME (clk, GAME_clk);

wire [3:0]edge_key;
key_filter filter (clk, ~key, edge_key);

wire [15:0] X, Y;
reg [15:0] snakeX, snakeY;
reg [3:0] direction;

VGA vga_gen
(
	.clk			( VGA_clk ),
	.rst			( rst ),
	.hSync		( hSync ),
	.vSync		( vSync ),
	.vCLK			( vCLK ),
	.BLANK		( BLANK ),
	.SYNC			( SYNC ),
	.hPos			( X ),
	.vPos			( Y )
);


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
		snakeX <= (640 + 10 - head_size) /2;
		snakeY <= (480 + 16 - head_size) /2;
	end else begin
		if (direction == 4'h1) begin
			snakeX <= snakeX - 5;
		end else if (direction == 4'h2) begin
			snakeY <= snakeY - 5;
		end else if (direction == 4'h8) begin
			snakeX <= snakeX + 5;
		end else if (direction == 4'h4) begin
			snakeY <= snakeY + 5;
		end
	end
end


always @(posedge VGA_clk or posedge rst)
begin
	if (rst) begin
		R <= 8'h00;
		G <= 8'h00;
		B <= 8'h00;
	end else begin
		if (BLANK & X >= snakeX & X <= snakeX + head_size & Y >= snakeY & Y <= snakeY + head_size) begin
			R <= 8'h00;
			G <= 8'hFF;
			B <= 8'h00;
		end else begin
			R <= 8'h00;
			G <= 8'h00;
			B <= 8'h00;
		end
	end
end

endmodule
