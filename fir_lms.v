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

  parameter W1 = 8,   // �����źŵĿ��
            W2 = 16,  // �˷�����������2*W1
            L  = 2;   // FIR����Ӧ�˲����ĳ���

  input clk;  // �����źŵ�ʱ��
  input [W1-1:0] x_in, d_in;  // �˲����������źźͲο��ź�
  output [W2-1:0] e_out, y_out;  // �˲���������źź�����ź�
  output [W1-1:0] f0_out, f1_out;  // Results

  reg  [W1-1:0] x, x0, x1, f0, f1; // ���ϵ���ļĴ���
  reg  [W1-1:0] d;
  wire [W1-1:0] emu;
  wire [W2-1:0] p0, p1, xemu0, xemu1; // ��ų˻��ļĴ���
  wire  [W2-1:0]  y, sxty, e, sxtd; 
  wire  clken, aclr;
  wire  [W2-1:0] sum;  

  assign sum=0; 
  assign aclr=0; 
  assign clken=0;

   //������Ĳο��ź���չ��16����
  assign  sxtd = {{8{d[7]}}, d};

  always @(posedge clk)  begin
      d <= d_in;    // ��ɼĴ��������ݲ�������������� 
      x0 <= x_in;   
      x1 <= x0;   // ��λ
      f0 <= f0 + xemu0[15:8]; ////��λ�൱�ڳ��Բ�������
      f1 <= f1 + xemu1[15:8]; 
  end

// ��� p(i) = f(i) * x(i)�ĳ˷�����
  mult mult_0(      //  x0*f0 = p0  
		 .clk(clk), 
		 .a(x0), 				// x_in��������
		 .b(f0), 				// f����w
		 .q(p0));
 
  mult mult_1(     // x0*f0 = p0  
		 .clk(clk), 
		 .a(x1), 				// x_in ��������
		 .b(f1), 
		 .q(p1));
		 
  assign y = p0 + p1;  // ����ADF�����

  // ��y��չ��16λ
  assign  sxty = { {7{y[15]}}, y[15:7]};

  assign e = sxtd - sxty;		// �ο��ź� ��ȥ y(i), y(i)=w * xn(i)
  assign emu = e[8:1];  

 // ��� xemu(i) = emu * x(i)�ļ���
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
		 
  assign  y_out  = y;    // ������������
  assign  e_out  = e;
  assign  f0_out = f0;
  assign  f1_out = f1;

endmodule


