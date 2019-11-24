module cordicci(input  wire  clk,
                input wire 	  clk_en,
                input wire 	  reset,
                input wire [7:0]  n,
                input wire 	  start,
                output reg 	  done,
                input wire [31:0] dataa,
                input wire [31:0] datab,
                output reg [31:0] result);
   
   reg signed [31:0] 		  X, X_next;
   reg signed [31:0] 		  Y, Y_next;
   reg signed [31:0] 		  A, A_next;
   reg signed [31:0] 		  T, T_next;
   reg [4:0] 			  cnt, cnt_next;
   
   always @(posedge clk)
     begin
	X   <= reset ? 32'h0 : (clk_en ? X_next : X);
	Y   <= reset ? 32'h0 : (clk_en ? Y_next : Y);
	A   <= reset ? 32'h0 : (clk_en ? A_next : A);
	T   <= reset ? 32'h0 : (clk_en ? T_next : T);
	cnt <= reset ? 5'h0  : (clk_en ? cnt_next : cnt);
     end
   
   // state machine
   localparam 
     Sidle     = 0,
     SX        = 1,
     SY        = 2,
     Srot0     = 3,
     Srot1     = 4,
     Srot2     = 5;
   
   reg [2:0] state, state_next;
   always @(posedge clk or posedge reset)
     state <= reset ? Sidle : (clk_en ? state_next : state);

   reg [31:0] angle;
   always @(*)
     begin
	angle = 32'd0;
	case (cnt)
	  5'd0:  angle = 32'd210828714;
	  5'd1:  angle = 32'd124459457;
	  5'd2:  angle = 32'd65760959;
	  5'd3:  angle = 32'd33381289;
	  5'd4:  angle = 32'd16755421;
	  5'd5:  angle = 32'd8385878;
	  5'd6:  angle = 32'd4193962;
	  5'd7:  angle = 32'd2097109;
	  5'd8:  angle = 32'd1048570;
	  5'd9:  angle = 32'd524287;
	  5'd10: angle = 32'd262143;
	  5'd11: angle = 32'd131071;
	  5'd12: angle = 32'd65535;
	  5'd13: angle = 32'd32767;
	  5'd14: angle = 32'd16383;
	  5'd15: angle = 32'd8191;
	  5'd16: angle = 32'd4095;
	  5'd17: angle = 32'd2047;
	  5'd18: angle = 32'd1024;
	  5'd19: angle = 32'd511;
	  default: angle = 32'd0;
	endcase
     end
   
   always @(*)
     begin
	done   = 0;
	result = 32'd0;
	cnt_next = cnt;
	X_next   = X;
	Y_next   = Y;
	A_next   = A;
	T_next   = T;
	
	case (state)
	  Sidle: if (start)
	    state_next = (n == 8'd0) ? Srot0 :
			 (n == 8'd1) ? SX :
			 (n == 8'd2) ? SY :
			 Sidle;

	  SX: begin
	     result = X;
	     done   = 1;
	     state_next = Sidle;
	  end
	    
	  SY: begin
	     result = Y;
	     done   = 1;
	     state_next = Sidle;
	  end

	  Srot0: begin
	     cnt_next = 0;
	     X_next   = 32'd163008218;
	     Y_next   = 32'd0;
	     T_next   = dataa;
	     A_next   = 32'd0;
	     state_next = Srot1;
	  end
	    
	  Srot1: begin
	     cnt_next = cnt + 1'd1;
	     Y_next   = (T > A) ? (X >>> cnt) + Y : Y - (X >>> cnt);
	     X_next   = (T > A) ? X - (Y >>> cnt) : X + (Y >>> cnt);
	     A_next   = (T > A) ? A + angle : A - angle;
	     state_next = (cnt == 5'd19) ? Srot2 : Srot1;
	  end
	  
	  Srot2: begin
	     done = 1;
	     state_next = Sidle;	     
	  end

	  default: begin
	     state_next = Sidle;
	  end
	    
	endcase
     end
	
endmodule
