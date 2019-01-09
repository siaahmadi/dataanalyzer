function [xLims yLims] = adjustpath_getdisplims(hFig)
% rotation = getappdata(hFig,'rotation');
pathData = getappdata(hFig,'pathData');
pathLocs = getappdata(hFig,'pathLocs');
currLoc = getappdata(hFig,'currentLoc');
iLocPaths = find(pathLocs == currLoc);
pathData = transposeStructVectors(pathData,'row');
xLoc = [pathData(iLocPaths).x];
yLoc = [pathData(iLocPaths).y];
[xC yC] = getPathCenter(xLoc,yLoc);
[~,r] = cart2pol(xLoc-xC,yLoc-yC);
maxDiam = 2*max(r);

w = diff(minmax(xLoc));
h = diff(minmax(yLoc));


len = maxDiam; %*1.01; %+2*pad;
wPad = (len-w)/2;
hPad = (len-h)/2;

xMin = min(xLoc)-wPad;
xMax = max(xLoc)+wPad;
yMin = min(yLoc)-hPad;
yMax = max(yLoc)+hPad;
xLims = [xMin xMax];
yLims = [yMin yMax];
