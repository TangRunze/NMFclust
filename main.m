
%% Parameter Setting for Simulation

maxIter = 1000;

lambdaVec = [0.001, 0.01, 0.1, 0.2, 0.3, 0.4, 0.5, 0.7, 1];

nCore = 12;

delete(gcp('nocreate'))
parpool(nCore);

%% Generate Data

% Set parameters
n = 10;
kappa = 2;
m = 5;
rho = 2;

r = 2;
T = n;

n2 = n*n;

% --- Generate poisson parameter matrix ---
poissonCol1 = kappa*ones(n, n);
% Xcol1(1:(n+1):n^2) = [];
poissonCol1 = reshape(poissonCol1, 1, n2);
poissonCol1 = poissonCol1';

poissonCol2 = kappa*ones(n, n);
poissonCol2((n-m+1):n, (n-m+1):n) = rho*kappa*ones(m, m);
% Xcol2(1:(n+1):n^2) = [];
poissonCol2 = reshape(poissonCol2, 1, n2);
poissonCol2 = poissonCol2';

poissonBase = [poissonCol1, poissonCol2];

% --- Generate poisson matrix ---

H = [repmat([1; 0], 1, T/2), repmat([0; 1], 1, T/2)];
poissonMatrix = poissonBase*H;

%% Simulation

parfor iIter = 1:maxIter
    
    loadFile = ['./data/data-NMFclust-kappa' num2str(kappa) '-rho' ...
        num2str(rho) '-n' num2str(n) '-r' num2str(r) '-T' num2str(T) ...
        '-N' num2str(n2) '-graph' num2str(iIter) '.mat'];
    
    if exist(loadFile, 'file') == 0
        % Generate noisy data using poisson dist
        G = poissrnd(poissonMatrix);
        N = sum(G);
        X = G/diag(sum(G));
        
        parsavedata(loadFile, poissonBase, H, G, N, X);
    else
        load(loadFile);
    end
    
    for iLambda = 1:length(lambdaVec);
        lambda = lambdaVec(iLambda);
        
        saveFile = ['./results/results-NMFclust-kappa' num2str(kappa) ...
            '-rho' num2str(rho) '-n' num2str(n) '-r' num2str(r) '-T' ...
            num2str(T) '-N' num2str(n2) '-graph' num2str(iIter) ...
            '-lambda' num2str(lambda) '.mat'];
        
        if exist(saveFile, 'file') == 0
            % Solve the Optimization Problem
            [wHat, hHat] = nmfnormalize(X, n2, r, T, lambda);
            
            % Calculate -loglikelihood
            xHat = wHat*hHat;
            l = 0;
            for t = 1:T
                % l = l - log(factorial(N(t)));
                for i = 1:N(t)
                    l = l - log(i);
                end
                for i = 1:n2
                    l = l + log(factorial(G(i,t))) - G(i,t)*log(xHat(i,t));
                end
            end
            
            parsaveresult(saveFile, poissonBase, H, G, N, X, wHat, hHat,...
                l);
        end
        
    end
end