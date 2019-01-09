function options = setFunctionOptions(obj, funcOptions)

if ~isstruct(funcOptions)
	warning('DataAnalyzer:ExpSession:NoNewOptionsSet', 'No new options set.');
	options = obj.getOptions('all');
	return;
end

funcFields = fieldnames(funcOptions);

for i = 1:length(funcFields)
	obj.functionOptions.(funcFields{i}) = funcOptions.(funcFields{i}); % adds only provided fields--does not reset obj.functionOptions
end

options = obj.getOptions('all');