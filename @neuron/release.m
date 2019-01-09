function release(obj, whatToRelease)

if numel(obj) > 1
	arrayfun(@(x) x.release(whatToRelease), obj);
	
	return;
end

obj.history = {''};
if ~isempty(regexp(whatToRelease, 'spikes', 'once'))
	obj.selectionFlag.spikes.lowerBound = obj.parentTrial.beginTS;
	obj.selectionFlag.spikes.upperBound = obj.parentTrial.endTS;
end
if ~isempty(regexp(whatToRelease, 'placefields', 'once'))
	
end
if ~isempty(regexp(whatToRelease, 'passes', 'once'))
	
end

obj.selectionFlag.spikes.duration = sum(obj.selectionFlag.spikes.upperBound - obj.selectionFlag.spikes.lowerBound);

obj.isRestricted = false;