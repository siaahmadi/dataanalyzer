function y = gsmooth(x,boxSize,sigma,method)
% GSMOOTH   Smooth 1D or 2D data with Gaussian boxcar
%
% Y = GSMOOTH(X,BOXSIZE,SIGMA). 
%
%       BOXSIZE can be 1x2 vector giving the number of rows and columns of 
%       the boxcar or a scalar giving both dimensions. If X in NxM, 
%       BOXSIZE(1) cannot be greater than N and BOXSIZE(2) cannot be 
%       greater than M. For adaptability, if either dimension exceeds its 
%       maximum, it will be set to its maximum without warning.
%
%       SIGMA is the standard deviation of the gaussian in samples or
%       pixels.
%
% Y = GSMOOTH(X,BOXSIZE) uses the default SIGMA of 1 (sample or pixel).
%
% Y = GSMOOTH(X) uses the default BOXSIZE of (at most) [5 5].
%
% See also CONV2, FSPECIAL

if nargin<3 || isempty(sigma)
    sigma = 1;
end
if nargin<2 || isempty(boxSize)
    boxSize = [5 5];
end
if isscalar(boxSize)
    boxSize = [boxSize boxSize];
end
if ~exist('method', 'var') || isempty(method)
	method = 'sia';
end

boxSize = [min(size(x,1),boxSize(1)) min(size(x,2),boxSize(2))];
box = fspecial('gaussian',boxSize,sigma);

% x = inpaint_nans(x);

if strcmpi(method, 'chris')
	x(isnan(x)) = 0;
	x = dataanalyzer.makePlaceMaps.ext.patchnans(x,boxSize,sigma); % very inefficient implementation by Chris of conv2 of NaNs
else
	x = dataanalyzer.makePlaceMaps.ext.patchnans2(x,boxSize,sigma);
end
y = conv2(x,box,'same');