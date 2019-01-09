function centerParams = getCtrParamsCorr(obj, options)

if isa(obj, 'dataanalyzer.trial') % first, try to get centerParams from session-wide data (presumably more accurate)
	anc = dataanalyzer.ancestor(obj, 'expSession');
	if ~isempty(anc.positionData.centerParams)
		obj.centerParams = anc.positionData.centerParams;
	end
end

if isempty(obj.centerParams)
	rawX = obj.getX('unrestr');
	rawY = obj.getY('unrestr');
	mzTemplate = dataanalyzer.positiondata.layout2bw(radial8maze); % @radial8maze private function
	mzTemplate = weightArms(mzTemplate);
	centerParams = dataanalyzer.positiondata.ctrposdat(rawX, rawY, mzTemplate, options); % uses 2-D correlation to estimate params
	obj.centerParams = centerParams;
else
	centerParams = obj.centerParams;
end

function mzTemplate = weightArms(mzTemplate)
pxi = regionprops(mzTemplate, 'PixelIdxList');
buffer = double(mzTemplate);
for i = [1:3 5:9] % for radial 8 maze, the 4-th element is the stem
	buffer(pxi(i).PixelIdxList) = buffer(pxi(i).PixelIdxList) + 1e3;
end
buffer(pxi(4).PixelIdxList) = -1;
mzTemplate = buffer;