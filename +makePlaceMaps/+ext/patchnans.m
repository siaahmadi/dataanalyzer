function Z = patchnans(Z0,boxSize,sigma)
% Convolve Z0 with a gaussian of size boxSize, but only on the NaN elements
% The normalization is with respect to the neighboring elements of the
% element the convolution window is centered on.

if isscalar(boxSize)
    boxSize = [boxSize boxSize];
end
Z = Z0;
box0 = fspecial('gaussian',boxSize,sigma);
rBox = (boxSize-1)/2;
[iNan, jNan] = find(isnan(Z0));

nNan = length(iNan);
trys = 0;
while nNan > 0 && trys<=100
    trys = trys+1;
    for n = 1:nNan
        [i, j] = dataanalyzer.makePlaceMaps.ext.neighsubs(size(Z0),iNan(n),jNan(n),rBox);
        indZ = sub2ind(size(Z0),i,j);
        iBox = i - iNan(n)+rBox(1)+1;
        jBox = j - jNan(n)+rBox(2)+1;
        indBox = sub2ind(boxSize,iBox,jBox);
        Z(iNan(n),jNan(n)) = nansum(box0(indBox)/nansum(box0(indBox)).*Z0(indZ));
    end
    [iNan, jNan] = find(isnan(Z));    
    nNan = length(iNan);
    Z0 = Z;
end