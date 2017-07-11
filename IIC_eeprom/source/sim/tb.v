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
reg [7:0]  ctrl_byte;
reg [31:0] data_in;
wire [31:0] data_out;
reg  req;
wire ack;
wire busy;


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
    req = 0;
    ctrl_byte = 8'hA6;
    data_in = 32'h12345678;
    #10000;
    
    req = 1;
    # 60;
    req = 0;
    
    # 600000;
    ctrl_byte = 8'hA7;
    #10000;
    
    req = 1;
    # 60;
    req = 0;
    
end

EEPROM u_EEPROM(
	.scl	(scl),
	.sda	(sda)
);

eeprom_ctrl i_eeprom_ctrl(
    .clk             (clk),
    .rst_n           (rst_n),
    .scl             (scl),
    .sda             (sda),
    .ctrl_byte       (ctrl_byte),
    .data_in         (data_in),
    .data_out        (data_out),
    .req             (req),
    .ack             (ack),
    .busy            (busy)
);


endmodule
