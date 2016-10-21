`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:24:37 08/18/2007 
// Design Name: 
// Module Name:    fir_lms 
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
module fir_lms(clk, x_in, d_in, e_out, y_out, f0_out, f1_out);

  parameter W1 = 8,   // 输入信号的宽度
            W2 = 16,  // 乘法器的输出宽度2*W1
            L  = 2;   // FIR自适应滤波器的长度

  input clk;  // 输入信号的时钟
  input [W1-1:0] x_in, d_in;  // 滤波器的输入信号和参考信号
  output [W2-1:0] e_out, y_out;  // 滤波器的输出信号和误差信号
  output [W1-1:0] f0_out, f1_out;  // Results

  reg  [W1-1:0] x, x0, x1, f0, f1; // 存放系数的寄存器
  reg  [W1-1:0] d;
  wire [W1-1:0] emu;
  wire [W2-1:0] p0, p1, xemu0, xemu1; // 存放乘积的寄存器
  wire  [W2-1:0]  y, sxty, e, sxtd; 
  wire  clken, aclr;
  wire  [W2-1:0] sum;  

  assign sum=0; 
  assign aclr=0; 
  assign clken=0;

   //将输入的参考信号扩展到16比特
  assign  sxtd = {{8{d[7]}}, d};

  always @(posedge clk)  begin
      d <= d_in;    // 完成寄存器的数据采样，并存放数据 
      x0 <= x_in;   
      x1 <= x0;   // 移位
      f0 <= f0 + xemu0[15:8]; ////截位相当于乘以步长因子
      f1 <= f1 + xemu1[15:8]; 
  end

// 完成 p(i) = f(i) * x(i)的乘法计算
  mult mult_0(      //  x0*f0 = p0  
		 .clk(clk), 
		 .a(x0), 				// x_in数据输入
		 .b(f0), 				// f就是w
		 .q(p0));
 
  mult mult_1(     // x0*f0 = p0  
		 .clk(clk), 
		 .a(x1), 				// x_in 数据输入
		 .b(f1), 
		 .q(p1));
		 
  assign y = p0 + p1;  // 计算ADF的输出

  // 将y扩展到16位
  assign  sxty = { {7{y[15]}}, y[15:7]};

  assign e = sxtd - sxty;		// 参考信号 减去 y(i), y(i)=w * xn(i)
  assign emu = e[8:1];  

 // 完成 xemu(i) = emu * x(i)的计算
  mult mult_2( // Multiply  x0*f0 = p0  
		 .clk(clk), 
		 .a(x0), 
		 .b(emu), 
		 .q(xemu0));
		 
  mult mult_3( // Multiply  x0*f0 = p0  
		 .clk(clk), 
		 .a(x1), 
		 .b(emu), 
		 .q(xemu1));
		 
  assign  y_out  = y;    // 监控输出控制信
  assign  e_out  = e;
  assign  f0_out = f0;
  assign  f1_out = f1;

endmodule


