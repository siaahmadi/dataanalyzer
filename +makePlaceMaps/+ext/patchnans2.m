function Z = patchnans2(Z,boxSize,sigma)
% Convolve Z0 with a gaussian of size boxSize, but only on the NaN elements
% The normalization is with respect to the neighboring elements of the
% element the convolution window is centered on.

if isscalar(boxSize)
    boxSize = [boxSize boxSize];
end
box0 = fspecial('gaussian',boxSize,sigma);

iNaN = isnan(Z);
Z(iNaN) = 0;
convZ0 = conv2(Z, box0, 'same');
Z(iNaN) = convZ0(iNaN);