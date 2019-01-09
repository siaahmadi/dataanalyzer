function s = sibling(h, type)

type = regexp(type, '((?<=^dataanalyzer.)\w*$)|(^\w*$)', 'match', 'once');

p = properties(h.Parent);
c = cellfun(@(x) accFunc_eval(x, h), p, 'UniformOutput', false);

mcls = cellfun(@meta.class.fromName, c, 'UniformOutput', false);
mcls = cat(1, mcls{:});

sInd = 0;
for pInd = 1:length(mcls)
	if isa(h.Parent.(p{pInd}), ['dataanalyzer.' type])
		sInd = sInd + 1;
		s(sInd).obj = h.Parent.(p{pInd});
		s(sInd).name = p{pInd};
	end
end

function c = accFunc_eval(x, h) %#ok<INUSD>

c = eval(['class(h.Parent.', x, ')']);