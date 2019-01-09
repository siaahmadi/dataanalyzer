function ctrOfMass = centerofmass(obj)

fieldBins = obj.fieldInfo.bins;
binRangeX = obj.fieldInfo.binRangeX;
binRangeY = obj.fieldInfo.binRangeY;

[fieldBinRate, finIdx] = obj.rate();

ctrM = meanw(fieldBins(finIdx, :), fieldBinRate/sum(fieldBinRate)); % this line is
% the only place where it's justified to use only the finite elements
% of fieldBins. The reason that it's justified is you should compute
% the center of mass with the finite squares (where there was firing;
% one should not assume firing rate was 0 at NaN elements of the
% identified boundaries) and not when calculating the area of the
% field, say.
% As of 11/18/2015 the above reason is no longer valid due to the workings
% of place map computation. The maps no longer contain NaNs--instead they
% come with a logical occupancy matrix.

ctrOfMass.y_ind = round(ctrM(1)); ctrOfMass.x_ind = round(ctrM(2));
if obj.fieldInfo.dim > 1
	ctrOfMass.y_cm = interp1(1:length(binRangeY), binRangeY, ctrM(1));
else
	ctrOfMass.y_cm = 0;
end
ctrOfMass.x_cm = interp1(1:length(binRangeX), binRangeX, ctrM(2));