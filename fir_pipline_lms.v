`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:07:27 10/07/2007 
// Design Name: 
// Module Name:    fir_pipline_lms 
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
module fir_pipeline_lms (clk, x_in, d_in, e_out, y_out);

  parameter W1 = 16,   //输入信号的位宽
            W2 = 32;  //乘法器的输出位宽

  input clk;  //输入时钟
  input [W1-1:0] x_in, d_in;  //输入信号和参考信号 
  output [W2-1:0] e_out, y_out;  //误差信号和输出信号

  //声明中间变量
  reg  [W1-1:0] x, x0, x1, x2, x3, x4, f0, f1;  
  reg  [W1-1:0] d0, d1, d2, d3; 
  wire [W1-1:0] emu;
  wire [W2-1:0] p0, p1, xemu0, xemu1; //纪录乘积
  wire  [W2-1:0]  y, sxty, e, sxtd; 

  //扩展输入的参考信号
  assign  sxtd = {{16{d3[7]}}, d3};
  
  //存储数据和系数. 4级移位，补偿乘法器的流水线所带来的延迟
  always @(posedge clk) begin
      d0 <= d_in; //构成移位寄存器
      d1 <= d0;
      d2 <= d1;
      d3 <= d2;
      x0 <= x_in; 
      x1 <= x0;   
      x2 <= x1;
      x3 <= x2;
      x4 <= x3;
      f0 <= f0 + xemu0[31:16]; //相当于步长因子为1/2
      f1 <= f1 + xemu1[31:16]; 
  end

  //调用IPCore生成乘法器lmsmult时，选了最大的流水线级数3级
  //计算p(i) = f(i) * x(i); 
  // x0*f0 = p0  
  lmsmult mul1(
   .clk(clk), .a(x0), .b(f0), .q(p0));    
    // x1*f1 = p1 
  lmsmult mul2(              
   .clk(clk), .a(x1), .b(f1), .q(p1));
  
  // 计算滤波器的输出
  assign y = p0 + p1;  
  
  assign  sxty = {{15{y[15]}}, y[31:16]};

  assign e = sxtd - sxty;
  assign emu = e[16:1]; 
  
  //计算xemu(i) = emu * x(i);
  //xemu0 = emu * x0;
  lmsmult mul3(
	.clk(clk), .a(x3), .b(emu), .q(xemu0));
  //xemu1 = emu * x1;  
  lmsmult mul4(            
   .clk(clk), .a(x4), .b(emu), .q(xemu1));

  assign  y_out  = y;   
  assign  e_out  = e;

endmodule

