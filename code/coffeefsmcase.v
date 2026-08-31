module coffee_fsm (Clock, Reset, N, D, O, C, S);

input Clock, Reset;	// Clock and Reset
input N, D;				// Nickel and Dime sensors (active-high)
output reg O, C; 			// Open and Change (active-high)

output reg [2:0] S; 	// current state
reg [2:0] S_star; 	// next state

parameter [2:0] S0=3'b000, S5=3'b001, S10=3'b010, S15=3'b110, S20=3'b111;


// Flip-flops for state (state memory)
always @(posedge Reset, posedge Clock)
	if (Reset == 1) S <= 3'b000;	// initialization
	else S <= S_star;
	
// Next state logics 
// input: S, N, D
// output: S_star
always@(S,N,D)
begin
  case(S)
    S0:
	   if (N==0 && D==0) S_star = S0;
		else if (N==0 && D==1) S_star = S10;
		else if (N==1 && D==0) S_star = S5;
		else S_star = S0;
	 S5:
	   	if (N==0 && D==0) S_star = S5;
		else if (N==0 && D==1) S_star = S15;
		else if (N==1 && D==0) S_star = S10;
		else S_star = S5;
	 
	 S10:
	 	if (N==0 && D==0) S_star = S10;
		else if (N==0 && D==1) S_star = S20;
		else if (N==1 && D==0) S_star = S15;
		else S_star = S10;
	 
	 S15:
	   if (N==0 && D==0) S_star = S0;
		else S_star = S15;
	 
	 S20:
	   	if (N==0 && D==0) S_star = S0;
		else S_star = S20;

		
	 default:
		S_star = S0;
	 
  endcase
end


// Output logics 
// Moore machine: output is only determined by the current state (S), that is, input is S
always@(S)
begin
	case(S)
	  S0:
	  begin
	    	O = 0;
		 C = 0;
	  end
	  S5:
	  begin
	  	O = 0;
		C = 0;
	  end
	  S10:
	  begin
	  	O = 0;
		C = 0;
	  end
	  S15:
	  begin
	  	O = 1;
		C = 0;
	  end
	  S20:
	  begin
	  	O = 1;
		C = 1;
	  end
	  default:
	  begin
	    O = 0;
	    C = 0;
	  end
	endcase
end

endmodule
