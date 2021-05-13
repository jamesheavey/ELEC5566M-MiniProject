module keyboard_input
(
	input clk, PS2_clk, PS2_data, 
	output reg direction, jump, move, pause=0
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
				code = prevCode;
			else
				code = keyCode[8:1];
		end
		
		prevCode = keyCode[8:1];
		count = 0;
	end
end
	
always@(code)
begin		
	jump <= 0;
	move <= 0;

	if (code == 8'h1C) begin
		direction <= 1;
		move <= 1;
	end else if (code == 8'h23) begin
		direction <= 0;
		move <= 1;
	end else if (code == 8'h29)
		jump <= 1;
	else if (code == 8'h76)
		pause <= ~pause;
		
	lastCode <= code;
end

endmodule
