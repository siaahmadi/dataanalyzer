function [funcOpt, paramOpt] = extractFunctionOptions(options)

funcOpt = [];
paramOpt = [];

if ~isstruct(options)
	return;
end

classMtd = methods(class(dataanalyzer.expSession));

fn = fieldnames(options);

funcFields = fn(matchstri(fn, classMtd));
paramFields = setdiff(fn, funcFields);

for i = 1:length(funcFields)
	funcOpt.(funcFields{i}) = options.(funcFields{i});
end

for i =1:length(paramFields)
	paramOpt.(paramFields{i}) = options.(paramFields{i});
end