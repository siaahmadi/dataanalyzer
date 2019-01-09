function rotate(obj, varargin)

if isempty(varargin)
	rotationAlgorithm = 'pca';
else
	if isa(varargin{1}, 'char')
		rotationAlgorithm = varargin{1};
	elseif isa(varargin{1}, 'numeric')
		rotationAlgorithm = 'rotateby';
		rotateBy = varargin{1};
	end		
end

x = obj.getX('unrestr');
y = obj.getY('unrestr');

% if ~alreadyCentered(x, y)
% 	choice = questdlg('It has been automatically determined that your position data may not have been centered properly or at all. Would you like to center position data using default Neuralynx parameters set in the |expSession| class?', ...
% 		'dataanalyzer:positiondata:rotate', ...
% 		'Yes', 'No', 'No');
% 	switch choice
% 		case 'Yes'
% 			x = x - dataanalyzer.expSession.NlxVideoTrackerXcenter;
% 			y = y - dataanalyzer.expSession.NlxVideoTrackerYcenter;
% 		case 'No'
% 			% pass
% 	end
% end

x = x(:);
y = y(:);

if strcmpi(rotationAlgorithm, 'mid')
	rp_x1 = x(x>5 & x<15);rp_x2 = x(x>-15 & x<-5);
	rp_y1 = y(x>5 & x<15);rp_y2 = y(x>-15 & x<-5);
	rotateBy =  -atan2(mean(rp_y1) - mean(rp_y2), mean(rp_x1) - mean(rp_x2));
	[x,y] = rotatePoints(x,y,rotateBy);
elseif strcmpi(rotationAlgorithm, 'pca')
% 	coeff = pca([x, y]);
% 	rotateBy = atan2(coeff(1),coeff(2));
% 	[x,y] = rotatePoints(x,y, rotateBy-pi/2);
	d = [x,y] * pca([x, y]);
	x = d(:, 1); y = d(:, 2);
elseif strcmpi(rotationAlgorithm, 'rotateby')
	[x, y] = rotatePoints(x, y, rotateBy);
end

obj.X = x;
obj.Y = y;

function I = alreadyCentered(x, y)

I = false;

if -1 <= log2(abs(max(x)/min(x))) && log2(abs(max(x)/min(x))) <= 1
	if abs(mean(x)) < 10 && abs(mean(y)) < 10
		I = true;
	end
end