function ax = plot(obj, varargin)

import dataanalyzer.figure

[ax, args, nargs] = axescheck(varargin{:});


if isempty(ax) % if no Axes provided, create one
	h_fig = figure;
	ax = axes('Parent', h_fig);
end
if numel(obj) > 1
	hold(ax, 'on');
	arrayfun(@(x) x.plot(ax, args{:}), obj, 'un', 0);
	hold(ax, 'off');
	return;
end

x = obj.getX();
t = obj.getTS();


p = inputParser();
p.KeepUnmatched = true;
p.addParameter('range', true(size(x)), @(idx) valididx(idx, x));
p.addParameter('mask', dataanalyzer.mask(), @(m) isa(m, 'dataanalyzer.mask'));
p.addParameter('internalmask', 'default', @(m) hasmask(obj, m));
p.parse(args{:});
range = p.Results.range;
if ~ismember('mask', p.UsingDefaults)
	range = p.Results.mask(1).apply(t); % in case of multiple masks provided, use the first one only
end

[t, idxdata] = insertnanatjump(t, .05);
X = NaN(size(idxdata));
X(idxdata) = x;
x = X;
Range = NaN(size(idxdata));
Range(idxdata) = range;
range = Range;

range = lau.raftidx(range);

[x, t] = arrayfun(@(i,j) deal([x(i:j);NaN], [t(i:j);NaN]), range(1, :), range(2, :), 'UniformOutput', false);

x = cat(1, x{:});
t = cat(1, t{:});

fn = fieldnames(p.Unmatched);
if ~isempty(fn)
	args = cell(length(fn)*2, 1);
	args(1:2:end) = fn;
	args(2:2:end) = struct2cell(p.Unmatched);
else
	args = {};
end

plot(ax, x, t, args{:});

function I = valididx(idx, x)
I = false;
if islogical(idx)
	I = isequal(numel(x), numel(idx));
elseif isnumeric(idx)
	I = min(idx)>=0 & max(idx) <= numel(x);
end