function center(obj, centerParams)

posx = obj.getX('unrestr');
posy = obj.getY('unrestr');

if ~exist('centerParams', 'var') || isempty(centerParams)
	[~, ~, center] = centreBox(posx, posy);
	centerParams.xCenter = center(1);
	centerParams.yCenter = center(2);
end

obj.X = posx - centerParams.xCenter;
obj.Y = posy - centerParams.yCenter;