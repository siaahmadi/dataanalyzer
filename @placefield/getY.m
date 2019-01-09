function y = getY(obj, contour)
%GETX Get y-coordinates of placefield boundary for a given contour
%
% If contour not given, the smallest will be chosen automatically

if ~exist('contour', 'var')
	contour = smallestContour(obj);
end

y = obj.fieldInfo.boundary.(contour)(2, :);
y = y(:);