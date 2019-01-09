function dynProps = cprops(obj, contour)
% compute placefield properties
%
% The average rate obtained from pfields.meanRate is NOT going to be the
% same as the pfields.numSpikes/pfields.ts_duration!
% This is because meanRate is obtained by smoothing the map, among other
% operations which is different than taking the total number of spikes and
% dividing that number by the time spent within the field.

if nargin < 2
	availableContours = regexp(fieldnames(obj.fieldInfo.boundary), '^c\d{2}$', 'match', 'once');
	cpropsContours = dataanalyzer.constant('cpropsContours');
	
	contour = intersect(cpropsContours, availableContours);
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

dynProps.(contour) = initialize();

if isempty(obj) % phantom field (rate too low to be a field)
	fprintf('Skipping contour %s. No field extracted from reference map (i.e. phantom field).\n', contour);
	return;
end

% parentNeuron = dataanalyzer.ancestor(obj, 'neuron');
% pd = dataanalyzer.sibling(parentNeuron, 'positiondata').('obj'); % this is vulnerable -- obj may have more than one positiondata type sibling. should be fine for now 11/19/2015
parentNeuron = obj.Parent.RefNeuron;
pd = obj.Parent.RefPD;

% to make this piece of code more readable, I'm gonna define each field
% first and put everything together afterwards


% convex hull
dynProps.(contour).cvxHull = obj.convhull(contour);

% center of mass
dynProps.(contour).ctrOfMass = obj.centerofmass();

% area
dynProps.(contour).area = obj.area(contour);

% diameter
dynProps.(contour).diameter = obj.diameter(contour);

% mean and peak rates
fieldBinRate = obj.rate();
dynProps.(contour).meanRate = mean(fieldBinRate);
[dynProps.(contour).peakRate, dynProps.(contour).peakLoc] = obj.peak();

% passes
tic;
passes = pd.passesThroughROI(obj, obj.ParentMask, parentNeuron);
toc;
if numel(passes) == 0 % no time spent in field (may be due to masking)
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

function pfieldStruct = initialize()

ctrOfMass = struct('x_cm', [], 'y_cm', [], 'x_ind', [], 'y_ind', []);
peakLoc = struct('x_cm', [], 'y_cm', [], 'x_ind', [], 'y_ind', []);
cvxHull = struct('x_cm', [], 'y_cm', [], 'area', []);
area = 0;
diameter = NaN;
meanRate = NaN;
peakRate = NaN;
passes = repmat(dataanalyzer.mazerun(), 0, 1);
shnnInfo = NaN;
pfieldStruct = struct('ctrOfMass', ctrOfMass, 'cvxHull', cvxHull, 'peakLoc', peakLoc, ...
	'area', area, 'diameter', diameter, 'meanRate', meanRate, 'peakRate', peakRate, ...
	'passes', passes, 'avgVelocity', NaN, 'shnnInfo', shnnInfo);