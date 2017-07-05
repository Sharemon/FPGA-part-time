`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:43:51 07/03/2017 
// Design Name: 
// Module Name:    uart_fifo_tx 
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
module uart_fifo_tx(
    input       clk,
    input       rst_n,
    
    // uart
    output      uart_tx,
    
    // fifo
    input  [63:0]   fifo_din,
    input           fifo_wr_en,
    output wire     fifo_full,
    output wire     fifo_empty,
    
    // tx enable : pulse with 1 clk cycle width
    input       enable,
	 
	// busy : indicate if the module is busy 
	output      busy
    );

parameter baud_div = 216;
parameter cnt_width = 8;  
    
reg  [7:0]  uart_tx_dat_8bit;
reg  [63:0] uart_tx_dat_64bit;
wire        uart_tx_en_pre;
reg  [1:0]  uart_tx_en_r;
wire        uart_tx_en;
wire        uart_busy;
reg         uart_busy_dly;
wire        uart_busy_fedge;
reg  [3:0]  uart_tx_cnt;
wire        uart_tx_cnt_dn = uart_tx_cnt[3];    
    
wire [63:0] fifo_dout;
wire        fifo_rd_en = enable & (~fifo_empty);   
reg         fifo_dout_sync; 
reg         fifo_dout_sync_dly;
reg         fifo_dout_rdy; 
    
// uart tx
uart_tx # (.baud_div(baud_div), .cnt_width(cnt_width))
u_uart_tx(
    .clk        (clk),        
    .rst_n      (rst_n),
    
    // tx
    .tx         (uart_tx),
    .tx_dat     (uart_tx_dat_8bit),
    .tx_en      (uart_tx_en),
    .busy       (uart_busy)
);      
    
// uart tx busy falling edge 
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) uart_busy_dly <= 1'b0;
    else        uart_busy_dly <= uart_busy;  
end     

assign uart_busy_fedge = uart_busy_dly & ~uart_busy;
    
// tx fifo
fifo_tx u_fifo_tx(
    .clk        (clk),
    .rst        (~rst_n),
    .din        (fifo_din),
    .wr_en      (fifo_wr_en),
    .rd_en      (fifo_rd_en),
    .dout       (fifo_dout),
    .full       (fifo_full),
    .empty      (fifo_empty)
);


/******* tranlate 64bit -> 8byte *********/
// fifo out data sync
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) fifo_dout_sync <= 1'b0;
    else        fifo_dout_sync <= fifo_rd_en;
end

// delay fifo dout sync to fit the fifo read timing
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) fifo_dout_sync_dly <= 1'b0;
    else        fifo_dout_sync_dly <= fifo_dout_sync;
end


// fifo out data
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)              uart_tx_dat_64bit <= 64'h0;
    else if (fifo_dout_sync) uart_tx_dat_64bit <= fifo_dout;
end

// fifo out data ready
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)              fifo_dout_rdy <= 1'b0;
    else if (fifo_dout_sync) fifo_dout_rdy <= 1'b1;
    else if (uart_tx_cnt_dn) fifo_dout_rdy <= 1'b0;
end

assign busy = fifo_dout_rdy;


// uart tx counter, 0-8 make sure send 8 bytes
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)             uart_tx_cnt <= 4'h0;
    else if (fifo_rd_en)    uart_tx_cnt <= 4'd0;
    else if (fifo_dout_rdy & uart_busy_fedge)   uart_tx_cnt <= uart_tx_cnt + 1'b1;
end

assign uart_tx_en_pre = fifo_dout_sync_dly | uart_busy_fedge;

// uart tx enable
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) uart_tx_en_r <= 2'h0;
    else        uart_tx_en_r <= {uart_tx_en_r[0] & ~uart_tx_cnt_dn, uart_tx_en_pre};
end

assign uart_tx_en = uart_tx_en_r[1];

// uart 8bit data
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) uart_tx_dat_8bit <= 8'h0;
    else if (uart_tx_en_r[0]) begin
        case (uart_tx_cnt)
            4'h0:   uart_tx_dat_8bit <= uart_tx_dat_64bit[ 7: 0];
            4'h1:   uart_tx_dat_8bit <= uart_tx_dat_64bit[15: 8];
            4'h2:   uart_tx_dat_8bit <= uart_tx_dat_64bit[23:16];
            4'h3:   uart_tx_dat_8bit <= uart_tx_dat_64bit[31:24];
            4'h4:   uart_tx_dat_8bit <= uart_tx_dat_64bit[39:32];
            4'h5:   uart_tx_dat_8bit <= uart_tx_dat_64bit[47:40];
            4'h6:   uart_tx_dat_8bit <= uart_tx_dat_64bit[55:48];
            4'h7:   uart_tx_dat_8bit <= uart_tx_dat_64bit[63:56];
            default:uart_tx_dat_8bit <= 8'h0;
        endcase
    end
end

/******* tranlate 64bit -> 8byte *********/


endmodule
