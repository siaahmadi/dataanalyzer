function setRegion(obj, anatReg)

if isa(anatReg, 'dataanalyzer.anatomy')
	obj.anatomicalRegion = anatReg;
elseif isstruct(anatReg)
	if ~isfield(anatReg, 'region')
		error('Region must be specified')
	end
	region = anatReg.region;
	if isfield(anatReg, 'subregion')
		subregion = anatReg.subregion;
	else
		subregion = '';
	end
	if isfield(anatReg, 'layer')
		layer = anatReg.layer;
	else
		layer = '';
	end
	obj.anatomicalRegion = dataanalyzer.anatomy(region, layer, subregion);
elseif ishandle(anatReg)
	error('todo');
end