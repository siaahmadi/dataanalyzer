function [regionName, layerName, subregionName, ttLabels] = ttLocate(ratNo, ttNo)

numFields = 5;
ttLabelsInd = 1;
regionNameInd = 2;
layerNameInd = 3;
subregionNameInd = 5;

[ttDB, ~, pageInd] = dataanalyzer.env.rad8.getTetDB(ratNo, numFields);


ttListPage = ttDB{pageInd};
ttListPage(:, 1) = cellfun(@(x) str2double(regexp(x, '\d*', 'match')), ttListPage(:, 1), 'UniformOutput', false);

if nargin > 1

	rowInd = cat(1, ttListPage{:, 1}) == ttNo;

	if sum(rowInd) ~= 1
		error('ttNo non-existent or duplicated in ratNo page');
	end

	regionName = ttListPage(rowInd, regionNameInd);
	layerName = ttListPage(rowInd, layerNameInd);
	subregionName = ttListPage(rowInd, subregionNameInd);
	
	return
end

[~, rowInd] = sort(cat(1, ttListPage{:, 1}));

ttLabels = ttDB{pageInd}(rowInd, ttLabelsInd);
regionName = ttListPage(rowInd, regionNameInd);
layerName = ttListPage(rowInd, layerNameInd);
subregionName = ttListPage(rowInd, subregionNameInd);