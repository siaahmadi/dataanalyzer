function hc = hardcopy(obj, unit, zeroAnchored)
if nargin > 2
	hc = obj.neurons.hardcopy(unit, zeroAnchored);
	return
elseif nargin > 1
	hc = obj.neurons.hardcopy(unit);
	return
else
	hc = obj.neurons.hardcopy();
end