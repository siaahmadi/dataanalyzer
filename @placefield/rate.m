function [r, finIdx] = rate(obj)
%RATE Firing rate of parentNeuron inside the identified field (this is done
%for c20 by default)

fieldBins = obj.fieldInfo.bins;
rateMap = obj.fieldInfo.fullrmap;
occup = obj.Parent.RMap.occup;
rateMap(~occup) = NaN;


r = rateMap(sub2ind(size(rateMap), fieldBins(:, 1),  fieldBins(:, 2)));
if length(r)>1 % if it's only one square and == NaN then leave it at that
	% otherwise remove NaNs
	finIdx = isfinite(r);
	r(~finIdx) = [];
end