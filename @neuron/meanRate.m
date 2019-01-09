function m = meanRate(obj, returnStock)

if ~exist('returnStock', 'var')
	returnStock = false;
end

if numel(obj) > 1
	m = arrayfun(@(x) x.meanRate(returnStock), obj, 'UniformOutput', false);
	m = cell2mat(m);
	return
end

if isempty(obj.avgFiringRate)
	% compute
	if obj.isRestricted
		obj.avgFiringRate = numel(obj.getSpikeTrain) / obj.getDuration('trial');
	else
		obj.avgFiringRate = numel(obj.spikeTrain) / obj.getDuration('trial');
	end
end

if returnStock && obj.isRestricted
	m = numel(obj.spikeTrain) / obj.getDuration();
	return
end

m = obj.avgFiringRate;