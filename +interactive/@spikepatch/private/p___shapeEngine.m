function [x_dflt, y_dflt] = p___shapeEngine(shape, x, y)

% Make a rectangle
rect.x = [1/2, 1/2, -1/2, -1/2, 1/2];
rect.y = [-1/2, 1/2, 1/2, -1/2, -1/2];

% Make a star
star.x = [0.1753, 0.8736, 0.9994, 0.2875, 0.7478, 0.4126, 0.0031, -0.4120, -0.7416, -0.2869, -0.9994, -0.8730, -0.1753, -0.2076, 0.2076, 0.1753];
star.y = [0.2113, 0.4622, 0.0731, -0.1252, -0.7119, -0.9486, -0.3364, -0.9486, -0.7119, -0.1245, 0.0737, 0.4616, 0.2113, 0.9498, 0.9498, 0.2113];

% Make a circle
res = 10;
if exist('circ_res', 'var') && circ_res >= 1 % let's not implement this actually---will be a pain in the butt
	res = circ_res;
end
circ.x = linspace(-.5,.5, 2+res); % unit diameter (the 2 is for the ends)
circ.y = [-sqrt(0.25 - circ.x.^2) sqrt(0.25 - circ.x.^2)];
circ.x = [circ.x fliplr(circ.x)];
circ.x(length(circ.y)/2) = [];
circ.y(length(circ.y)/2) = [];

if nargin == 3
	if nargout == 2
		warning('Shape identification mode: second output is meaningless');
		y_dflt = y;
	end
	switch length(x)
		case length(rect.x)
			x_dflt = 'rectangle';
		case length(circ.x)
			x_dflt = 'circle';
		case length(star.x)
			x_dflt = 'star';
	end
	return
end

switch shape
	case 'rectangle'
		x_dflt = rect.x;
		y_dflt = rect.y;
	case 'star'
		x_dflt = star.x;
		y_dflt = star.y;
	case 'circle'
		x_dflt = circ.x;
		y_dflt = circ.y;
	case 'hexagon'

	otherwise
		x_dflt = [];
		y_dflt = [];
		warning('Shape not found')
end