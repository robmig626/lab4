parameter idle = 3'b000;
parameter write_to_mem = 3'b001;
parameter update_address = 3'b100;

module FSM_mem_w_init(start, clk, wr_en, mem_addr, wr_data);
	input clk, start;
	
	output wr_en;
	output [7:0] mem_addr, wr_data; 

	reg[7:0] address = 8'h00;
	reg[7:0] wr_data = 8'h00;
	reg state [2:0];
	
	assign wr_en = state[0];
	
	assign mem_addr = address;
	assign wr_data = address; //this is only for the first part of the code
	
	always_ff@(posedge clk)
	begin
		case(state)
			idle: if(start) state<=write_to_mem;
					else state<= idle;

			write_to_mem: state <= update_address;
			
			update_address: begin state <= idle; address<= address+1; end
		endcase
	end
endmodule 