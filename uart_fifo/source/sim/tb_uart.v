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

parameter UART_PERIOD = 1_000_000_000/115200;

reg clk;
reg rst_n;

reg uart_rx;
wire [63:0] rx_dout;
wire rx_full;
wire rx_empty;
reg  rx_rd_en;

wire uart_tx;
reg [63:0] tx_din;
wire tx_full;
wire tx_empty;
reg  tx_wr_en;
reg  tx_en;
wire tx_busy;

integer i;

initial begin
    clk = 0;
    rst_n = 1;
    #100;
    rst_n = 0;
    #1000;
    rst_n    = 1;
	 #1000;
end

always begin 
    #10 clk = ~clk;
end


// rx fifo verification
initial begin
	rx_rd_en = 0;	
	uart_rx = 1;
	# 10000;
	for (i=0;i<512*8;i=i+1) begin
			uart_send_data(i & 8'hff);
	end
	i = 8'hAA;
	uart_send_data(i & 8'hff);
	uart_send_data(i & 8'hff);
	uart_send_data(i & 8'hff);
	uart_send_data(i & 8'hff);
	uart_send_data(i & 8'hff);
	uart_send_data(i & 8'hff);
	uart_send_data(i & 8'hff);
	uart_send_data(i & 8'hff);
	uart_send_data(i & 8'hff);
	uart_send_data(i & 8'hff);
	
	rx_rd_en = 0;
	# 20;
	rx_rd_en = 1;
	# 20;
	rx_rd_en = 0;
	
	# 800000;
	rx_rd_en = 0;
	# 20;
	rx_rd_en = 1;
	# 20;
	rx_rd_en = 0;
	
	# 800000;
	rx_rd_en = 0;
	# 20;
	rx_rd_en = 1;
	# 20;
	rx_rd_en = 0;
	
end


// tx fifo verification
initial begin
	tx_wr_en = 0;
	tx_en = 0;
	#10000;
	tx_din = 64'h1234567887654321;
	#20;
	tx_wr_en = 1;
	#20;
	tx_wr_en = 0;
	#100;
	tx_en = 1;
	#20;
	tx_en = 0;
	#1000000;
	tx_en = 1;
	#20;
	tx_en = 0; 
	#1000000;
	tx_din = 64'h0102030405060708;
	#20;
	tx_wr_en = 1;
	#20;
	tx_wr_en = 0;
	#100;
	tx_en = 1;
	#20;
	tx_en = 0;	
	
end


// task to send data through uart
task uart_send_data;
input [7:0] data;

begin
	uart_rx = 0;
	#UART_PERIOD;
	uart_rx = data[0];
	#UART_PERIOD;
	uart_rx = data[1];
	#UART_PERIOD;
	uart_rx = data[2];
	#UART_PERIOD;
	uart_rx = data[3];
	#UART_PERIOD;
	uart_rx = data[4];
	#UART_PERIOD;
	uart_rx = data[5];
	#UART_PERIOD;
	uart_rx = data[6];
	#UART_PERIOD;
	uart_rx = data[7];
	#UART_PERIOD;
	uart_rx = 1;
	#UART_PERIOD;
end

endtask


uart_fifo_rx i_uart_fifo_rx(
    .clk(clk),
    .rst_n(rst_n),
    
    // uart
    .uart_rx(uart_rx),
    
    // fifo
    .fifo_dout(rx_dout),
    .fifo_full(rx_full),
    .fifo_empty(rx_empty),
    .fifo_rd_en(rx_rd_en)
);

uart_fifo_tx i_uart_fifo_tx(
	.clk(clk),
	.rst_n(rst_n),
	
	// uart
	.uart_tx(uart_tx),
	
	// fifo
	.fifo_din(tx_din),
	.fifo_full(tx_full),
	.fifo_empty(tx_empty),
	.fifo_wr_en(tx_wr_en),
	
	// en
	.enable(tx_en),
	.busy(tx_busy)
);



endmodule
