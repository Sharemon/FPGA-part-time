`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:        		Roy.Pan
// 
// Create Date:        	21:41:47 06/30/2017 
// Design Name:     
// Module Name:        	uart_rx 
// Project Name:     
// Target Devices:     	Spartan6
// Tool versions: 
// Description:     		Uart rx
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module uart_rx(
    input         clk,        //50Mhz
    input         rst_n,
    
    // rx
    input               rx,
    output reg [7:0]    rx_dat,
    output wire         rx_rdy
);

parameter baud_div 	= 216; 
parameter cnt_width	= 8;


wire clk_half_pule;
wire rx_fe;

reg [2:0] rx_dly;
reg       rx_last;
reg [4:0] cnt;
reg [1:0] rx_rdy_dly;

// detect falling edge of rx
always@ (posedge clk or negedge rst_n) begin
    if (!rst_n)        rx_dly <= 3'd0;
    else begin
        rx_dly[0] <= rx;
        rx_dly[1] <= rx_dly[0];
        rx_dly[2] <= rx_dly[1];
    end
end

assign rx_fe = ~rx_dly[1] & rx_dly[2];


// rx last enable
always@ (posedge clk or negedge rst_n) begin
    if (!rst_n)                rx_last <= 1'b0;
    else if (rx_fe)            rx_last <= 1'b1;
    else if (cnt == 5'h13)     rx_last <= 1'b0;
end


// get baudrate clk
clk_div_uart #(.baud_div(baud_div), .cnt_width(cnt_width))    //217 means 57600 when clk = 25Mhz
u_clk_div_uart (
    .i_clk          (clk),
    .i_rst_n        (rst_n & rx_last),
    .i_en           (rx_last),
    .o_clk_half_pule(clk_half_pule)
);
 
 
// cnt
always@ (posedge clk or negedge rst_n) begin
    if (!rst_n)                          cnt <= 5'h0;
    else if (rx_last & clk_half_pule)    cnt <= cnt + 1'b1;
    else if (~rx_last)                   cnt <= 5'h0;
end


// rx_dat
always@ (posedge clk or negedge rst_n) begin
    if (!rst_n)                          rx_dat <= 8'd0;
    else if (clk_half_pule & ~cnt[0])    rx_dat <= {rx, rx_dat[7:1]};
end    
  
  
// rx_data_rdy
always@ (posedge clk or negedge rst_n) begin
    if (!rst_n) rx_rdy_dly <= 2'b00;
    else begin
        rx_rdy_dly[0] <= (cnt == 5'h12);
        rx_rdy_dly[1] <= rx_rdy_dly[0];
    end
end

assign rx_rdy = rx_rdy_dly[0] & ~rx_rdy_dly[1];


endmodule
