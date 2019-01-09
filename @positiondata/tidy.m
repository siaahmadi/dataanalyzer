function tidy(obj)

% Siavash Ahmadi
% 12/11/2014
% linear interpolation using intset2int and linspace

% Modified 11/9/2015 @author Sia
% Changed completely to instead of using linspace and intervals use interp1
% and the spline method to carry out the objective.

x = obj.getX('unrestr'); x(x==0) = NaN;
y = obj.getY('unrestr'); y(y==0) = NaN;

if isnan(x(1)) % this will reduce ridicuolous values introduced by interpolation
	x(1) = x(find(isfinite(x), 1));
end
if isnan(y(1)) % this will reduce ridicuolous values introduced by interpolation
	y(1) = y(find(isfinite(y), 1));
end

idx = find(isnan(x));
X = x;
Y = y;
X(idx) = interp1(find(~isnan(x)), x(~isnan(x)), idx, 'pchip');
Y(idx) = interp1(find(~isnan(y)), y(~isnan(y)), idx, 'pchip');

if any(abs(X-500)>500) || any(abs(Y-500)>500) % interpolation method is introducing outliers
	X = x;
	Y = y;
	%%% These will ensure that the 'linear' interpolation method doesn't
	%%% degenerate due to NaN values at the beginning and end of the arrays
	X(1) = X(find(isfinite(X), 1));
	X(end) = X(find(isfinite(X), 1, 'last'));
	Y(1) = Y(find(isfinite(Y), 1));
	Y(end) = Y(find(isfinite(Y), 1, 'last'));
	%%%
	idx = find(isnan(X));
	X(idx) = interp1(find(~isnan(X)), X(~isnan(X)), idx, 'linear');
	Y(idx) = interp1(find(~isnan(Y)), Y(~isnan(Y)), idx, 'linear');
end

x = X;
y = Y;

smoothingWindow = 15;
kernel = ones(1, smoothingWindow) / smoothingWindow;

obj.X = conv(x, kernel, 'same'); % MATLAB's @smooth function cannot handle some inputs for some reason (takes forever)
obj.Y = conv(y, kernel, 'same');