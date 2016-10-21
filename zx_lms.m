function [yn err] = zx_lms(xn, dn, param)
% x        输入信号
% dn       期望输出
% param    Structure for using LMS, must include at least
%          .w        - 初始化权值
%          .u        - 学习率
%          .M        - 滤波器阶数
%          .max_iter - 最大迭代次数
%          .min_err  - 迭代最小误差
%
% y        经过滤波器后的输出信号
% error    误差输出

W = param.w;  % 初始权值
M = param.M;  % 滤波器阶数

if length(W) ~= M
    error('param.w的长度必须与滤波器阶数相同.\n');
end
if param.max_iter > length(xn) || param.max_iter < M
    error('迭代次数太大或太小，M<=max_iter<=length(xn)\n');    
end

iter  = 0;
for k = M:param.max_iter
    x    = xn(k:-1:k-M+1);   % 滤波器M个抽头的输入
    y    = W.*x;
    err  = dn(k) - y;
    
    % 更新滤波器权值系数
    W = W + 2*param.u*x;
    %W = W + param.u*err.*x;
    iter = iter + 1;    
    if (abs(err) < param.min_err); break; end
end

% 求最优时滤波器的输出序列
yn = inf * ones(size(xn));
for k = M:length(xn)
    x = xn(k:-1:k-M+1);
    yn(k) = W(:,end).'* x;
end

end