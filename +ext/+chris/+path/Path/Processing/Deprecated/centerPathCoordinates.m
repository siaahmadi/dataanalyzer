function [x y center] = centerPathCoordinates(x,y)
[cX cY] = getPathCenter(x,y);
x = x-cX;
y = y-cY;
center = [cX cY];