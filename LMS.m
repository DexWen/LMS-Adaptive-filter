function [test_targets, a, updates] = LMS(train_patterns, train_targets, test_patterns, params)

% Classify using the least means square algorithm(LMS)
% Inputs:
% 	train_patterns	- Train patterns
%	train_targets	- Train targets
%   test_patterns   - Test  patterns
%	param		    - [Maximum iteration Theta (Convergence criterion), Convergence rate]
%
% Outputs
%	test_targets	- Predicted targets
%   a               - Weights vector
%   updates         - Updates throughout the learning iterations
%
% NOTE: Suitable for only two classes
%

[c, n]          		= size(train_patterns);
[Max_iter, theta, eta]	= process_params(params);

y               = [train_patterns ; ones(1,n)];
train_zero      = find(train_targets == 0);

%Preprocessing
processed_patterns               = y;
processed_patterns(:,train_zero) = -processed_patterns(:,train_zero);
b                                = 2*train_targets - 1; 

%Initial weights
a               = sum(processed_patterns')';
iter  	        = 1;
k				= 0;
update	        = 1e3;
updates         = 1e3;

while ((sum(abs(update)) > theta) & (iter < Max_iter))
    iter = iter + 1;
    
    %k <- (k+1) mod n
    k = mod(k+1,n);
    if (k == 0), 
        k = n;
    end
    
    % a <- a + eta*(b-a'*Yk)*Yk'
    update  = eta*(b(k) - a'*y(:,k))*y(:,k);
    a	    = a + update;
    
    updates(iter) = sum(abs(update));
end

if (iter == Max_iter),
    disp(['Maximum iteration (' num2str(Max_iter) ') reached']);
else
    disp(['Did ' num2str(iter) ' iterations'])
end

%Classify the test patterns
test_targets = a'*[test_patterns; ones(1, size(test_patterns,2))];

test_targets = test_targets > 0;
