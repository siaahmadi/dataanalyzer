function [template locBnds] = fig8trialtemplate()
maze = fig8maze();
locs = fields(maze.locs);
[xC yC] = getPathCenter(maze.whole.basic(:,1),maze.whole.basic(:,2));
for l = 1:length(locs)
   maze.locs.(locs{l})(:,1) = maze.locs.(locs{l})(:,1)-xC;
   maze.locs.(locs{l})(:,2) = maze.locs.(locs{l})(:,2)-yC;
end
r = diff(minmax(maze.locs.N1(:,1)))/2;
dd = 0.2;
da = dd/r;

xTmp = 0;
yTmp = max(maze.locs.A25(:,2));

yA25 = sort([min(maze.locs.A25(:,2)):dd:max(maze.locs.A25(:,2))]','descend');
xA25 = sum(minmax(maze.locs.A25(:,1)))/2*ones(length(yA25),1);

xTmp = cat(1,xTmp,xA25);
yTmp = cat(1,yTmp,yA25);
dTmp = getPathDistance(xTmp,yTmp);
locBnds.center = minmax(dTmp);
lastMax = max(dTmp);

[xN5L yN5L] = pol2cart(-[0:da:pi/2]',r);
xN5L = xN5L + min(maze.locs.N5(:,1));
yN5L = yN5L + max(maze.locs.N5(:,2));
xTmp = cat(1,xTmp,xN5L);
yTmp = cat(1,yTmp,yN5L);
dTmp = getPathDistance(xTmp,yTmp);
locBnds.choice = minmax(dTmp(dTmp>=lastMax));
lastMax = max(dTmp);

[xN5R yN5R] = pol2cart([pi:da:5*pi/2]',r);
xN5R = xN5R + max(maze.locs.N5(:,1));
yN5R = yN5R + max(maze.locs.N5(:,2));

xA56 = sort([min(maze.locs.A56(:,1)):dd:max(maze.locs.A56(:,1))]','descend');
yA56 = sum(minmax(maze.locs.A56(:,2)))/2*ones(length(xA56),1);
xTmp = cat(1,xTmp,xA56);
yTmp = cat(1,yTmp,yA56);
dTmp = getPathDistance(xTmp,yTmp);
locBnds.base = minmax(dTmp(dTmp>=lastMax));
lastMax = max(dTmp);

[xN6 yN6] = pol2cart(-[pi/2:da:pi]',r);
xN6 = xN6 + max(maze.locs.N6(:,1));
yN6 = yN6 + max(maze.locs.N6(:,2));
xTmp = cat(1,xTmp,xN6);
yTmp = cat(1,yTmp,yN6);
dTmp = getPathDistance(xTmp,yTmp);
locBnds.reward = minmax(dTmp(dTmp>=lastMax));
lastMax = max(dTmp);

yA16 = [min(maze.locs.A16(:,2)):dd:max(maze.locs.A16(:,2))]';
xA16 = sum(minmax(maze.locs.A16(:,1)))/2*ones(length(yA16),1);

[xN1 yN1] = pol2cart(-[pi:da:3*pi/2]',r);
xN1 = xN1 + max(maze.locs.N1(:,1));
yN1 = yN1 + min(maze.locs.N1(:,2));

xA12 = [min(maze.locs.A12(:,1)):dd:max(maze.locs.A12(:,1))]';
yA12 = sum(minmax(maze.locs.A12(:,2)))/2*ones(length(xA12),1);
xTmp = cat(1,xTmp,[xA16;xN1;xA12]);
yTmp = cat(1,yTmp,[yA16;yN1;yA12]);
dTmp = getPathDistance(xTmp,yTmp);
locBnds.return = minmax(dTmp(dTmp>=lastMax));
lastMax = max(dTmp);

[xN2L yN2L] = pol2cart(-[3*pi/2:da:2*pi]',r);
xN2L = xN2L + min(maze.locs.N2(:,1));
yN2L = yN2L + min(maze.locs.N2(:,2));
xTmp = cat(1,xTmp,xN2L);
yTmp = cat(1,yTmp,yN2L);
dTmp = getPathDistance(xTmp,yTmp);
locBnds.choiceEnd = minmax(dTmp(dTmp>=lastMax));

d = dTmp;

template.L.x = xTmp;
template.L.y = yTmp;
template.L.d = d;
template.R.x = -xTmp;
template.R.y = yTmp;
template.R.d = d;
    
