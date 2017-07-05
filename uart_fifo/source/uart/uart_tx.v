`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:        		Roy.Pan
// 
// Create Date:        	21:41:47 06/30/2017 
// Design Name:     
// Module Name:        	uart_tx 
// Project Name:     
// Target Devices:     	Spartan6
// Tool versions: 
// Description:     		Uart tx
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module uart_tx(
    input           clk,    //50Mhz
    input           rst_n,
    
    // tx
    input           tx_en,
    output reg      tx,
    input [7:0]     tx_dat,
    output wire     busy
);

parameter baud_div 	= 216; 
parameter cnt_width	= 8;


wire clk_half_pule;

reg [4:0] cnt;
reg       tx_last;
reg       tx_en_r;
reg [7:0] tx_dat_r;

// lock tx_dat
always@ (posedge clk or negedge rst_n) begin
    if (!rst_n)     tx_dat_r <= 8'h0;
    else if (tx_en) tx_dat_r <= tx_dat; 
end

// sync tx_en_r with tx_dat_r
always@ (posedge clk or negedge rst_n) begin
    if (!rst_n) tx_en_r <= 1'b0;
    else        tx_en_r <= tx_en;
end


// tx_last enable
always@ (posedge clk or negedge rst_n) begin
    if (!rst_n)             tx_last <= 1'b0;
    else if (tx_en_r)       tx_last <= 1'b1;
    else if (cnt == 5'h14)  tx_last <= 1'b0;
end

// tx busy
assign busy = tx_last;

// get baudrate clk
clk_div_uart #(.baud_div(baud_div), .cnt_width(cnt_width))    //216 means 115200bps when clk = 50Mhz
u_clk_div_uart(
    .i_clk          (clk),
    .i_rst_n        (rst_n),
    .i_en           (tx_last),
    .o_clk_half_pule(clk_half_pule)
);



// tx cnt
always@ (posedge clk or negedge rst_n) begin
    if (!rst_n)                          cnt <= 5'h0;
    else if (tx_last & clk_half_pule)    cnt <= cnt +1'b1;
    else if (~tx_last)                   cnt <= 5'h0;
end    


// tx
always@ (posedge clk or negedge rst_n) begin
    if (!rst_n)     tx <= 1'b1;
    else if (tx_last) begin
        case (cnt[4:1])
            4'h0:    tx <= 1'b0;
            4'h1:    tx <= tx_dat_r[0];
            4'h2:    tx <= tx_dat_r[1];
            4'h3:    tx <= tx_dat_r[2];
            4'h4:    tx <= tx_dat_r[3];
            4'h5:    tx <= tx_dat_r[4];
            4'h6:    tx <= tx_dat_r[5];
            4'h7:    tx <= tx_dat_r[6];
            4'h8:    tx <= tx_dat_r[7];
            4'h9:    tx <= 1'b1;
            default: tx <= 1'b1;
        endcase    
    end
end


endmodule




