function ts = getTS(obj, ~)
%getTS Return the unrestricted spike train of neuron object
%
% (In order for the neuron class to serve as a valid mask reference object,
% it must have a getTS method.)

if numel(obj) > 1
	ts = arrayfun(@(x) x.getSpikeTrain(), obj, 'UniformOutput', false);
	return;
end

ts = obj.getSpikeTrain('unrestr');