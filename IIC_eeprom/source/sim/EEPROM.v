/****************************************************************************
模块名称：EEPROM  文件名：eeprom.v
模块功能：用于模拟真实的EEPROM（AT24C02/4/8/16） 的随机读写的功能。对于符合
          AT24C02/4/8/16 要求的scl和sda 随机读/写信号能根据I2C协议，分析
          其含义并进行相应的读/写操作。
模块说明：本模块为行为模块，不可综合为门级网表。而且本模块为教学目的做了许
          多简化，功能不完整，不能用做商业目的。
****************************************************************************/

`timescale 1ns/1ns
`define timeslice1 100
module EEPROM(scl, sda);	 	
input  scl;    //串行时钟线
inout  sda;    //串行数据线
reg out_flag;  //SDA数据输出的控制信号
reg[7:0]  memory[511:0];
reg[10:0] address; 
reg[7:0]  memory_buf;
reg[7:0]  sda_buf;   //SDA 数据输出寄存器
reg[7:0]  shift;     //SDA 数据输入寄存器
reg[7:0]  addr_byte; //EEPROM 存储单元地址寄存器
reg[7:0]  ctrl_byte; //控制字寄存器
reg[1:0]  State;     //状态寄存器
integer i;

//--------------------------------------------------------------
parameter 	  r7= 8'b10101111,w7= 8'b10101110,         //main7
      		    r6= 8'b10101101,w6= 8'b10101100,         //main6
 		          r5= 8'b10101011,w5= 8'b10101010,         //main5
		          r4= 8'b10101001,w4= 8'b10101000,         //main4
 		          r3= 8'b10100111,w3= 8'b10100110,         //main3
 		          r2= 8'b10100101,w2= 8'b10100100,         //main2
 		          r1= 8'b10100011,w1= 8'b10100010,         //main1
 		         r0= 8'b10100001,w0= 8'b10100000;         //main0
//--------------------------------------------------------------
assign sda = (out_flag == 1) ? sda_buf[7] : 1'bz; 

//----------寄存器和存储器初始化---------
initial
  begin
    addr_byte     = 0;
    ctrl_byte     = 0; 
    out_flag      = 0;
    sda_buf       = 0;
    State         = 2'b00;
    memory_buf    = 0;
    address       = 0;
    shift         = 0;
    for(i=0;i<=2047;i=i+1)
      memory[i]=0;
  end
//------------ 启动信号 -----------------------------
always @ (negedge sda)  
  if(scl == 1 )
    begin
      State = State + 1;
      if(State == 2'b11)
         disable write_to_eeprm;
    end

//------------ 主状态机 --------------------------
always @(posedge sda)            
  if (scl == 1 ) begin     //停止操作 
    stop_W_R;
  end
  else 
    begin
     casex(State)
         2'b01:       // 做RTL仿真时，处此应该是2'b10, 
                      // 做布局布线后仿真时也应该是2’b10
                      // 但Modelsim和quartusII版本必须是6.1b和6.1以上
   	         begin  
   	           read_in;
                   if(ctrl_byte==w7||ctrl_byte==w6||ctrl_byte==w5
                      ||ctrl_byte==w4||ctrl_byte==w3||ctrl_byte==w2
                      ||ctrl_byte==w1||ctrl_byte==w0)
	              begin
	                State = 2'b10;
	                write_to_eeprm;  //写操作 
	               end
	           else
	             State = 2'b00;
	         end
	
         2'b11:    
               read_from_eeprm;      //读操作            

     default:  
               State=2'b00;  
		   
   endcase
  end  //主状态机结束

//------------- 操作停止------------------------------
task stop_W_R;
  begin
    State =2'b00;  //状态返回为初始状态
    addr_byte  = 0;
    ctrl_byte  = 0;
    out_flag  = 0;
    sda_buf   = 0;
  end
endtask

//------------- 读进控制字和存储单元地址 ------------------------
task  read_in;
  begin
    shift_in(ctrl_byte);
    shift_in(addr_byte);   
  end
endtask

//------------EEPROM 的写操作---------------------------------------
task write_to_eeprm;
  begin
    address          = {ctrl_byte[3:1],addr_byte};
    //
    //  Modified to support 4 byte page write
    //
    for (i=0; i<4; i=i+1) begin
        shift_in(memory_buf);  
        memory[address+i]  = memory_buf;	
        $display("eeprm----memory[%0h]=%0h",address+i,memory[address+i]);   
    end
    //
    //  Modified to support 4 byte page write
    //
    
    State =2'b00;             //回到0状态
  end
endtask

//-----------EEPROM 的读操作----------------------------------------
task read_from_eeprm;
  begin 
    shift_in(ctrl_byte);
    if(ctrl_byte==r7||ctrl_byte==r6||ctrl_byte==r5||ctrl_byte==r4
       ||ctrl_byte==r3||ctrl_byte==r2||ctrl_byte==r1||ctrl_byte==r0)
      begin
        address = {ctrl_byte[3:1],addr_byte};	
        //
        //  Modified to support 4 byte sequential read
        //
	     sda_buf = memory[address];
         shift_out;
         sda_buf = memory[address+1];
         shift_out;
         sda_buf = memory[address+2];
         shift_out;
         sda_buf = memory[address+3];
	     shift_out;
        //
        //  Modified to support 4 byte sequential read
        // 
        
	     State= 2'b00;
      end
  end	   
endtask   
 	   
//-----SDA 数据线上的数据存入寄存器，数据在SCL的高电平有效-------------
task shift_in;
 output [7:0] shift; 
  begin
     @ (posedge  scl) shift[7] = sda;  
     @ (posedge  scl) shift[6] = sda;
     @ (posedge  scl) shift[5] = sda;
     @ (posedge  scl) shift[4] = sda;
     @ (posedge  scl) shift[3] = sda; 
     @ (posedge  scl) shift[2] = sda;
     @ (posedge  scl) shift[1] = sda;
     @ (posedge  scl) shift[0] = sda;
     @ (negedge scl)      
       begin 	
         #`timeslice1 ;
      	 out_flag = 1;     //应答信号输出
          sda_buf  = 0;  
       end
     @(negedge scl)
        #`timeslice1 out_flag  = 0;  
  end
endtask

//----EEPROM 存储器中的数据通过SDA 数据线输出，数据在SCL 低电平时变化
task shift_out;
  begin
    out_flag = 1;
    for(i=6;i>=0;i=i-1)
      begin 
        @ (negedge scl);
        #`timeslice1;
        sda_buf = sda_buf<<1;
      end
    @(negedge scl)  #`timeslice1 out_flag  = 0;  
    @(negedge scl)  #`timeslice1 sda_buf[7] = 1;  //非应答信号输出
  end
endtask	    
  endmodule
  //-------------------------------eeprom.v 文件结束----------------


 















                      


 
 

