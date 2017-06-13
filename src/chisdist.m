function d = chisdist(h1,h2)
    d = 0.5*(h1-h2).^2./(h1+h2);
    ind = find(isnan(d(:)));
    d(ind) = 0;
    d = sum(d);
    
end