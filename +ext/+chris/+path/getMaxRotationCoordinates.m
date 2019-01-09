function rMax = getMaxRotationCoordinates(x,y)
xLenMax = diff(minmax(x));
yLenMax = diff(minmax(y));
for phi = 1:360
    [xr yr] = rotatePath(x,y,deg2rad(phi));
    if diff(minmax(xr))>xLenMax
        xLenMax = diff(minmax(x));
        xMax = max(abs(minmax(x)));
    end
    if diff(minmax(yr))>yLenMax
        yLenMax = diff(minmax(y));
        yMax = max(abs(minmax(y)));
    end
end
rMax = max(xMax,yMax);