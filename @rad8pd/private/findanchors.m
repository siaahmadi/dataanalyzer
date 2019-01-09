function anchors = findanchors(x,y)

[points.theta, points.rho] = cart2pol(x,y);

sector = phaprec.parsemz.rad8.sector(x, y, pi/8);

farthestPoint = zeros(8, 1);
I = zeros(size(farthestPoint));

for i = 1:length(farthestPoint)
	[farthestPoint(i), I(i)] = max(eucldist(0, 0, x(sector==i), y(sector==i)));
	
	buffer = find(sector == i, I(i));
	I(i) = buffer(end);
end

anchors = repmat(struct('x', [], 'y', [], 'coanchor', []), 8, 1);

for i = 1:8
	bisector = (i-1)*pi/4 + pi/8;
	
	[~, ii] = max([farthestPoint(i), farthestPoint(mod(i,8)+1)]); ii = ii - 1; % = 0 if first one bigger, = 1 if second one bigger
	f = [x(I(i+ii)), y(I(i+ii))];
	
	a1 = dot(f, [cos(bisector), sin(bisector)]);
	a2 = sqrt(eucldist(0, 0, f(1), f(2))^2 - a1^2);
	alpha = abs(mod(2*pi+atan2(f(2), f(1)), 2*pi) - bisector);
	r = a1+a2*tan(alpha);
	[anchors(i).x, anchors(i).y] = pol2cart(bisector, r);
	anchors(i).coanchor = [-anchors(i).y, anchors(i).x] / r;
end