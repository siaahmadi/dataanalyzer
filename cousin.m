function c = cousin(h, type)
%COUSIN Run a BFS search on ancestors' children to find an object of type
%'type'
%
%

% Siavash Ahmadi
% 12/12/2015 5:43 PM

found = false;
c = [];

type = ['dataanalyzer.' regexp(type, '(?<=^dataanalyzer.).*|.*', 'match', 'once')];

ancestor = h.Parent.Parent;
while ~found
	c = bfschildren(ancestor,  type);
	if isempty(c)
		ancestor = ancestor.Parent;
		if isempty(ancestor) % no luck
			return;
		end
	else
		found = true;
	end
end

function c = bfschildren(a, type)

c = [];

if numel(a) == 0 % no more ancestors
	return;
end

fields = setdiff(properties(a), 'Parent'); % don't include Parent in the BFS
try
	idx = cellfun(@(f) accFunc_isa(a,type,f), fields);
catch
	idx = false; % one instance where an error is thrown is @neuron.cellType() if it hasn't been run yet -- this should change
end
if any(idx)
	c = a.(fields{find(idx, 1)});
else
	for i = 1:length(fields) % this is the breadth-first part
		try
			children = cat(1, a.(fields{i}));
		catch err
			if strcmp(err.identifier, 'MATLAB:catenate:dimensionMismatch') % usually text doesn't match
				continue;
			end
		end
		c = bfschildren(children, type);
		if ~isempty(c) % found
			return;
		end
	end
end

function I = accFunc_isa(a, type, f)

I = all(arrayfun(@(an) accFunc_isa2(an,type,f), a));

function I = accFunc_isa2(a, type, f)
try
	child = a.(f);
catch
	child = [];
end
I = isa(child, type);