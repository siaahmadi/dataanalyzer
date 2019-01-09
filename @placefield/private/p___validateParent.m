function I = p___validateParent(parent)

I = false;

if isa(parent, 'dataanalyzer.placemap')
	I = true;
end

if ~I
	error('DataAnalyzer:PlaceField:InvalidParent', 'Parent must be a dataanalyzer.placemap object.');
end