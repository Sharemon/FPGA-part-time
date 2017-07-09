`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:38:12 07/09/2017 
// Design Name: 
// Module Name:    tb 
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
module tb();


reg clk;
reg rst_n;
wire scl;
wire sda;
reg [7:0] din;
wire [7:0] dout;
wire ack_in;
reg ack_out;
wire busy;
reg wr_en;
reg rd_en;
reg stop_en;
reg start_en;


always begin
    #10 clk = ~clk;
end


initial begin
    clk = 0;
    rst_n = 1;
    #100;
    rst_n = 0;
    #1000;
    rst_n = 1;   
end

initial begin
    wr_en = 0;
    rd_en = 0;
    stop_en = 0;
    start_en = 0;
    din = 0;
    ack_out = 1;
    #10000;
    
    // start_en
    start_en = 1;
    #40;
    start_en = 0;
    
    // write data
    #10100;
    din = 8'hC6;
    wr_en = 1;
    #40;
    wr_en = 0;
    
    // write data
    #90040;
    din = 8'h32;
    wr_en = 1;
    #40;
    wr_en = 0;
    # 80000;
    force sda = 1;
    
    // read data
    #10040;
    force sda = 1;
    rd_en = 1;
    #40;
    rd_en = 0;
    # 80000;
    release sda;
    // stop_en
    #10040;
    stop_en = 1;
    #40;
    stop_en = 0;
end




iic_ctrl i_iic_ctrl(
    .clk        (clk),
    .rst_n      (rst_n),
    .scl        (scl),
    .sda        (sda),
    .din        (din),
    .ack_in     (ack_in),
    .dout       (dout),
    .ack_out    (ack_out),
    .wr_en      (wr_en),
    .rd_en      (rd_en),
    .start_en   (start_en),
    .stop_en    (stop_en),
    .busy       (busy)
);


endmodule
