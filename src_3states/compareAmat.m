v = zeros(1,size(Amat,1));
%q = zeros(1,size(Amat,3));
for ic = 1:size(Amat,1)
    for jc = 1:size(Amat2,1)
        if sum(Amat(ic,:) == Amat2(jc,:)) == size(Amat,2)
            v(ic) = 1;
        end
        %if ((sum(Amat(1,:,ic) == Amat(1,:,jc)) == size(Amat,2)) && (ic ~= jc))
        %    q(ic) = 1;
        %    keyboard;
        %end
    end
end

%%
% count = 0;
% for ic = 1:size(Amat,1)
%     for jc = 1:size(Amat2,1)
%         if ismember(Amat(ic,:),Amat2(jc,:),'rows')
%             count = count+1;
%         end
%     end
% end
count = sum(ismember(Amat,Amat2,'rows'));

disp(['True: ', num2str(count == size(Amat,1))])