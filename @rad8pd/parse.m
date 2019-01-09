function parseInfo = parse(t, x, y, options)
%PARSE Parse path data
%
% pathData = PARSE(t, x, y, options)
% t, x, y: cell arrays for each trial
%
% pathData = PARSE(pathData, options)
% pathData: struct array with fields t, x, y
%
% Required Options:
%     'prjType'                    'orthogonal', 'hypb'
%     'rewardRadiusThreshold'      scalar real value
%     'revisitRadiusThreshold'     scalar real value
%     'stem_radius'                scalar real value
%     'pathMSEtolerance'           scalar real value
%     'armBisector'                scalar real value (radians)
% The following are not used at the moment (5/8/2018):
%     'rewardfirst'                true, false
%     'rewardImmobilityThreshold'  scalar real value


if nargin >= 3 % first syntax
	if ~iscell(t) && isnumeric(t)
		if ~isequaln(numel(t), numel(x), numel(y))
			error('Bad input. Path data number of elements mismatch.');
		end
		t = t(:);
		x = x(:);
		y = y(:);
	else
		if exist('options', 'var')
			parseInfo = cellfun(@(t,x,y) dataanalyzer.rad8pd.parse(t,x,y,options), t, x, y, 'un', 0);
		else
			parseInfo = cellfun(@(t,x,y) dataanalyzer.rad8pd.parse(t,x,y), t, x, y, 'un', 0);
		end
		parseInfo = cat(1, parseInfo{:});
		return;
	end
elseif isstruct(t) % second syntax
	if nargin == 2 % options provided
		options = x;
	end
	pd = t;
	t = {pd.t}';
	x = {pd.x}';
	y = {pd.y}';
	if exist('options', 'var')
		parseInfo = cellfun(@(t,x,y) dataanalyzer.rad8pd.parse(t,x,y,options), t, x, y, 'un', 0);
	else
		parseInfo = cellfun(@(t,x,y) dataanalyzer.rad8pd.parse(t,x,y), t, x, y, 'un', 0);
	end
	parseInfo = cat(1, parseInfo{:});
	return;
else
	error('Wrong syntax.');
end

if any(isnan(x))
	nansOfPD = find(isnan(x));
	trialsByNaN = [[1; nansOfPD(1:end-1)+1], nansOfPD-1];
	trialIdx = ivlset(trialsByNaN);
elseif iscell(x)
	% todo: cat all pathdata and separate by NaNs at the end
else % treat entire path data as a single trial
	trialIdx = ivlset(1, length(x));
end


prjType = options.prjType;
rewardRadiusThreshold = options.rewardRadiusThreshold;
rewardfirst = options.rewardfirst;
rewardImmobilityThreshold = options.rewardImmobilityThreshold;
pathMSEtolerance = options.pathMSEtolerance;
armBisector = options.armBisector;

assertPathMSE(x, y, pathMSEtolerance);

[rw_anchors.x, rw_anchors.y] = pol2cart(0:pi/4:2*pi-pi/4, rewardRadiusThreshold);
sectors = sector(x, y, armBisector);
sv = sectorvisits(sectors);
r = eucldist(0, 0, x, y);
arm_visit_idx = blendsectorvisits(sv, r);
prj_path = projpath(x, y, sectors, prjType);
% runs_farthest_pt = farthestPointInVisit(r, arm_visits, rewardRadiusThreshold); % needs to be changed to make sure |rewardfirst| is honored correctly
% rewards_immobility = stretchoflittlemovement(lin_prjpath, runs_farthest_pt, rewardImmobilityThreshold, rewardRadiusThreshold, r);
putative_rewards = findRewardEpochs(r, options);
[runs_rw_at_end, reward] = rewards2runs(putative_rewards, r);
reward_visits = sectors(runs_rw_at_end(:, 2));
run_is_in_trial = trialIdx.index(runs_rw_at_end(:, 1));

% if sum(arm_visits <= runs_farthest_pt(2)) == 1 % this happens when the trial begins on the arm--hence both an arm visit (i.e. arm_visit) and a run (i.e. runs) have been initiated at index 1
% 	center = [arm_visits(1); cell2mat(cellfun(@auxFunc_lastOfNonEmpty, ininterval(runs_farthest_pt, arm_visits, false), 'UniformOutput', false)); length(r)];
% else
% 	center = [cell2mat(cellfun(@auxFunc_lastOfNonEmpty, ininterval(runs_farthest_pt, arm_visits, false), 'UniformOutput', false)); length(r)];
% end
% |arm_visits| marks the end of arm visits, and since |@ininterval| is called non-inclusive, this last index should be added

% if ~rewardfirst % swap the role of |rewards| and |runs|, such that |rewards| will contain the indices indicating the beginning of reward consumption, and runs the end of them.
% 	buffer = runs_farthest_pt(2:end-1);
% 	runs_farthest_pt(2:end-1) = rewards_immobility;
% 	rewards_immobility = buffer;
% end

[anchor_outbound, theta_outbound] = arrayfun(@(fpx,fpy) anchor_point(rw_anchors, [fpx,fpy]), x(runs_rw_at_end(:, 1)), y(runs_rw_at_end(:, 1)), 'un', 0);
M_outbound = cellfun(@(rotate, translate) rotationMatrix(pi-rotate, -translate), theta_outbound, anchor_outbound, 'un', 0);
[anchor_inbound, theta_inbound] = arrayfun(@(fpx,fpy) anchor_point(rw_anchors, [fpx,fpy]), x(runs_rw_at_end(:, 2)), y(runs_rw_at_end(:, 2)), 'un', 0);
M_inbound = cellfun(@(rotate, translate) rotationMatrix(pi-rotate, -translate), theta_inbound, anchor_inbound, 'un', 0);

anchoredRuns_outbound = anchor_pathdata_at_origin(t, x, y, M_outbound, runs_rw_at_end);
anchoredRuns_outbound = add_arm_numbers_outbound(anchoredRuns_outbound, reward_visits, reward, options);
anchoredRuns_inbound = anchor_pathdata_at_origin(t, x, y, M_inbound, runs_rw_at_end);
anchoredRuns_inbound = add_arm_numbers_inbound(anchoredRuns_inbound, reward_visits, reward, options);

trajectory_table = separateTrajectory(anchoredRuns_outbound);

parsedBound = parseTravelBound(anchoredRuns_outbound, putative_rewards, runs_rw_at_end, options);
lin_prjpath = linearizeAnchoredRuns(anchoredRuns_outbound, options);
pathdata_linearized = ezstruct({'t', 'x'}, {{anchoredRuns_outbound.t}', lin_prjpath});

ivl = ivlset(runs_rw_at_end);
trial_idx = cellfun(@(i) struct('idx', i), ivl.restrict(1:length(t)));
[direction, dir_idx] = findRunDirection(x, y, runs_rw_at_end, {trial_idx.idx}');


trial_no = arrayfun(@(pi,i) pi.idx*i, trial_idx, [1:length(trial_idx)]', 'un', 0);
trials = sum(cat(1, trial_no{:}));

idx_zones = structfun(@(zone) arrayfun(@(i,j) idx2logic(i:j, length(t)), zone(:, 1), zone(:, 2), 'un', 0), parsedBound, 'un', 0);
idx_zones = structfun(@(zone) sum(cat(1, zone{:}))'==1, idx_zones, 'un', 0);

for i = 1:length(trial_idx)
	T{i} = structfun(@(zone) t(zone(:) & trial_idx(i).idx(:)), idx_zones, 'un', 0);
	X{i} = structfun(@(zone) x(zone(:) & trial_idx(i).idx(:)), idx_zones, 'un', 0);
	Y{i} = structfun(@(zone) y(zone(:) & trial_idx(i).idx(:)), idx_zones, 'un', 0);
% 	V{i} = structfun(@(zone) v(zone(:) & trial_idx(i).idx(:)), idx_zones, 'un', 0);
end

parseInfo.path.t = t(:);
parseInfo.path.orig.a = [x(:), y(:)];
parseInfo.path.orig.x = x(:);
parseInfo.path.orig.y = y(:);
parseInfo.path.ideal.a = prj_path;
parseInfo.path.ideal.x = prj_path(:, 1);
parseInfo.path.ideal.y = prj_path(:, 2);
parseInfo.path.ideal.prj = prjType;
parseInfo.path.linear = pathdata_linearized;

parseInfo.runs.t = cat(1, T{:});
parseInfo.runs.x = cat(1, X{:});
parseInfo.runs.y = cat(1, Y{:});
parseInfo.runs.direction_egocentric = direction(:);
parseInfo.runs.anchored.outbound.tform = M_outbound;
parseInfo.runs.anchored.outbound = anchoredRuns_outbound;
parseInfo.runs.anchored.inbound.tform = M_inbound;
parseInfo.runs.anchored.inbound = anchoredRuns_inbound;
parseInfo.runs.trajectory_table = trajectory_table;
parseInfo.runs.trial = run_is_in_trial;

parseInfo.idx = structmerge(idx_zones, dir_idx, struct('run_seq', trials(:)));

% parseInfo.runs.arms = arm_visits;
% pathData.runs.runs_farthest_pt = runs_farthest_pt;

% pathData.runs.rewards = rewards_immobility;
% pathData.runs.center = center; 

% pathData.runs.runsWcenter = [runs_farthest_pt(:); center(:)];
% pathData.runs.runsWcenter(1:2:end) = runs_farthest_pt;
% pathData.runs.runsWcenter(2:2:end) = center;


function y = auxFunc_lastOfNonEmpty(x)

y = [];
if ~isempty(x)
	y = x(end);
end

function M = rotationMatrix(rotate, translate)
rotate = [cos(rotate), -sin(rotate), 0;
	sin(rotate), cos(rotate), 0;
	0, 0, 1];
translate = [1, 0, translate(1);
			0, 1, translate(2);
			0, 0, 1];

% First translate, then rotate
M = rotate * translate; % to be multiplied by position matrix from the right (M * data)

function [anchor, theta] = anchor_point(rw_anchors, referencePt)
% Finds the reward point, given by rw_anchors) that's closest to some point
% (given by referencePt) from the path.
% if referencePt is the first point, the run will be anchored outbound, if
% this is a point at reward (at the end of the run) the anchoring will be
% inbound.

% Find the closest reward to the referencePt
d = eucldist(rw_anchors.x, rw_anchors.y, referencePt(1), referencePt(2));
[~, I] = min(d);

% return results:
anchor = [rw_anchors.x(I), rw_anchors.y(I)];
theta = cart2pol(anchor(1), anchor(2));

function pathData = anchor_pathdata_at_origin(t, x, y, M, runs_rw_at_end)

for idx = 1:size(runs_rw_at_end, 1)
	t_run = t(runs_rw_at_end(idx,1):runs_rw_at_end(idx,2))';
	x_run = x(runs_rw_at_end(idx,1):runs_rw_at_end(idx,2))';
	y_run = y(runs_rw_at_end(idx,1):runs_rw_at_end(idx,2))';
	one = ones(1,1+runs_rw_at_end(idx,2)-runs_rw_at_end(idx,1));

	pts = M{idx} * [x_run; y_run; one];
	
	pathData(idx, 1).t = t_run(:);
	pathData(idx, 1).x = pts(1, :)';
	pathData(idx, 1).y = pts(2, :)';
end


function parsed = parseTravelBound(anchoredRuns, putative_rewards, runs_rw_at_end, options)
%PARSETRAVELBOUND Parse maze into
%             -inbound (immediately following reward consumption)
%             -stem (on stem)
%             -outbound (from stem to beginning of reward consumption)
%             -reward (reward consumption).
%
% returns indices in struct |parsed|

origin.x = options.rewardRadiusThreshold;
origin.y = 0;
stem_polygon = circle(origin, options.stem_radius);
revisit_polygon = circle(origin, options.revisitRadiusThreshold);
stem = arrayfun(@(run) inpolygon(run.x, run.y, stem_polygon(:, 1), stem_polygon(:, 2)), anchoredRuns, 'un', 0);
revisit_idx = arrayfun(@(run) inpolygon(run.x, run.y, revisit_polygon(:, 1), revisit_polygon(:, 2)), anchoredRuns, 'un', 0);

parsed.in = getInboundIndex(stem, revisit_idx, runs_rw_at_end);

parsed.stem = getStemIndex(stem, revisit_idx, runs_rw_at_end);
parsed.out = getOutboundIndex(stem, revisit_idx, putative_rewards, runs_rw_at_end);
parsed.rw = NaN(size(runs_rw_at_end));
[~, rw_runs] = ismember(putative_rewards.end, runs_rw_at_end(:, 2));
parsed.rw(rw_runs, :) = [putative_rewards.begin, putative_rewards.end];
rw_noruns = isnan(parsed.rw(:, 1));
parsed.rw(rw_noruns, :) = [runs_rw_at_end(rw_noruns, 2)+1, runs_rw_at_end(rw_noruns, 2)];

function idx = getInboundIndex(stem, revisit_idx, runs_rw_at_end)
firststem = cellfun(@(x) uniform(find(x,1), 0), stem);
revisit_idx = cellfun(@(x) uniform(find(x,1), 0), revisit_idx);
firststem(firststem == 0) = revisit_idx(firststem == 0);
if firststem(end) == 0 % trial didn't end inside revist zone
	firststem(end) = length(stem{end});
end

idx = cellfun(@(stem,run) [run(1),run(1)-1+stem-1], num2cell(firststem), row2cell(runs_rw_at_end), 'un', 0);
idx = cat(1, idx{:});

function idx = getStemIndex(stem, revisit_idx, runs_rw_at_end)
firststem = cellfun(@(x) uniform(find(x,1), 1), stem);
laststem = cellfun(@(x) uniform(find(x,1,'last'), 0), stem);
revisit_first = cellfun(@(x) uniform(find(x,1), 1), revisit_idx);
firststem(firststem == 0) = revisit_first(firststem == 0);

idx = arrayfun(@(firststem,laststem,run) [run(1)-1+firststem,run(1)-1+laststem], firststem, laststem, runs_rw_at_end(:, 1), 'un', 0);
idx = cat(1, idx{:});

function idx = getOutboundIndex(stem, revisit_idx, putative_rewards, runs_rw_at_end)
% The outbound portion of a run is the moment the animal leaves the stem to
% the beginning of reward

nextReward = 1;
idx = cell(size(runs_rw_at_end, 1), 1);
for run = 1:size(runs_rw_at_end, 1)
	if run == 9
		1;
	end
	laststem = find(stem{run}, 1, 'last') + runs_rw_at_end(run, 1) - 1;
	if isempty(laststem)
		laststem = runs_rw_at_end(run, 2) + 1;
	end
	if nextReward <= length(putative_rewards.end) && runs_rw_at_end(run, 2) == putative_rewards.end(nextReward) % nextReward is the same as the end point of this run
		idx{run} = [laststem+1, putative_rewards.begin(nextReward)-1]; % post-stem up until the NaN at the end of the run
		nextReward = nextReward + 1; % look to the next reward on the following cycle
	elseif nextReward <= length(putative_rewards.end) && runs_rw_at_end(run, 2) < putative_rewards.end(nextReward) % no reward at the end of run
		idx{run} = [laststem+1, runs_rw_at_end(run, 2)]; % this might end up being descending: either 1) never present on stem, 2) always on stem
	elseif nextReward == length(putative_rewards.end)+1 % last run
		idx{run} = [laststem+1, runs_rw_at_end(run, 2)];
	else
		error('This should not happen. There must be a bug somewhere before this line.');
	end
end


% % Old version, works for only one trial with no NaNs:
% laststem = cellfun(@(x) uniform(find(x,1,'last'), 0), stem);
% revisit_idx = cellfun(@(x) uniform(find(x,1), 0), revisit_idx);
% laststem(laststem == 0) = revisit_idx(laststem == 0);
% 
% if length(putative_rewards.begin) < length(laststem) % trial ended on stem
% 	idx = arrayfun(@(stem,run,rw) [run-1+stem+1, rw-1], laststem, runs_rw_at_end(:, 1), [putative_rewards.begin; 1], 'un', 0);
% else % trial ended outside stem
% 	idx = arrayfun(@(stem,run,rw) [run-1+stem+1, rw-1], laststem, runs_rw_at_end(:, 1), putative_rewards.begin, 'un', 0);
% end

idx = cat(1, idx{:});

function c = circle(origin, radius)
% Make an m-by-2 matrix of circular (x, y) coordinates with radius |radius|
% centerd at |origin| (struct with fields |x| and |y|). Last point repeats.
x_upper = radius:-0.1:-radius;
x_lower = -radius+.1:.1:radius;
y_upper = sqrt(radius^2 - x_upper.^2);
y_lower = -sqrt(radius^2 - x_lower.^2);

c = [x_upper(:), y_upper(:); x_lower(:), y_lower(:)];
c(:, 1) = c(:, 1) + origin.x;
c(:, 2) = c(:, 2) + origin.y;
[c(:, 1), c(:, 2)] = poly2cw(c(:, 1), c(:, 2));

function ang = mycart2pol(x,y,i)
idx = i-1+find(~isnan(x(i:end)), 1);
if ~isempty(idx)
	ang = cart2pol(x(idx), y(idx));
else
	ang = 0;
end

function [direction, idx] = findRunDirection(x, y, runs_rw_at_end, trial_idx)
% Define a dictionary of egocentric "directions"
dirs = {'S', 'SE', 'E', 'NE', 'N', 'NW', 'W', 'SW'};
% Find the angle of the first point in the run
angles_begin = arrayfun(@(i) mycart2pol(x,y,i), runs_rw_at_end(:, 1));
angles_begin = mod(angles_begin+2*pi, 2*pi);
% Find the angle of the last point in the run
angles_end = arrayfun(@(i) mycart2pol(x,y,i), runs_rw_at_end(:, 2));
angles_end = mod(angles_end+2*pi, 2*pi);
% Find the angle between the last and the first points in the run
% (trigonometric circle-wise)
angles = mod(angles_end+2*pi-angles_begin, 2*pi);
% Convert the angles to indices
angle_idx = interp1(0:pi/4:2*pi, 1:9, angles, 'nearest'); % goes out to a "9th" arm for interpolation reasons (i.e. interp1 returns NaN for out-of-range,
% hence 2*pi-pi/16 would return NaN, when it should return 1 (or 9, which will be transformed into 1 in the following line))

% Look up the indices in the dictionary defined earlier in the function
direction = dirs(mod(angle_idx-1,8)+1); % the mod is taking care of the "9th" arm

idx = cell(size(dirs));
for i = 1:length(dirs)
	[ism, ia] = ismember(direction, dirs{i});
	if ~any(ism)
		idx{i} = false(size(trial_idx{1}));
	else
		idx{i} = sum(cat(1, trial_idx{ia==1}), 1)==1;
	end
	idx{i} = idx{i}(:);
end

idx = ezstruct(dirs, idx);

function [runs_rw_at_end, reward] = rewards2runs(putative_rewards, r)
runs_rw_at_end = [[1; putative_rewards.end+1], [putative_rewards.end; length(r)]];
[runs_rw_at_end, reward] = helper_rewards2runs_breakRunsThatIncludeEndOfTrialNans(r, runs_rw_at_end, putative_rewards);
valid = runs_rw_at_end(:, 2) > runs_rw_at_end(:, 1);
runs_rw_at_end = runs_rw_at_end(valid, :);
reward = reward(valid);

function [runs_rw_at_end_corrected, reward] = helper_rewards2runs_breakRunsThatIncludeEndOfTrialNans(r, runs_rw_at_end, putative_rewards)
runsToBreak = find(arrayfun(@(i,j) any(isnan(r(i:j))), runs_rw_at_end(:, 1), runs_rw_at_end(:, 2)));
if isempty(runsToBreak)
	runs_rw_at_end_corrected = runs_rw_at_end(runs_rw_at_end(:, 2) > runs_rw_at_end(:, 1), :);
	
	reward = false(size(runs_rw_at_end_corrected, 1), 1);
	runs = ivlset(runs_rw_at_end_corrected);
	reward_runs = runs.index(putative_rewards.begin);
	reward(reward_runs) = true;
	
	return;
end
idxOfBreak = find(isnan(r));

newRuns = cell(length(runsToBreak), 1);
i = 1;
j = 0;
for run = runsToBreak(:)'
	j = j + 1;
	currentTestRun = [runs_rw_at_end(run, 1), runs_rw_at_end(run, 2)];
	brokenRun = [runs_rw_at_end(run, 1), idxOfBreak(i)-1];
	while currentTestRun(1) <= currentTestRun(2) && idxOfBreak(i) <= currentTestRun(2) % a designated run might have multiple break points (i.e. NaNs)
		if brokenRun(2) >= brokenRun(1) % add only if valid
			newRuns{j} = [newRuns{j}; {brokenRun}];
		end
		currentTestRun = [idxOfBreak(i)+1, runs_rw_at_end(run, 2)];
		if i < length(idxOfBreak)
			i = i + 1;
		end
		brokenRun = [idxOfBreak(i-1)+1, idxOfBreak(i)-1];
	end
	% add the remainder of the run to the list
	if currentTestRun(1) <= currentTestRun(2) && idxOfBreak(i) > currentTestRun(2)
		newRuns{j} = [newRuns{j}; {currentTestRun}];
	end
end
i = 1;
j = 0;
runs_rw_at_end_corrected = [];
for run = runsToBreak(:)'
	j = j + 1;
	runs_rw_at_end_corrected = [runs_rw_at_end_corrected; runs_rw_at_end(i:run-1, :); cat(1, newRuns{j}{:})];
	i = run+1;
end

reward = false(size(runs_rw_at_end_corrected, 1), 1);
runs = ivlset(runs_rw_at_end_corrected);
reward_runs = runs.index(putative_rewards.begin);
reward(reward_runs) = true;


function idealRuns = idealizeAnchoredRuns(anchoredRuns, options)
armBisector = options.armBisector;
xoffset = options.rewardRadiusThreshold;

sc = arrayfun(@(run) sector(run.x-xoffset, run.y, armBisector), anchoredRuns, 'un', 0);
prj = cellfun(@(run,sc) projpath(run.x-xoffset, run.y, sc, 'ortho'), num2cell(anchoredRuns), sc, 'un', 0);
[X, Y] = cellfun(@(run) deal(run(:, 1)+xoffset, run(:, 2)), prj, 'un', 0);
idealRuns = ezstruct({'x', 'y'}, {X, Y});

function sklt = anchoredInterpolantSkeleton(options)
xtreme = options.rewardRadiusThreshold; % add 50% to the reward radius
numArms = 8;
angle_between_two_consecutive_arms = 2*pi/numArms;
resolution = 100;
cvgMlp = 1.5; % coverage multiplier
startRad = cvgMlp*xtreme / round(cvgMlp*resolution);

inbound_arm.x = linspace(-xtreme/2,xtreme, round(cvgMlp*resolution))';
inbound_arm.y = zeros(round(cvgMlp*resolution), 1);
inbound_arm.v = linspace(-xtreme/2,xtreme, round(cvgMlp*resolution))';

outbound_arm1.theta = ones(round(cvgMlp*resolution), 1) * (pi+angle_between_two_consecutive_arms);
outbound_arm1.rho = linspace(startRad, cvgMlp*xtreme, round(cvgMlp*resolution))';

[outbound_arm.x, outbound_arm.y] = arrayfun(@(arm) pol2cart(outbound_arm1.theta+arm*angle_between_two_consecutive_arms,outbound_arm1.rho), (1:numArms-1)'-1, 'un', 0);
outbound_arm.x = cat(1, outbound_arm.x{:})+xtreme;
outbound_arm.y = cat(1, outbound_arm.y{:});
outbound_arm.v = repmat(linspace(xtreme,xtreme+cvgMlp*xtreme, round(cvgMlp*resolution)), 1, numArms-1)';

sklt.x = [inbound_arm.x; outbound_arm.x];
sklt.y = [inbound_arm.y; outbound_arm.y];
sklt.v = [inbound_arm.v; outbound_arm.v];

function lin_prjpath = linearizeAnchoredRuns(anchoredRuns, options)
idealRuns = idealizeAnchoredRuns(anchoredRuns, options);
sklt = anchoredInterpolantSkeleton(options);
F = scatteredInterpolant(sklt.x, sklt.y, sklt.v, 'nearest');

lin_prjpath = cellfun(@(x,y) F(x,y), {idealRuns.x}', {idealRuns.y}', 'un', 0);

function anchoredRuns_inbound = add_arm_numbers_inbound(anchoredRuns_inbound, reward_visits, reward, options)

CENTER_OF_ANCHORED = options.rewardRadiusThreshold;
valid = num2cell(assertRunValidity(anchoredRuns_inbound, reward, CENTER_OF_ANCHORED, options));

reward_visits = num2cell(reward_visits);
origin_visits = [NaN; reward_visits(1:end-1)];
[anchoredRuns_inbound.arm_begin] = origin_visits{:};
[anchoredRuns_inbound.arm_end] = reward_visits{:};
[anchoredRuns_inbound.valid] = valid{:};

function anchoredRuns_outbound = add_arm_numbers_outbound(anchoredRuns_outbound, reward_visits, reward, options)
CENTER_OF_ANCHORED = options.rewardRadiusThreshold;
valid = num2cell(assertRunValidity(anchoredRuns_outbound, reward, CENTER_OF_ANCHORED, options));

reward_visits = num2cell(reward_visits);
origin_visits = [NaN; reward_visits(1:end-1)];
[anchoredRuns_outbound.arm_begin] = origin_visits{:};
[anchoredRuns_outbound.arm_end] = reward_visits{:};
[anchoredRuns_outbound.valid] = valid{:};

function valid = assertRunValidity(anchoredRuns, reward, CENTER_OF_ANCHORED, options)
r_begin = arrayfun(@(pd) eucldist(CENTER_OF_ANCHORED, 0, pd.x(1), pd.y(1)), anchoredRuns);
r_max_2nd_half = arrayfun(@(pd) max(eucldist(CENTER_OF_ANCHORED, 0, pd.x(floor(length(pd.y)/2)+1:end), pd.y(floor(length(pd.y)/2)+1:end))), anchoredRuns);
valid = r_begin >= options.revisitRadiusThreshold & r_max_2nd_half >= options.rewardRadiusThreshold & reward;

function trajectory_table = separateTrajectory(anchoredRuns)

valid = cat(1, anchoredRuns.valid);
arm_begin = cat(1, anchoredRuns.arm_begin);
arm_end = cat(1, anchoredRuns.arm_end);

arms_out_from = finite(unique(arm_begin));

trajectory_table = false(8, 8, length(anchoredRuns));

% this can be calculated from the point of view of "inbound" or "outbound".
% I chose to do it from the point of view of "outbound". Both should give
% the same result. To look only at inbound or outbound runs the "trajectory_table"
% matrix can be view by columns or by rows.
for arm_from = arms_out_from(:)'
	arms_out_to = finite(arm_end(arm_begin == arm_from));
	
	for arm_to = unique(arms_out_to(:))'
		trajectory_table(arm_from, arm_to, :) = arm_begin == arm_from & arm_end == arm_to;
	end
end

trajectory_table(:, :, ~valid) = false;