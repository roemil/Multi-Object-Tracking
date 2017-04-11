v = zeros(1,size(Amat,3));
q = zeros(1,size(Amat,3));
for ic = 1:size(Amat,3)
    for jc = 1:size(Amat2,3)
        if sum(Amat(1,:,ic) == Amat2(1,:,jc)) == size(Amat,2)
            v(ic) = 1;
        end
        if ((sum(Amat(1,:,ic) == Amat(1,:,jc)) == size(Amat,2)) && (ic ~= jc))
            q(ic) = 1;
            keyboard;
        end
    end
end
