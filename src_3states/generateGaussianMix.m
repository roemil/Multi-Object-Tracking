function gaussMix = generateGaussianMix(x, w, mu, sigma)

gaussMix = 0;

if iscell(sigma)
    for i = 1:size(w,2)
        gaussMix = gaussMix+w(i)*mvnpdf(x, mu(:,i), sigma{i});
    end
else
    for i = 1:size(w,2)
        gaussMix = gaussMix+w(i)*mvnpdf(x, mu(i), sigma(i));
    end
end