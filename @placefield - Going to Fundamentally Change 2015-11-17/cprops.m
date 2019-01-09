function pfields = cprops(obj, rateMap, fieldBins, boundaryStruct, binRangeX, binRangeY, constraints)
% compute placefield properties
%
% The average rate obtained from pfields.meanRate is NOT going to be the
% same as the pfields.numSpikes/pfields.ts_duration!
% This is because meanRate is obtained by smoothing the map, among other
% operations which is different than taking the total number of spikes and
% dividing that number by the time spent within the field.

nFields = numel(boundaryStruct);
if ~exist('constraints', 'var')
	constraints = [];
end

% to make this piece of code more readable, I'm gonna define each field
% first and put everything together afterwards
ctrOfMass = struct('x_cm', [], 'y_cm', [], 'x_ind', [], 'y_ind', []);
cvxHull = struct('x_cm', [], 'y_cm', [], 'area', []);
area = [];
meanRate = [];
peakRate = [];
passes = struct('idx', [], 'x', [], 'y', [], 'ts', []);
shnnInfo = [];
pfieldStruct = struct('ctrOfMass', ctrOfMass, 'cvxHull', cvxHull, ...
	'area', area, 'meanRate', meanRate, 'peakRate', peakRate, ...
	'passes', passes, 'avgVelocity', [], 'shnnInfo', shnnInfo);

pfields = repmat(pfieldStruct, nFields, 1);


for pfInd = 1:nFields

	% convex hull
	x = boundaryStruct(pfInd).boundary(1, :)*max(binRangeX); x = x(isfinite(x));
	y = boundaryStruct(pfInd).boundary(2, :)*max(binRangeY); y = y(isfinite(y));
	% the isfinite line is because extractpfSession takes the union of
	% multiple fields and that may introduce discontinuities in the
	% representation of the polygons in MATLAB (i.e. the borders must be
	% separated by a NaN).
	[K,A] = convhull(x,y);
	cvxHull.x_cm = x(K);
	cvxHull.y_cm = y(K);
	cvxHull.area = A;
	pfields(pfInd).cvxHull = cvxHull;	
	
	% center of mass
	fieldBinRate = rateMap(sub2ind(size(rateMap), fieldBins{pfInd}(:, 1),  fieldBins{pfInd}(:, 2)));
	if length(fieldBinRate)>1 % if it's only one square and == NaN then leave it at that
		% otherwise remove NaNs
		finIdx = isfinite(fieldBinRate);
		fieldBinRate(~finIdx) = [];
	else
		1;
	end
	ctrM = meanw(fieldBins{pfInd}(finIdx, :), fieldBinRate/sum(fieldBinRate)); % this line is
	% the only place where it's justified to use only the finite elements
	% of fieldBins. The reason that it's justified is you should compute
	% the center of mass with the finite squares (where there was firing;
	% one should not assume firing rate was 0 at NaN elements of the
	% identified boundaries) and not when calculating the area of the
	% field, say.
	ctrOfMass.y_ind = round(ctrM(1)); ctrOfMass.x_ind = round(ctrM(2));
	ctrOfMass.y_cm = interp1(1:length(binRangeY), binRangeY, ctrM(1));
	ctrOfMass.x_cm = interp1(1:length(binRangeX), binRangeX, ctrM(2));
	pfields(pfInd).ctrOfMass = ctrOfMass;
	
	% area
	areaOfEachBin = (binRangeX(2)-binRangeX(1)) * (binRangeY(2)-binRangeY(1));
	pfields(pfInd).area = size(fieldBins{pfInd}, 1)*areaOfEachBin;
	
	% mean and peak rates
	pfields(pfInd).meanRate = mean(fieldBinRate);
	pfields(pfInd).peakRate = max(fieldBinRate);
	
	% passes
	S = obj.parent.getSpikeTrain();
	polyROI = [x;y];
	passes = obj.parent.parentTrial.positionData.getPassesThroughPolygon(polyROI, constraints);
	passes = passes{1}; % this is because I wrote getPassesThroughPolygon to handle more than 1 constraint
						% but now I don't need it to do that. I leave
						% getPassesThroughPolygon with what it does but
						% since cprops should never receive more than 1
						% constraint at a time this line is there to ensure
						% everything works
	[~, passes] = dataanalyzer.placefield.extractSpikesPass(passes, S);
	pfields(pfInd).passes = passes;
	
	% time spent in ROI:
	%%% this is my most accurate esimate of the true duration inside ROI
	% this can be estimated, less accurately, by summing all the individual
	% durations estimated for single passes: sum(cat(1,passes.ts_duration))
	a = {passes.ts}';
	sRate = meanw(cellfun(@(x) mean(diff(x)), a), cellfun(@(x) length(x), a));
	if isempty(sRate) % animal never passes through (it might be due to different trajectories in different trials)
		sRate = 0;
	end
	totalInROIDuration = length(cat(2,passes.ts))*sRate;
	pfields(pfInd).duration = totalInROIDuration;
	%%%%
	
	% velocity
	X = {passes.x}';
	Y = {passes.y}';
	pfields(pfInd).distanceCovered = sum(cell2mat(cellfun(@(X,Y) eucldist(X(2:end), Y(2:end), X(1:end-1), Y(1:end-1)), X, Y, 'UniformOutput', false)));
	pfields(pfInd).avgVelocity = pfields(pfInd).distanceCovered / pfields(pfInd).duration;
	
	% information content (TODO)
% 	skgInfo = dataanalyzer.makePlaceMaps.skaggsi(spikeTrain, locationInfo, sumMask, minSpikes);
% 	pfields(pfInd).shnnInfo = skgInfo;

	%%% TODO: multiply these by max of binRangeX and binRangeY
	pfields(pfInd).bin_idx_on_rateMap = fieldBins{pfInd};
	pfields(pfInd).boundary = boundaryStruct(pfInd);
end