function gaussMix = generateGaussianMix(w, mu, sigma)

gaussMix = @(x) 0;

if iscell(sigma)
    for i = 1:size(w,2)
        gaussMix = @(x) gaussMix(x)+w(i)*mvnpdf(x, mu(:,i), sigma{i});
    end
else
    for i = 1:size(w,2)
        gaussMix = @(x) gaussMix(x)+w(i)*mvnpdf(x, mu(i), sigma(i));
    end
end