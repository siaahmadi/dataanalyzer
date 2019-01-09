function adj = pos2adj(pos,wTarget,hTarget)
if nargin<2
    wTarget = (40+5/8)*2.54;
    hTarget = (5*12)*2.54;
end
% adj.boundary = pos;
adj.xCenter = pos(1)+pos(3)/2;
adj.yCenter = pos(2)+pos(4)/2;
adj.xScale = wTarget/pos(3);
adj.yScale = hTarget/pos(4);