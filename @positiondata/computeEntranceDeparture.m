function [off2on, on2off, edgeLabels, sequenceOfEvents, entranceEdges, departureEdges] = computeEntranceDeparture(x, y, polygROI)
% polygROI must be a 2 x m polygon

% In cases where a constraint is applied, the ROI might become disconnected
% the following few lines ensure that only the biggest outer contour is
% used as the ROI
if any(isnan(polygROI(:)))
	warning('The ROI is disconnected, perhaps by having been intersected with a constraint. Using only the biggest outer contour...')
	[polygROI(1,:), polygROI(2,:)] = poly2cw(polygROI(1,:), polygROI(2,:));
	[a,b] = dataanalyzer.makePlaceMaps.biggestOuterPoly(polygROI(1,:), polygROI(2,:));
	polygROI = [a;b];
end

if iscell(x) && iscell(y) % discontiguity introduced by mask causes this
	if nargout > 2
		[off2on, on2off, edgeLabels, sequenceOfEvents, entranceEdges, departureEdges] = ...
			cellfun(@(x,y) dataanalyzer.positiondata.computeEntranceDeparture(x, y, polygROI), x, y, 'UniformOutput', false);
	else
		[off2on, on2off] = ...
			cellfun(@(x,y) dataanalyzer.positiondata.computeEntranceDeparture(x, y, polygROI), x, y, 'UniformOutput', false);
	end
	
	return;
elseif xor(iscell(x), iscell(y))
	error('Why are x and y not both cell or both arrays???');
end

IN = inpolygon(x,y,polygROI(1,:), polygROI(2,:));
ctrPolyg = [mean(polygROI(1,:)), mean(polygROI(2,:))]; % [x1, y1]
y2 = ctrPolyg(2); % y2 = y1
x2 = max(polygROI(1,:))+1; % x2 = rightmost point of ROI + 1

[polygROI(1,:), polygROI(2,:)] = poly2ccw(polygROI(1,:), polygROI(2,:));

testSegment.x = [ctrPolyg(1), x2];
testSegment.y = [ctrPolyg(2), y2];
if nargout >= 3
	[roiEdgeStruct, roiSegmentsArray] = extractSegmentsOfPolygon(polygROI);
	i = whichLinesegIntersect(roiEdgeStruct, testSegment);
	edgeLabels = circshift(1:length(roiEdgeStruct), i-1, 2);
end

allCrossingsIdx = find(lau.rt(bwmorph(IN, 'clean'))); % 'clean' is to avoid single-frame out-of-ROIs
on2off = allCrossingsIdx(2:2:end);
off2on = allCrossingsIdx(1:2:end);

if nargout > 3
	%%%% starting in the polygon or finishing inside should be included or not?
	% if off2on(1) == 1
	% 	off2on = off2on(2:end);
	% end
	% if on2off(end) == length(IN)
	% 	on2off = on2off(1:end-1);
	% end
	entranceEdges = zeros(length(off2on), 1);
	departureEdges = zeros(length(on2off), 1);

	for i = 1:length(entranceEdges)
		bInd = off2on(i)-1;
		if bInd == 0, bInd = 1; end;
		testSegment.x = x(bInd:off2on(i));
		testSegment.y = y(bInd:off2on(i));
		entranceEdges(i) = whichLinesegIntersect(roiEdgeStruct, testSegment);
	end
	for i = 1:length(departureEdges)
		eInd = on2off(i)+1;
		if eInd >= length(IN), eInd = length(IN); end;
		testSegment.x = x(on2off(i):eInd);
		testSegment.y = y(on2off(i):eInd);
		departureEdges(i) = whichLinesegIntersect(roiEdgeStruct, testSegment);	
	end

	ex = repmat({'exit'}, numel(departureEdges), 1);
	en = repmat({'enter'}, numel(entranceEdges), 1);
	[~, I] = sort([on2off off2on]);
	allevents = [ex; en];
	sequenceOfEvents = allevents(I);
end

function ind = whichLinesegIntersect(roiEdgeStruct, testSegment)

for ind = 1:length(roiEdgeStruct)
	if ~isempty(polyxpoly(roiEdgeStruct(ind).x, roiEdgeStruct(ind).y, testSegment.x, testSegment.y));
		break;
	end
end

function [roiSegmentsStruct, roiSegmentsArray] = extractSegmentsOfPolygon(polygROI)
roiSegmentsStruct = repmat(struct('x1', [], 'y1', [], 'x2', [], 'y2', [], 'x', [], 'y', []), size(polygROI, 2)-1, 1);

for i = 1:length(roiSegmentsStruct)
	roiSegmentsStruct(i).x1 = polygROI(1, i);
	roiSegmentsStruct(i).y1 = polygROI(2, i);
	roiSegmentsStruct(i).x2 = polygROI(1, i+1);
	roiSegmentsStruct(i).y2 = polygROI(2, i+1);
	roiSegmentsStruct(i).x = [roiSegmentsStruct(i).x1; roiSegmentsStruct(i).x2];
	roiSegmentsStruct(i).y = [roiSegmentsStruct(i).y1; roiSegmentsStruct(i).y2];
end

roiSegmentsArray = zeros(2, 2*(size(polygROI, 2)-1));

roiSegmentsArray(:, 1) = polygROI(:, 1);
roiSegmentsArray(:, 2:end-1) = reshape(repmat(polygROI(:, 2:end-1), 2, 1), 2, 2*(size(polygROI, 2)-2));
roiSegmentsArray(:, end) = polygROI(:, end);