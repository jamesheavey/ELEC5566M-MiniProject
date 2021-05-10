module VGA
(
	(* chip_pin = "AF14" *)
	input clk,
	
	(* chip_pin = "AB12" *)
	input rst,
	
	(* chip_pin = "B11" *) 
	output reg hSync,
	
	(* chip_pin = "D11" *) 
	output reg vSync,
	
	(* chip_pin = "F13, E12, D12, C12, B12, E13, C13, A13" *)
	output reg [7:0] R,
	
	(* chip_pin = "E11, F11, G12, G11, G10, H12, J10, J9" *)	
	output reg [7:0] G,
	
	(* chip_pin = "J14, G15, F15, H14, F14, H13, G13, B13" *)
	output reg [7:0] B,
	
	(* chip_pin = "A11" *)
	output vCLK,
	
	(* chip_pin = "F10" *)
	output reg BLANK,
	
	(* chip_pin = "C10" *)
	output SYNC,

	output reg [15:0] hPos, vPos
);

wire pixel_clk;
clk_divider div (clk, pixel_clk);


localparam [15:0] hVisible = 640;
localparam [7:0] hBackPorch = 48;
localparam [7:0] hSyncPulse = 96;
localparam [7:0] hFrontPorch = 16;

localparam [15:0] vVisible = 480;
localparam [7:0] vBackPorch = 33;
localparam [7:0] vSyncPulse = 2;
localparam [7:0] vFrontPorch = 10;

reg hs = 0;
reg vs = 0;
reg de = 0;


assign vCLK = pixel_clk;
assign SYNC = 0;


always @(posedge pixel_clk or posedge rst)
begin
	if (rst) begin
		hPos <= 0;
	end else begin
		if (hPos == (hVisible + hFrontPorch + hSyncPulse + hBackPorch - 1)) begin
			hPos <= 0;
		end else begin
			hPos <= hPos + 1;
		end
	end
end

always @(posedge pixel_clk or posedge rst)
begin
	if (rst) begin
		vPos <= 0;
	end else begin
		if (hPos == (hVisible + hFrontPorch + hSyncPulse + hBackPorch - 1)) begin
			if (vPos == (vVisible + vFrontPorch + vSyncPulse + vBackPorch - 1)) begin
				vPos <= 0;
			end else begin
				vPos <= vPos + 1;
			end
		end
	end
end

always @(posedge pixel_clk or posedge rst)
begin
	if (rst) begin
		hs <= 0;
		hSync <= 0;
	end else begin
		if ((hPos >= hVisible + hFrontPorch) && (hPos < hVisible + hFrontPorch + hSyncPulse)) begin
			hs <= 0;
		end else begin
			hs <= 1;
		end
		hSync <= hs;
	end
end

always @(posedge pixel_clk or posedge rst)
begin
	if (rst) begin
		vs <= 0;
		vSync <= 0;
	end else begin
		if ((vPos >= vVisible + vFrontPorch) && (vPos < vVisible + vFrontPorch + vSyncPulse)) begin
			vs <= 0;
		end else begin
			vs <= 1;
		end
		vSync <= vs;
	end
end

always @(posedge pixel_clk or posedge rst)
begin
	if (rst) begin
		de <= 0;
		BLANK <= 0;
	end else begin
		if (hPos < hVisible && vPos < vVisible) begin
			de <= 1;
		end else begin
			de <= 0;
		end
		BLANK <= de;
	end
end

always @(posedge pixel_clk or posedge rst)
begin
	if (rst) begin
		R <= 8'h00;
		G <= 8'h00;
		B <= 8'h00;
	end else begin
		if (de) begin
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
	
	