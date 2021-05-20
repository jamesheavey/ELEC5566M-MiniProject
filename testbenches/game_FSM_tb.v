                                                    
`timescale 1 ns/100 ps

module game_FSM_tb;

reg clk, rst, collision, pause, flap;

wire [3:0] game_state;

game_FSM dut (
	.clk			( clk 			),
	.rst			( rst 			),
	.collision	( collision		),	
	.pause		( pause			),
	.flap			( flap			),
	.game_state	( game_state	)
);

localparam RST_CYCLES 	= 2;
localparam WAIT_CYCLES 	= 2;
localparam MAX_CYCLES 	= 50;

// Initialise clk
initial begin
	clk = 0;
end

// Alternate clk every 10ns
always #10 clk = ~clk;

// Variables
integer num_cycles 	= 0;
integer num_errors 	= 0;
integer counter 		= 0;
integer local_rst 	= 1;
integer alternator	= 0;

wire	START_SCREEN, IN_GAME, PAUSE, END_SCREEN;

assign {END_SCREEN, PAUSE, IN_GAME, START_SCREEN} = {game_state[3], game_state[2], game_state[1], game_state[0]};

always begin

	// Start in rst
	if (local_rst) begin
	
		rst = 1;
		repeat(RST_CYCLES) @(posedge clk);
		rst = 0;
		
		local_rst = 0;
		counter 		= 0;
		
		if (IN_GAME || PAUSE || END_SCREEN) begin
			$display("Error FSM not set to START_SCREEN state when rst button pressed. Inputs: collision=%b, pause=%b, flap=%b. Outputs: START_SCREEN=%b, IN_GAME=%b, PAUSE=%b, END_SCREEN=%b.",
						 collision,pause,flap, START_SCREEN, IN_GAME, PAUSE, END_SCREEN);
			num_errors = num_errors + 1;
			
		end
	end
	
	// START_SCREEN STATE
	if (START_SCREEN) begin
	
		collision 	= 1;
		pause			= 1;
		repeat(1) @(negedge clk);
		
		if (!START_SCREEN) begin
			$display("Error START_SCREEN state changed with incorrect inputs. Inputs: collision=%b, pause=%b, flap=%b. Outputs: START_SCREEN=%b, IN_GAME=%b, PAUSE=%b, END_SCREEN=%b.",
						 collision,pause,flap, START_SCREEN, IN_GAME, PAUSE, END_SCREEN);
			num_errors = num_errors + 1;
		end 
		
		flap			= 1;
		repeat(1) @(negedge clk);
		
		if (START_SCREEN) begin
			$display("Error START_SCREEN state not changed with correct input. Inputs: collision=%b, pause=%b, flap=%b. Outputs: START_SCREEN=%b, IN_GAME=%b, PAUSE=%b, END_SCREEN=%b.",
						 collision,pause,flap, START_SCREEN, IN_GAME, PAUSE, END_SCREEN);
			num_errors = num_errors + 1;
			
		end
		
		collision	= 0;
		pause			= 0;
		flap			= 0;
	end
	
	// IN_GAME STATE
	if (IN_GAME) begin
	
		flap			= 1;
		repeat(1) @(negedge clk);
		
		if (!IN_GAME) begin
			$display("Error IN_GAME state changed with incorrect inputs. Inputs: collision=%b, pause=%b, flap=%b. Outputs: START_SCREEN=%b, IN_GAME=%b, PAUSE=%b, END_SCREEN=%b.",
						 collision,pause,flap, START_SCREEN, IN_GAME, PAUSE, END_SCREEN);
			num_errors = num_errors + 1;
		end 
		
		if (alternator) begin
			collision	= 1;
			alternator	= ~alternator;
		end else begin
			pause			= 1;
			alternator	= ~alternator;
		end
		
		repeat(1) @(negedge clk);
		
		if (START_SCREEN) begin
			$display("Error IN_GAME state not changed with correct input. Inputs: collision=%b, pause=%b, flap=%b. Outputs: START_SCREEN=%b, IN_GAME=%b, PAUSE=%b, END_SCREEN=%b.",
						 collision,pause,flap, START_SCREEN, IN_GAME, PAUSE, END_SCREEN);
			num_errors = num_errors + 1;
			
		end
		
		collision	= 0;
		pause			= 0;
		flap			= 0;
	end
	
	// PAUSE STATE
	if (PAUSE) begin
	
		collision 	= 1;
		flap			= 1;
		repeat(1) @(negedge clk);
		
		if (!PAUSE) begin
			$display("Error PAUSE state changed with incorrect inputs. Inputs: collision=%b, pause=%b, flap=%b. Outputs: START_SCREEN=%b, IN_GAME=%b, PAUSE=%b, END_SCREEN=%b.",
						 collision,pause,flap, START_SCREEN, IN_GAME, PAUSE, END_SCREEN);
			num_errors = num_errors + 1;
		end 
		
		pause			= 1;
		repeat(1) @(negedge clk);
		
		if (PAUSE) begin
			$display("Error PAUSE state not changed with correct input. Inputs: collision=%b, pause=%b, flap=%b. Outputs: START_SCREEN=%b, IN_GAME=%b, PAUSE=%b, END_SCREEN=%b.",
						 collision,pause,flap, START_SCREEN, IN_GAME, PAUSE, END_SCREEN);
			num_errors = num_errors + 1;
			
		end
		
		collision	= 0;
		pause			= 0;
		flap			= 0;
	end
	
	// END_SCREEN STATE
	if (END_SCREEN) begin
	
		collision 	= 1;
		flap			= 1;
		repeat(1) @(negedge clk);
		
		if (!END_SCREEN) begin
			$display("Error END_SCREEN state changed with incorrect inputs. Inputs: collision=%b, pause=%b, flap=%b. Outputs: START_SCREEN=%b, IN_GAME=%b, PAUSE=%b, END_SCREEN=%b.",
						 collision,pause,flap, START_SCREEN, IN_GAME, PAUSE, END_SCREEN);
			num_errors = num_errors + 1;
		end 
		
		pause			= 1;
		repeat(1) @(negedge clk);
		
		if (END_SCREEN) begin
			$display("Error END_SCREEN state not changed with correct input. Inputs: collision=%b, pause=%b, flap=%b. Outputs: START_SCREEN=%b, IN_GAME=%b, PAUSE=%b, END_SCREEN=%b.",
						 collision,pause,flap, START_SCREEN, IN_GAME, PAUSE, END_SCREEN);
			num_errors = num_errors + 1;
			
		end
		
		collision	= 0;
		pause			= 0;
		flap			= 0;
	end
	
	if (num_cycles == 63) begin
		local_rst = 1;
	end
	
	num_cycles = num_cycles + 1;
	
	$display("Cycle %d",num_cycles);
		
	if (num_cycles == 2*(MAX_CYCLES)) begin
		
		$display("TOTAL ERRORS = %d",num_errors);
		$stop;
	end
end

endmodule
	
