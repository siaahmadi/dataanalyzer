function adj = autoadjustpath(pathData,boxSize,edgeAlpha)
dPhi = 1;
if nargin<3 || isempty(edgaAlpha)
    edgeAlpha = 0.01;
end
if isscalar(boxSize)
    boxSize = [boxSize boxSize];
end

pathData = transposeStructVectors(pathData,'row');

xRef = [pathData.x];
yRef = [pathData.y];
[~, ~, adj.rotation] = rotateByAreaMinimization(xRef,yRef,dPhi);

if adj.rotation > 0
[xRef yRef] = rotatePath(xRef,yRef,deg2rad(adj.rotation));
end
[xBox yBox] = boxedges(xRef,yRef,edgeAlpha);
w0 = diff(minmax(xBox));
h0 = diff(minmax(yBox));

adj.xScale = boxSize(1)/w0;
adj.yScale = boxSize(2)/h0;
adj.xCenter = sum(minmax(xBox))/2;
adj.yCenter = sum(minmax(yBox))/2;
