function x = getX(obj, contour)
%GETX Get x-coordinates of placefield boundary for a given contour
%
% If contour not given, the smallest will be chosen automatically

if ~exist('contour', 'var')
	contour = smallestContour(obj);
end

x = obj.fieldInfo.boundary.(contour)(1, :);
x = x(:);