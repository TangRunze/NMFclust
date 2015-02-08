function [W, H] = nmfnormalize(X, n, r, T)

%% Parameter Setting
lambda = 1;

% I am using MATLAB Tensor Toolbox Version 2.5 (released Feb. 1, 2012)
% http://www.sandia.gov/~tgkolda/TensorToolbox/index-2.5.html
[wInit, hInit] = nnmf(X, r);

% Normalize the column sum
wInit = wInit/diag(sum(wInit));
hInit = hInit/diag(sum(hInit));

% Combine W and H
whInit = [reshape(wInit, n*(n-1)*r, 1); reshape(hInit, r*T, 1)];

% Construct inequality linear constraint
ineConMat = zeros(r+T, length(whInit));

% Constraints for W
for i = 1:r
    ineConMat(i, ((i-1)*n*(n-1)+1):(i*n*(n-1))) = 1;
end

% Constraints for H
for i = 1:T
    ineConMat(i+r, (n*(n-1)*r+(i-1)*r+1):(n*(n-1)*r+i*r)) = 1;
end

ineConVec = ones(r+T, 1);

%% Solve Optimization Problem

% projectoptions = optimoptions('fmincon', 'TolX', 1e-6, 'MaxIter', 10000,...
%     'MaxFunEvals', 10000);

whHat = fmincon(@(wh) nmfnormobjfun(X, wh, n, r, T, lambda), whInit, ...
    [], [], ineConMat, ineConVec, zeros(length(whInit), 1), ...
    Inf(length(whInit), 1));

wHat = whHat(1:(n*(n-1)*r), 1);
hHat = whHat((n*(n-1)*r+1):end, 1);
wHat = reshape(wHat, n*(n-1), r);
hHat = reshape(hHat, r, T);

reshape(W(:, 1), n-1, n)
reshape(W(:, 2), n-1, n)
reshape(wInit(:, 1), n-1, n)
reshape(wInit(:, 2), n-1, n)
reshape(wHat(:, 1), n-1, n)
reshape(wHat(:, 2), n-1, n)

H
hInit
hHat

end