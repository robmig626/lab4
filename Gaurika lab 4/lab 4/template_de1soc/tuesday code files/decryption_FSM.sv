/*
//compute one byte per character in the encrypted message. You will build this in Task 2
i = 0, j=0
for k = 0 to message_length-1 { // message_length is 32 in our implementation
    i = i+1
    j = j+s[i]
    swap values of s[i] and s[j]
    f = s[ (s[i]+s[j]) ]
    decrypted_output[k] = f xor encrypted_input[k] // 8 bit wide XOR function
}
*/

module decryption_FSM(  input logic clk,
								//s memomry ROM/RAM
                        output logic wren,
                        input  logic [7:0] q,
                        output logic [7:0] data,
                        output logic [7:0] address,

                        //Decrypted memory RAM
                        output logic [7:0] address_d,
                        output logic [7:0] data_d,
                        output logic wren_d,
                        
                        //Encrypted memory ROM
                        output logic [7:0] address_m,
                        input logic [7:0] q_m,

                        input logic FSM_one_in_use,
                        input logic FSM_three_in_use,
                        output logic FSM_two_in_use
                      );

reg start_decrypting;
reg [7:0] i, j, k;
reg [7:0] readdata_si, readdata_sj, readdata_enc, f, sum, decrypted_output;

enum {check_fsm, idle, compute_i, compute_j, compute_si_plus_sj, 
    read_si, read_sj, read_si_plus_sj, read_encrypted, 
    write_si, write_sj, write_decr, turn_off_write_s, turn_off_write_d,
    delay_one, delay_one_one,
    delay_two, delay_two_two,
    delay_three, delay_three_three,
    delay_enc, delay_enc_enc,
    state_xor, increment_k, delay_write_si} state;
	
	 
always_ff@(posedge clk) begin

	case(state)		
		 check_fsm: 			begin 
												if(FSM_one_in_use != 1'b1 /* && FSM_three_in_use == 1'b0*/) 
													begin
													FSM_two_in_use <= 1'b1;
													start_decrypting <= 1'b1; 
													state <= idle; 
													end
												else 
													begin 
													FSM_two_in_use <= 1'b0;
													state <= check_fsm;
													start_decrypting <= 1'b0; 
													end 
													
													wren = 1'b0;
													wren_d = 1'b0;
									end
		 
		 
		 idle: 					begin 	
												if(start_decrypting) 
														begin
														 i <= 8'b0;
														 j <= 8'b0;
														 k <= 8'b0;
														 start_decrypting <= 1'b0;
														 state <= compute_i; 
														end
												else 	begin 
														 state <= idle; 
														end
									end

		 compute_i:       	begin  	i <= i + 1'b1; 
												state <= read_si; end
				
		 read_si: 				begin 													 
												wren = 1'b0; //write is off, so read is on
												address <= i;
												state <= delay_one; end
											
		 delay_one:				begin   	state <= delay_one_one; end
		
		 delay_one_one:		begin   	readdata_si <= q;
												state <= compute_j; end
		
		 compute_j:				begin   	j <= j + readdata_si; //j = j+s[i]
												state <= read_sj; end
		
		 read_sj: 				begin   	address <= j;
												state <= delay_two; end
										
		 delay_two: 			begin   	state <= delay_two_two; end

		 delay_two_two: 		begin   	readdata_sj <= q;
												state <= write_si; end
		 
		 //swapping s[i] and s[j]

		 write_si: 				begin		/*//testing code
														 address_d <= 8'b00000011;
														 data_d <= readdata_sj;
														 wren_d <= 1'b1;*/
		 
												wren <= 1'b1; //turning write enable on
												address <= i;
												data <= 8'b111;//readdata_sj;
												//state <= write_sj; 
												state <= delay_write_si; end
		
		 delay_write_si: 		begin 	state <= write_sj; end
		
		 write_sj: 				begin  	address <= j;
												data <= 8'b0; //readdata_si;
												state <= turn_off_write_s; end
		
		 
		
		 turn_off_write_s:	begin   		/*	//testing code
														address_d <= 8'b00000001;
														 data_d <= 8'b11;
														 wren_d <= 1'b1; */
												wren = 1'b0;
												state <= compute_si_plus_sj; end

		 compute_si_plus_sj: begin    sum <= readdata_si + readdata_sj; //sum = s[i]+s[j]
												state <= read_si_plus_sj; end

		 read_si_plus_sj:    begin   	address <= sum; //f = s[sum]
												state <= delay_three; end
		 
		 delay_three:        begin    state <= delay_three_three; end

		 delay_three_three:  begin    f <= q; //f = s[ (s[i]+s[j]) ]
											   state <= read_encrypted; end
		 
		 read_encrypted:     begin    address_m <= k;
											   state <= delay_enc; 

												end  

		 delay_enc:          begin    state <= delay_enc_enc; end

		 delay_enc_enc:      begin    readdata_enc <= q_m; // readdata_enc = encrypted_input[k]
											   state <= state_xor; 
												end

		 state_xor:          begin    decrypted_output <= f ^ readdata_enc; //f xor encrypted_input[k]
											   //decrypted_output <= 8'b0101 ^ 8'b0000; 
												state <= write_decr; 
												end 

		 write_decr:         begin   
												wren_d <= 1'b1;
											   address_d <= k;
											   data_d <= decrypted_output;
											   state <= turn_off_write_d; end

		 turn_off_write_d:   begin    //wren_d <= 1'b0;
												state <= increment_k;  
												end

		 increment_k: 			begin    if (k < 5'b11111) //i < 31 where 31 is message_length-1
														begin 
															k <= k + 1'b1;
															state <= compute_i; 
														end
												else 	begin 
															state <= idle; 
															FSM_two_in_use <= 1'b0;
														end
									end 

		default state <= check_fsm; 
		endcase
	   end

endmodule
