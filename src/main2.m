% Main for running the filter multiple times. Each filter-call uses whole
% sequences

%load('case3')
sigmaR = 0.01;
R = sigmaR*eye(2);
FOVsize = [20,30];
clear Z

K = 50; %size(X,2)-1;
T = 5;

maxObj = 0;
for k = 2:K
    if size(X{k},2) > maxObj
        maxObj = size(X{k},2);
    end
end

PestVec = zeros(4,K,maxObj+1,T);
squareError = zeros(4,K,maxObj,T);

% Run the whole sequence T times to find averages
for t = 1:T
    disp(['--------------- t = ', num2str(t), ' ---------------'])
    
    Z = measGenerateCase2(X, R, FOVsize, K);
    
    [~, ~, est{t}, Pest{t}] = PMBM(Z);
    
    [PestVec(:,:,:,t), squareError(:,:,:,t)] = generateSE(X, est{t}, Pest{t}, K);
end

PestAvg = mean(PestVec,4);
MSE = mean(squareError,4);

plotStates(Z, X, est{t}, Pest{t});
plotMSE(PestAvg,MSE,K);
