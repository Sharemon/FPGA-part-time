`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:        		Roy.Pan
// 
// Create Date:        	21:41:47 06/30/2017 
// Design Name:     
// Module Name:        	clk_div_uart
// Project Name:     
// Target Devices:     	Spartan6
// Tool versions: 
// Description:     		Uart clk divider
//								
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module clk_div_uart        //216 means 115200 when clk = 50Mhz
(            
    input i_clk,
    input i_rst_n,
    input i_en,
    output reg o_clk_half_pule
);

parameter baud_div=216;
parameter cnt_width=8;

reg [cnt_width-1:0] cnt;

always@ (posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n)               cnt <= 'h0;
    else if (!i_en)             cnt <= 'h0;
    else if (cnt == baud_div)   cnt <= 'h0;
    else                        cnt <= cnt + 1'b1;
end

always@ (posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n)                o_clk_half_pule <= 1'b0;
    else if (cnt == baud_div)    o_clk_half_pule <= 1'b1;
    else                         o_clk_half_pule <= 1'b0;
end

endmodule

