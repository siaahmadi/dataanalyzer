function neurons = getNeurons(obj, varargin)

if numel(obj) > 1
	neurons = arrayfun(@(obj) obj.getNeurons(varargin{:}), obj, 'un', 0);
	neurons = cat(1, neurons{:});
	return;
end

neurons = cat(1, obj.neurons.neuronArray{:});

if ~isempty(varargin)
	try
		if islogical(varargin{1}) && numel(varargin{1}) == numel(neurons)
			neurons = neurons(varargin{1});
			return;
		end
		neurons = findobj(neurons,varargin{:});
	catch
		error('Selection parameters not consistent or not well-formed')
	end
end