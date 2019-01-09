function [x y] = correctPath(x,y,dPhi,center,scale,extremal)
if nargin<6 || isempty(extremal)
    edgeSuppression = 0;
else
    edgeSuppression = 1;
end
% [x y] = rotateAndCenterPath(x,y,deg2rad(dPhi),center);
[x y] = rotatePath(x,y,deg2rad(dPhi));

x = x*scale(1);
y = y*scale(2);
x = x-center(1);
y = y-center(2);
if edgeSuppression
    [x y] = suppressEdges(x,y,extremal);
end
