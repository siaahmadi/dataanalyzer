function options = setParamOptions(obj, paramOptions)

if ~isstruct(paramOptions)
	warning('No new options set.');
	options = obj.getOptions('all');
	return;
end

paramFields = fieldnames(paramOptions);

for i = 1:length(paramFields)
	obj.paramOptions.(paramFields{i}) = paramOptions.(paramFields{i}); % adds only provided fields--does not reset obj.functionOptions
end

options = obj.getOptions('all');