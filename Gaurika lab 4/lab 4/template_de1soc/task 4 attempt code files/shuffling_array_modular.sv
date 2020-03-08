
module shuffling_array_modular(
											input logic reset,

											input logic clk,

											output logic [7:0] address,
											output logic [7:0] data,
											output logic wren,
											input logic [7:0] q,

											//Decrypted memory RAM
											output logic [7:0] address_d,
											output logic [7:0] data_d,
											output logic wren_d,
											
											//Encrypted memory ROM
											output logic [7:0] address_m,
											input logic [7:0] q_m
										);

parameter [7:0] keylength = 8'b00000011;

enum {FSM3_setting_keys, FSM3_check_validity, FSM3_do_nothing,
		
		initialize_array, idle, read_si, delay_one, delay_one_one, compute_j, read_sj, 
		delay_two, delay_two_two, write_si, write_sj, turn_off_write, increment_i,

		FSM2_check_fsm, FSM2_idle, FSM2_compute_i, FSM2_read_si, FSM2_delay_one, FSM2_delay_one_one, FSM2_compute_j, 
		FSM2_read_sj, FSM2_delay_two, FSM2_delay_two_two, FSM2_write_si, FSM2_delay_write_si, FSM2_write_sj, 
		FSM2_turn_off_write_s, FSM2_read_encrypted, FSM2_delay_enc, FSM2_delay_enc_enc,
		FSM2_compute_si_plus_sj, FSM2_read_si_plus_sj, FSM2_delay_three, FSM2_delay_three_three, 
		FSM2_state_xor, FSM2_write_decr, FSM2_turn_off_write_d,
		FSM2_increment_k

		} state;


reg start_shuffling_array;
reg [7:0] which_key, i, j, readdata_si, readdata_sj;
reg [8:0] counter = 9'b0;
wire [7:0] mod_temp;

//FSM2_
reg FSM2_start_decrypting;
reg [7:0] FSM2_i, FSM2_j, FSM2_k;
reg [7:0] FSM2_readdata_si, FSM2_readdata_sj, FSM2_readdata_enc, FSM2_f, FSM2_sum, FSM2_decrypted_output;

	 logic FSM_two_in_use;
	 logic FSM_one_in_use;
	 
//FSM3
reg [23:0] secret_key = 24'b00000000_00000010_10101010;


assign mod_temp = (i % keylength);

always_ff@(posedge clk) begin
 case(mod_temp)
	8'b00000000: which_key <= secret_key[23:16];
	8'b00000001: which_key <= secret_key[15:8];
	8'b00000010: which_key <= secret_key[7:0];
	default which_key <= secret_key[7:0];
 endcase
end

	 
always_ff@(posedge clk) begin

	if (reset) begin
	counter <= 9'b0;
	i <= 1'b0;
	j <= 1'b0;
	readdata_si <= 8'b0;
	readdata_sj <= 8'b0;
	FSM2_i <= 8'b0;
	FSM2_j <= 8'b0;
	FSM2_k <= 8'b0;
   FSM2_readdata_si <= 8'b0;
	FSM2_readdata_sj <= 8'b0;
	FSM2_readdata_enc <= 8'b0;
	FSM2_f <= 8'b0;
	FSM2_sum <= 8'b0;
	FSM2_decrypted_output <= 8'b0;
	secret_key <= 24'b1;
	
	state <= initialize_array; end
	
	else begin 
	case(state)
	
	initialize_array: begin 		FSM_one_in_use = 1'b1;
											if (counter <= 9'b11111111) begin
											address <= counter;
											data <= counter;
											counter <= counter + 1'b1;
											wren <= 1'b1; 
											start_shuffling_array <= 1'b0;
											state <= initialize_array; end
											
							else begin 	wren <= 1'b0; 
											start_shuffling_array <= 1'b1; 
											state <= idle;  end 
							end

	
	idle: 				begin if(start_shuffling_array) begin
										counter <= 9'b0;
										i <= 8'b0;
										j <= 8'b0;
										start_shuffling_array <= 1'b0;
										state <= read_si; end
									else state <= idle; end

									
	read_si: 			begin wren = 1'b0; //write is off, so read is on
									address <= i;
									state <= delay_one; end
									
	delay_one:			state <= delay_one_one;
	
	delay_one_one:		begin readdata_si <= q;
									state <= compute_j; end
	
	compute_j:			begin j <= (j + readdata_si + which_key ); //j = (j + s[i] + secret_key[i % keylength] )
									state <= read_sj; end
	
	read_sj: 			begin address <= j;
									state <= delay_two; end
									
	delay_two: 			state <= delay_two_two;

	delay_two_two: 	begin readdata_sj <= q;
									state <= write_si; end
	 
	write_si: 			begin	wren <= 1'b1; //turning write enable on
									address <= i;
									data <= readdata_sj;
									state <= write_sj; end
	
	write_sj: 			begin address <= j;
									data <= readdata_si;
									state <= turn_off_write; end
	
	turn_off_write: 	begin wren = 1'b0;
									state <= increment_i; end
									
	increment_i: 		begin if (i < 8'b11111111) begin //counter < 255
											i <= i + 1'b1;
											state <= read_si; end
									else 	begin
											FSM_one_in_use = 1'b0;
											state <= FSM2_check_fsm; end
							end
							
							
							
							
							
	FSM2_check_fsm: 			begin 
												if(FSM_one_in_use != 1'b1) 
													begin
													FSM_two_in_use <= 1'b1;
													FSM2_start_decrypting <= 1'b1; 
													state <= FSM2_idle; 
													end
												else 
													begin 
													FSM_two_in_use <= 1'b0;
													state <= FSM2_check_fsm;
													FSM2_start_decrypting <= 1'b0; 
													end 
													
													wren = 1'b0;
													wren_d = 1'b0;
									end
		 
		 
		 FSM2_idle: 			begin 	
												if(FSM2_start_decrypting) 
														begin
														 FSM2_i <= 8'b0;
														 FSM2_j <= 8'b0;
														 FSM2_k <= 8'b0;
														 FSM2_start_decrypting <= 1'b0;
														 state <= FSM2_compute_i; 
														end
												else 	begin 
														 state <= FSM2_idle; 
														end
														
														wren = 1'b0;
														wren_d = 1'b0;
									end

									
									
									
		 FSM2_compute_i:       	begin  FSM2_i <= FSM2_i + 1'b1; 
												 state <= FSM2_read_si;
										end
				
		 FSM2_read_si: 			begin 													 
												wren = 1'b0; //write is off, so read is on
												address <= FSM2_i;
												state <= FSM2_delay_one; 
										end
											
		 FSM2_delay_one:			begin state <= FSM2_delay_one_one; end
		
		 FSM2_delay_one_one:		begin   	
												FSM2_readdata_si <= q;
												state <= FSM2_compute_j; 
										end
		
		 FSM2_compute_j:			begin
												FSM2_j <= FSM2_j + FSM2_readdata_si; //j = j+s[i]
												state <= FSM2_read_sj; 
										end
		
		 FSM2_read_sj: 			begin   
												address <= FSM2_j;
												state <= FSM2_delay_two; 
										end
										
		 FSM2_delay_two: 			begin   state <= FSM2_delay_two_two; end

		 FSM2_delay_two_two: 	begin 
												FSM2_readdata_sj <= q;
												state <= FSM2_write_si; 
										end
		 
		 //swapping s[i] and s[j]

		 FSM2_write_si: 				begin
												wren <= 1'b1; //turning write enable on
												address <= FSM2_i;
												data <= FSM2_readdata_sj;
												state <= FSM2_delay_write_si; 
											end
		
		 FSM2_delay_write_si: 		begin state <= FSM2_write_sj; end
		
		 FSM2_write_sj: 				begin  	
												address <= FSM2_j;
												data <= FSM2_readdata_si;
												state <= FSM2_turn_off_write_s; 
											end
		
		 FSM2_turn_off_write_s:		begin
												wren = 1'b0;
												state <= FSM2_compute_si_plus_sj; 
											end

		 FSM2_compute_si_plus_sj: begin   
												FSM2_sum <= FSM2_readdata_si + FSM2_readdata_sj; //sum = s[i]+s[j]
												state <= FSM2_read_si_plus_sj;
										  end

		 FSM2_read_si_plus_sj:    begin   
												address <= FSM2_sum; //f = s[sum]
												state <= FSM2_delay_three; 
										  end
		 
		 FSM2_delay_three:        begin    state <= FSM2_delay_three_three; end

		 FSM2_delay_three_three:  begin    
												FSM2_f <= q; //f = s[ (s[i]+s[j]) ]
												state <= FSM2_read_encrypted; 
										  end
		 
		 FSM2_read_encrypted:     begin   
												address_m <= FSM2_k;
											   state <= FSM2_delay_enc; 
										  end  

		 FSM2_delay_enc:          begin state <= FSM2_delay_enc_enc; end

		 FSM2_delay_enc_enc:      begin    
												FSM2_readdata_enc <= q_m; // readdata_enc = encrypted_input[k]
											   state <= FSM2_state_xor; 
												end

		 FSM2_state_xor:          begin    
												FSM2_decrypted_output <= FSM2_f ^ FSM2_readdata_enc; //f xor encrypted_input[k]
												//state <= FSM3_check_validity; 
												state <= FSM2_write_decr;
										  end 
										  

							
							
/*
					
										  
		FSM3_check_validity:		begin
												if( ((FSM2_decrypted_output >= 8'd97) && (FSM2_decrypted_output <= 8'd122)) || (FSM2_decrypted_output == 8'd32) )
												begin
														state <= FSM2_write_decr;
												end
												
												else begin
														state <= FSM3_setting_keys; 
													  end
										end
			
		FSM3_setting_keys: 		begin 
													if(secret_key < 24'b001111111111111111111111)
													begin 
														secret_key <= secret_key + 1'b1;
														state <= initialize_array;
													end
												 else state <= FSM3_do_nothing;
										end
	
		FSM3_do_nothing: state <= FSM3_do_nothing;
	
		
										  
	*/						  
										  
					
										  
										  

		 FSM2_write_decr:         begin   
												wren_d <= 1'b1;
											   address_d <= FSM2_k;
											   data_d <= FSM2_decrypted_output;
											   state <= FSM2_turn_off_write_d; 
										  end

		 FSM2_turn_off_write_d:   begin 
												wren_d <= 1'b0;
												state <= FSM2_increment_k;  
										  end

		 FSM2_increment_k: 			begin    if (FSM2_k < 5'b11111) //i < 31 where 31 is message_length-1
														begin 
															FSM2_k <= FSM2_k + 1'b1;
															state <= FSM2_compute_i; 
														end
												else 	begin 
															//state <= FSM3_setting_keys;
															state <= FSM2_idle; 
															FSM_two_in_use <= 1'b0;
														end
											end 

							
	default state <= initialize_array;
	endcase
	end
	
end

endmodule
