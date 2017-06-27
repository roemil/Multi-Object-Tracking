function ans = isinside(Xest,GT)
ans = 0;
for i = 1 : size(GT,2)
    x1 = GT(1) - GT(4)*0.5;
    y1 = GT(2) - GT(5)*0.5;
    x2 = x1 + GT(4);
    y2 = y1 + GT(5);

    if(((Xest(1) > x1) && (Xest(1) < x2)) && ((Xest(2) > y1) && (Xest(2) < y2)) && GT(6,i) == -1)
        ans = 1;
    else
        ans = 0;
    end
end

end