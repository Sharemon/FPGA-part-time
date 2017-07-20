`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:        		Roy.Pan
// 
// Create Date:        	21:41:47 06/30/2017 
// Design Name:     
// Module Name:        	uart_ctrl 
// Project Name:     
// Target Devices:  		Spartan6
// Tool versions: 
// Description:     		Uart top
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module uart_ctrl(
    input           clk,        //50Mhz
    input           rst_n,
    
    // tx
    input           tx_en,
    output wire     tx,
    input [7:0]     tx_dat,
    
    // rx
    input               rx,
    output wire [7:0]   rx_dat,
    output wire         rx_rdy
    );

parameter baud_div = 216;
parameter cnt_width = 8;

// tx
uart_tx #(.baud_div(baud_div), .cnt_width(cnt_width))
u_uart_tx(
    .clk    (clk),
    .rst_n  (rst_n),
    .tx_en  (tx_en),
    .tx     (tx),
    .tx_dat (tx_dat)
    );    
    

// rx
uart_rx #(.baud_div(baud_div), .cnt_width(cnt_width))
u_uart_rx(
    .clk    (clk),
    .rst_n  (rst_n),
    .rx     (rx),
    .rx_dat (rx_dat),
    .rx_rdy (rx_rdy)
    );
    

endmodule
