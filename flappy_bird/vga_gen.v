/*
 * ELEC5566 MINI-PROJECT:
 * VGA Timing Generator
 * ---------------------------------
 * For: University of Leeds
 * Date: 19/5/2021
 *
 * Description
 * ---------------------------------
 * This module generates the timing and 
 * output signals required for 640x480
 * resolution VGA display. The module
 * operates using a 25MHz clock and 
 * iterates through the display and 
 * synchronous pixels, outputting the
 * current pixel position for use in 
 * the image rendering module.
 *
 */
 

module vga_gen
(
	input clk, rst,
	output reg h_sync, v_sync,
	output v_clk, sync_n, 
	output reg display_on,
	output reg [15:0] h_pos, v_pos
);

// VGA STANDARD TIMING PARAMETERS
// (640x480) REF: http://tinyvga.com/vga-timing/640x480@60Hz
localparam H_DISPLAY 	= 640;
localparam H_BACK 	=  48;
localparam H_sync_n 	=  96;
localparam H_FRONT 	=  16;

localparam V_DISPLAY 	= 480;
localparam V_BACK 	=  33;
localparam V_sync_n	=   2;
localparam V_FRONT 	=  10;

assign v_clk = clk;
assign sync_n = 0;

always @(posedge clk or posedge rst)
begin
	if (rst) begin
		h_pos <= 0;
	end else begin
		// If the horizontal count exceeds the maximum horizontal pixel number,
		// reset to 0, otherwise increment.
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
		// If the horizontal counter has reached the end of a pixel row,
		// increment the vertical counter. If the vertical counter exceeds the
		// Maximum number of rows, reset to 0.
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
		// H sync and V sync outputs are high when not in the visible pixel range
		h_sync		<= ((h_pos >= H_DISPLAY + H_FRONT) && (h_pos < H_DISPLAY + H_FRONT + H_sync_n)) ? 0:1;
		v_sync		<= ((v_pos >= V_DISPLAY + V_FRONT) && (v_pos < V_DISPLAY + V_FRONT + V_sync_n)) ? 0:1;
		
		// display on is high when in the visible range
		display_on	<= (h_pos < H_DISPLAY && v_pos < V_DISPLAY) ? 1:0;
	end
end

endmodule
	
	
