module flpmac ( 
	// avalon slave interface
    input  wire clk,
	input  wire reset,	
    input  wire [1:0]  slaveaddress,
	input  wire        slaveread,
	output wire [31:0] slavereaddata,
	input  wire        slavewrite, 
	input  wire [31:0] slavewritedata,
	output wire        slavereaddatavalid,
	output wire        slavewaitrequest
    );

    // floating point multiplier
    wire fpmulclk;
    wire fpmulclk_en;
    wire [31:0] fpmuldataa;
	wire [31:0] fpmuldatab;
	wire [ 7:0] fpmuln;
    wire fpmulreset;
	wire fpmulstart;
	wire fpmuldone;
	wire [31:0] fpmulresult;
	
    // floating point adder
    wire fpaddclk;
    wire fpaddclk_en;
    wire [31:0] fpadddataa;
	wire [31:0] fpadddatab;
	wire [ 7:0] fpaddn;
    wire fpaddreset;
	wire fpaddstart;
	wire fpadddone;
	wire [31:0] fpaddresult;

/* A = first operand
   B = second operand
   C = MAC

   Upon writing B, this unit computes

        C = C + A * B

   A, B, C are read/write from software

*/

  reg   [31:0] Areg, Breg, Creg;
  wire  [31:0] Cregnext;
  reg          Bwritten;
  reg          mulclken;
  reg          addclken;

  always @(posedge clk)
    begin
    Areg <= reset ? 32'h0 : (slavewrite & (slaveaddress == 2'h0)) ? slavewritedata : Areg;
    Breg <= reset ? 32'h0 : (slavewrite & (slaveaddress == 2'h1)) ? slavewritedata : Breg;
    Creg <= reset ? 32'h0 : (slavewrite & (slaveaddress == 2'h2)) ? slavewritedata : Cregnext;
    Bwritten <= reset ? 1'b0 : (slavewrite & (slaveaddress == 2'h1));
    mulclken <= reset ? 1'b0 : 
    		    (slavewrite & (slaveaddress == 2'h1)) ? 1'b1 :
    		    fpmuldone ? 1'b0 : 
    		    mulclken;
    addclken <= reset ? 1'b0 : 
    		    fpmuldone ? 1'b1 :
    		    fpadddone ? 1'b0 : 
    		    addclken;
    end

  assign fpmulclk    = clk;
  assign fpmulclk_en = mulclken;
  assign fpmuldataa  = Areg;
  assign fpmuldatab  = Breg;
  assign fpmuln      = 8'd252;   // code for multiply
  assign fpmulreset  = reset;
  assign fpmulstart  = Bwritten;

  assign fpaddclk    = clk;
  assign fpaddclk_en = addclken;
  assign fpadddataa  = fpmulresult;
  assign fpadddatab  = Creg;  
  assign fpaddn      = 8'd253;   // code for add
  assign fpaddreset  = reset;
  assign fpaddstart  = fpmuldone;

  assign Cregnext    = fpadddone ? fpaddresult : Creg;

  assign slavewaitrequest = 1'h0;
  assign slavereaddatavalid = (slaveread & (slaveaddress == 2'h0)) ||
                              (slaveread & (slaveaddress == 2'h1)) || 
                              (slaveread & (slaveaddress == 2'h2));
  assign slavereaddata      = (slaveread & (slaveaddress == 2'h0)) ? Areg :
                              (slaveread & (slaveaddress == 2'h1)) ? Breg :
                              (slaveread & (slaveaddress == 2'h2)) ? Creg :
                              32'h0;

  fpoint_wrapper fpmul(.clk(fpmulclk),
  	                   .clk_en(fpmulclk_en),
  	                   .dataa(fpmuldataa),
  	                   .datab(fpmuldatab),
  	                   .n(fpmuln),
  	                   .reset(fpmulreset),
  	                   .start(fpmulstart),
  	                   .done(fpmuldone),
  	                   .result(fpmulresult));

  fpoint_wrapper fpadd(.clk(fpaddclk),
  	                   .clk_en(fpaddclk_en),
  	                   .dataa(fpadddataa),
  	                   .datab(fpadddatab),
  	                   .n(fpaddn),
  	                   .reset(fpaddreset),
  	                   .start(fpaddstart),
  	                   .done(fpadddone),
  	                   .result(fpaddresult));



endmodule