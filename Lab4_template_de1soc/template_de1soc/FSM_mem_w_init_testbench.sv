module FSM_mem_w_init_testbench ();
	reg clk, start, rst;
	
	wire wr_en, finish;
	wire [7:0] mem_addr, wr_data;
	
	FSM_mem_w_init DUT(.rst(rst), .start(start), .clk(clk), .wr_en(wr_en), .mem_addr(mem_addr), .wr_data(wr_data), .finish(finish));
	
	initial begin
		forever begin
			clk = 1'b0;
			#5;
			clk = 1'b1;
			#5;
		end
	end
	
	initial begin
		rst = 1'b1;
		start = 1'b1;
		#10;
		rst = 1'b0;
		#300;
	end
endmodule 