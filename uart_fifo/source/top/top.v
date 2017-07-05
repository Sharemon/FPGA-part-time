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
    output wire [7:0] led,
	 
	// key
	input       key_left,
	input       key_right,
	input       key_up,
	input       key_down,
	input       key_enter
);

// system
wire    sys_clk;
wire    sys_rst_n;

// tx fifo
wire [63:0] tx_fifo_din;
wire        tx_fifo_full;
wire        tx_fifo_empty;
wire        tx_fifo_wr_en;
wire        tx_en;
wire        tx_busy;

// rx fifo
wire [63:0] rx_fifo_dout;
wire        rx_fifo_full;
wire        rx_fifo_empty;
wire        rx_fifo_wr_en;

// key
reg  [2:0]  key_up_dly;
reg  [2:0]  key_down_dly;
wire        transfer_en;
wire        send_en;


// led
reg         working_led;
reg  [23:0] led_cnt;

clk_gen i_clkgen(
	.CLK_IN1		(i_clk),
	.CLK_OUT1	(sys_clk),
	.RESET		(~i_rst_n),
	.LOCKED		(sys_rst_n)
);


// led 
assign led[0] = working_led;

always @ (posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)                     led_cnt <= 24'd0;
    else if (led_cnt == 24'd12_500_000) led_cnt <= 24'd0;
    else                                led_cnt <= led_cnt + 1'b1;
end

always @ (posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)                     working_led <= 1'b1;
    else if (led_cnt == 24'd12_500_000) working_led <= ~working_led;
end

// key
always @ (posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) key_up_dly <= 3'd0;
    else begin
        key_up_dly[0] <= key_up;
        key_up_dly[1] <= key_up_dly[0];
        key_up_dly[2] <= key_up_dly[1];
    end
end

assign transfer_en = key_up_dly[2] & ~key_up_dly[1] & ~rx_fifo_empty;

always @ (posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) key_down_dly <= 3'd0;
    else begin
        key_down_dly[0] <= key_down;
        key_down_dly[1] <= key_down_dly[0];
        key_down_dly[2] <= key_down_dly[1];
    end
end

assign send_en = key_down_dly[2] & ~key_down_dly[1];



// fifo rx & tx
assign tx_en            = send_en;
assign tx_fifo_din      = rx_fifo_dout;
assign rx_fifo_rd_en    = transfer_en;

reg [2:0] transfer_en_dly;
always @ (posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) transfer_en_dly <= 3'd0;
    else begin
        transfer_en_dly[0] <= transfer_en;
        transfer_en_dly[1] <= transfer_en_dly[0];
        transfer_en_dly[2] <= transfer_en_dly[1];
    end
end

assign tx_fifo_wr_en = transfer_en_dly[2];

// uart_fifo_rx
uart_fifo_rx i_uart_fifo_rx(
    .clk(sys_clk),
    .rst_n(sys_rst_n),
    
    // uart
    .uart_rx(uart_rx),
    
    // fifo
    .fifo_dout(rx_fifo_dout),
    .fifo_full(rx_fifo_full),
    .fifo_empty(rx_fifo_empty),
    .fifo_rd_en(rx_fifo_rd_en)
);

assign led[1] = rx_fifo_full;
assign led[2] = rx_fifo_empty;

// uart_fifo_tx
uart_fifo_tx i_uart_fifo_tx(
	.clk(sys_clk),
	.rst_n(sys_rst_n),
	
	// uart
	.uart_tx(uart_tx),
	
	// fifo
	.fifo_din(tx_fifo_din),
	.fifo_full(tx_fifo_full),
	.fifo_empty(tx_fifo_empty),
	.fifo_wr_en(tx_fifo_wr_en),
	
	// en
	.enable(tx_en),
	.busy(tx_busy)
);

assign led[3] = tx_fifo_full;
assign led[4] = tx_fifo_empty;
assign led[5] = tx_en;
assign led[6] = tx_busy;
assign led[7] = 1'b0;

endmodule
