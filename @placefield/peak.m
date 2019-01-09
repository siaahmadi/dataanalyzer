function [p, peakLoc] = peak(obj)

[fieldBinRate, finIdx] = obj.rate();
binRangeX = obj.fieldInfo.binRangeX;
binRangeY = obj.fieldInfo.binRangeY;
fieldBins = obj.fieldInfo.bins;

[p, I] = max(fieldBinRate);

if any(I)
	I = last(find(finIdx, I));
	peakLoc.y_ind = fieldBins(I, 1); peakLoc.x_ind = fieldBins(I, 2);
	if obj.fieldInfo.dim > 1
		peakLoc.y_cm = interp1(1:length(binRangeY), binRangeY, peakLoc.y_ind);
	else
		peakLoc.y_cm = 0;
	end
	peakLoc.x_cm = interp1(1:length(binRangeX), binRangeX, peakLoc.x_ind);
else
	peakLoc.y_ind = NaN;
	peakLoc.x_ind = NaN;
	peakLoc.y_cm = NaN;
	peakLoc.x_cm = NaN;
end