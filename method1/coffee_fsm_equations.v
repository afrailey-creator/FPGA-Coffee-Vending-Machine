module coffee_fsm (Clock, Reset, N, D, O, C, S);

input Clock, Reset;	// Clock and Reset
input N, D;				// Nickel and Dime sensors (active-high)
output O, C; 			// Open and Change (active-high)

output reg [2:0] S; 			// current state
wire [2:0] S_star; 	// next state

// Flip-flops for state (state memory)
always @(posedge Reset, posedge Clock)
	if (Reset == 1) S <= 3'b000;	// initialization
	else S <= S_star;
	
// Next state logics
// input: S, N, D
// output: S_star
assign S_star[2] = (~S[2] & ~S[1] & S[0] & D) | (~S[2] & S[1] & ~S[0] & (N | D));
assign S_star[1] = ~S[2] & (S[1] | D | (S[0] & N));
assign S_star[0] = (~S[2] & ~S[1] & ~D & (S[0] ^ N)) | (~S[2] & S[1] & D);


// Output logics
// Moore machine: output is only determined by the current state (S), that is, input is S
assign O = S[2];
assign C = S[2] & S[0];

endmodule
