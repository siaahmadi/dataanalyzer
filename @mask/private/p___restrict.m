function Idx = p___restrict(values, restriction)

if ~isa(restriction, 'ivlset')
	error('DataAnalyzer:Mask:InvalidRestriction', '"%s" must be an ivlset object.\n', inputname(2));
end

Idx = restriction.restrict(values);