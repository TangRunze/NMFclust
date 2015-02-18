close all
clear all

%% --- Simulation ---

% Parameter Setting
maxIter = 1000;
lambdaVec = [0.001, 0.01, 0.1, 0.2, 0.3, 0.4, 0.5, 0.7, 1];

n = 10;
p = 0.1;
m = 5;
q = 0.9;
r = 2;
T = n;
n2 = n*n;

ind = [];
for iIter = 1:maxIter
    flag = true;
    for iLambda = 1:length(lambdaVec)
        lambda = lambdaVec(iLambda);
        if ~exist(['./results/results-NMFclust-p' num2str(p) '-q' ...
                num2str(q) '-n' num2str(n) '-r' num2str(r) '-T' num2str(T) ...
                '-N' num2str(n2) '-graph' num2str(iIter) '-lambda' ...
                num2str(lambda) '.mat'])
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
diffXnoise = zeros(length(lambdaVec), maxIter);
diffX = zeros(length(lambdaVec), maxIter);

hStar = [ones(1, T/2), 2*ones(1, T/2)];

for iInd = 1:maxIter
    iIter = ind(iInd);
    for iLambda = 1:length(lambdaVec)
        lambda = lambdaVec(iLambda);
        load(['./results/results-NMFclust-p' num2str(p) '-q' ...
            num2str(q) '-n' num2str(n) '-r' num2str(r) '-T' num2str(T) ...
            '-N' num2str(n2) '-graph' num2str(iIter) '-lambda' ...
            num2str(lambda) '.mat']);
        X = W*H;
        hClust = 2 - (hHat(1, :) >= 0.5);
        errorRate(iLambda, iInd) = min(sum(hClust ~= hStar), ...
            sum(3 - hClust ~= hStar))/T;
        diffXnoise(iLambda, iInd) = norm(Xnoise - wHat*hHat, 'fro');
        diffX(iLambda, iInd) = norm(X - wHat*hHat, 'fro');
    end
end

errorMean = mean(errorRate, 2)';
% errorCIASGE = [errorMean - 1.96*std(errorRate)/sqrt(maxIter), ...
%     errorMean + 1.96*std(errorRate)/sqrt(maxIter)];
errorMedian = median(errorRate, 2)';

diffXnoiseMean = mean(diffXnoise, 2)';
diffXnoiseMedian = median(diffXnoise, 2)';

diffXMean = mean(diffX, 2)';
diffXMedian = median(diffX, 2)';

