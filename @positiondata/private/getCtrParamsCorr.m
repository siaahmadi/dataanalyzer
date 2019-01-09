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
	error('the following line is wrong! |radial8maze| should not be called for a general |positiondata| object.'); % I don't have time right now to trace how this function is being called. Fix later!
	mzTemplate = dataanalyzer.positiondata.layout2bw(radial8maze); % @radial8maze private function
	mzTemplate = weightArms(mzTemplate);
	centerParams = dataanalyzer.positiondata.ctrposdat(rawX, rawY, mzTemplate, options); % uses 2-D correlation to estimate params
	obj.centerParams = centerParams;
else
	centerParams = obj.centerParams;
end

