module vga_gen
(
	input clk, rst,
	output reg h_sync, v_sync,
	output v_clk, sync_n, 
	output reg display_on,
	output reg [15:0] h_pos, v_pos
);

localparam [15:0]	H_DISPLAY 	= 640;
localparam [7:0]	H_BACK 		= 48;
localparam [7:0]	H_sync_n 	= 96;
localparam [7:0]	H_FRONT 		= 16;

localparam [15:0]	V_DISPLAY 	= 480;
localparam [7:0]	V_BACK 		= 33;
localparam [7:0]	V_sync_n		= 2;
localparam [7:0]	V_FRONT 		= 10;

assign v_clk = clk;
assign sync_n = 0;

always @(posedge clk or posedge rst)
begin
	if (rst) begin
		h_pos <= 0;
	end else begin
		if (h_pos == (H_DISPLAY + H_FRONT + H_sync_n + H_BACK - 1))
			h_pos <= 0;
		else
			h_pos <= h_pos + 1;
	end
end

always @(posedge clk or posedge rst)
begin
	if (rst) begin
		v_pos <= 0;
	end else begin
		if (h_pos == (H_DISPLAY + H_FRONT + H_sync_n + H_BACK - 1)) begin
			if (v_pos == (V_DISPLAY + V_FRONT + V_sync_n + V_BACK - 1))
				v_pos <= 0;
			else
				v_pos <= v_pos + 1;
		end
	end
end

always @(posedge clk or posedge rst)
begin
	if (rst) begin
		h_sync 		<= 0;
		v_sync		<= 0;
		display_on	<= 0;
	end else begin
		h_sync		<= ((h_pos >= H_DISPLAY + H_FRONT) && (h_pos < H_DISPLAY + H_FRONT + H_sync_n)) ? 0:1;
		v_sync		<= ((v_pos >= V_DISPLAY + V_FRONT) && (v_pos < V_DISPLAY + V_FRONT + V_sync_n)) ? 0:1;
		display_on	<= (h_pos < H_DISPLAY && v_pos < V_DISPLAY) ? 1:0;
	end
end

endmodule
	
	