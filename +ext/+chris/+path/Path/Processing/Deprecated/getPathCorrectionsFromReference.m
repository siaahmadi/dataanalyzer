function [corrections x y] = getPathCorrectionsFromReference(x,y,dPhi,boxSize,edgeSuppression)
if isequal(size(boxSize),[1 1])
    boxSize = [boxSize boxSize];
end
dPhi = abs(dPhi);
if dPhi > 0
    [x y dPhi] = rotateByAreaMinimization(x,y,dPhi);
end

if edgeSuppression
    [xExt yExt] = getExtremal(x,y);
    extremal = [xExt yExt];
    [x,y] = suppressEdges(x,y,extremal);
else
    extremal = [];
end
[x y center] = centerPathCoordinates(x,y);
if boxSize(1)==0
    xScale = 1;
else
    xScale = boxSize(1)/diff(minmax(x));
end
if boxSize(2)==0
    yScale = 1;
else
    yScale = boxSize(2)/diff(minmax(y));
end
x = x*xScale;
y = y*yScale;



corrections.dPhi = dPhi;
corrections.center = center;
corrections.extremal = extremal;
corrections.scale = [xScale yScale];