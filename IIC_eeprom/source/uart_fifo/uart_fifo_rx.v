`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:43:13 07/03/2017 
// Design Name: 
// Module Name:    uart_fifo_rx 
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
module uart_fifo_rx(
    input       clk,
    input       rst_n,
    
    // uart
    input       uart_rx,
    
    // fifo
    output wire [63:0]  fifo_dout,
    output wire         fifo_full,
    output wire         fifo_empty,
    input               fifo_rd_en
   
    );

parameter baud_div = 216;
parameter cnt_width = 8;    
    
wire [7:0]  uart_rx_dat;
wire        uart_rx_rdy;    
reg  [3:0]  uart_rx_cnt;
wire        uart_rx_cnt_dn = uart_rx_cnt[3];

reg  [63:0] fifo_din;
reg         fifo_wr_en;

// uart rx module
uart_rx # (.baud_div(baud_div), .cnt_width(cnt_width))
u_uart_rx(
    .clk        (clk),        
    .rst_n      (rst_n),
    
    // rx
    .rx         (uart_rx),
    .rx_dat     (uart_rx_dat),
    .rx_rdy     (uart_rx_rdy)
);    
    
// rx fifo width-64 depth-512
fifo_rx u_fifo_rx(
    .clk        (clk),
    .rst        (~rst_n),
    .din        (fifo_din),
    .wr_en      (fifo_wr_en),
    .rd_en      (fifo_rd_en),
    .dout       (fifo_dout),
    .full       (fifo_full),
    .empty      (fifo_empty)
);
    
/******* tranlate 8byte -> 64bit *********/
// uart rx counter
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)             uart_rx_cnt <= 3'h0;
    else if (uart_rx_cnt_dn)uart_rx_cnt <= 3'h0;
    else if (uart_rx_rdy)   uart_rx_cnt <= uart_rx_cnt + 1'b1;
end

// shift 8 rx bytes to 64 bits
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)             fifo_din <= 64'h0;
    else if (uart_rx_rdy)   fifo_din <= {uart_rx_dat, fifo_din[63:8]};
end

// generate write enable
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)     fifo_wr_en <= 1'b0;
    else            fifo_wr_en <= uart_rx_cnt_dn & !fifo_full;
end
    
/******* tranlate 8byte -> 64bit *********/
    
    
endmodule
