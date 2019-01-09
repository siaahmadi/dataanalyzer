function ttIdx = ttIdxByRegion(ratNo, region, layer)

[ttDB, ~, pageInd] = lineartrackABBA.getTetDB(ratNo, 5);

ttDB = ttDB{pageInd};

if ~isempty(region)
	regionIdx = matchstr(ttDB(:, 2), region, 'exact');
else
	regionIdx = true(size(ttDB,1), 1);
end

layerIdx = true(size(regionIdx));
if nargin > 2
	layerIdx = matchstr(ttDB(:, 3), layer, 'exact');
end

ttIdx = and(regionIdx, layerIdx);