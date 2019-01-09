function idx = mask2idx(obj)

if numel(obj) > 1
	idx = {obj.tIdx}';
else
	idx = obj.tEffectiveIvls.restrict(obj.Parent.getTS('unrestr'));
	idx = sum(cat(2, idx{:}), 2) > 0;
end