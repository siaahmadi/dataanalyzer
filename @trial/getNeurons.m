function na = getNeurons(obj, idx)

if numel(obj) > 1
	na = arrayfun(@(x) x.getNeurons(idx), obj);
	na = cat(1, na{:});
	return;
end

if nargin == 1
	na = obj.neurons;
else
	if isnumeric(idx)
	elseif ischar(idx) || (iscell(idx) && all(cellfun(@ischar, idx) | cellfun(@isempty, idx))) 
		if ~iscell(idx), idx = {idx}; end;
		idx = findByNamestring(obj.neurons.neuronArray, idx);
	else
		error('Unkown reference to neuron')
	end
	na = obj.neurons.neuronArray(idx);
end

function na = findByNamestring(neuronArray, namestrings)

na = zeros(length(neuronArray), 1) == 1;
for i = 1:length(namestrings)
	na = na | cellfun(@(x) strcmp(x.namestring, namestrings(i)), neuronArray);
end
