// fibonacci lfsr
// REF: https://stackoverflow.com/questions/28586384/lsfr-counter-for-random-number

module random_number_gen#(
  parameter POLYNOMIAL = 4'h9,
  parameter N = 4,
  parameter BITS = 2
)(
  input  clk,
  input  rst,

  output [BITS-1:0] random
);
reg [N-1:0] data;
reg [N-1:0] data_next;
reg feedback;

assign random = data[N-1:N-BITS];

always @(*) begin
  data_next = data;
  for (int i=0; i<BITS; i++) begin
    feedback  = ^( POLYNOMIAL & data_next);
    data_next = {data_next[N-2:0], ~feedback} ; 
  end
end

always @(posedge clk or negedge rst)
begin
  if (~rst) 
    data <= 'b0;
  else
    data <= data_next;
end
	 
endmodule
