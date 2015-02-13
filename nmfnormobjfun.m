function val = nmfnormobjfun(X, WH, n, r, T, lambda)
% Objective functions in NMF normalization problem

%% Pre-calculation
X = reshape(X, n*(n-1), T);
W = WH(1:(n*(n-1)*r), 1);
H = WH((n*(n-1)*r+1):end, 1);
W = reshape(W, n*(n-1), r);
H = reshape(H, r, T);

% Version 1: max of the col sum.
% val = norm(X - W*H, 'fro') + lambda*norm(H, 1);

% Version 2: sum of the col sum.
% val = norm(X - W*H, 'fro') + lambda*sum(sum(H));

% Version 3: sum of the col sum except the last one.
val = norm(X - W*H, 'fro') + lambda*sum(sum(H(1:(end-1), :)));

% Version 4 : Frobenius norm.
% val = norm(X - W*H, 'fro') + lambda*norm(H, 'fro');
end