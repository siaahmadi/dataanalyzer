function hc = hardcopy(obj)

hc = [];
masks = arrayfun(@(pf) pf(1).ParentMask.name, obj, 'un', 0);
for mInd = 1:length(masks)
	hc.fields.(masks{mInd}) = obj(mInd).PFields.hardcopy();
	hc.tuning.(masks{mInd}) = obj(mInd).SpatialTuningMeasures;
end