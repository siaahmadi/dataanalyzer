function I = isempty(obj)

I = arrayfun(@(o) isempty(o.tEffectiveIvls), obj);