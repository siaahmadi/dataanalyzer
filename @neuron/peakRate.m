function p = peakRate(obj, spatialOrTemporal, forceStock)

if ~exist('forceStock', 'var')
	forceStock = false;
end
sptm = 'temporal';
if exist('spatialOrTemporal', 'var') && strcmp(spatialOrTemporal, 'spatial')
	sptm = spatialOrTemporal;
end

if numel(obj) > 1
	p = arrayfun(@(x) x.peakRate(sptm, forceStock), obj, 'UniformOutput', false);
	p = cell2mat(p);
	return
end

if isempty(obj.peakFiringRate)
	if strcmp(sptm, 'temporal')
		rf = obj.ratefun();
		obj.peakFiringRate = max(rf([]));
	end
end

if forceStock && obj.isRestricted
	rf = obj.ratefun(true);
	p = max(rf([]));
	return
end

obj.rtfun = [];

p = obj.peakFiringRate;