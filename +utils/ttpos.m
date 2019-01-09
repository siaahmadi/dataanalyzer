function pos = ttpos(project_name, rat, ttno, day)
%TTPOS Find a particular tetrode's anatomical end position or all tetrodes
%in a particular anatomical location
%
% USAGE:
%   pos = ttpos(project_name, rat, ttno, day)
%   OR
%   pos = ttpos(project_name, anatomical_position)
%
%
%  pos = ttpos(project_name, rat, ttno, day)
%     returns the position of the specified tetrode
%     'day' is optional
%
%  pos = ttpos(project_name, anatomical_position)
%     returns all tetrodes in a particular location

opt = dataanalyzer.options(project_name);

if ~exist('day', 'var')
	day = 'any';
end


tt = table2struct(dataanalyzer.utils.loadttpos(opt.ttdbfile));

if nargin == 2
	[~, idx_subregion] = findstruct(tt, 'Subregion', rat);
	pos = tt(idx_subregion{1});
	return;
end

[~, idx_rat_tt] = findstruct(tt, {'Rat', 'TT'}, {rat, ttno});
idx = prod(cat(1, idx_rat_tt{:}))>0;
if isnumeric(day)
	[~, idx_day] = findstruct(tt, 'Day', day);
	idx = idx & idx_day{1};
end


pos = {tt(idx).Subregion};