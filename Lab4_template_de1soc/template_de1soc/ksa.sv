module ksa (input CLOCK_50,
    input KEY[3:0],
    input [9:0] SW,
    output LEDR[9:0],
    output HEX0[6:0],
    output HEX1[6:0],
    output HEX2[6:0],
    output HEX3[6:0],
    output HEX4[6:0],
    output HEX5[6:0]);

    wire write_enable;
    wire q;
    wire [7:0] address, write_data;

    FSM_mem_w_init FSM1
    (
        .clk(CLOCK_50),
        .start(1'b1),
        .wr_en(write_enable),
        .mem_addr(address),
        .wr_data(write_data)
    );

    s_memory mem
    (
        .address(address),
        .clock(CLOCK_50),
        .data(write_data),
        .wren(write_enable),
        .q(q)
    );

endmodule 


    