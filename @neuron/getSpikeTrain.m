function S = getSpikeTrain(obj, restriction)

if nargin < 2
	restriction = 'restr';
end

if numel(obj) > 1
	S = cellfun(@(x) x.getSpikeTrain(restriction), num2cell(obj), 'UniformOutput', false);
	return
end

s = obj.spikeTrain; s = s(:)'; % 1 x n
if isempty(s)
	S = [];
	return;
end

masks = [];
if isa(obj.Parent, 'dataanalyzer.maskable')
	masks = obj.Parent.Mask; % each entry corresponds to a mask in maskarray
end

restr = validatestring(restriction, {'restr', 'unrestr', 'restricted', 'unrestricted'});

if isempty(masks) || strcmp(restr, 'unrestr')
	idx = {true(size(s))};
else
	idx = masks.apply(s);
end

if strcmp(restr, 'restr')
	S = cellfun(@(i) s(i), idx, 'un', 0);
else
	S = s(idx{1});
end