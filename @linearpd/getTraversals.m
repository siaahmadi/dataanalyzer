function [traversals, leftboundPassesTS, rightboundPassesTS] = getTraversals(obj, target)
% this should be a special case of datanalyzer.positiondata.getTraversals()
% to be coordinated with that methods later

x = obj.getX();
y = obj.getY();
ts = obj.getTS();

leftcross = diff(x - target.left>0);
rightcross = diff(x - target.right>0);

rightbound.left = [find([0;leftcross]>0), repmat('a', sum([0;leftcross]>0), 1)];
rightbound.right = [find(rightcross>0), repmat('b', sum(rightcross>0), 1)];
leftbound.left = [find(leftcross<0), repmat('x', sum(leftcross<0), 1)];
leftbound.right = [find([0; rightcross]<0), repmat('y', sum([0;rightcross]<0), 1)];

allcrosses = cat(1, leftbound.left, leftbound.right, rightbound.left, rightbound.right);
[crosses, I] = sort(double(allcrosses(:, 1)));
crossesChar = allcrosses(I, 2)';
lfbdIdx = regexp(crossesChar, 'yx'); lfbdIdx = [lfbdIdx; lfbdIdx+1];
rtbdIdx = regexp(crossesChar, 'ab'); rtbdIdx = [rtbdIdx; rtbdIdx+1];


traversals = repmat(struct(...
	'right', struct('x', [], 'y', [], 'ts', []),...
	'left', struct('x', [], 'y', [], 'ts', [])),...
	max(size(lfbdIdx, 2), size(rtbdIdx, 2)), 1);

j = 0;
for i = lfbdIdx
	j = j + 1;
	traversals(j).left.x = x(crosses(i(1)):crosses(i(2)));
	traversals(j).left.y = y(crosses(i(1)):crosses(i(2)));
	traversals(j).left.ts = ts(crosses(i(1)):crosses(i(2)));
	traversals(j).boundsLeft = [ts(crosses(i(1)));ts(crosses(i(2)))];
end
j = 0;
for i = rtbdIdx
	j = j + 1;
	traversals(j).right.x = x(crosses(i(1)):crosses(i(2)));
	traversals(j).right.y = y(crosses(i(1)):crosses(i(2)));
	traversals(j).right.ts = ts(crosses(i(1)):crosses(i(2)));
	traversals(j).boundsRight = [ts(crosses(i(1)));ts(crosses(i(2)))];
end

leftboundPassesTS = cat(2, traversals.boundsLeft);
rightboundPassesTS = cat(2, traversals.boundsRight);