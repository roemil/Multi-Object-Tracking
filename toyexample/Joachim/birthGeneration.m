% Function to generate a somewhat like Poisson arrival
function birthVec = birthGeneration(Pb, nbrTimeSteps)

birthVec = zeros(1,nbrTimeSteps);
%figure(2);
%hold on
%plot(0,nbrBirths,'o')
for i = 2:nbrTimeSteps
    birth = unifrnd(0,1);
    if birth <= Pb
        birthVec(i) = birthVec(i-1)+1;
        %figure(2);
        %plot(i,nbrBirths,'o')
    else
        birthVec(i) = birthVec(i-1);
    end
end