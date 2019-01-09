function diam = diameter(obj, contour)
%DIAMETER Farthest two points from all peaks of a place field object
%
% diam = DIAMETER(obj, contour) Compute the diameter for |contour|

x = obj.getX(contour);
y = obj.getX(contour);
diam = polydiam([finite(x(:)), finite(y(:))]);