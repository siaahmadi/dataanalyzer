function I = haspd(obj, pd)

if numel(obj) > 1
	error('Can''t handle more than 1 expSession at a time.');
end

if numel(pd) > 1
	I = arrayfun(@(pd) obj.haspd(pd), pd(:), 'un', 0);
	I = sum(cat(2, I{:}), 2) > 0;
	return;
end

I = ~isempty(obj.positionData.addonPD);
if I
	I = any(cellfun(@(apd) apd == pd, obj.positionData.addonPD(:)));
end