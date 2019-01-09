function I = p___validateFieldInfo(fieldInfo, requiredFieldNames)

if isempty(requiredFieldNames)
	I = true;
	return;
end

I = false;
if isstruct(fieldInfo)
	fn = fieldnames(fieldInfo);
	if all(ismember(requiredFieldNames, fn)) && isstruct(fieldInfo.boundary)
		fn = fieldnames(fieldInfo.boundary);
		if any(cellfun(@(x) ~isempty(x), regexp(fn, '^c\d{2}$'))) % at least one field with name c##
			I = true;
		end
	end
end

if ~I
	error('DataAnalyzer:PlaceField:InvalidFieldInfo', ...
		['fieldInfo must be a struct with the following fields: ' ...
		repmat('%s, ', 1, length(requiredFieldNames)-1), '%s;\n', ...
		' where boundary is a struct with at least one field whose name starts with ''c'' followed by two digits.'], requiredFieldNames{:});
end