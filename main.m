
%% Parameter Setting for Simulation

maxIter = 100;

lambdaVec = [0.001, 0.01, 0.1, 0.5 1];

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

n2 = n*n;

% Generate data
Xcol1 = p*ones(n, n);
% Xcol1(1:(n+1):n^2) = [];
Xcol1 = reshape(Xcol1, 1, n2);
Xcol1 = Xcol1';

Xcol2 = p*ones(n, n);
Xcol2((n-m+1):n, (n-m+1):n) = q*ones(m, m);
% Xcol2(1:(n+1):n^2) = [];
Xcol2 = reshape(Xcol2, 1, n2);
Xcol2 = Xcol2';

W = [Xcol1, Xcol2];
H = [repmat([1; 0], 1, T/2), repmat([0; 1], 1, T/2)];

% Normalize data
Wnorm = W/diag(sum(W));
Hnorm = H/diag(sum(H));

X = Wnorm*Hnorm;

%% Simulation

for iIter = 1:maxIter
    
    loadFile = ['./data/data-NMFclust-p' num2str(p) '-q' ...
        num2str(q) '-n' num2str(n) '-r' num2str(r) '-T' num2str(T) ...
        '-N' num2str(n2) '-graph' num2str(iIter) '.mat'];
    
    if exist(loadFile, 'file') == 0
        % Generate noisy data using adjacency matrix
        Wnoise = reshape(binornd(ones(1, n2*r), ...
            reshape(W, 1, n2*r)), n2, r);
        Wnoise = Wnoise/diag(sum(Wnoise));
        Xnoise = Wnoise*Hnorm;
        
        parsavedata(loadFile, W, H, Wnoise, Xnoise);
    else
        load(loadFile);
    end
    
    for iLambda = 1:length(lambdaVec);
        lambda = lambdaVec(iLambda);
        
        saveFile = ['./results/results-NMFclust-p' num2str(p) '-q' ...
            num2str(q) '-n' num2str(n) '-r' num2str(r) '-T' num2str(T) ...
            '-N' num2str(n2) '-graph' num2str(iIter) '-lambda' ...
            num2str(lambda) '.mat'];
        
        if exist(saveFile, 'file') == 0
            % Solve the Optimization Problem
            [wHat, hHat] = nmfnormalize(Xnoise, n2, r, T, lambda);
            
            parsaveresult(saveFile, W, H, Wnoise, Xnoise, wHat, hHat)
        end
        
    end
end