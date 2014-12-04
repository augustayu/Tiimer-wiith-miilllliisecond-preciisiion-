`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:35:38 11/30/2014 
// Design Name: 
// Module Name:    ms_timer 
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

module ms_timer(
input clk,
input inc,
input wire switch, // 1 为start， 0 为stop
input rst, // 复位，上升沿触发，异步
output reg [7:0] num, // 选择显示的数据，用parameter参数赋值
output reg [3:0] loc// 选择哪一个数码管位输出
    );
parameter  SEG_NUM0 = 8'b00000011,  // abcdefg dp
           SEG_NUM1 = 8'b10011111,
			  SEG_NUM2 = 8'b00100101,
			  SEG_NUM3 = 8'b00001101,
			  SEG_NUM4 = 8'b10011001,
			  SEG_NUM5 = 8'b01001001,
			  SEG_NUM6 = 8'b01000001,
			  SEG_NUM7 = 8'b00011111,
			  SEG_NUM8 = 8'b00000001,
			  SEG_NUM9 = 8'b00001001,
			  SEGD_NUM0 = 8'b00000010,  // 秒单位，需要小数点 abcdefg dp
           SEGD_NUM1 = 8'b10011110,
			  SEGD_NUM2 = 8'b00100100,
			  SEGD_NUM3 = 8'b00001100,
			  SEGD_NUM4 = 8'b10011000,
			  SEGD_NUM5 = 8'b01001000,
			  SEGD_NUM6 = 8'b01000000,
			  SEGD_NUM7 = 8'b00011110,
			  SEGD_NUM8 = 8'b00000000,
			  SEGD_NUM9 = 8'b00001000;

// 位选		  
parameter  DUAN_3 = 4'b0111,			  
			  DUAN_2 = 4'b1011,
			  DUAN_1 = 4'b1101,
			  DUAN_0 = 4'b1110;
			  
reg [20:0] count = 0;
reg [3:0] ms1 = 0;   // 毫秒单位
reg [3:0] ms10 = 0; // 10毫秒单位
reg [3:0] ms100 = 0; // 100毫秒单位
reg [3:0] s1 = 0; // 1秒单位

reg [17:0] fenpin = 0;
reg clk_1ms = 0;
reg cen = 0;
integer fsm = 1; //判断状态,一开始为停止状态
always @(posedge clk) begin
	   if(fenpin == 100000)
		   fenpin <= 0;
		else 
		   fenpin <= fenpin + 1'b1;
end

always @ (posedge clk) begin
   if(fenpin < 50000)
	    clk_1ms  <= 0;
	else
	    clk_1ms  <= 1;
end
// 扫描位选
always @ (posedge clk) begin
   count <= count + 1'b1;	
end

always @ (posedge clk_1ms or posedge rst) begin
if (rst) begin
fsm = 1;
cen = 0;
end
else begin
 case(fsm)
    0: begin // 在start的自加状态下	  
	    cen = 1;
	    if(!switch)// 触发stop
		 fsm = 1;
		 else	
		  fsm = 0;
	    end
	 1: begin  // stop状态
	    cen = 0;
	    if(switch) //触发start
		 fsm = 0;
       else if(inc) 
		 fsm = 2;
		 else
		 fsm = 1;
       end		 
	 2: begin    // inc函数
	    cen = 1;
	    fsm = 3;
		 end
	 3: begin
	    cen = 0;
		 if(inc)
		 fsm = 3;
		 else
		 fsm = 1;
	   end
 endcase
end

end

// 计时器加1，实现4个数字的加法
always @ (posedge clk_1ms) begin 
if(!rst) begin
if(cen) begin
case(ms1)
	 4'b1001: ms1 <= 4'b0000;
	 default:  ms1 <= ms1 + 1'b1;
	 endcase
	 
	 case(ms10)
	 4'b1001: begin
	           if(ms1 == 4'b1001)
	             ms10 <= 4'b0000;
				 end
	 default: begin
    	       if(ms1 == 4'b1001)
	             ms10 <= ms10 + 1'b1;
				 end
	 endcase
	 
	 case(ms100)
	 4'b1001: begin
	           if(ms1 == 4'b1001 && ms10 == 4'b1001)
	             ms100 <= 4'b0000;
				 end
	 default: begin
    	       if(ms1 == 4'b1001 && ms10 == 4'b1001)
	             ms100 <= ms100 + 1'b1;
				 end
	 endcase
	 
	 case(s1)
	 4'b1001: begin
	           if(ms1 == 4'b1001 && ms10 == 4'b1001 && ms100 == 4'b1001)
	             s1 <= 4'b0000;
				 end
	 default: begin
    	       if(ms1 == 4'b1001 && ms10 == 4'b1001 && ms100 == 4'b1001)
	             s1 <= s1 + 1'b1;
				 end
	 endcase
end
end
//复位清零
else begin
ms1 <= 0;
ms100 <= 0;
ms10 <= 0;
s1 <= 0;
end
end

// 扫描显示,位选信号。扫描到对应数码管位就显示那一位数字
always @ (posedge clk) begin
  case(count[19:18])
  2'b00: begin
          loc <= DUAN_3;
			 case(s1)
			 4'b0000: num <= SEGD_NUM0;
			 4'b0001: num <= SEGD_NUM1;
			 4'b0010: num <= SEGD_NUM2;
			 4'b0011: num <= SEGD_NUM3;
			 4'b0100: num <= SEGD_NUM4;
			 4'b0101: num <= SEGD_NUM5;
			 4'b0110: num <= SEGD_NUM6;
			 4'b0111: num <= SEGD_NUM7;
			 4'b1000: num <= SEGD_NUM8;
			 4'b1001: num <= SEGD_NUM9;
			 endcase
			end
	
  2'b01: begin
          loc <= DUAN_2;
			 case(ms100)
			 4'b0000: num <= SEG_NUM0;
			 4'b0001: num <= SEG_NUM1;
			 4'b0010: num <= SEG_NUM2;
			 4'b0011: num <= SEG_NUM3;
			 4'b0100: num <= SEG_NUM4;
			 4'b0101: num <= SEG_NUM5;
			 4'b0110: num <= SEG_NUM6;
			 4'b0111: num <= SEG_NUM7;
			 4'b1000: num <= SEG_NUM8;
			 4'b1001: num <= SEG_NUM9;
			 endcase
			end
  2'b10: begin
          loc <= DUAN_1;
			 case(ms10)
			 4'b0000: num <= SEG_NUM0;
			 4'b0001: num <= SEG_NUM1;
			 4'b0010: num <= SEG_NUM2;
			 4'b0011: num <= SEG_NUM3;
			 4'b0100: num <= SEG_NUM4;
			 4'b0101: num <= SEG_NUM5;
			 4'b0110: num <= SEG_NUM6;
			 4'b0111: num <= SEG_NUM7;
			 4'b1000: num <= SEG_NUM8;
			 4'b1001: num <= SEG_NUM9;
			 endcase
			end
  2'b11: begin
          loc <= DUAN_0;
			 case(ms1)
			 4'b0000: num <= SEG_NUM0;
			 4'b0001: num <= SEG_NUM1;
			 4'b0010: num <= SEG_NUM2;
			 4'b0011: num <= SEG_NUM3;
			 4'b0100: num <= SEG_NUM4;
			 4'b0101: num <= SEG_NUM5;
			 4'b0110: num <= SEG_NUM6;
			 4'b0111: num <= SEG_NUM7;
			 4'b1000: num <= SEG_NUM8;
			 4'b1001: num <= SEG_NUM9;
			 endcase
			end
  endcase

end
   
endmodule



//test 使用代码
/*
module ms_timer(
input clk,
input inc,
input wire switch, // 1 为start， 0 为stop
input rst, // 复位，上升沿触发，异步
output reg [7:0] num, // 选择显示的数据，用parameter参数赋值
output reg [3:0] loc// 选择哪一个数码管位输出
    );
parameter  SEG_NUM0 = 8'b00000011,  // abcdefg dp
           SEG_NUM1 = 8'b10011111,
			  SEG_NUM2 = 8'b00100101,
			  SEG_NUM3 = 8'b00001101,
			  SEG_NUM4 = 8'b10011001,
			  SEG_NUM5 = 8'b01001001,
			  SEG_NUM6 = 8'b01000001,
			  SEG_NUM7 = 8'b00011111,
			  SEG_NUM8 = 8'b00000001,
			  SEG_NUM9 = 8'b00001001,
			  SEGD_NUM0 = 8'b00000010,  // 秒单位，需要小数点 abcdefg dp
           SEGD_NUM1 = 8'b10011110,
			  SEGD_NUM2 = 8'b00100100,
			  SEGD_NUM3 = 8'b00001100,
			  SEGD_NUM4 = 8'b10011000,
			  SEGD_NUM5 = 8'b01001000,
			  SEGD_NUM6 = 8'b01000000,
			  SEGD_NUM7 = 8'b00011110,
			  SEGD_NUM8 = 8'b00000000,
			  SEGD_NUM9 = 8'b00001000;

// 位选		  
parameter  DUAN_3 = 4'b0111,			  
			  DUAN_2 = 4'b1011,
			  DUAN_1 = 4'b1101,
			  DUAN_0 = 4'b1110;
			  
reg [20:0] count = 0;
reg [3:0] ms1 = 0;   // 毫秒单位
reg [3:0] ms10 = 0; // 10毫秒单位
reg [3:0] ms100 = 0; // 100毫秒单位
reg [3:0] s1 = 0; // 1秒单位

reg cen = 0;
integer fsm = 1; //判断状态,一开始为停止状态

// 扫描位选
always @ (posedge clk) begin
   count <= count + 1'b1;	
end

always @ (posedge clk or posedge rst) begin
if (rst) begin
fsm = 1;
cen = 0;
end
else begin
 case(fsm)
    0: begin // 在start的自加状态下	  
	    cen = 1;
	    if(!switch)// 触发stop
		 fsm = 1;
		 else	
		  fsm = 0;
	    end
	 1: begin  // stop状态
	    cen = 0;
	    if(switch) //触发start
		 fsm = 0;
       else if(inc) 
		 fsm = 2;
		 else
		 fsm = 1;
       end		 
	 2: begin
	    cen = 1;
	    fsm = 3;
		 end
	  3: begin
	    cen = 0;
		 if(inc)
		 fsm = 3;
		 else
		 fsm = 1;
	   end
 endcase
end

end

always @ (posedge clk) begin 
if(!rst) begin
if(cen) begin
case(ms1)
	 4'b1001: ms1 <= 4'b0000;
	 default:  ms1 <= ms1 + 1'b1;
	 endcase
	 
	 case(ms10)
	 4'b1001: begin
	           if(ms1 == 4'b1001)
	             ms10 <= 4'b0000;
				 end
	 default: begin
    	       if(ms1 == 4'b1001)
	             ms10 <= ms10 + 1'b1;
				 end
	 endcase
	 
	 case(ms100)
	 4'b1001: begin
	           if(ms1 == 4'b1001 && ms10 == 4'b1001)
	             ms100 <= 4'b0000;
				 end
	 default: begin
    	       if(ms1 == 4'b1001 && ms10 == 4'b1001)
	             ms100 <= ms100 + 1'b1;
				 end
	 endcase
	 
	 case(s1)
	 4'b1001: begin
	           if(ms1 == 4'b1001 && ms10 == 4'b1001 && ms100 == 4'b1001)
	             s1 <= 4'b0000;
				 end
	 default: begin
    	       if(ms1 == 4'b1001 && ms10 == 4'b1001 && ms100 == 4'b1001)
	             s1 <= s1 + 1'b1;
				 end
	 endcase
end
end

else begin
ms1 <= 0;
ms100 <= 0;
ms10 <= 0;
s1 <= 0;
end
end

// 扫描显示
always @ (posedge clk) begin
  case(count[2:1])
  2'b00: begin
          loc <= DUAN_3;
			 case(s1)
			 4'b0000: num <= SEGD_NUM0;
			 4'b0001: num <= SEGD_NUM1;
			 4'b0010: num <= SEGD_NUM2;
			 4'b0011: num <= SEGD_NUM3;
			 4'b0100: num <= SEGD_NUM4;
			 4'b0101: num <= SEGD_NUM5;
			 4'b0110: num <= SEGD_NUM6;
			 4'b0111: num <= SEGD_NUM7;
			 4'b1000: num <= SEGD_NUM8;
			 4'b1001: num <= SEGD_NUM9;
			 endcase
			end
	
  2'b01: begin
          loc <= DUAN_2;
			 case(ms100)
			 4'b0000: num <= SEG_NUM0;
			 4'b0001: num <= SEG_NUM1;
			 4'b0010: num <= SEG_NUM2;
			 4'b0011: num <= SEG_NUM3;
			 4'b0100: num <= SEG_NUM4;
			 4'b0101: num <= SEG_NUM5;
			 4'b0110: num <= SEG_NUM6;
			 4'b0111: num <= SEG_NUM7;
			 4'b1000: num <= SEG_NUM8;
			 4'b1001: num <= SEG_NUM9;
			 endcase
			end
  2'b10: begin
          loc <= DUAN_1;
			 case(ms10)
			 4'b0000: num <= SEG_NUM0;
			 4'b0001: num <= SEG_NUM1;
			 4'b0010: num <= SEG_NUM2;
			 4'b0011: num <= SEG_NUM3;
			 4'b0100: num <= SEG_NUM4;
			 4'b0101: num <= SEG_NUM5;
			 4'b0110: num <= SEG_NUM6;
			 4'b0111: num <= SEG_NUM7;
			 4'b1000: num <= SEG_NUM8;
			 4'b1001: num <= SEG_NUM9;
			 endcase
			end
  2'b11: begin
          loc <= DUAN_0;
			 case(ms1)
			 4'b0000: num <= SEG_NUM0;
			 4'b0001: num <= SEG_NUM1;
			 4'b0010: num <= SEG_NUM2;
			 4'b0011: num <= SEG_NUM3;
			 4'b0100: num <= SEG_NUM4;
			 4'b0101: num <= SEG_NUM5;
			 4'b0110: num <= SEG_NUM6;
			 4'b0111: num <= SEG_NUM7;
			 4'b1000: num <= SEG_NUM8;
			 4'b1001: num <= SEG_NUM9;
			 endcase
			end
  endcase

end
   
endmodule
*/
