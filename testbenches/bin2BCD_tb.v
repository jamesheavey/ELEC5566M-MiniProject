
                                                      
`timescale 1 ns/100 ps

module bin2BCD_tb;

reg [9:0] bin;
wire [11:0] BCD;

bin2BCD bin2BCD_dut
(
	.bin		(bin),
	.BCD		(BCD)
);

integer i;

initial begin
   $display("%d ns\tSimulation Started",$time);
	
	bin = 0;
	#10;
	for (i=0; i<1000; i=i+1) begin
		bin = bin+1;
		$display("BINARY= %d. 100ths= %d. 10s= %d. 1s= %d.",
						 bin,BCD[11:8], BCD[7:4], BCD[3:0]);
		#10;
	end

   $display("%d ns\tSimulation Finished",$time); 
end
endmodule
