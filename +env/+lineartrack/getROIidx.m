function roiIdx = getROIidx(pathToSession, tFileNames, roi)

ratNo = regexp(regexp(pathToSession, 'Rat\d\d\d', 'match'), '\d\d\d', 'match'); ratNo = str2double(ratNo{1});
roiTTs = find(lineartrackABBA.ttIdxByRegion(ratNo, roi));
if isempty(roiTTs)
	roiIdx = zeros(size(tFileNames))==1;
	return
end
roiIdx = matchstr(tFileNames, cateachrow(strcat('TT', cellfun(@num2str, num2cell(roiTTs), 'UniformOutput', false)), '|'), 'contains');