function pos = adj2pos(adj,wTarget,hTarget)
if nargin<2
    wTarget = (40+5/8)*2.54;
    hTarget = (5*12)*2.54;
end
pos = nan(1,4);
pos(3) = wTarget/adj.xScale;
pos(4) = hTarget/adj.yScale;
pos(1) = adj.xCenter-pos(3)/2;
pos(2) = adj.yCenter-pos(4)/2;