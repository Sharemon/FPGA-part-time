`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:51:58 07/10/2017 
// Design Name: 
// Module Name:    eeprom_ctrl 
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
//                           |                             |
//  Write Mode Operation     |     Read Mode Operation     | 
//                           |                             |
//       IIC Start           |          IIC Start          |
//           |               |              |              |
//     Write Ctrl Byte:      |       Write Ctrl Byte:      |
//  {101000,ctrl_byte[7],0}  |   {101000,ctrl_byte[7],0}   |
//           |               |              |              |
//     Write Address         |        Write Address        |
//           |               |              |              |
//   Write data_in[7:0]      |          IIC Start          |
//           |               |              |              |
//   Write data_in[15:8]     |       Write Ctrl Byte:      |
//           |               |   {101000,ctrl_byte[7],1}   |
//   Write data_in[23:16]    |              |              |
//           |               |      Read data_out[7:0]     |
//   Write data_in[31:24]    |              |              |
//           |               |      Read data_out[15:8]    |
//       IIC Stop            |              |              |
//                           |      Read data_out[23:16]   |
//                           |              |              |
//                           |      Read data_out[31:24]   |
//                           |              |              |
//                           |          IIC Stop           |
//                           |                             |
//////////////////////////////////////////////////////////////////////////////////
module eeprom_ctrl(
    input               clk,
    input               rst_n,
    
    // iic
    output wire         scl,
    inout               sda,
    
    // data 
    input [7:0]         ctrl_byte,
    input [31:0]        data_in,
    output wire [31:0]  data_out,
    
    // ctrl
    input               req,
    output reg          ack,
    output reg          busy
);

parameter freq_div  =124;
parameter cnt_width =7;

reg  [7:0] iic_din;
wire [7:0] iic_dout;    
wire iic_ack_in;
reg  iic_ack_out;
reg  iic_wr_en;
reg  iic_rd_en; 
reg  iic_start_en;
reg  iic_stop_en;
wire iic_busy;

reg  [3:0]  ack_out_buf;
reg  [5:0]  ack_in_buf;

reg [47:0]  wr_buf;
reg [31:0]  rd_buf;

reg [19:0]  op_buf;  
reg [ 3:0]  op_cnt;
reg [ 1:0]  cur_op;  // 00: start, 01: write, 10: read, 11: stop

// use grey code to avoid using default in case structure
// have no idea how to dela with the default situation
localparam OP_START = 2'b00;
localparam OP_WRITE = 2'b01;
localparam OP_READ  = 2'b10;
localparam OP_STOP  = 2'b11;


reg [9:0]   cur_st;
reg [9:0]   nxt_st;


localparam ST_IDLE      = 10'h01 ;
localparam ST_ACTIVE    = 10'h02 ;
localparam ST_WR_PRE    = 10'h04 ;
localparam ST_RD_PRE    = 10'h08 ;
localparam ST_IIC_START = 10'h10 ;
localparam ST_IIC_WR    = 10'h20 ;
localparam ST_IIC_RD    = 10'h40 ;
localparam ST_IIC_STOP  = 10'h80 ;
localparam ST_IIC_TRANS = 10'h100;
localparam ST_IIC_OP    = 10'h200;


// ============================= FSM ================================|
// IDLE     : detect req, pull down busy                             |
// ACTIVE   : pull up ack, determine wr or rd                        |
// WR_PRE   : pull down ack, prepare for eeprom write,               |
//              init operation sequence, init wr_buf                 |
// RD_PRE   : pull down ack, prepare for eeprom read,                |
//              init operation sequence, init wr_buf and ack_out_buf |
// OP       : extract new operation, cleanup last operation          |
//              if op counter is exhausted, go to IDLE               |
// TRANS    : determine which state to go with current operation     |
// IIC_START: enable iic start                                       |
// IIC_WR   : transfer output data to iic module, enable iic write   |
// IIC_RD   : transfer ack out to iic module, enable iic read        |
// IIC_STOP : enable iic stop                                        |
// ==================================================================|
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)     cur_st <= ST_IDLE;
    else            cur_st <= nxt_st;
end

always @ (*) begin
    nxt_st = 10'bx;
    case (cur_st)
        ST_IDLE: 
            begin
                if (req)    nxt_st = ST_ACTIVE;
                else        nxt_st = ST_IDLE;
            end
        ST_ACTIVE:
            begin
                if (ctrl_byte[0])   nxt_st = ST_RD_PRE;
                else                nxt_st = ST_WR_PRE;
            end
        ST_WR_PRE:
            begin
                nxt_st = ST_IIC_OP;
            end
        ST_RD_PRE:
            begin
                nxt_st = ST_IIC_OP;
            end
        ST_IIC_OP:
            begin
                if (iic_busy)               nxt_st = ST_IIC_OP;
                else if (op_cnt == 4'd0)    nxt_st = ST_IDLE;
                else                        nxt_st = ST_IIC_TRANS;
            end
        ST_IIC_TRANS:
            begin
                case (cur_op)
                    OP_START:   nxt_st = ST_IIC_START;
                    OP_WRITE:   nxt_st = ST_IIC_WR;
                    OP_READ :   nxt_st = ST_IIC_RD;
                    OP_STOP :   nxt_st = ST_IIC_STOP;
                    default :   nxt_st = ST_IIC_STOP;   // should never happen
                endcase
            end
        ST_IIC_START:
            begin
                if (!iic_busy)  nxt_st = ST_IIC_START;
                else            nxt_st = ST_IIC_OP;
            end
        ST_IIC_WR:
            begin
                if (!iic_busy)  nxt_st = ST_IIC_WR;
                else            nxt_st = ST_IIC_OP;
            end
        ST_IIC_RD:
            begin
                if (!iic_busy)  nxt_st = ST_IIC_RD;
                else            nxt_st = ST_IIC_OP;
            end
        ST_IIC_STOP:
            begin
                if (!iic_busy)  nxt_st = ST_IIC_STOP;
                else            nxt_st = ST_IIC_OP;
            end
        default:  
            nxt_st = ST_IDLE;
    endcase
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ack         <=  1'b0;
        wr_buf      <= 48'h0;
        rd_buf      <= 32'h0;
        op_buf      <= 16'h0;
        op_cnt      <=  4'h0;
        ack_in_buf  <=  6'h0;
        ack_out_buf <=  4'h0;
        iic_din     <=  8'h0;
        iic_ack_out <=  1'b0;
        iic_start_en<=  1'b0;
        iic_wr_en   <=  1'b0;
        iic_rd_en   <=  1'b0;
        iic_stop_en <=  1'b0;
    end 
    else begin
        case (cur_st)
            ST_IDLE: 
                begin
                    ack     <= 1'b0;
                    busy    <= 1'b0;
                end
            ST_ACTIVE:
                begin
                    ack     <= 1'b1;
                    busy    <= 1'b1;
                end
            ST_WR_PRE:
                begin
                    ack     <= 1'b0;
                    op_buf  <= 20'b00_01_01_01_01_01_01_11_0000;
                    op_cnt  <= 4'd8;
                    wr_buf  <= {{6'b101000,ctrl_byte[7],1'b0},
                                {ctrl_byte[6:1], 2'b00},
                                data_in[ 7: 0], data_in[15: 8], 
                                data_in[23:16], data_in[31:24]};
                end
            ST_RD_PRE:
                begin
                    ack     <= 1'b0;
                    op_buf  <= 20'b00_01_01_00_01_10_10_10_10_11;
                    op_cnt  <= 4'd10;
                    wr_buf  <= {{6'b101000,ctrl_byte[7],1'b0},
                                {ctrl_byte[6:1], 2'b00},
                                {6'b101000,ctrl_byte[7],1'b1},
                                24'h0};
                    ack_out_buf  <= 4'b0001;
                end
            ST_IIC_OP:
                begin
                    if (!iic_busy) begin
                        // operation assignment
                        cur_op  <= op_buf[19:18];
                        // add stop op at last in case there is any problem
                        op_buf  <= {op_buf[17:0], 2'b11};   
                        if (op_cnt != 4'h0) op_cnt <= op_cnt - 1'b1;
                        // cannot put rd shift in ST_RD_PRE
                        // otherwise, the last byte will not shift into rd_buf
                        // also need to judge if the last operatio is OP_READ
                        // in case the shift operate after OP_STOP
                        if (cur_op == OP_READ) begin
                            rd_buf      <= {iic_dout, rd_buf[31:8]};                   
                        end
                        // put ack_in shift here at the same reason
                        if (cur_op == OP_WRITE) begin
                            ack_in_buf  <= {ack_in_buf[4:0], iic_ack_in};
                        end
                    end
                end
            ST_IIC_TRANS:
                begin
                    iic_start_en    <= 1'b0;
                    iic_wr_en       <= 1'b0;
                    iic_rd_en       <= 1'b0;
                    iic_stop_en     <= 1'b0;
                end
            ST_IIC_START:
                begin
                    if (!iic_busy)  iic_start_en <= 1'b1;
                    else            iic_start_en <= 1'b0;
                end
            ST_IIC_WR:
                begin
                    if (!iic_busy)  begin
                        iic_wr_en <= 1'b1;
                        // wr shift and assignment cannot be put in ST_OP, 
                        // otherewise, start operatio will also do the shift
                        if (!iic_wr_en) begin   // if not judge iic_wr_en, wr data will shift twice
                            iic_din     <= wr_buf[47:40];
                            wr_buf      <= {wr_buf[39:0], 8'h0};
                        end
                    end
                    else            iic_wr_en <= 1'b0;
                end
            ST_IIC_RD:
                begin
                    if (!iic_busy)  begin
                        iic_rd_en <= 1'b1;
                        // so do ack out shift and assignment
                        if (!iic_rd_en) begin  // if not judge iic_rd_en, ack out data will shift twice              
                            iic_ack_out <= ack_out_buf[3];
                            ack_out_buf <= {ack_out_buf[2:0], 1'b0};
                        end
                    end
                    else            iic_rd_en <= 1'b0;
                end
            ST_IIC_STOP:
                begin
                    if (!iic_busy)  iic_stop_en <= 1'b1;
                    else            iic_stop_en <= 1'b0;
                end
            default:
                begin
                    ack         <=  1'b0;
                    wr_buf      <= 48'h0;
                    rd_buf      <= 32'h0;
                    op_buf      <= 16'h0;
                    op_cnt      <=  4'h0;
                    ack_in_buf  <=  4'h0;
                    ack_out_buf <=  6'h0;
                    iic_din     <=  8'h0;
                    iic_ack_out <=  1'b0;
                    iic_start_en<=  1'b0;
                    iic_wr_en   <=  1'b0;
                    iic_rd_en   <=  1'b0;
                    iic_stop_en <=  1'b0;
                end
        endcase
    end
end

assign data_out = rd_buf;

iic_ctrl #(.freq_div(freq_div), .cnt_width(cnt_width))
u_iic_ctrl(
    .clk        (clk),
    .rst_n      (rst_n),
    .scl        (scl),
    .sda        (sda),
    .din        (iic_din),
    .ack_in     (iic_ack_in),
    .dout       (iic_dout),       
    .ack_out    (iic_ack_out),
    .wr_en      (iic_wr_en),
    .rd_en      (iic_rd_en),
    .start_en   (iic_start_en),
    .stop_en    (iic_stop_en),
    .busy       (iic_busy)
);


endmodule
