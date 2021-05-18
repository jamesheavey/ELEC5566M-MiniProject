module score_counter
(
	input rst,
	input	[31:0] score_count,
	output [11:0] score_BCD, hiscore_BCD,
	output [41:0] seven_seg
);

reg [31:0] hiscore;

always @(score_count or rst)
begin
	if (rst)
		hiscore = 0;
	else
		hiscore = (score_count > hiscore) ? score_count : hiscore; // load from mem in future
end

genvar i;
generate 
	// generate a HexTo7Seg converter for each available display
	for (i = 0; i < 6; i = i + 1) begin : seven_seg_loop
		hex_to_7seg display (
			.hex			( i < 3 ? score_count[(i*4)+:4] : 0 ),
			.seven_seg	( seven_seg[(i*7)+:7] )
		);
	end 
endgenerate

bin2BCD scr (score_count, score_BCD);
bin2BCD hiscr (hiscore, hiscore_BCD);

endmodule
