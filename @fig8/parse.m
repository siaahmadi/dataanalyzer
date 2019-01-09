function pd = parse(pathData, options)
%PARSE Parse path data
%
% pathData = PARSE(pi, x, y, t, options)
% x, y, t: pathdata for a whole session
% 
% trials must be separated by NaNs in the x, y, t vectors.

try
	[pathDataIdeal, locInfo] = idealizepath(pathData);
catch
% 	To Do: put target trials's pathData.x, pathData.y in x, y variables
	x = pathData.x;
	y = pathData.y;
	figure;plot(x,y);
	brushed_locs = lau.raftidx(get(get(gca,'children'), 'BrushData'));
	ind = reshape(brushed_locs(:), numel(brushed_locs)/2, 2);
	for i = 1:size(ind, 1)
		x(ind(i, 1):ind(i,2)) = NaN;
	end
	figure;plot(x,y);
	[pathDataIdeal, locInfo] = idealizepath(pathData);
end
trialInfo = trialsFromLoc(locInfo);
pathDataLin = linearizepath(pathDataIdeal,trialInfo);
parseInfo_session = parsepath(pathDataIdeal,dataanalyzer.env.fig8.parsingtemplate());
parseInfo_byTrial = dataanalyzer.env.fig8.parseinfo2trial(parseInfo_session, trialInfo);


[t, I_trials] = arrayfun(@(pd,ti) restrict(pd.t, pd.t, ti.simp_tInt), pathData, trialInfo, 'un', 0);
I_trials = cellfun(@idx2double, I_trials, 'un', 0);
[t_Left, I_left_trials] = selectleft(t, trialInfo);
[t_Right, I_right_trials] = selectright(t, trialInfo);
I_Left = cellfun(@(pd,ti,dir) findepochs(pd.t, ti.simp_tInt(dir)), num2cell(pathData), num2cell(trialInfo), I_left_trials, 'un', 0);
I_Right = cellfun(@(pd,ti,dir) findepochs(pd.t, ti.simp_tInt(dir)), num2cell(pathData), num2cell(trialInfo), I_right_trials, 'un', 0);
I_Left = cellfun(@(x) sum(cat(2, x{:}), 2)>0, I_Left, 'un', 0);
I_Right = cellfun(@(x) sum(cat(2, x{:}), 2)>0, I_Right, 'un', 0);
% I_left_pd = 
% Original
x = arrayfun(@(pd,ti) restrict(pd.x, pd.t, ti.simp_tInt), pathData, trialInfo, 'un', 0);
x_Left = selectleft(x, trialInfo);
x_Right = selectright(x, trialInfo);
y = arrayfun(@(pd,ti) restrict(pd.y, pd.t, ti.simp_tInt), pathData, trialInfo, 'un', 0);
y_Left = selectleft(y, trialInfo);
y_Right = selectright(y, trialInfo);
% Ideal
x_ideal = arrayfun(@(pd,ti) restrict(pd.x, pd.t, ti.simp_tInt), pathDataIdeal, trialInfo, 'un', 0);
x_ideal_Left = selectleft(x_ideal, trialInfo);
x_ideal_Right = selectright(x_ideal, trialInfo);
y_ideal = arrayfun(@(pd,ti) restrict(pd.y, pd.t, ti.simp_tInt), pathDataIdeal, trialInfo, 'un', 0);
y_ideal_Left = selectleft(y_ideal, trialInfo);
y_ideal_Right = selectright(y_ideal, trialInfo);
% Linearized
x_lin = arrayfun(@(pd,ti) restrict(pd.x, pd.t, ti.simp_tInt), pathDataLin, trialInfo, 'un', 0);
x_lin_Left = selectleft(x_lin, trialInfo);
x_lin_Right = selectright(x_lin, trialInfo);
y_lin = arrayfun(@(pd,ti) restrict(pd.y, pd.t, ti.simp_tInt), pathDataLin, trialInfo, 'un', 0);
y_lin_Left = selectleft(y_lin, trialInfo);
y_lin_Right = selectright(y_lin, trialInfo);

% Put everything together
pd.path.L.timestamps = t_Left(:);
pd.path.R.timestamps = t_Right(:);
pd.path.L.orig.x = x_Left(:);
pd.path.L.orig.y = y_Left(:);
pd.path.R.orig.x = x_Right(:);
pd.path.R.orig.y = y_Right(:);
pd.path.L.ideal.x = x_ideal_Left;
pd.path.L.ideal.y = y_ideal_Left;
pd.path.R.ideal.x = x_ideal_Right;
pd.path.R.ideal.y = y_ideal_Right;
pd.path.L.linear.x = x_lin_Left;
pd.path.L.linear.y = y_lin_Left;
pd.path.R.linear.x = x_lin_Right;
pd.path.R.linear.y = y_lin_Right;

pdlin = cellfun(@(t,x) struct('t', t, 'x', x), {pathDataLin.t}', {pathDataLin.x}');
pd.path.linear = pdlin;

runs = parsezones(pathData, parseInfo_byTrial);
[runs.direction] = trialInfo.direction;
% pd.visits.arms = arm_visits;
pd.runs = runs;
pd.idx = parseInfo_session;
[pd.idx.trials] = I_trials{:};
[pd.idx.left] = I_Left{:};
[pd.idx.right] = I_Right{:};
% pd.visits.rewards = rewards;
% pd.visits.center = center; 
% 
% pd.visits.runsWcenter = [runs(:); center(:)];
% pd.visits.runsWcenter(1:2:end) = runs;
% pd.visits.runsWcenter(2:2:end) = center;

function [x, I] = restrict(x, xt, t)
I = findepochs(xt, t);
x = cellfun(@(i) x(i), I, 'un', 0);

function [x, I] = selectleft(x, ti)
directions = {ti.direction};
[x, I] = cellfun(@(x,dir) deal(x(strcmp(dir, 'L')), strcmp(dir, 'L')), x(:), directions(:), 'un', 0);

function [x, I] = selectright(x, ti)
directions = {ti.direction};
[x, I] = cellfun(@(x,dir) deal(x(strcmp(dir, 'R')), strcmp(dir, 'R')), x(:), directions(:), 'un', 0);

function pz = parsezones(pathData, parseInfo)
for i = 1:length(pathData)
	pz{i} = structfun(@(td) accFunc_parsepath(td, parseInfo{i}), pathData(i), 'un', 0);
end
pz = cat(1, pz{:});

function pz = accFunc_parsepath(td, pi)
pz = arrayfun(@(pi) structfun(@(zone) td(zone), pi, 'un', 0), pi, 'un', 0);
pz = cat(1, pz{:});

function epochs = findepochs(t, tInt)
if isempty(tInt)
	epochs = {false(size(t))};
else
	[~, epochs] = cellfun(@(tInt) restr(t, tInt(1), tInt(end)), tInt, 'un', 0);
end

function I_trials = idx2double(I_trials)
I_trials = cellfun(@(idx_tr,trNo) idx_tr*trNo, I_trials(:), num2cell([1:length(I_trials)]'), 'un', 0);
I_trials = sum(cat(2, I_trials{:}), 2);