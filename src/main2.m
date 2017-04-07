% Main for running the filter multiple times. Each filter-call uses whole
% sequences

load('case3')
sigmaR = 0.01;
R = sigmaR*eye(2);
clear Z

K = 20; %size(X,2);
T = 30;

maxObj = 0;
for k = 2:K
    if size(X{k},2) > maxObj
        maxObj = size(X{k},2);
    end
end

PestVec = zeros(4,K,maxObj,T);
squareError = zeros(4,K,maxObj,T);

% Run the whole sequence T times to find averages
for t = 1:T
    for k = 1:K
        Z{k} = [];
        for i = 1:size(X{k},2)
            Z{k} = [Z{k}, measGenerate(X{k}(:,i),R)];
        end
    end
    
    [~, ~, est{t}, Pest{t}] = PMBM(Z);
    
    [PestVec(:,:,:,t), squareError(:,:,:,t)] = generateSE(X, est{t}, Pest{t}, K);
end

PestAvg = mean(PestVec,4);
MSE = mean(squareError,4);

plotStates(Z, X, est{t}, Pest{t});
plotMSE(PestAvg,MSE,K);
