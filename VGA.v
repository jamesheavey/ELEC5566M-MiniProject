module VGA
(
	input clk,
	
	input rst,
	
	output reg hSync,
	
	output reg vSync,
	
	output vCLK,
	
	output reg display_on,
	
	output SYNC,

	output reg [15:0] hPos, vPos
);

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


assign vCLK = clk;
assign SYNC = 0;


always @(posedge clk or posedge rst)
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

always @(posedge clk or posedge rst)
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

always @(posedge clk or posedge rst)
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

always @(posedge clk or posedge rst)
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

always @(posedge clk or posedge rst)
begin
	if (rst) begin
		de <= 0;
		display_on <= 0;
	end else begin
		if (hPos < hVisible && vPos < vVisible) begin
			de <= 1;
		end else begin
			de <= 0;
		end
		display_on <= de;
	end
end

endmodule
	
	