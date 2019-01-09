% To structify the spikes + fields (placemaps)
function hc = hardcopy(obj, unit, zeroAnchored, legacy)

if exist('legacy', 'var') && (strcmpi(legacy, 'legacy') || legacy)
	trialBegin = 0;
	conversionUnit = 1;
	if exist('unit', 'var') && ~isempty(unit)
		conversionUnit = unit;
	end
	if exist('zeroAnchored', 'var') && ~isempty(zeroAnchored)
			trialBegin = obj.trialBeginTS;
	end
	hc = (obj.getSpikeTrain('unrestr') - trialBegin) * conversionUnit; % handle obj
else
	if nargin > 1
		error('Are you sure you don''t mean to use the legacy version?');
	end
	objp = [obj.Parent];
	hc = struct('namestring', {obj.namestring}, ...
		'spikes', {obj.spikeTrain}, ...
		'rate', {obj.avgFiringRate}, ...
		'placemap', arrayfun(@fieldsHC, obj(:)', 'un', 0), ...
		'rmap', arrayfun(@fieldsRMap, obj(:)', 'un', 0), ...
		'anatomy', {obj.anatomicalRegion}, ...
		'rat', {objp.ratNo}, ...
		'session', {objp.namestring})';

	for i = 1:length(hc)		
		hc(i).tuning = hc(i).placemap.tuning;
		hc(i).fields = hc(i).placemap.fields;
	end
	hc = rmfield(hc, 'placemap');
	hc = hc(:);
end

function fields = fieldsHC(o)
if ~isempty(o.placeMaps)
	fields = o.placeMaps.Maps.hardcopy;
else
	fields = [];
end

function rmap = fieldsRMap(o)
if ~isempty(o.placeMaps)
	rmap = o.placeMaps.Maps.RMap;
else
	rmap = [];
end