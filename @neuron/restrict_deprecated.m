function s = restrict(obj, varargin)
% if you want to input an interval set, enter either a vector or a 2 x n
% matrix, where n is the number of intervals

error('Obsolete');

if numel(obj) > 1
	s = arrayfun(@(x) x.restrict(varargin{:}), obj, 'UniformOutput', false);
	
	return
end
if isempty(varargin)
	error('Provide restriction bounds')
end

inputData = varargin{:};

if isa(inputData, 'dataanalyzer.wip.neuralevents.neuralevent')
	obj.isRestricted = true;
	
	bounds = dataanalyzer.wip.neuralevents.neuralevent.nev2interval(inputData);
elseif isa(inputData, 'dataanlyzer.meta.placefieldarray')
	
elseif isa(inputData, 'dataanalyzer.meta.passarray')
	
elseif isa(inputData, 'double')
	bounds = inputData(:);
else
	error('input type not supported')
end

obj.selectionFlag.spikes.lowerBound = bounds(1:2:end);
obj.selectionFlag.spikes.upperBound = bounds(2:2:end);
obj.selectionFlag.spikes.duration = sum(obj.selectionFlag.spikes.upperBound - obj.selectionFlag.spikes.lowerBound);

s = obj.getSpikeTrain();
obj.isRestricted = true;