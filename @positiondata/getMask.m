function mask = getMask(obj, select, each)

anc = dataanalyzer.ancestor(obj, 'dataanalyzer.maskable', true);

if ~exist('select', 'var') || isempty(select)
	% do select
	select = true(size(obj.Mask.List));
end

if isa(obj.Mask, 'dataanalyzer.mask') && strcmp(obj.Mask.name, 'default')%|| numel(obj.Mask.List) == 0 % use ancestor
	if isa(anc, 'dataanalyzer.maskable')
		if ~exist('each', 'var')
			error('todo');
		else
			mask = anc.getMask();
		end
		return;
	else % doesn't have a mask or a maskable ancestor (since I added a 'default' mask to the initializer of positiondata this should not execute. Leaving it for optimization purposes using MATLAB's timer.
		mask = obj.Mask;
	end
else % use obj
	if exist('select', 'var')
		if ~strcmp(select, 'each') && ~(exist('each', 'var') && strcmpi(each, 'each')) % if 2nd argument is 'each', disregard the 3rd argument
			if ~exist('each', 'var') % if a pair is not given, make it a pair
				each = select;
			end
			% process the pair
			masknames = {obj.Mask.List.name};
			[~, idx] = intersect(masknames, each, 'stable');
			mask = obj.Mask.List(idx);
		else % disregarding the 3rd arg
			mask = obj.Mask.List;
		end
		return;
	end
	ivl = ivlset(obj.Mask.List.mask2ivl);
	mask = dataanalyzer.mask(ivl, obj.Parent, 'all');
end