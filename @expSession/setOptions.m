function options = setOptions(obj, options)
% todo...

if ischar(options) % user didn't provide a struct with actual options, but rather requested a preset option
	colonInd = regexp(options, ':');
	if isempty(colonInd)
		error('DataAnalyzer:OptionParsing:UnrecognizedOption', 'Unrecognized options requested');
	end
	
	if strcmpi(options(1:colonInd(1)-1), 'defaultOptions')
		optionsType = options(colonInd(1)+1:end);
		
		try
			options = defaultOptions(optionsType);
		catch err
			if strcmp(err.identifier, 'DataAnalyzer:OptionDefinition:NotDefined')
				warning('No options set!!!!!!!!!!!!!');
				options = [];
			end
		end
	else
		error('DataAnalyzer:OptionParsing:UnrecognizedOption', 'Behavior not defined')
	end
elseif isstruct(options) && isfield(options, 'defaultOptions')
	optionsType = options.defaultOptions;
	defOpt = defaultOptions(optionsType);
	fn = fieldnames(defOpt);
	for i = 1:length(fn)
		options.(fn{i}) = defOpt.(fn{i});
	end
end

[funcOpt, paramOpt] = extractFunctionOptions(options);
obj.setFunctionOptions(funcOpt);
obj.setParamOptions(paramOpt);

options = obj.getOptions('all');