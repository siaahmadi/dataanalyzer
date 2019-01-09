function newObj = p___logical(operator, obj, obj2)

if ~exist('obj2', 'var') % unary operator
	ivl = feval(operator, obj.mask2ivlset());
	name = [operator '_' obj.name];
else % binary operator
	ivl = feval(operator, obj.mask2ivlset(), obj2.mask2ivlset());
	name = [obj2.name operator obj.name];
end

newObj = dataanalyzer.mask(ivl, obj, name);