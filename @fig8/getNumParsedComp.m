function N = getNumParsedComp(obj, whatToGet)

if isempty(obj.parsedComponents)
	N = 0;
	return;
end
fn = fieldnames(obj.parsedComponents);

if ~any(strcmp(fn, whatToGet))
	error('DataAnalyzer:PositionData:ParsedComponents:WrongPC', 'Parsed Component requested not found.');
end

N = cellfun(@numel, {obj.parsedComponents.(whatToGet)});

N = N(:);