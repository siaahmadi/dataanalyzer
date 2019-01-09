function proj_path = projpathhypb(x, y, visits)
%PROJ_PATH = PROJPATHHYPB(X, Y)
% 
% (DEPRECATED)
%
% For more information see |phaprec.parsemz.rad8.projpath|'s documentation.

% Siavash Ahmadi
% 10/3/15

anchor = phaprec.parsemz.rad8.findanchors(x, y);
sector = phaprec.parsemz.rad8.sector(x, y);
spine = phaprec.parsemz.rad8.mazespine();

x_tilde = zeros(size(x));
proj_path = zeros(length(x), 1);


for s = unique(sector(:)')
% 	x0 = anchor(s).x;
% 	y0 = anchor(s).y;
% 	x1 = x(sector == s);
% 	y1 = y(sector == s);
% 
% 	x0p = spine(s).coord(1, 1);
% 	y0p = spine(s).coord(1, 2);
% 	x1p = spine(s).coord(2, 1);
% 	y1p = spine(s).coord(2, 2);
% 
% 	Y = ((y1-y0)./(x1-x0).*x0+y0) - ((y1p-y0p)./(x1p-x0p).*x0p+y0p);
% 	X = (y1-y0)./(x1-x0) - (y1p-y0p)./(x1p-x0p);
% 	x_tilde(s) = Y ./ X;
% 	y_tilde = (y1-y0)./(x1-x0).*(x_tilde - x0) + y0;

	idx = sector == s;
	r = [x(:) - anchor(s).x, y(:) - anchor(s).y];
	r = r(idx, :);
	proj_path(idx) = dot(repmat(anchor(s).coanchor(:), 1, size(r, 1)), r')' ./ eucldist(0, 0, r(:, 1), r(:, 2));
	
end

% proj_path = [x_tilde(:), y_tilde(:)];

% proj_path = [proj_path, mod(sector(:)+heaviside(sign(sector(:)))-1, 8)+1]; % wiggle in the same arm may cause the points to be assigned two different values (e.g. on arm 2, this will be 2 and 3); |mod(heaviside(sign...| fixes that
proj_path = [abs(proj_path), phaprec.parsemz.rad8.sector(x(:), y(:), pi/8)];
proj_path(:, mod(proj_path(:, 2), 1) > 0) = 0; % points at origin will be assigned a non-integer arm number by |heaviside| in previous line