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
    
    // iic
    output wire scl,
    inout       sda,
    
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

// key
reg  [2:0]  key_up_dly;
reg  [2:0]  key_down_dly;
reg  [2:0]  key_left_dly;
reg  [2:0]  key_right_dly;
wire        read_rx_fifo_en;
wire        wr_rd_eeprom_en;
wire        uart_tx_en;
wire        wr_to_fifo_en;


// led
reg         working_led;
reg  [23:0] led_cnt;

clk_gen i_clkgen(
	.CLK_IN1	(i_clk),
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
// ------------------ operating sequence ------------------------- 
// send uart (ctrl[0] = 0) from PC -> keyup -> keydown
// send uart (ctrl[0] = 1) from PC -> keyup -> keydown -> keyright -> key_left
// ------------------ operating sequence ------------------------- 
always @ (posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) key_up_dly <= 3'd0;
    else begin
        key_up_dly[0] <= key_up;
        key_up_dly[1] <= key_up_dly[0];
        key_up_dly[2] <= key_up_dly[1];
    end
end

assign read_rx_fifo_en = key_up_dly[2] & ~key_up_dly[1];

always @ (posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) key_down_dly <= 3'd0;
    else begin
        key_down_dly[0] <= key_down;
        key_down_dly[1] <= key_down_dly[0];
        key_down_dly[2] <= key_down_dly[1];
    end
end

assign wr_rd_eeprom_en = key_down_dly[2] & ~key_down_dly[1];

always @ (posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) key_left_dly <= 3'd0;
    else begin
        key_left_dly[0] <= key_left;
        key_left_dly[1] <= key_left_dly[0];
        key_left_dly[2] <= key_left_dly[1];
    end
end

assign uart_tx_en = key_left_dly[2] & ~key_left_dly[1];


always @ (posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) key_right_dly <= 3'd0;
    else begin
        key_right_dly[0] <= key_right;
        key_right_dly[1] <= key_right_dly[0];
        key_right_dly[2] <= key_right_dly[1];
    end
end

assign wr_to_fifo_en = key_right_dly[2] & ~key_right_dly[1];


wire [31:0] eeprom_dout;
reg         req;
//wire        busy;
reg  [ 7:0] ctrl_byte;
reg  [ 6:0] addr;

wire [63:0] rx_fifo_dout;
wire        rx_fifo_rd_en;
wire [63:0] tx_fifo_din;
wire        tx_fifo_wr_en;
wire        tx_en;
wire        eeprom_busy;
reg  [ 1:0] eeprom_busy_dly;
wire        eeprom_busy_fe;

always @ (posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)     eeprom_busy_dly <= 2'b00;
    else                eeprom_busy_dly <= {eeprom_busy_dly[0], eeprom_busy};
end

assign eeprom_busy_fe = ~eeprom_busy_dly[0] & eeprom_busy_dly[1];

always @ (posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)     req <= 1'b0;
    else                req <= wr_rd_eeprom_en;
end

always @ (*) begin
    addr = rx_fifo_dout[63:37];
end

eeprom_ctrl u_eeprom_ctrl(
    .clk            (sys_clk),
    .rst_n          (sys_rst_n),
    .scl            (scl),
    .sda            (sda),
    .ctrl_byte      (rx_fifo_dout[63:56]),
    .data_in        (rx_fifo_dout[31:0]),
    .data_out       (eeprom_dout),
    .req            (req),
    .ack            (),
    .busy           (eeprom_busy)
);


uart_fifo_rx i_uart_fifo_rx(
    .clk(sys_clk),
    .rst_n(sys_rst_n),
    
    // uart
    .uart_rx(uart_rx),
    
    // fifo
    .fifo_dout(rx_fifo_dout),
    .fifo_full(),
    .fifo_empty(),
    .fifo_rd_en(read_rx_fifo_en)
);

// uart_fifo_tx
uart_fifo_tx i_uart_fifo_tx(
	.clk(sys_clk),
	.rst_n(sys_rst_n),
	
	// uart
	.uart_tx(uart_tx),
	
	// fifo
	.fifo_din({32'hAACCDDEE, eeprom_dout}),
	.fifo_full(),
	.fifo_empty(),
	.fifo_wr_en(wr_to_fifo_en),
	
	// en
	.enable(uart_tx_en),
	.busy()
);

assign led[7:1] = 'h0;

endmodule
