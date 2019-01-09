function newObj = clip(obj, ref)

if ~isa(ref, 'ivlset') && ~isa(ref, 'dataanalyzer.mask')
	error('Input 1, ref (%s), must be an ivlset or mask object', inputname(2));
end

newObj = copy(obj);

if isa(ref, 'dataanalyzer.mask')
	ivl = ref.mask2ivlset;
else
	ivl = ref;
end

[~, newObj.spikeTrain, newObj.phases] = ivl.restrict(newObj.spikeTrain, newObj.spikeTrain, newObj.phases);
newObj.Parent = obj;
