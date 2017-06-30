`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:52:51 04/24/2017 
// Design Name: 
// Module Name:    tb_uart 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module tb_uart;

reg clk;
reg rst_n;

wire a2b;
wire b2a;

reg [7:0]     tx_dat;
reg         tx_en;

wire [7:0]     rx_dat_a;
wire [7:0]     rx_dat_b;
wire        rx_rdy_a;
wire        rx_rdy_b;


reg            top_rx;
wire        top_tx;

initial begin
    clk = 0;
    rst_n = 1;
    #100
    rst_n = 0;
    #1000
    rst_n    = 1;
    #3000000;
end

always begin 
    #20 clk = ~clk;
end

initial begin
    #2000
    tx_dat = 8'h5A;
    tx_en = 1'b0;
    @ (posedge clk)
    tx_en = 1'b1;
    @ (posedge clk)
    tx_en = 1'b0;
end

initial begin
    #2000
	top_rx=1'b1;
	#100000
	top_rx=1'b0;
	#8695
	top_rx=1'b1;
	#8690
	top_rx=1'b0;
	#26080
	top_rx=1'b1;
	#17375
	top_rx=1'b0;
	#17385
	top_rx=1'b1;
	#8690
	top_rx=1'b0;
	#17385
	top_rx=1'b1;
	#8685
	top_rx=1'b0;
	#17385
	top_rx=1'b1;
	#17385
	top_rx=1'b0;
	#17385
	top_rx=1'b1;
	#8680
	top_rx=1'b0;
	#8695
	top_rx=1'b1;
	#17385
	top_rx=1'b0;
	#17385
	top_rx=1'b1;
	#17375
	top_rx=1'b0;
	#17385
	top_rx=1'b1;
	#8690
	top_rx=1'b0;
	#26070
	top_rx=1'b1;
	#8690
	top_rx=1'b0;
	#8695
	top_rx=1'b1;
	#17385
	top_rx=1'b0;
	#17385
	top_rx=1'b1;
	#8680
	top_rx=1'b0;
	#8695
	top_rx=1'b1;
	#8690
	top_rx=1'b0;
	#8695
	top_rx=1'b1;
	#8690
	top_rx=1'b0;
	#8695
	top_rx=1'b1;
	#17375
	top_rx=1'b0;
	#17385
	top_rx=1'b1;
	#8695
	top_rx=1'b0;
	#17385
	top_rx=1'b1;
	#17375
	top_rx=1'b0;
	#8695
	top_rx=1'b1;
	#17385
	top_rx=1'b0;
	#17385
	top_rx=1'b1;
	#8690
	top_rx=1'b0;
	#8685
	top_rx=1'b1;
	#26080
	top_rx=1'b0;
	#8695
	top_rx=1'b1;
	#17370
	top_rx=1'b0;
	#17385
	top_rx=1'b1;
	#8695
	top_rx=1'b0;
	#34760
	top_rx=1'b1;
	#26075
	top_rx=1'b0;
	#17385
	top_rx=1'b1;
	#8690
	top_rx=1'b0;
	#8685
	top_rx=1'b1;
	#8690
	top_rx=1'b0;
	#17385
	top_rx=1'b1;
	#26075
	top_rx=1'b0;
	#17375
	top_rx=1'b1;
	#8690
	top_rx=1'b0;
	#43455
	top_rx=1'b1;
	#17380
	top_rx=1'b0;
	#17385
	top_rx=1'b1;
	#8695
	top_rx=1'b0;
	#8690
	top_rx=1'b1;
	#8685
	top_rx=1'b0;
	#8690
	top_rx=1'b1;
	#17385
	top_rx=1'b0;
	#34760
	top_rx=1'b1;
	#8690
	top_rx=1'b0;
	#17390
	top_rx=1'b1;
	#8690
	top_rx=1'b0;
	#8695
	top_rx=1'b1;
	#8680
	top_rx=1'b0;
	#34770
	top_rx=1'b1;

	

end


top u_top(
    .i_clk(clk),
    .i_rst_n(rst_n),
    .uart_tx(top_tx),
    .uart_rx(top_rx)
);


endmodule
