% s11 = [1 0 0 0 0];
% s12 = [0 0 1 0 0];
% s1 = s11+s12;
% 
% s21 = [1 0 0 0 0];
% s22 = [0 1 0 0 0];
% s23 = [0 0 0 1 0];
% s2 = s21+s22+s23;
% 
% s31 = [1 0 0 0 0];
% s32 = [0 0 0 0 1];
% 
% s = [s1;s2];
% Amat = zeros(numel(find(s == 1)),2); % 2 = nbrMeas
% [row, col] = find(s == 1);
%%
function S = gatingCombs
s11 = [1 0 0 0 0 0];
s12 = [0 0 1 0 0 0];
st1 = s11+s12;

s21 = [1 0 0 0 0 0];
s22 = [0 1 0 0 0 0];
s23 = [0 0 0 1 0 0];
st2 = s21+s22+s23;

s31 = [1 0 0 0 0 0];
s32 = [0 0 0 0 1 0];
st3 = s31+s32;

s41 = [0 1 0 0 0 0];
s42 = [0 0 0 0 0 1];
st4 = s41+s42;

st = [st1;st2;st3;st4];
s1 = [s11;s12];
s2 = [s21;s22;s23];
s3 = [s31;s32];
s4 = [s41;s42];
Stmp{1,1} = s1;
Stmp{2,1} = s2;
Stmp{3,1} = s3;
Stmp{4,1} = s4;
nbrObj = 2;
nbrMeas = 4;

%indGlob = 2;
indvInd = zeros(nbrMeas,2);
for i = 1:nbrMeas
    indvInd(i,:) = [1, size(Stmp{i,1},1)];
end
%indvInd(1,1:2) = [1, size(s1,1)];
%indvInd(2,1:2) = [1, size(s2,1)];
%indvInd(3,1:2) = [1, size(s3,1)];
%indVec{1} = [1;2];
%indVec{2} = [1;2;3];
%maxInd = 3;
S = zeros(nbrMeas,(nbrObj+nbrMeas),1);
ind = 1;
while indvInd(1,1) <= indvInd(1,2)
    ind
    for z = 1:size(Stmp,1)
        S(z,1:(nbrObj+nbrMeas),ind) = Stmp{z,1}(indvInd(z,1),:);
    end
    indvInd(nbrMeas,1) = indvInd(nbrMeas,1)+1;
    for indI = nbrMeas:-1:2
        if indvInd(indI,1) > indvInd(indI,2)
            indvInd(indI,1) = 1;
            indvInd(indI-1,1) = indvInd(indI-1,1)+1;
        end
    end
    sumCol = sum(S(:,:,ind));
    if isempty(find(sumCol > 1,1))
        ind = ind+1;
    end
end
            
%%
% s1 = [s11;s12];
% s2 = [s21;s22;s23];
% ind = 1;
% for i1 = 1:size(s1,1)
%     for i2 = 1:size(s2,1)
%         [~,col1] = find(s1(i1,:) == 1);
%         [~,col2] = find(s2(i2,:) == 1);
%         if col1 ~= col2
%             S(1:2,1:4,ind) = [s1(i1,:);s2(i2,:)];
%             ind = ind+1;
%         end
%     end
% end
    