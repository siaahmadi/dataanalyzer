function idx = apply(obj, maskable)
%APPLY Apply mask to timeable object, double array, or cell array of
%doubles

idx = arrayfun(@(x) x.apply(maskable), obj.List, 'un', 0);