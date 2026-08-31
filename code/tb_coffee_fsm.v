module tb();
	reg Clock, Reset, N, D;
	wire O, C;
	wire [2:0] S;
	
	coffee_fsm dut(
		.Clock(Clock),
		.Reset(Reset),
		.N(N),
		.D(D),
		.O(O),
		.C(C),
		.S(S)); 
	
	initial begin
		Clock = 0;
		forever #5 Clock = ~Clock;
	end
	
	initial begin
		Reset = 1;
		N = 0; D = 0;
		#10 Reset = 0;
		#10 N = 1; D = 0;
		#10 N = 1; D = 0;
		#10 N = 1; D = 0;
		#10 N = 0; D = 0;
		#25 $finish;
	end
endmodule
