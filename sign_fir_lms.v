`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:31:41 08/25/2007 
// Design Name: 
// Module Name:    sign_fir_lms 
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
module sign_fir_lms(clk, reset, x_in, d_in, y_out);

  parameter W1 = 8,   // 输入信号的宽度
            W2 = 16,  // 乘法器的输出宽度2*W1
				lamda = 8;// //步长因子为2的(lamda-1)次方的倒数

  input clk;  // 输入信号的时钟
  input reset;
  input [W1-1:0] x_in, d_in;  // 滤波器的输入信号和参考信号
  output [W2-1:0] y_out;  // 滤波器的输出信号
  
  reg [2*W1-1:0] x_t, f_t, d_t;
  wire [2*W2-1:0] q1, q2;
  //参考信号的移位寄存器输出，以弥补乘法器的时延
  wire [W1-1:0] d_i;     
  wire [2*W1-1:0] fir_out, e_t;
  
  always @(posedge clk) begin
     if(!reset) begin
		  x_t <= 0;
		  f_t <= 0;
	  end
	  else begin
	     x_t[15:0] <= {x_t[7:0], x_in};
		  d_t[15:0] <= {{8{d_i[7]}}, d_i};
		  // 完成误差符号LMS算法的系数更新
		  f_t[W1-1:0] <= f_t[W1-1:0] + {{9{e_t[15]}}, x_t[7:1]};
		  f_t[2*W1-1:W1] <= f_t[2*W1-1:W1] + {{9{e_t[15]}}, x_t[15:9]};  
	  end
  end
  
  assign fir_out = q1 + q2;
  assign y_out = (!reset) ? 0 : fir_out ;
  assign e_t = fir_out - d_t;
  
  // 调用Xilinx公司乘法器的IpCore,完成 p(i)=f(i)*x(i)的乘法计算
  mult mult_0(      //  x0*f0 = p0  
		 .clk(clk), 
		 .a(x_t[2*W1-1:W1]), 
		 .b(f_t[2*W1-1:W1]), 
		 .q(q1));
 
  mult mult_1(     // x0*f0 = p0  
		 .clk(clk), 
		 .a(x_t[W1-1:0]), 
		 .b(f_t[W1-1:0]), 
		 .q(q2));
  
  // 调用基于SRL16的移位寄存器
  shiftreg4 shiftreg4(
		 .clk(clk), 
		 .d(d_in), 
		 .q(d_i));	 
		 
endmodule
