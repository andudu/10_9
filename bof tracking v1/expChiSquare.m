function similarity = expChiSquare(X1, X2, length, sigma)

if size(X1,1) == 1
    X1 = X1(:);
end

if size(X2,1) == 1
    X2 = X2(:);
end

if ((size(X1,1)==length)&&(size(X2,1)==length))
    similarity = sum( ((X1-X2).^2)./(X1+X2+0.0001) );
    similarity = exp(-similarity/sigma);
end
