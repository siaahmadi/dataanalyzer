function I = p___validateRateMap(rmap)

I = false;

if ismatrix(rmap) && isnumeric(rmap)
	I = true;
end

if ~I
	error('DataAnalyzer:PlaceField:InvalidRateMap', 'Rate map must be a numeric matrix.');
end