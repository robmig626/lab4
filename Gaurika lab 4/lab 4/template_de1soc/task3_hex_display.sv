module task4(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    reg en, rdy;
    wire key_valid;
    wire [7:0] ct_addr, ct_rddata;
    wire [23:0] key;
    reg [6:0] key_0, key_1, key_2, key_3, key_4, key_5;

    enum {INIT, PROCESSING} init_state;

    always_ff @(posedge CLOCK_50 or negedge KEY[3]) begin
    	if(~KEY[3]) begin
    		en <= 1'b1;
    		HEX0 <= 7'b1111_111;
    		HEX1 <= 7'b1111_111;
    		HEX2 <= 7'b1111_111;
    		HEX3 <= 7'b1111_111;
    		HEX4 <= 7'b1111_111;
    		HEX5 <= 7'b1111_111;
    		init_state <= INIT;
    	end else begin
    		case(init_state)
    			INIT: begin
    					HEX0 <= 7'b1111_111;
			    		HEX1 <= 7'b1111_111;
			    		HEX2 <= 7'b1111_111;
			    		HEX3 <= 7'b1111_111;
			    		HEX4 <= 7'b1111_111;
			    		HEX5 <= 7'b1111_111;
    					if(rdy) begin
    						en <= 1'b0;
    						init_state <= PROCESSING;
    					end
    				end
    			PROCESSING: begin
    					if(rdy) begin
    						if(key_valid) begin
    							HEX0 <= key_0;
    							HEX1 <= key_1;
    							HEX2 <= key_2;
    							HEX3 <= key_3;
    							HEX4 <= key_4;
    							HEX5 <= key_5;
    						end else begin
    							HEX0 <= 7'b0_111_111;
    							HEX1 <= 7'b0_111_111;
    							HEX2 <= 7'b0_111_111;
    							HEX3 <= 7'b0_111_111;
    							HEX4 <= 7'b0_111_111;
    							HEX5 <= 7'b0_111_111;
    						end
    					end
    				end
    		endcase // init_state
    	end
    end

    sseg hex_0(key[3:0], key_0);
	sseg hex_1(key[7:4], key_1);
	sseg hex_2(key[11:8], key_2);
	sseg hex_3(key[15:12], key_3);
	sseg hex_4(key[19:16], key_4);
	sseg hex_5(key[23:20], key_5);

    ct_mem ct(.address(ct_addr), .clock(CLOCK_50), .q(ct_rddata));
    crack c(.clk(CLOCK_50), .rst_n(KEY[3]),
            .en(en), .rdy(rdy),
            .key(key), .key_valid(key_valid),
            .ct_addr(ct_addr), .ct_rddata(ct_rddata));

    // your code here

endmodule: task4



//
//	MODULE RE-USED FROM CPEN 211
//

// The sseg module below can be used to display the value of datpath_out on
// the hex LEDS the input is a 4-bit value representing numbers between 0 and
// 15 the output is a 7-bit value that will print a hexadecimal digit.  You
// may want to look at the code in Figure 7.20 and 7.21 in Dally but note this
// code will not work with the DE1-SoC because the order of segments used in
// the book is not the same as on the DE1-SoC (see comments below).

module sseg(in,segs);
  input [3:0] in;
  output reg [6:0] segs;

  // NOTE: The code for sseg below is not complete: You can use your code from
  // Lab4 to fill this in or code from someone else's Lab4.  
  //
  // IMPORTANT:  If you *do* use someone else's Lab4 code for the seven
  // segment display you *need* to state the following three things in
  // a file README.txt that you submit with handin along with this code: 
  //
  //   1.  First and last name of student providing code
  //   2.  Student number of student providing code
  //   3.  Date and time that student provided you their code
  //
  // You must also (obviously!) have the other student's permission to use
  // their code.
  //
  // To do otherwise is considered plagiarism.
  //
  // One bit per segment. On the DE1-SoC a HEX segment is illuminated when
  // the input bit is 0. Bits 6543210 correspond to:
  //
  //    0000
  //   5    1
  //   5    1
  //    6666
  //   4    2
  //   4    2
  //    3333
  //
  // Decimal value | Hexadecimal symbol to render on (one) HEX display
  //             0 | 0
  //             1 | 1
  //             2 | 2
  //             3 | 3
  //             4 | 4
  //             5 | 5
  //             6 | 6
  //             7 | 7
  //             8 | 8
  //             9 | 9
  //            10 | A
  //            11 | b
  //            12 | C
  //            13 | d
  //            14 | E
  //            15 | F
  `define NUMBER_0 7'b1000000
  `define NUMBER_1 7'b1111001
  `define NUMBER_2 7'b0100100
  `define NUMBER_3 7'b0110000
  `define NUMBER_4 7'b0011001
  `define NUMBER_5 7'b0010010
  `define NUMBER_6 7'b0000010
  `define NUMBER_7 7'b1111000
  `define NUMBER_8 7'b0000000
  `define NUMBER_9 7'b0010000
  `define NUMBER_A 7'b0001000
  `define NUMBER_b 7'b0000011
  `define NUMBER_C 7'b1000110
  `define NUMBER_d 7'b0100001
  `define NUMBER_E 7'b0000110
  `define NUMBER_F 7'b0001110
  
  always @(*) begin
    case(in)
      4'b0000: segs = `NUMBER_0;
      4'b0001: segs = `NUMBER_1;
      4'b0010: segs = `NUMBER_2;
      4'b0011: segs = `NUMBER_3;
      4'b0100: segs = `NUMBER_4;
      4'b0101: segs = `NUMBER_5;
      4'b0110: segs = `NUMBER_6;
      4'b0111: segs = `NUMBER_7;
      4'b1000: segs = `NUMBER_8;
      4'b1001: segs = `NUMBER_9;
      4'b1010: segs = `NUMBER_A;
      4'b1011: segs = `NUMBER_b;
      4'b1100: segs = `NUMBER_C;
      4'b1101: segs = `NUMBER_d;
      4'b1110: segs = `NUMBER_E;
      4'b1111: segs = `NUMBER_F;
      default: segs = {7{1'bx}};
    endcase
  end

endmodule