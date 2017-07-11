`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:09:11 07/09/2017 
// Design Name: 
// Module Name:    iic_ctrl 
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
module iic_ctrl(
    input           clk,
    input           rst_n,
    
    // iic 
    output          scl,
    inout           sda,
    
    // data
    input  [7:0]    din,
    output reg      ack_in,
    
    output reg [7:0]dout,       
    input           ack_out,
    
    // control
    input           wr_en,
    input           rd_en,
    input           start_en,
    input           stop_en,
    
    // state
    output          busy
);

parameter freq_div  =124;
parameter cnt_width =7;

localparam ACK  = 1'b0;
localparam NACK = 1'b1;

wire sda_direction;     // 1: input, 0 :output
reg  sda_idle;      // after start/stop/wr/rd, sda will remain different value

wire sda_out;
wire scl_out;

reg sda_start;
reg sda_stop;
reg sda_wr;
reg sda_rd;

reg scl_start;
reg scl_stop;
reg scl_wr;
reg scl_rd;

reg start_valid;
reg stop_valid;
reg wr_valid;
reg rd_valid;

wire iic_en         = start_en | stop_en | wr_en | rd_en;
wire iic_valid      = start_valid | stop_valid | wr_valid | rd_valid;
wire half_clk_en    = iic_valid;

reg [5:0]   half_clk_cnt;


clk_div_iic #(.freq_div(freq_div), .cnt_width(cnt_width))
i_clk_div_iic(            
    .clk(clk),
    .rst_n(rst_n),
    .en(half_clk_en),
    .half_clk_pulse(half_clk_pulse)
);

// ================ half iic clk counter ===================
// half clk counter, pulse 1 every half iic clk
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)                 half_clk_cnt <= 6'h0;
    else if (half_clk_pulse)    half_clk_cnt <= half_clk_cnt + 1'b1;
    else if (iic_en)            half_clk_cnt <= 6'h0;
end


// ================= sda direction judge ====================
// sda is input when read data and read ack
// otherwise, sda is ouput. 1: output, 0 :input
assign sda_direction = 
    (wr_valid & half_clk_cnt[5]) || (rd_valid & ~half_clk_cnt[5]);

    
// ================= sda idle assignment ====================
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)             sda_idle <= 1'b1;
    else if (start_valid)   sda_idle <= 1'b0;
    else if (stop_valid)    sda_idle <= 1'b1;
    else if (wr_valid)      sda_idle <= 1'bz;
    else if (rd_valid)      sda_idle <= ack_out;
end    
    

// ================ generate write signal ===================
// write valid
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)                     wr_valid <= 1'b0;
    else if (wr_en)                 wr_valid <= 1'b1;
    else if (half_clk_cnt == 6'd36) wr_valid <= 1'b0;
end

// write scl
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)                         scl_wr <= 1'b0;
    else if (half_clk_cnt[1:0] == 2'd1) scl_wr <= 1'b1;
    else if (half_clk_cnt[1:0] == 2'd3) scl_wr <= 1'b0;
end

// write sda 
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)     sda_wr <= 1'b0;
    else if (~half_clk_cnt[5] && (half_clk_cnt[1:0] == 2'd0)) begin
        case (half_clk_cnt[5:2])
            4'd0 :  sda_wr <= din[7];
            4'd1 :  sda_wr <= din[6];
            4'd2 :  sda_wr <= din[5];
            4'd3 :  sda_wr <= din[4];
            4'd4 :  sda_wr <= din[3];
            4'd5 :  sda_wr <= din[2];
            4'd6 :  sda_wr <= din[1];
            4'd7 :  sda_wr <= din[0];
            default : sda_wr <= 1'b0;
        endcase
    end
end

// read ack after write 8 bit
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)                     ack_in <= ACK;
    else if (half_clk_cnt == 6'd34) ack_in <= sda;
end


// ================ generate read signal ===================
// read valid
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)                     rd_valid <= 1'b0;
    else if (rd_en)                 rd_valid <= 1'b1;
    else if (half_clk_cnt == 6'd36) rd_valid <= 1'b0;
end

// read scl
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)                         scl_rd <= 1'b0;
    else if (half_clk_cnt[1:0] == 2'd1) scl_rd <= 1'b1;
    else if (half_clk_cnt[1:0] == 2'd3) scl_rd <= 1'b0;
end

// read sda 
wire rd_pulse;
wire rd_pulse_w;
reg  rd_pulse_r;

assign rd_pulse_w = rd_valid & ~half_clk_cnt[5] & (half_clk_cnt[1:0] == 2'd2);
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)                     rd_pulse_r <= 1'b0;
    else                            rd_pulse_r <= rd_pulse_w;
end

assign rd_pulse = rd_pulse_w & ~rd_pulse_r;

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)                     dout <= 8'h0;
    else if (rd_pulse)              dout <= {dout[6:0], sda};
end


// send ack after read 8 bit
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)                     sda_rd <= 1'b0;
    else if (half_clk_cnt == 6'd32) sda_rd <= ack_out;
end



// ================ generate start signal ===================
// start valid
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)                     start_valid <= 1'b0;
    else if (start_en)              start_valid <= 1'b1;
    else if (half_clk_cnt == 6'h4)  start_valid <= 1'b0;
end

// start scl
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)                     scl_start <= 1'b0;
    else if (start_en)              scl_start <= 1'b0;
    else if (^ half_clk_cnt[1:0])   scl_start <= 1'b1;
    else                            scl_start <= 1'b0;
end

// start sda
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)                     sda_start <= 1'b1;
    else if (start_en)              sda_start <= 1'b1;
    else if (|half_clk_cnt[2:1])    sda_start <= 1'b0;
end




// ================ generate stop signal ===================
// stop valid
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)                     stop_valid <= 1'b0;
    else if (stop_en)               stop_valid <= 1'b1;
    else if (half_clk_cnt == 8'h4)  stop_valid <= 1'b0;
end

// stop scl
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)                     scl_stop <= 1'b0;
    else if (stop_en)               scl_stop <= 1'b0;
    else if (^half_clk_cnt[1:0])    scl_stop <= 1'b1;
    else                            scl_stop <= 1'b0;
end

// stop sda
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)                     sda_stop <= 1'b0;
    else if (stop_en)               sda_stop <= 1'b0;
    else if (|half_clk_cnt[2:1])    sda_stop <= 1'b1;
end



// ================== mux scl and sda =====================
assign sda_out = (start_valid)? sda_start : (stop_valid)? sda_stop : (wr_valid)? sda_wr : (rd_valid)? sda_rd : sda_idle;
assign scl_out = (start_valid)? scl_start : (stop_valid)? scl_stop : (wr_valid)? scl_wr : (rd_valid)? scl_rd : 1'b0;
assign sda = (sda_direction)? 1'bz : sda_out;
assign scl = scl_out;

assign busy = iic_valid;

endmodule
