module random_number_generator
(
	input clk, user_input,
	output reg signed [5:0] random = 6'b101001
);

always @(posedge clk) begin
	if (user_input) begin
		random[0] = random[0] ^ random[5];
		random[1] = random[3] ^ random[2];
		random[2] = random[2] ^ random[5];
		random[3] = random[0] ^ random[1];
		random[4] = random[5] ^ user_input;
		random[5] = random[4] ^ random[1];
	end
end

endmodule