function [funcSpecificOptions, db] = options(project_name)

db = dataanalyzer.internal.p___loadOptionsDB();

ST = dbstack('-completenames');
if length(ST) < 2
	error('DataAnalyzer:Options:InvalidCaller', 'Options cannot be called by user in Command Window.');
end
str = ST(2).file;
[pathstr, name] = fileparts(regexp(str, '(?<=^(.*)*\+dataanalyzer\\).*', 'match', 'once'));
prec = cellfun(@(x) [x, '_'], regexp(pathstr, '\w*', 'match'), 'UniformOutput', false);

if isfield(db.(project_name), [cat(2, prec{1}), name])
	funcSpecificOptions = db.(project_name).([cat(2, prec{1}), name]);
	%                                                     ^ determines the
	%                                                     naming convention.
	%                                                     Can be a ':'
else
	funcSpecificOptions = [];
end