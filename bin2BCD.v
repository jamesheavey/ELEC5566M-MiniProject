module bin2BCD
(
	input [9:0] bin,
	output [11:0] BCD
);

reg [3:0] unit100, unit10, unit1;

integer i, j;
always @(bin)
begin
	{unit100,unit10,unit1} = 0;
	
	for(i=9; i>=0; i=i-1) begin
		if (unit100 >= 5)
			unit100 = unit100 + 3;
			
		if (unit10 >= 5)
			unit10 = unit10 + 3;
			
		if (unit1 >= 5)
			unit1 = unit1 + 3;
			
		unit100 = unit100 << 1;
		unit100[0] = unit10[3];
		
		unit10 = unit10 << 1;
		unit10[0] = unit1[3];
		
		unit1 = unit1 << 1;
		unit1[0] = bin[i];
	end
	
end

assign BCD = {unit100,unit10,unit1};

endmodule
