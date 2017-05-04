s11 = [1 0 0 0];
s12 = [0 0 1 0];
s1 = [s11;s12];

s21 = [1 0 0 0];
s22 = [0 1 0 0];
s23 = [0 0 0 1];
s2 = [s21;s22;s23];

ind = 1;
for i1 = 1:size(s1,1)
    for i2 = 1:size(s2,1)
        [~,col1] = find(s1(i1,:) == 1);
        [~,col2] = find(s2(i2,:) == 1);
        if col1 ~= col2
            S(1:2,1:4,ind) = [s1(i1,:);s2(i2,:)];
            ind = ind+1;
        end
    end
end
        