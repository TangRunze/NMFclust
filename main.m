
%% Generate Data

% Model: http://www.cis.jhu.edu/~parky/CEP-Publications/PCP-JCGS-2010.pdf
% See Figure 1 on Page 2, and Section 3 on Page 14.
% We change the parameters.

% Set parameters
n = 10;
p = 0.1;
m = 5;
q = 0.9;

r = 2;
T = n;

% Generate data
Xcol1 = p*ones(n, n);
Xcol1(1:(n+1):n^2) = [];
Xcol1 = Xcol1';

Xcol2 = p*ones(n, n);
Xcol2((n-m+1):n, (n-m+1):n) = q*ones(m, m);
Xcol2(1:(n+1):n^2) = [];
Xcol2 = Xcol2';

W = [Xcol1, Xcol2];
H = [repmat([1; 0], 1, T/2), repmat([0; 1], 1, T/2)];

% Normalize data
W = W/diag(sum(W));
H = H/diag(sum(H));

X = W*H;

%% Solve the Optimization Problem
lambda = 0.04;

[wHat, hHat] = nmfnormalize(X, n, r, T, lambda);

hHat



%% Result Analysis
hClust = (hHat >= 0.5);


