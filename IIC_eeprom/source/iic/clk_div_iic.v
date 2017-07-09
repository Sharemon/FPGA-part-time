`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:        		
// 
// Create Date:        	19:09:11 07/09/2017 
// Design Name:     
// Module Name:        	clk_div_iic
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
module clk_div_iic       
(            
    input clk,
    input rst_n,
    input en,
    output reg half_clk_pulse
);

parameter freq_div  =124;
parameter cnt_width =7;

reg [cnt_width-1:0] cnt;

always@ (posedge clk or negedge rst_n) begin
    if (!rst_n)                 cnt <= 'h0;
    else if (!en)               cnt <= 'h0;
    else if (cnt == freq_div)   cnt <= 'h0;
    else                        cnt <= cnt + 1'b1;
end

always@ (posedge clk or negedge rst_n) begin
    if (!rst_n)                 half_clk_pulse <= 1'b0;
    else if (cnt == freq_div)   half_clk_pulse <= 1'b1;
    else                        half_clk_pulse <= 1'b0;
end

endmodule

