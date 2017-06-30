`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    06:56:10 04/25/2017 
// Design Name: 
// Module Name:    top 
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
module top(
    input       i_clk,
    input       i_rst_n,
    
    // uart
    output wire uart_tx,
    input       uart_rx,
    
    // led
    output wire [7:0] led
);

wire sys_clk;
wire sys_rst_n;

wire [7:0]  uart_rx_dat;
wire        uart_rx_rdy;
reg  [7:0]  uart_tx_dat;
reg         uart_tx_en;

reg         working_led;
reg  [23:0] led_cnt;
reg  [4:0]  rdy_cnt;

clk_gen i_clkgen(
	.CLK_IN1		(i_clk),
	.CLK_OUT1	(sys_clk),
	.RESET		(~i_rst_n),
	.LOCKED		(sys_rst_n)
);


// led 
assign led = 8'hff;

always@ (posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)                     led_cnt <= 24'd0;
    else if (led_cnt == 24'd12_500_000) led_cnt <= 24'd0;
    else                                led_cnt <= led_cnt + 1'b1;
end

always@ (posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)                     working_led <= 1'b1;
    else if (led_cnt == 24'd12_500_000) working_led <= ~working_led;
end


// uart
uart_ctrl #(.baud_div(216), .cnt_width(8)) 
u_uart(
    .clk        (sys_clk),        //50Mhz
    .rst_n      (sys_rst_n),
    
    // tx
    .tx_en      (uart_tx_en),
    .tx         (uart_tx),
    .tx_dat     (uart_tx_dat),
    
    // rx
    .rx         (uart_rx),
    .rx_dat     (uart_rx_dat),
    .rx_rdy     (uart_rx_rdy)
);

// tx en
always@ (posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)  uart_tx_en <= 1'b0;
    else             uart_tx_en <= uart_rx_rdy;
end
    
    
// tx data
always@ (posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)          uart_tx_dat <= 8'h0;
    else if (uart_rx_rdy)    uart_tx_dat <= uart_rx_dat;
end

// count rdy
always@ (posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)         rdy_cnt <= 4'h0;
    else if (uart_rx_rdy)   rdy_cnt <= rdy_cnt + 1'b1;
end

endmodule
