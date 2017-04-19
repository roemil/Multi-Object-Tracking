function [Atot, Stot] = generateAtot(maxNbrOldTargets, maxNbrMeas)

nbrOldTargets = 1:maxNbrOldTargets;
nbrMeas = 1:maxNbrMeas;

Atot = cell(maxNbrOldTargets, maxNbrMeas);
Stot = cell(maxNbrOldTargets, maxNbrMeas,1);

for t = 1:maxNbrOldTargets
    for m = 1:maxNbrMeas
        disp('-------------------')
        disp(['Nbr old targets: ', num2str(t)])
        disp(['Nbr measurements: ', num2str(m)])
        [S, Atot{t, m}] = generateGlobalIndTest(m,t);
        for i = 1:size(S,3)
               Stot{t, m, i} = S(:,:,i);
        end
    end
end