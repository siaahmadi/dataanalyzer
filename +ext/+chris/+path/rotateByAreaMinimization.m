function [x y dPhi] = rotateByAreaMinimization(x,y,dPhi,mode)
if nargin<4 || isempty(mode)
    mode = '';
end
if nargin<3 || isempty(dPhi)
    dPhi = 1;
end
if dPhi == 0
    return;
end
dPhi = abs(dPhi);

[~,AHull] = convhull(x,y);
A = enclosingBoxArea(x,y);
ARatio = AHull/A;
[xL yL] = rotatePath(x,y,deg2rad(dPhi));
AL = enclosingBoxArea(xL,yL);
[xR yR] = rotatePath(x,y,-deg2rad(dPhi));
AR = enclosingBoxArea(xR,yR);
if AHull/AR>ARatio || AHull/AL>ARatio
    if AHull/AR>AHull/AL
        dPhi = -dPhi;
        maxARatio = AHull/AR;
    else
        maxARatio = AHull/AL;
    end
else
    maxARatio = ARatio;
end

r = 0;
ARatio = maxARatio;
while ARatio>=maxARatio
    r = r+1;
    maxARatio=ARatio;
    [x,y] = rotatePath(x,y,deg2rad(dPhi));
    A = enclosingBoxArea(x,y);
    ARatio = AHull/A;
end
[x,y] = rotatePath(x,y,-deg2rad(dPhi));
dPhi = dPhi*(r-1);

switch mode
    case 'CW'
        if dPhi>0
            [x y] = rotatePath(x,y,-deg2rad(90));
            dPhi = dPhi-90;
        end
    case 'CCW'
        if dPhi<0
            [x y] = rotatePath(x,y,deg2rad(90));
            dPhi = dPhi+90;
        end
    case 'wide'
        if diff(minmax(x))<diff(minmax(y))
            if dPhi<0
                [x y] = rotatePath(x,y,deg2rad(90));
                dPhi = dPhi+90;
            else
                [x y] = rotatePath(x,y,-deg2rad(90));
                dPhi = dPhi-90;
            end
        end
    case 'tall'
        if diff(minmax(x))>diff(minmax(y))
            if dPhi<0
                [x y] = rotatePath(x,y,deg2rad(90));
                dPhi = dPhi+90;
            else
                [x y] = rotatePath(x,y,-deg2rad(90));
                dPhi = dPhi-90;
            end
        end
    otherwise
        % Use minimum rotation
end
