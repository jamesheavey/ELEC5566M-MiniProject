module keyboard_input
(
	input clk, rst, PS2_clk, PS2_data, 
	output reg pause, flap
);
	
reg [7:0] code, nextCode, prevCode;
reg [10:0] keyCode;

reg raw_flap, raw_pause;

integer count = 0;

always@(negedge PS2_clk)
begin
	keyCode[count] = PS2_data;
	count = count + 1;
	code = 0;
	
	if(count == 11) begin
		nextCode = keyCode[8:1];
		
		if (nextCode == 8'hF0)
			code = prevCode;
		
		if (prevCode == 8'hF0)
			code = 0;

		prevCode = keyCode[8:1];
		count = 0;
	end
end

always @(code or rst)
begin
	if (rst) begin
		flap 	= 0;
		pause 	= 0;
	end else begin
		flap 	= 0;
		pause 	= 0;
		if (code == 8'h29)
			flap 	= 1;
		else if (code == 8'h76)
			pause 	= 1;
	end
end

//key_filter p_edgeF (clk, raw_pause, pause);
//key_filter p_edgeP (clk, raw_flap, flap);

endmodule
