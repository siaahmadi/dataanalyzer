function [xBox yBox] = boxedges(x,y,alpha,nBoot)
if nargin<4 || isempty(nBoot)
    nBoot = 100;
end
if nargin<3 || isempty(alpha)
    alpha = 0.05;
end
[xMin xMax] = alphaboot(x,alpha,nBoot,'two');
[yMin yMax] = alphaboot(y,alpha,nBoot,'two');
[xBox yBox] = rectcoords(xMax-xMin,yMax-yMin,xMin,yMin);