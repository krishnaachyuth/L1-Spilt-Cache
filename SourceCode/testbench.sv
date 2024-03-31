/**********************************************************************/
/*              L1 SPILT CACHE                                        */										
/* Description: This system verilog file designs the test bench for   */
/*              passing the arguments to DUT(instruction & Data Cache)*/
/*              Trace.txt contains the instructions.                  */
/* Authors : Achyuth Krishna Chepuri                                  */
/* 			                                                       */
/**********************************************************************/

module top();

parameter N = 32;

logic clock=0;
logic reset;
logic fileisopen;
int file;
int tracedata;
logic [3:0]n;
logic [N-1:0]addressbits;
string line;

always #5 clock = ~clock;

InstructionCache #(.MODE(0)) instrcache (clock, reset,addressbits,n);
DataCache #(.MODE(0)) datacache(clock,reset,addressbits,n);

initial begin 
 file = $fopen("Trace.txt","r");
      while (!$feof(file)) 
	  begin	
       @(posedge clock) tracedata = $fscanf(file,"%d %h",n,addressbits);
      end 
	  $fclose(file);
	  $stop;
end 

endmodule