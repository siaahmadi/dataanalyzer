function [region, subregion, layer] = getRegion(obj)
region = obj.anatomicalRegion.region;
subregion = obj.anatomicalRegion.subregion;
layer = obj.anatomicalRegion.layer;

if nargout < 1
	region = obj.anatomicalRegion;
end