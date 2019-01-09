function regions = getRegions(obj, idx)

if nargin == 1
	regions = cell(length(obj.neuronArray), 1);
	for i = 1:length(regions)
		if ~isempty(obj.neuronArray{i})
			regions{i} = obj.neuronArray{i}.getRegion();
		end
	end
else
	idx = reshape(idx, 1, numel(idx));
	regions = cell(length(idx));
	for i = idx
		if ~isempty(obj.neuronArray{i})
			regions{i} = obj.neuronArray{i}.getRegion();
		end
	end
end