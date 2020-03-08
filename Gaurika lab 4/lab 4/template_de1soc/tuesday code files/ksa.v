
module ksa (input CLOCK_50,
    input KEY[3:0],
    input SW[9:0],
    output LEDR[9:0],
    output HEX0[6:0],
    output HEX1[6:0],
    output HEX2[6:0],
    output HEX3[6:0],
    output HEX4[6:0],
    output HEX5[6:0]);
	 
    logic clk;
    logic reset_n;
    logic [6:0] ssOut;
    logic [3:0] nIn;
	
	 
    assign clk = CLOCK_50;
    assign reset_n = KEY[3];

    SevenSegmentDisplayDecoder mod (.nIn(nIn), .ssOut(ssOut));
	 
	 //s_mem instantiation
	 logic [7:0] address, data, q;
	 logic wren;
	 //e and d mem instantiation
	 logic [7:0] address_m, q_m, address_d, q_d, data_d;
	 logic wren_d;
	 
	 //FSM 1 
	 logic [23:0] secret_key;
	 logic [7:0] address_shuffle, data_shuffle, q_shuffle;
	 logic wren_shuffle;
	 logic FSM_one_in_use;
	 
	 //FSM 2
	 logic [7:0] data_decryption, address_decryption;
	 logic wren_decryption;
	 
	 
	 logic FSM_two_in_use;
	 logic FSM_three_in_use;
	 assign FSM_three_in_use = 1'b0;
	 
	 assign address = FSM_one_in_use ? address_shuffle : (FSM_two_in_use ? address_decryption : (FSM_three_in_use ? address_decryption : address_decryption));
	 assign data = FSM_one_in_use ? data_shuffle : (FSM_two_in_use ? data_decryption : (FSM_three_in_use ? data_decryption : data_decryption));
	 assign wren =  FSM_one_in_use ? wren_shuffle : (FSM_two_in_use ? wren_decryption : (FSM_three_in_use ? 1'b0: 1'b0));

	 s_memory smem(.address(address),.clock(clk),.data(data),.wren(wren),.q(q));
	
	 encrypted_message emem(.address(address_m), .clock(clk), .q(q_m));
	
	 decrypted_message dmem(.address(address_d), .clock(clk), .data(data_d), .wren(wren_d), .q(q_d));	
	 //decrypted_message dmem(.address(8'b0), .clock(clk), .data(q_m), .wren(1'b1), .q(q_d));
	 
	 
	 shuffling_array_modular shuffle(
												.clk(clk),
												.secret_key(24'b00000000_00000010_01001001),
												.FSM_one_in_use(FSM_one_in_use),
												.address(address_shuffle),
												.data(data_shuffle),
												.wren(wren_shuffle),
												.q(q)
												);
		 

		 
		 
	 decryption_FSM gaurika_fucked_it( 	.clk(clk),
							//s memomry ROM/RAM
							.wren(wren_decryption),
							.q(q),
							.data(data_decryption),
							.address(address_decryption),

							//Decrypted memory RAM
							.address_d(address_d),
							.data_d(data_d),
							.wren_d(wren_d),
							
							//Encrypted memory ROM
							.address_m(address_m),
							.q_m(q_m),

							.FSM_one_in_use(FSM_one_in_use),
							.FSM_three_in_use(FSM_three_in_use),
							.FSM_two_in_use(FSM_two_in_use)
						 );
	
endmodule








	 /*
	 reg [7:0] counter = 8'b0;
	 wire wren, done_shuffling_array;
	 reg  start_shuffling_array;
	 
	 always@(posedge clk) begin
		if (counter < 8'b11111111) begin
			counter <= counter + 1'b1;
				wren <= 1'b1; 
				start_shuffling_array <= 1'b0; end
		else begin wren <= 1'b0; 
					  start_shuffling_array <= 1'b1; end
	 end
	 
	 logic [7:0] q;

	 s_memory init_s_memory(.address(counter),.clock(clk),.data(counter),.wren(wren),.q(q));
	 */

	 
	 
	 	 /*shuffling_array inst_shuffle(	.clk(clk),
												.secret_key(24'b00000000_00000010_01001001),
												.done_shuffling_array(done_shuffling_array));
		*/