function newObj = clip(obj, ref)

if ~isa(ref, 'ivlset') && ~isa(ref, 'dataanalyzer.mask')
	error('Input 1, ref (%s), must be an ivlset or mask object', inputname(2));
end

newObj = copy(obj);

if isa(ref, 'dataanalyzer.mask')
	[~, newObj.timeStamps, newObj.stockX, newObj.stockY] = ref.apply(newObj.timeStamps, newObj.timeStamps,  newObj.stockX, newObj.stockY);
else
	[~, newObj.timeStamps, newObj.stockX, newObj.stockY] = ref.restrict(newObj.timeStamps, newObj.timeStamps,  newObj.stockX, newObj.stockY);
end

newObj.resetToStock();
newObj.Parent = obj;