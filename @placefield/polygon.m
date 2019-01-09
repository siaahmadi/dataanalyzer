function polyg = polygon(obj, contour)
%POLYGON Convert |contour| of a placefield object to a MATLAB polygon
%
% polyg = POLYGON(obj, contour)

polyg = [obj.getX(contour);obj.getY(contour)];