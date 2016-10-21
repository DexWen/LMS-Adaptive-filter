clear all;
clc;
close all;

fs = 44100;
% x = wavread('b.wav');
t = -5*pi:pi/100:5*pi;
x = sin(t);
x = x(:);
sx = size(x,1);

subplot(2,2,1);
plot(x);axis([0 sx -1 1]);

% ԭ�ź�FFT
xf = fft(x,1024);
subplot(2,2,3);
plot(abs(xf));

% ��Ӹ�˹����
t = 0 : 1/fs : (sx-1)/fs;
noise = 0.2*randn(size(x));  % ��ֵΪ0������Ϊ0.5�ı�׼��̬����
x1 = x + noise;
subplot(2,2,2);
plot(x1);axis([0 sx -1 1]);

% �źż��������FFT
xf = fft(x1,1024);
subplot(2,2,4);
plot(abs(xf));

% LMS����Ӧ�˲�
param.M        = 50;
param.w        = ones(param.M, 1) * 0.1;
param.u        = 0.1;
param.max_iter = 100;
param.min_err  = 0.5;

[yn err] = zx_lms(x1(:,1), x(:,1), param);

figure,
plot(yn)

ynf = fft(yn(param.M:end), 1024);
figure,
plot(abs(ynf));