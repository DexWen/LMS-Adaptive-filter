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

  parameter W1 = 16,   //�����źŵ�λ��
            W2 = 32;  //�˷��������λ��

  input clk;  //����ʱ��
  input [W1-1:0] x_in, d_in;  //�����źźͲο��ź� 
  output [W2-1:0] e_out, y_out;  //����źź�����ź�

  //�����м����
  reg  [W1-1:0] x, x0, x1, x2, x3, x4, f0, f1;  
  reg  [W1-1:0] d0, d1, d2, d3; 
  wire [W1-1:0] emu;
  wire [W2-1:0] p0, p1, xemu0, xemu1; //��¼�˻�
  wire  [W2-1:0]  y, sxty, e, sxtd; 

  //��չ����Ĳο��ź�
  assign  sxtd = {{16{d3[7]}}, d3};
  
  //�洢���ݺ�ϵ��. 4����λ�������˷�������ˮ�����������ӳ�
  always @(posedge clk) begin
      d0 <= d_in; //������λ�Ĵ���
      d1 <= d0;
      d2 <= d1;
      d3 <= d2;
      x0 <= x_in; 
      x1 <= x0;   
      x2 <= x1;
      x3 <= x2;
      x4 <= x3;
      f0 <= f0 + xemu0[31:16]; //�൱�ڲ�������Ϊ1/2
      f1 <= f1 + xemu1[31:16]; 
  end

  //����IPCore���ɳ˷���lmsmultʱ��ѡ��������ˮ�߼���3��
  //����p(i) = f(i) * x(i); 
  // x0*f0 = p0  
  lmsmult mul1(
   .clk(clk), .a(x0), .b(f0), .q(p0));    
    // x1*f1 = p1 
  lmsmult mul2(              
   .clk(clk), .a(x1), .b(f1), .q(p1));
  
  // �����˲��������
  assign y = p0 + p1;  
  
  assign  sxty = {{15{y[15]}}, y[31:16]};

  assign e = sxtd - sxty;
  assign emu = e[16:1]; 
  
  //����xemu(i) = emu * x(i);
  //xemu0 = emu * x0;
  lmsmult mul3(
	.clk(clk), .a(x3), .b(emu), .q(xemu0));
  //xemu1 = emu * x1;  
  lmsmult mul4(            
   .clk(clk), .a(x4), .b(emu), .q(xemu1));

  assign  y_out  = y;   
  assign  e_out  = e;

endmodule

