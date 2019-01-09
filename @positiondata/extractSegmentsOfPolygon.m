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