function ind = whichLinesegIntersect(roiEdgeStruct, testSegment)

for ind = 1:length(roiEdgeStruct)
	if ~isempty(polyxpoly(roiEdgeStruct(ind).x, roiEdgeStruct(ind).y, testSegment.x, testSegment.y));
		break;
	end
end
