function h = figure(varargin)

ST = dbstack('-completenames');
if length(ST) < 2
	error('DataAnalyzer:Options:InvalidCaller', 'Options cannot be called by user in Command Window.');
end
str = ST(2).file;
[pathstr, name] = fileparts(regexp(str, '(?<=^([\w:]*\\)*\+dataanalyzer\\).*', 'match', 'once'));
prec = cellfun(@(x) [x, '_'], regexp(pathstr, '\w*', 'match'), 'UniformOutput', false);

h_fig = figure('Name', [cat(2, prec{1}), name], 'NumberTitle', 'off', varargin{:});

if nargout > 0
	h = h_fig;
end