function I = p___validateMask(parentMask)

I = false;

if isa(parentMask, 'dataanalyzer.mask')
	I = true;
end

if ~I
	error('DataAnalyzer:PlaceField:InvalidParentMask', 'Parent mask must be a dataanalyzer.mask object.');
end