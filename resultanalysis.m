close all
clear all

%% --- Simulation ---

% Parameter Setting
maxIter = 1000;
lambdaVec = [0.001, 0.01, 0.1, 0.2, 0.3, 0.4, 0.5, 0.7, 1];

n = 10;
kappa = 2;
m = 5;
rho = 2;
r = 2;
T = n;
n2 = n*n;

ind = [];
for iIter = 1:maxIter
    flag = true;
    for iLambda = 1:length(lambdaVec)
        lambda = lambdaVec(iLambda);
        if ~exist(['./results/results-NMFclust-kappa' num2str(kappa) ...
            '-rho' num2str(rho) '-n' num2str(n) '-r' num2str(r) '-T' ...
            num2str(T) '-N' num2str(n2) '-graph' num2str(iIter) ...
            '-lambda' num2str(lambda) '.mat'])
            flag = false;
            break;
        end
    end
    if flag
        ind = [ind iIter];
    end
end

maxIter = length(ind);

errorRate = zeros(length(lambdaVec), maxIter);
loglik = zeros(length(lambdaVec), maxIter);

for iInd = 1:maxIter
    iIter = ind(iInd);
    for iLambda = 1:length(lambdaVec)
        lambda = lambdaVec(iLambda);
        load(['./results/results-NMFclust-kappa' num2str(kappa) ...
            '-rho' num2str(rho) '-n' num2str(n) '-r' num2str(r) '-T' ...
            num2str(T) '-N' num2str(n2) '-graph' num2str(iIter) ...
            '-lambda' num2str(lambda) '.mat']);
        hStar = 2 - (H(1, :) == 1);
        hClust = 2 - (hHat(1, :) >= 0.5);
        errorRate(iLambda, iInd) = min(sum(hClust ~= hStar), ...
            sum(3 - hClust ~= hStar))/T;
        loglik(iLambda, iInd) = l;
    end
end

errorMean = mean(errorRate, 2)';
% errorCIASGE = [errorMean - 1.96*std(errorRate)/sqrt(maxIter), ...
%     errorMean + 1.96*std(errorRate)/sqrt(maxIter)];
errorMedian = median(errorRate, 2)';

loglikMean = mean(loglik, 2)';
loglikMedian = median(loglik, 2)';

errorL = zeros(1, size(loglik, 2));
posVec = zeros(1, size(loglik, 2));
for i = 1:size(loglik, 2)
    [~, pos] = min(loglik(:, i));
    errorL(i) = errorRate(pos, i);
    posVec(i) = pos;
end

errorLMean = mean(errorL);
errorLMedian = median(errorL);