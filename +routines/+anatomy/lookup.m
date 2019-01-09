function anatomy = lookup(db, ratNo, ttNo, varargin)

assert(isequal(numel(ratNo), numel(ttNo)), 'ratNo and ttNo entries must correspond one-to-one.');

if numel(ratNo) > 1
	error('todo');
end

[~, idx_rat] = findstruct(db, 'Rat', ratNo);
[~, idx_tt] = findstruct(db, 'TT', ttNo);

% todo name-value pairs in varargin

optional = cell(length(varargin)/2, 1);

for i = 1:2:length(varargin)
	[~, optional(i)] = findstruct(db, varargin{i}, varargin{i+1});
end

idx = idx_rat{1}(:) & idx_tt{1}(:) & prod(cat(1, optional{:}), 1)' > 0;

anatomy = dataanalyzer.anatomy(db(idx).Region, '', db(idx).Subregion);