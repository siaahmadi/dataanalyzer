function visualize(obj)

intervals = arrayfun(@mask2ivl, obj, 'un', 0);
ivls = cellfun(@ivlset, intervals, 'un', 0);

anc = dataanalyzer.ancestor(obj, 'dataanalyzer.visualizable'); % won't handle array of |obj|s

if ~isempty(anc) == 0 && isa(anc, 'dataanalyzer.visualizable')
	1;
	% todo
end

maskName = {obj.name}';

ivls = cat(1, ivls{:});
ivls.visualize(maskName);