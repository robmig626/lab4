parameter idle = 3'b000;
parameter write_to_mem = 3'b001;
parameter update_address = 3'b100;

module FSM_mem_w_init(rst,start, finish, clk, wr_en, mem_addr, wr_data);
	input clk, start, rst;
	
	output wr_en, finish;
	output [7:0] mem_addr, wr_data;

	reg[7:0] address = 8'h00;
	reg [2:0] state;
	
	assign wr_en = state[0];
	assign finish = state[2];
	
	assign mem_addr = address;
	assign wr_data = address; //this is only for the first part of the code
	
	always_ff@(posedge clk) begin
	
	if (rst) begin state<= idle;end
	else begin state<=state; end
	
		case(state)
			idle: if(start) state<=write_to_mem;
					else state<= idle;

			write_to_mem: state <= update_address;
			
			update_address: begin state <= idle; address<= address+1; end
		endcase
	end
endmodule 