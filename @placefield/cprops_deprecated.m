function dynProps = cprops(obj, contour)
% compute placefield properties
%
% The average rate obtained from pfields.meanRate is NOT going to be the
% same as the pfields.numSpikes/pfields.ts_duration!
% This is because meanRate is obtained by smoothing the map, among other
% operations which is different than taking the total number of spikes and
% dividing that number by the time spent within the field.

if nargin < 2
% 	contour = regexp(fieldnames(obj.fieldInfo.boundary), '^c\d{2}$', 'match', 'once');
	% TODO: uncomment above lines and set obj's dynProps
	contour = {'c20'; 'c50'};
	dynProps = cellfun(@(x) obj.cprops(x), contour, 'UniformOutput', false);
	for i = 1:length(contour)
		dp.(contour{i}) = dynProps{i}.(contour{i});
	end
	dynProps = dp;
	return;
end

if ~ischar(contour) || isempty(regexp(contour, '^c\d{2}$', 'match', 'once'))
	error('DataAnalyzer:PlaceField:CProps:InvalidContour', 'contour must be a string starting with ''c'' followed by two digits.');
end

fprintf('Computing properties (cprops) for contour %s.\n', contour);

rateMap = obj.fieldInfo.fullrmap;
occup = obj.Parent.RMap.occup;
rateMap(~occup) = NaN;
fieldBins = obj.fieldInfo.bins;
boundaryStruct = obj.fieldInfo.boundary;
binRangeX = obj.fieldInfo.binRangeX;
binRangeY = obj.fieldInfo.binRangeY;

parentNeuron = dataanalyzer.ancestor(obj, 'neuron');
pd = dataanalyzer.sibling(parentNeuron, 'positiondata').('obj'); % this is vulnerable -- obj may have more than one positiondata type sibling. should be fine for now 11/19/2015

% to make this piece of code more readable, I'm gonna define each field
% first and put everything together afterwards
ctrOfMass = struct('x_cm', [], 'y_cm', [], 'x_ind', [], 'y_ind', []);
peakLoc = struct('x_cm', [], 'y_cm', [], 'x_ind', [], 'y_ind', []);
cvxHull = struct('x_cm', [], 'y_cm', [], 'area', []);
area = 0;
diameter = NaN;
meanRate = NaN;
peakRate = NaN;
passes = repmat(dataanalyzer.mazerun(pd, NaN, NaN, NaN, NaN, NaN), 0, 1);
shnnInfo = NaN;
pfieldStruct = struct('ctrOfMass', ctrOfMass, 'cvxHull', cvxHull, 'peakLoc', peakLoc, ...
	'area', area, 'diameter', diameter, 'meanRate', meanRate, 'peakRate', peakRate, ...
	'passes', passes, 'avgVelocity', NaN, 'shnnInfo', shnnInfo);

dynProps.(contour) = pfieldStruct;

if isempty(boundaryStruct) % phantom field (rate too low to be a field)
	return;
end

% convex hull
x = boundaryStruct.(contour)(1, :); x = x(isfinite(x));
y = boundaryStruct.(contour)(2, :); y = y(isfinite(y));
% the isfinite line is because extractpfSession takes the union of
% multiple fields and that may introduce discontinuities in the
% representation of the polygons in MATLAB (i.e. the borders must be
% separated by a NaN).
[K,A] = convhull(x,y);
cvxHull.x_cm = x(K);
cvxHull.y_cm = y(K);
cvxHull.area = A;
dynProps.(contour).cvxHull = cvxHull;

% center of mass
fieldBinRate = rateMap(sub2ind(size(rateMap), fieldBins(:, 1),  fieldBins(:, 2)));
if length(fieldBinRate)>1 % if it's only one square and == NaN then leave it at that
	% otherwise remove NaNs
	finIdx = isfinite(fieldBinRate);
	fieldBinRate(~finIdx) = [];
end

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
ctrOfMass.y_cm = interp1(1:length(binRangeY), binRangeY, ctrM(1));
ctrOfMass.x_cm = interp1(1:length(binRangeX), binRangeX, ctrM(2));
dynProps.(contour).ctrOfMass = ctrOfMass;


% area
try
	dynProps.(contour).area = polyarea(obj.fieldInfo.boundary.(contour)(1,:), obj.fieldInfo.boundary.(contour)(2,:));
catch err
	if strcmp(err.identifier, 'MATLAB:UndefinedFunction') % if @polyarea is not available for some reason
		areaOfEachBin = (binRangeX(2)-binRangeX(1)) * (binRangeY(2)-binRangeY(1));
		dynProps.(contour).area = size(fieldBins, 1)*areaOfEachBin;
	else
		rethrow(err);
	end
end

dynProps.(contour).diameter = polydiam([x(:), y(:)]);

% mean and peak rates
dynProps.(contour).meanRate = mean(fieldBinRate);
[dynProps.(contour).peakRate, I] = max(fieldBinRate);

if any(I)
	I = last(find(finIdx, I));
	peakLoc.y_ind = fieldBins(I, 1); peakLoc.x_ind = fieldBins(I, 2);
	peakLoc.y_cm = interp1(1:length(binRangeY), binRangeY, peakLoc.y_ind);
	peakLoc.x_cm = interp1(1:length(binRangeX), binRangeX, peakLoc.x_ind);
else
	peakLoc.y_ind = NaN;
	peakLoc.x_ind = NaN;
	peakLoc.y_cm = NaN;
	peakLoc.x_cm = NaN;
end
dynProps.(contour).peakLoc = peakLoc;

% passes
S.ts = parentNeuron.getSpikeTrain('unrestr');
S.phase = parentNeuron.phases;

objPolyg = [x;y];
tic;
passes = pd.getPassesThroughPolygon(objPolyg, obj.ParentMask, S);
toc;
if numel(passes) > 0 % if animal did actually spend time in the field
	arrayfun(@(x) x.setParent(obj), passes, 'UniformOutput', false);
else % no time spent in field (may be due to masking)
	return;
end

dynProps.(contour).passes = passes;

% time spent in ROI:
%%% this is my most accurate esimate of the true duration inside ROI
% this can be estimated, less accurately, by summing all the individual
% durations estimated for single passes: sum(cat(1,passes.ts_duration))
a = {passes.ts}';
sRate = meanw(cellfun(@(x) mean(diff(x)), a), cellfun(@(x) length(x), a));
if isempty(sRate) % animal never passes through (it might be due to different trajectories in different trials)
	sRate = 0;
end
totalInROIDuration = sum(arrayfun(@(p) length(p.ts), passes))*sRate;
dynProps.(contour).duration = totalInROIDuration;
%%%%

% velocity
X = {passes.x}';
Y = {passes.y}';
dynProps.(contour).distanceTraversed = sum(cellfun(@auxFunc_totalRunDist, X, Y));
dynProps.(contour).avgVelocity = dynProps.(contour).distanceTraversed / dynProps.(contour).duration;

% information content (TODO)
% 	skgInfo = dataanalyzer.makePlaceMaps.skaggsi(spikeTrain, locationInfo, sumMask, minSpikes);
% 	pfields.shnnInfo = skgInfo;

function r = auxFunc_totalRunDist(x, y)
if length(x) < 2
	r = 0;
	return;
end
r = sum(eucldist(x(2:end), y(2:end), x(1:end-1), y(1:end-1)));