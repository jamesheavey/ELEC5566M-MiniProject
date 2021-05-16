// FIbonacci LFSR

module random_number_gen
(
	input clk, rst,
	output reg signed [4:0] data
);

reg signed [4:0] shift;

always @(*)
begin
  shift[4] = data[4]^data[1];
  shift[3] = data[3]^data[0];
  shift[2] = data[2]^shift[4];
  shift[1] = data[1]^shift[3];
  shift[0] = data[0]^shift[2];
end

always @(posedge clk or posedge rst)
begin
  if(rst)
    data <= 5'h1f;
  else
    data <= shift;
end

endmodule
