module keyboard_input
(
	input clk, rst, PS2_clk, PS2_data, 
	output reg direction, move, pause,
	output jump
);
	
reg [7:0] code, nextCode, prevCode, lastCode;
reg [10:0] keyCode;
integer count = 0;

always@(negedge PS2_clk)
begin
	keyCode[count] = PS2_data;
	count = count + 1;
	
	if(count == 11) begin
	
		nextCode = keyCode[8:1];
		
		if(nextCode != 8'hF0) begin
			if (nextCode == code && prevCode == 8'hF0)
				code = 0;
			else
				code = keyCode[8:1];				
		end
		
		prevCode = keyCode[8:1];
		count = 0;
	end
end

reg [1:0] j = 0;
always @(clk or rst)
begin
	if (rst) begin
		direction <= 0;
		j <= 0;
		move <= 0;
		pause <= 0;
	end else begin
		if (code == 8'h1C) begin
			direction <= 1;
			move <= 1;
			j <= 0;
		end else if (code == 8'h23) begin
			direction <= 0;
			move <= 1;
			j <= 0;
		end else if (code == 8'h1B) begin
			move <= 0;
			j <= 0;
		end else if (code == 8'h29) begin
			j <= j + 1;
		end else if (code == 8'h76)
			pause <= ~pause;
	end
end

assign jump = j == 1 ? 1:0;

endmodule
