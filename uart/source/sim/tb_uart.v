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
	#0
	top_rx=1'b1;
	#100000
	top_rx=1'b0;
	#8680
	top_rx=1'b1;
	#8690
	top_rx=1'b0;
	#26050
	top_rx=1'b1;
	#17360
	top_rx=1'b0;
	#17370
	top_rx=1'b1;
	#8670
	top_rx=1'b0;
	#17380
	top_rx=1'b1;
	#8670
	top_rx=1'b0;
	#17370
	top_rx=1'b1;
	#17360
	top_rx=1'b0;
	#17370
	top_rx=1'b1;
	#8670
	top_rx=1'b0;
	#8700
	top_rx=1'b1;
	#17370
	top_rx=1'b0;
	#17370
	top_rx=1'b1;
	#17340
	top_rx=1'b0;
	#17380
	top_rx=1'b1;
	#8690
	top_rx=1'b0;
	#26040
	top_rx=1'b1;
	#8670
	top_rx=1'b0;
	#8700
	top_rx=1'b1;
	#17370
	top_rx=1'b0;
	#17370
	top_rx=1'b1;
	#8670
	top_rx=1'b0;
	#8680
	top_rx=1'b1;
	#8690
	top_rx=1'b0;
	#8670
	top_rx=1'b1;
	#8700
	top_rx=1'b0;
	#8670
	top_rx=1'b1;
	#17370
	top_rx=1'b0;
	#17370
	top_rx=1'b1;
	#8670
	top_rx=1'b0;
	#17370
	top_rx=1'b1;
	#17370
	top_rx=1'b0;
	#8670
	top_rx=1'b1;
	#17370
	top_rx=1'b0;
	#17370
	top_rx=1'b1;
	#8690
	top_rx=1'b0;
	#8680
	top_rx=1'b1;
	#26040
	top_rx=1'b0;
	#8700
	top_rx=1'b1;
	#17360
	top_rx=1'b0;
	#17350
	top_rx=1'b1;
	#8690
	top_rx=1'b0;
	#34720
	top_rx=1'b1;
	#26060
	top_rx=1'b0;
	#17370
	top_rx=1'b1;
	#8670
	top_rx=1'b0;
	#8680
	top_rx=1'b1;
	#8690
	top_rx=1'b0;
	#17370
	top_rx=1'b1;
	#26040
	top_rx=1'b0;
	#17370
	top_rx=1'b1;
	#8670
	top_rx=1'b0;
	#43420
	top_rx=1'b1;
	#17360
	top_rx=1'b0;
	#17370
	top_rx=1'b1;
	#8690
	top_rx=1'b0;
	#8680
	top_rx=1'b1;
	#8670
	top_rx=1'b0;
	#8700
	top_rx=1'b1;
	#17370
	top_rx=1'b0;
	#34710
	top_rx=1'b1;
	#8690
	top_rx=1'b0;
	#17380
	top_rx=1'b1;
	#8670
	top_rx=1'b0;
	#8690
	top_rx=1'b1;
	#8670
	top_rx=1'b0;
	#34750
	top_rx=1'b1;
	#957185140
	top_rx=1'b0;
	#8700
	top_rx=1'b1;
	#8670
	top_rx=1'b0;
	#26050
	top_rx=1'b1;
	#17360
	top_rx=1'b0;
	#17370
	top_rx=1'b1;
	#8670
	top_rx=1'b0;
	#17380
	top_rx=1'b1;
	#8690
	top_rx=1'b0;
	#17370
	top_rx=1'b1;
	#17340
	top_rx=1'b0;
	#17380
	top_rx=1'b1;
	#8690
	top_rx=1'b0;
	#8670
	top_rx=1'b1;
	#17370
	top_rx=1'b0;
	#17370
	top_rx=1'b1;
	#17370
	top_rx=1'b0;
	#17370
	top_rx=1'b1;
	#8670
	top_rx=1'b0;
	#26040
	top_rx=1'b1;
	#8690
	top_rx=1'b0;
	#8680
	top_rx=1'b1;
	#17370
	top_rx=1'b0;
	#17370
	top_rx=1'b1;
	#8670
	top_rx=1'b0;
	#8700
	top_rx=1'b1;
	#8670
	top_rx=1'b0;
	#8700
	top_rx=1'b1;
	#8670
	top_rx=1'b0;
	#8680
	top_rx=1'b1;
	#17360
	top_rx=1'b0;
	#17370
	top_rx=1'b1;
	#8680
	top_rx=1'b0;
	#17370
	top_rx=1'b1;
	#17360
	top_rx=1'b0;
	#8700
	top_rx=1'b1;
	#17350
	top_rx=1'b0;
	#17370
	top_rx=1'b1;
	#8690
	top_rx=1'b0;
	#8680
	top_rx=1'b1;
	#26040
	top_rx=1'b0;
	#8700
	top_rx=1'b1;
	#17360
	top_rx=1'b0;
	#17380
	top_rx=1'b1;
	#8670
	top_rx=1'b0;
	#34740
	top_rx=1'b1;
	#26040
	top_rx=1'b0;
	#17370
	top_rx=1'b1;
	#8670
	top_rx=1'b0;
	#8700
	top_rx=1'b1;
	#8670
	top_rx=1'b0;
	#17380
	top_rx=1'b1;
	#26040
	top_rx=1'b0;
	#17370
	top_rx=1'b1;
	#8690
	top_rx=1'b0;
	#43420
	top_rx=1'b1;
	#17360
	top_rx=1'b0;
	#17360
	top_rx=1'b1;
	#8690
	top_rx=1'b0;
	#8680
	top_rx=1'b1;
	#8690
	top_rx=1'b0;
	#8680
	top_rx=1'b1;
	#17360
	top_rx=1'b0;
	#34740
	top_rx=1'b1;
	#8670
	top_rx=1'b0;
	#17380
	top_rx=1'b1;
	#8670
	top_rx=1'b0;
	#8700
	top_rx=1'b1;
	#8670
	top_rx=1'b0;
	#34740
	top_rx=1'b1;
	#778678820
	top_rx=1'b0;
	#8700
	top_rx=1'b1;
	#8670
	top_rx=1'b0;
	#26050
	top_rx=1'b1;
	#17360
	top_rx=1'b0;
	#17370
	top_rx=1'b1;
	#8670
	top_rx=1'b0;
	#17380
	top_rx=1'b1;
	#8690
	top_rx=1'b0;
	#17370
	top_rx=1'b1;
	#17350
	top_rx=1'b0;
	#17370
	top_rx=1'b1;
	#8690
	top_rx=1'b0;
	#8680
	top_rx=1'b1;
	#17360
	top_rx=1'b0;
	#17380
	top_rx=1'b1;
	#17360
	top_rx=1'b0;
	#17370
	top_rx=1'b1;
	#8670
	top_rx=1'b0;
	#26050
	top_rx=1'b1;
	#8690
	top_rx=1'b0;
	#8680
	top_rx=1'b1;
	#17360
	top_rx=1'b0;
	#17380
	top_rx=1'b1;
	#8670
	top_rx=1'b0;
	#8690
	top_rx=1'b1;
	#8670
	top_rx=1'b0;
	#8700
	top_rx=1'b1;
	#8670
	top_rx=1'b0;
	#8680
	top_rx=1'b1;
	#17370
	top_rx=1'b0;
	#17370
	top_rx=1'b1;
	#8690
	top_rx=1'b0;
	#17350
	top_rx=1'b1;
	#17370
	top_rx=1'b0;
	#8700
	top_rx=1'b1;
	#17360
	top_rx=1'b0;
	#17350
	top_rx=1'b1;
	#8690
	top_rx=1'b0;
	#8680
	top_rx=1'b1;
	#26040
	top_rx=1'b0;
	#8700
	top_rx=1'b1;
	#17370
	top_rx=1'b0;
	#17370
	top_rx=1'b1;
	#8670
	top_rx=1'b0;
	#34740
	top_rx=1'b1;
	#26040
	top_rx=1'b0;
	#17370
	top_rx=1'b1;
	#8670
	top_rx=1'b0;
	#8700
	top_rx=1'b1;
	#8670
	top_rx=1'b0;
	#17370
	top_rx=1'b1;
	#26040
	top_rx=1'b0;
	#17380
	top_rx=1'b1;
	#8690
	top_rx=1'b0;
	#43410
	top_rx=1'b1;
	#17370
	top_rx=1'b0;
	#17350
	top_rx=1'b1;
	#8690
	top_rx=1'b0;
	#8680
	top_rx=1'b1;
	#8690
	top_rx=1'b0;
	#8680
	top_rx=1'b1;
	#17360
	top_rx=1'b0;
	#34740
	top_rx=1'b1;
	#8670
	top_rx=1'b0;
	#17380
	top_rx=1'b1;
	#8670
	top_rx=1'b0;
	#8700
	top_rx=1'b1;
	#8670
	top_rx=1'b0;
	#34740
	top_rx=1'b1;

	

end


top u_top(
    .i_clk(clk),
    .i_rst_n(rst_n),
    .uart_tx(top_tx),
    .uart_rx(top_rx)
);


endmodule
