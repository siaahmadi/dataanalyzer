function preprocess(obj, doProcess)
%PREPROCESS(obj) Read raw position tracking, spiking, and local field
%potentials data, and save in a preprocessed (artifact-removed, time-stamp
%corrected, etc) and easy to read format (.mat)
%
% Method from the @expSession class

% Siavash Ahmadi
% 11/21/2016 7:49 PM

fprintf('Preprocessing raw data...\n');

if exist('doProcess', 'var')
	if ~isfield(doProcess, 'spikes')
		doProcess.spikes = true;
	end
	if ~isfield(doProcess, 'pd')
		doProcess.pd = true;
	end
	if ~isfield(doProcess, 'lfp')
		doProcess.lfp = false;
	end
	if ~isfield(doProcess, 'nlxEvents')
		doProcess.nlxEvents = true;
	end
	if ~isfield(doProcess, 'parse')
		doProcess.parse = true;
	end
else
	doProcess.spikes = true;
	doProcess.pd = true;
	doProcess.lfp = false;
	doProcess.nlxEvents = true;
	doProcess.parse = true;
end
trials = sortByCenteringGroup(obj.trialDirs);
trials = obj.trialDirs;

options = dataanalyzer.options(obj.projectname);

% I used to get the path adjustment parameters from a central database for
% all sessions of a project. This is not a good idea. Each session should
% have its own adjustment file in the directory where all the files reside.
% This can optionally include a 3-D projection transform for those sessions
% where the path data is greatly distorted.
% options = load(fullfile(obj.fullPath, 'pathadjustmentparameters.mat'));

tsConv = dataanalyzer.constant('neuralynxVideoTsConversionFactor');

X = cell(length(trials), 1);
Y = cell(length(trials), 1);
TS = cell(length(trials), 1);
V = cell(length(trials), 1);
W_Theta = cell(length(trials), 1); % Angular Velocity
W_Rho = cell(length(trials), 1); % Radial Velocity

b = cell(length(trials), 1);
e = cell(length(trials), 1);
evts = cell(length(trials), 1);

% LFP = cell(length(trials), 1);
nTTs = 14;

% subsession = ezstruct({trials.name}, 1:length(trials));

rawX = cell(length(trials), 1);
rawY = cell(length(trials), 1);

for i = 1:length(trials)
	%% Path data
	[rawTS, rawX{i}, rawY{i}] = Nlx2MatVT(fullfile(obj.fullPath, trials(i).name, 'VT1.nvt'), [1 1 1 0 0 0], 0, 1, 0);
	TS{i} = rawTS(:) * tsConv;
	if doProcess.pd
		startSession(i, :) = extractStartTimeFromCheetahLogFile(fullfile(obj.fullPath, trials(i).name, 'CheetahLogFile.txt')); %#ok<AGROW>

		[rawX{i}, rawY{i}] = dataanalyzer.routines.spatial.tidy(rawX{i}(:), rawY{i}(:));
	else
		startSession(i, :) = [datetime('00:00:00.000', 'InputFormat', 'HH:mm:ss.SSS'), datetime(0,0,0,0,0,0)];
	end
	
	%% Neuralynx Event Data
	
	if doProcess.nlxEvents
		[b{i}, e{i}, evts{i}] = NlxEvt2Ts(fullfile(obj.fullPath, trials(i).name, 'Events_fixed.nev'), 'begin');
		% |b| and |e| are cell arrays of doubles indicating begina and end
		% time stamps of each subtrial. Length of each cell array is equal
		% to the number of trials, with each cell entry containing an array
		% of length (# subtrials) for each trial.
		% |evts| contains the corresponding string names of the subtrials.
	end
end

if doProcess.pd
	if ~isfield(options, 'centerParams')
		% the automatic method in the next line sometimes fails.
		% It's necessary that the |centerParams| be found manually and saved
		% in "pathadjustmentparameters.mat"
		centerParams = findPerGroupCenteringParameters(trials, rawX, rawY, options);
	else
		centerParams = options.centerParams;
	end

	for i = 1:length(trials)
		%% Path data
		X{i} = (rawX{i}(:) -centerParams(trials(i).ctrgrp).xCenter) * options.xScale;
		Y{i} = -(rawY{i}(:) -centerParams(trials(i).ctrgrp).yCenter) * options.yScale;
		warning('If there are reflections in this path that are not detected set a breakpoint here and continue manually.');
		[X{i}, Y{i}] = interpolateNaNs(X{i}, Y{i}); % this is a manual step. Some reflections are not jumpy and must be detected manually.
		[X{i}, Y{i}] = patchReflectionJumps(TS{i}, X{i}, Y{i}, 150, 15);
		X{i} = smooth(X{i});
		Y{i} = smooth(Y{i});
		[X{i}, Y{i}] = rotatePoints(X{i}, Y{i}, -options.rotation);
		V{i} = dataanalyzer.routines.spatial.velocity(X{i},Y{i},TS{i});
		[W_Theta{i}, W_Rho{i}] = dataanalyzer.routines.spatial.velocity_ang(X{i},Y{i},TS{i});
	end
	if isfield(options, 'tform')
		[X, Y] = cellfun(@(x,y) options.tform.apply(x,y), X, Y, 'un', 0);
	end
end

%% Fix timestamps
if doProcess.pd && doProcess.nlxEvents
	[TS_tsfixed, b_tsfixed, e_tsfixed] = correctAsynchronousTimestamps(startSession, TS, b(:), e(:));
	% |b_tsfixed| is the time-translated |b| such that b_tsfixed{i}
	% indicates the actual "session" start tiem of TS{i}
	% |TS_tsfixed| contains the TS with each cell entry referenced to a
	% common zero starting time stamp.
else
	b_tsfixed = b(:);
	e_tsfixed = e(:);
	TS_tsfixed = TS;
end

%% LFP data
% Since LFP data takes up a lot of memory, the entire processing will take
% place sequentially (i.e. for each tetrode) right here
if doProcess.lfp
	fprintf('Processing LFP data...\n');
	fn = dataanalyzer.constant('FileName_LfpData_Session');
	for ttInd = 1:nTTs

		% Read in data
		[LFP, Fs] = arrayfun(@(tr) readCRTsd(fullfile(obj.fullPath, trials(tr).name, ['CSC' num2str(ttInd) '.ncs'])), (1:length(trials))', 'un', 0);

		% Fix timestamps
		LFP_tsfixed = correctAsynchronousTimestamps(startSession, LFP);

		% Filter and Calcualte Phase
		[LFP_phase, LFP_filt] = EEG.phase(LFP_tsfixed, 'theta');
		
		% Calculate theta power
		params = struct('Fs', Fs, 'fpass', [6, 10]);
		if all(~cellfun(@isempty, cellfun(@Data, LFP_tsfixed, 'un', 0)))
			[S,f] = cellfun(@mtspectrumc, cellfun(@Data,LFP_tsfixed,'un',0), num2cell(params), 'un', 0);
		else
			S = num2cell(zeros(size(LFP_tsfixed)));
		end
		POWER_THETA = cellfun(@rms, S, 'un', 0);
		
		% Save
		LFPs = ezstruct(arrayfun(@(tr) ['Raw_', trials(tr).name, '_tt', num2str(ttInd)], 1:length(trials), 'un', 0)', LFP_tsfixed); %#ok<NASGU>
		PHASES = ezstruct(arrayfun(@(tr) ['Phase_', trials(tr).name, '_tt', num2str(ttInd)], 1:length(trials), 'un', 0)', LFP_phase); %#ok<NASGU>
		FILTERED = ezstruct(arrayfun(@(tr) ['Filtered_', trials(tr).name, '_tt', num2str(ttInd)], 1:length(trials), 'un', 0)', LFP_filt); %#ok<NASGU>
		POWER = ezstruct(arrayfun(@(tr) ['ThetaRMS_', trials(tr).name, '_tt', num2str(ttInd)], 1:length(trials), 'un', 0)', POWER_THETA); %#ok<NASGU>
		fprintf('Saving LFP data for tetrode %d...\n', ttInd);
		[~, fn] = fileparts(fn);
		lfpFileToSave = fullfile(obj.fullPath, [fn, '_tt', num2str(ttInd), '.mat']);
		save(lfpFileToSave, '-struct', 'LFPs');
		save(lfpFileToSave, '-struct', 'PHASES', '-append');
		save(lfpFileToSave, '-struct', 'FILTERED', '-append');
		save(lfpFileToSave, '-struct', 'POWER', '-append');
		fprintf('Finished Saving LFP data for tetrode %d...\n', ttInd);
	end
end


%% Load spiking data
if doProcess.spikes
	Spikes = dataanalyzer.routines.spikes.loadtb(obj.fullPath, 'session', {trials.name});
	if all(cellfun(@isempty, Spikes.Session)) % no session .t files (this is convenient for when the sleep session is not cut yet)
		% allows avoidance of contamination of spike trains by
		% misattributed spikes to clusters not perfectly adjusted to sleep
		Spikes = dataanalyzer.routines.spikes.loadtb(obj.fullPath, 'trial', {trials.name});
		tfiles = Spikes.Properties.RowNames;
		Spikes = correctAsynchronousTimestamps(startSession, column2cell(table2cell(Spikes))');
		Spikes = cellmerge(cat(2, Spikes{:}));
		Spikes = cell2table(Spikes, 'VariableNames', {'Session'}, 'RowNames', tfiles);
	end
	
	if doProcess.nlxEvents
		Spikes_tsfixed = splitspiketrains(cat(1, b_tsfixed{:}), cat(1, e_tsfixed{:}), cat(1, evts{:}), Spikes);
	else
		Spikes_tsfixed = Spikes;
	end
	
	% Extract Phase:
% 	warning('Uncomment below:');
	if ~exist(fullfile(obj.fullPath, 'lfpdata_tt1.mat'), 'file')
		error('Run preprocessing with option doProcess.lfp = true');
	end
	[thetaphase, thetaamp] = loadValidPhaseFile(obj.fullPath);
	Phase = getPhase(Spikes_tsfixed, thetaphase);
	[ThetaCycle, ThetaTimes, ThetaAmp, ThetaAmpZ] = getThetaCycle(Spikes_tsfixed, thetaamp);
end

%% Use ts-fixed data from now on

if doProcess.pd
	[b_sorted, e_sorted, ev_sorted] = sortevents(cat(1, b_tsfixed{:}), cat(1, e_tsfixed{:}), cat(1, evts{:}));
	subtrialIvl = ivlset(b_sorted, e_sorted);

	% Path data
	pathData = ezstruct({'x', 'y', 't', 'v'}, {X, Y, TS_tsfixed, V});
	[TS_sorted, I] = sort(cat(1, TS_tsfixed{:}));
	X = cat(1, X{:}); X_sorted = X(I);
	Y = cat(1, Y{:}); Y_sorted = Y(I);
	V = cat(1, V{:}); V_sorted = V(I);
	W_Theta = cat(1, W_Theta{:}); W_Theta_sorted = W_Theta(I);
	W_Rho = cat(1, W_Rho{:}); W_Rho_sorted = W_Rho(I);
	subtrial = subtrialIvl.index(TS_sorted);
	assignment = ezstruct(['unassigned'; ev_sorted(:)], 0:subtrialIvl.length); % note: subtrial might not have unassigned entries if the Nlx events file is cut for each subtrial

	PathData = ezstruct({'t', 'x', 'y', 'v', 'w_theta', 'w_rho', 'subtrial', 'assignment'}, ...
		{TS_sorted, X_sorted, Y_sorted, V_sorted, W_Theta_sorted, W_Rho_sorted, subtrial, assignment});
	
	% Parse
	if doProcess.parse
		for trIdx = 1:length(obj.trialDirs) % allows for each subtrial to have a 
			switch dataanalyzer.maze(obj.trialDirs(trIdx).environment)
				case dataanalyzer.maze('fig8') % instead of just {'fig8'} ensures bi-directional translation of maze types by dataanalyzer.maze
					parseInfo{trIdx} = dataanalyzer.fig8.parse(pathData(trIdx));
					parseInfo{trIdx}.env = 'fig8';
				case dataanalyzer.maze('rad8')
					if trIdx == 1 % only run this block once
						% the reason I did the parsing by trial is to allow each trial to have a different environment.
						% this if block will run successfully if all the
						% trials are in the same environment.
						t = cat(1, pathData.t);
						x = cat(1, pathData.x);
						y = cat(1, pathData.y);

						NlxEvents = cellfun(@(b,e,ev) struct('event', ev, 'begin', b, 'end', e), b, e, evts);
						[t, x, y, ~, trNameStrings] = p___restrictToBegins(NlxEvents, t, x, y);

						options.trNameStrings = trNameStrings(:);
						parseInfoAll = dataanalyzer.rad8pd.parse(t, x, y, options);
						parseInfoAll.env = 'rad8';
					end

					parseInfo{trIdx} = dataanalyzer.rad8pd.parse(pathData(trIdx).t, pathData(trIdx).x, pathData(trIdx).y, options);
					parseInfo{trIdx}.runs.trial = parseInfo{trIdx}.runs.trial * trIdx; % 'parseInfo{trIdx}.runs.trial' will be all ones from @parse
					parseInfo{trIdx}.idx.run_seq = parseInfo{trIdx}.idx.run_seq * trIdx;
					parseInfo{trIdx}.env = 'rad8';
			end
		end
		parseInfo = cat(1, parseInfo{:});
		parseInfo = ezstruct(fieldnames(parseInfo), ...
			{cat(1, parseInfo.path), cat(1, parseInfo.runs), cat(1, parseInfo.idx), {{parseInfo.env}'}});
		paths = cat(1, parseInfo.path);
		paths_linear = cat(1, paths.linear);
		PathData.x_linearized = cat(1, paths_linear.x);
		if strcmp(dataanalyzer.maze(obj.trialDirs(trIdx).environment), dataanalyzer.maze('fig8'))
			% This needs more work. It is non-compliant with the rad8
			parseInfoAll.path = catstructfield(parseInfo.path);
			parseInfoAll.runs.t = cat(1, parseInfo.runs.t);
			parseInfoAll.runs.x = cat(1, parseInfo.runs.x);
			parseInfoAll.runs.y = cat(1, parseInfo.runs.y);
			parseInfoAll.runs.v = cat(1, parseInfo.runs.v);
			parseInfoAll.runs.direction = cat(1, parseInfo.runs.direction);
			parseInfoAll.idx = ezstruct(fieldnames(parseInfo.idx), cellfun(@(x) cat(1, x{:}), column2cell(struct2cell(parseInfo.idx)'), 'un', 0));
			N_trials = arrayfun(@(str) max(str.trials), parseInfo.idx); % the parsing gives the wrong output; this is wrong as of now 5/31/2018
			buffer = arrayfun(@(str,i) rectify(str.trials+i, i), parseInfo.idx, [0; cumsum(N_trials(1:end-1))], 'un', 0);
			parseInfoAll.idx.trials = cat(1, buffer{:});
			parseInfoAll.env = parseInfo.env{1};
		end
	end
end

if doProcess.spikes
	% Spikes
	Spikes = eztable2struct(Spikes_tsfixed);
	Phases = eztable2struct(Phase);
	ThetaCycles = eztable2struct(ThetaCycle);
	ThetaAmplitude = eztable2struct(ThetaAmp);
	ThetaAmplitudeZ = eztable2struct(ThetaAmpZ);
end



%% Write to file
if doProcess.pd
	fprintf('Saving subtrial interval sets...\n');
	fn = dataanalyzer.constant('FileName_SubtrialData_Session');
	save(fullfile(obj.fullPath, fn), 'subtrialIvl')
	
	fprintf('Saving path data...\n');
	fn = dataanalyzer.constant('FileName_PathData_Session');
	save(fullfile(obj.fullPath, fn), '-struct', 'PathData');
	
	if doProcess.parse
		fprintf('Saving parse information...\n');
		fn = dataanalyzer.constant('FileName_ParseData_Session');
		save(fullfile(obj.fullPath, fn), '-struct', 'parseInfo')
		save(fullfile(obj.fullPath, [fn(1:end-4), '_all.mat']), '-struct', 'parseInfoAll')
		
		fprintf('Saving linearized path data...\n');
		fn = dataanalyzer.constant('FileName_PathDataLinearized_Session');
		PathDataLin = PathData;
		PathDataLin.x = PathDataLin.x_linearized;
		PathDataLin.y = zeros(size(PathDataLin.y));
		PathDataLin = rmfield(PathDataLin, 'x_linearized');
		save(fullfile(obj.fullPath, fn), '-struct', 'PathDataLin');
	end
end
if doProcess.spikes
	fprintf('Saving spike data...\n');
	fn = dataanalyzer.constant('FileName_SpikeData_Session');
	save(fullfile(obj.fullPath, fn), 'Spikes', 'Phases', 'ThetaCycles', 'ThetaTimes', 'ThetaAmplitude', 'ThetaAmplitudeZ');
end
if doProcess.lfp
	% Already saved higher in the code
end
fprintf('Finished saving corrected raw data.\n');

function trials = sortByCenteringGroup(trials)

[~, I_master] = sort(cat(1, trials.useforcentering), 'descend');
[~, I_grp] = sort(cat(1, trials(I_master).ctrgrp));
trials = trials(I_master(I_grp));


function Spikes = splitspiketrains(b, e, ev, Spikes)
% Sort the events:
[b, e, ev] = sortevents(b, e, ev);

% Split:
tFileNames = Spikes.Properties.RowNames;
Spikes = cellfun(@(x) split(x, b, e), table2cell(Spikes), 'un', 0)';
Spikes = cell2table(cat(2, Spikes{:})', 'VariableName', ev, 'RowNames', tFileNames);

function spiketrains = split(spiketrain, evt0, evt1)
spiketrains = arrayfun(@(evt1, evt2) restr(spiketrain, evt1, evt2), evt0, evt1, 'un', 0);

function [b, e, ev] = sortevents(b, e, ev)
[b, I] = sort(b);
e = e(I);
ev = ev(I);

function Phase = getPhase(Spikes, thetaphase)
thetaphase = struct2cell(thetaphase);

ts = cellfun(@Range, thetaphase, 'un', 0);
phase = cellfun(@Data, thetaphase, 'un', 0);

ts = cat(1, ts{:});
phase = cat(1, phase{:});

[ts, I] = sort(ts);
phase = phase(I);
phase = mod(phase+2*pi, 2*pi);

if isempty(ts)
	Phase = cellfun(@(c) NaN(size(c)), table2cell(Spikes), 'un', 0);
else
	Phase = cellfun(@(sp) interp1(ts, phase, sp, 'nearest'), table2cell(Spikes), 'un', 0);
end

Phase = cell2table(Phase, 'RowNames', Spikes.Properties.RowNames, 'VariableNames', Spikes.Properties.VariableNames);

function [Cycle, theta_start_time, ampl, amplZ] = getThetaCycle(Spikes, theta)
theta = struct2cell(theta);

Fs = cellfun(@DT, theta, 'un', 0);
ts = cellfun(@Range, theta, 'un', 0);
thetaamp = cellfun(@Data, theta, 'un', 0);

[theta_peak, theta_start_time] = cellfun(@(theta,fs) findpeaks(theta,1./fs, 'MinPeakDistance', 0.1, 'MinPeakProminence', std(theta)), thetaamp, Fs, 'un', 0);
[theta_trough, trough_start_time] = cellfun(@(theta,fs) findpeaks(-theta,1./fs, 'MinPeakDistance', 0.1, 'MinPeakProminence', std(theta)), thetaamp, Fs, 'un', 0);

% Will not run this. See note inside @pushPeak
% [theta_peak, theta_start_time, theta_trough, trough_start_time] = cellfun(@pushPeak, theta_trough, trough_start_time, theta_peak, theta_start_time, 'un', 0);

theta_start_time = cellfun(@(ts,theta_start_time) ts(1) + theta_start_time, ts, theta_start_time, 'un', 0);
trough_start_time = cellfun(@(ts,trough_start_time) ts(1) + trough_start_time, ts, trough_start_time, 'un', 0);

theta_start_time = sort(cat(1, theta_start_time{:}));
trough_start_time = sort(cat(1, trough_start_time{:}));

if isempty(theta_start_time)
	Cycle = cellfun(@(c) NaN(size(c)), table2cell(Spikes), 'un', 0);
else
	Cycle = cellfun(@(sp) interp1(theta_start_time, 1:length(theta_start_time), sp, 'previous'), table2cell(Spikes), 'un', 0);
end

[ampl, amplZ] = cellfun(@(c) findAmplitude(c, cat(1, theta_peak{:}), cat(1, theta_trough{:})), Cycle', 'un', 0);

Cycle = cell2table(Cycle, 'RowNames', Spikes.Properties.RowNames, 'VariableNames', Spikes.Properties.VariableNames);
ampl = cell2table(ampl', 'RowNames', Spikes.Properties.RowNames, 'VariableNames', Spikes.Properties.VariableNames);
amplZ = cell2table(amplZ', 'RowNames', Spikes.Properties.RowNames, 'VariableNames', Spikes.Properties.VariableNames);

function [peak_amp, peak_start_time, trough_amp, trough_start_time] = pushPeak(trough_amp, trough_start_time, peak_amp, peak_start_time)
% Makes sure Peaks and Troughs of the same index are in order (Peak first,
% Trough next)

% Because the statistics of the signal is not the same for peak vs. trough
% in @getThetaCycle the line @findpeaks will not necessarily return the
% same number of peaks and troughs. This will create problems for aligning
% peaks and troughs. To get around the problem, the maximum of the average
% of peaks and troughs within a certain neighborhood will be assigned as
% the signal amplitude at the time of spiking.

if trough_start_time(1) < peak_start_time(1)
	peak_start_time = [0; peak_start_time];
	peak_amp = [0; peak_amp];
end
if trough_start_time(end) < peak_start_time(end)
	trough_start_time = [trough_start_time; peak_start_time(end)+.1];
	trough_amp = [trough_amp; 0];
end

function [ampl, amplZ] = findAmplitude(cycle, peaks, troughs)

ampl = arrayfun(@(c) avgAmpl(peaks, troughs, c), cycle);
amplZ = arrayfun(@(c) avgAmpl(zscore(peaks), zscore(troughs), c), cycle);

function ampl = avgAmpl(peaks, troughs, c)
N_CYCLES_NEIGHBORHOOD = 1;
if c - N_CYCLES_NEIGHBORHOOD > 0
	i = c - N_CYCLES_NEIGHBORHOOD;
else
	i = 1;
end
if c + N_CYCLES_NEIGHBORHOOD > min([length(peaks), length(troughs)])
	j = min([length(peaks), length(troughs)]);
else
	j = c + N_CYCLES_NEIGHBORHOOD;
end

if isnan(c)
	ampl = NaN;
else
	ampl = max([mean(peaks(i:j)), mean(troughs(i:j))]);
end

function centerParams = findPerGroupCenteringParameters(trials, rawX, rawY, options)

options.fgt = 2;
options.viz = 0;
options.method = 'nonrigid_lowrank';
options.tol = 1e-8;
options.beta = 10;
options.lambda = 30;
options.max_it = 200;
pathdata = [cat(1, rawX{1}), cat(1, rawY{1})];

ctrgrps = cat(1, trials.ctrgrp);
Locb = arrayfun(@(key) find(key==ctrgrps), unique(ctrgrps), 'un', 0);
Locb = nancat(2, Locb{:});
options.ctrXCorrPeakFinderMethod = 'peak';
useforcentering = cat(1, trials.useforcentering);
useforcentering(useforcentering~=0) = find(useforcentering~=0);
for combGrpIdx = 1:size(Locb, 2)
	switch trials(Locb(1, combGrpIdx)).environment % Assumes all centering group trials have the same environment
		case 'rad8'
			rad8_sk = rad8maze_skeleton;
% 			mzTemplate = dataanalyzer.positiondata.layout2bw(dataanalyzer.env.rad8.radial8maze, options.res); % @radial8maze private function
% 			mzTemplate = dataanalyzer.env.rad8.weightArms(mzTemplate, options.res);
		case 'fig8'
			mzTemplate = dataanalyzer.positiondata.layout2bw(dataanalyzer.env.fig8.figure8maze); % @fig8maze private function
		case 'square'
			mzTemplate = dataanalyzer.positiondata.layout2bw(dataanalyzer.env.box.squarebox(20)); % @box private function
	end
	
	% find current centering group trials:

	[Transform, C] = cpd_register(rad8_sk, pathdata, options);
% 	thisCtrGrp = positive(useforcentering(finite(Locb(:, combGrpIdx)))); % only take those that are indicated to be used to find centering parameters
% 	centerParams(combGrpIdx, 1) = dataanalyzer.positiondata.ctrposdat(cat(1, rawX{thisCtrGrp}), cat(1, rawY{thisCtrGrp}), mzTemplate, options);
end

function a = positive(a)
a = a(a>0);

function [phase, filtered] = loadValidPhaseFile(fullpath)
% Currently just loads TT14 which is typically placed in the hippocampal
% fissure in our experiments. If this one is empty (e.g. because it wasn't
% recorded) it tries TT1, TT2, ... returning the first non-empty file.
%
% Ideally, this would take in the tetrode numbers and load the
% corresponding LFP phase.

[phase, filtered] = loadLFPwithHighestThetaRMS(fullpath);
% [phase, filtered] = loadAnyNonEmptyPhaseFilePrioritizingTT14(fullpath);

function [phase, filtered] = loadLFPwithHighestThetaRMS(fullpath)
thetapower = NaN(14, 1);
for i = [1:12, 14]
	buffer = load(fullfile(fullpath, ['lfpdata_tt' num2str(i) '.mat']), 'ThetaRMS*');
	thetapower(i) = mean(struct2array(buffer));
end
[~, BestTheta] = nanmax(thetapower);
phase = load(fullfile(fullpath, ['lfpdata_tt' num2str(BestTheta) '.mat']), 'Phase*');
filtered = load(fullfile(fullpath, ['lfpdata_tt' num2str(BestTheta) '.mat']), 'Filtered*');

if structfun(@length, phase)==0
	error('No tetrode has consistent phase information for all trials!!');
end

function [phase, filtered] = loadAnyNonEmptyPhaseFilePrioritizingTT14(fullpath)
phase = load(fullfile(fullpath, 'lfpdata_tt14.mat'), 'Phase*');
i = 1;
while any(structfun(@length, phase)==0) && i < 13
	phase = load(fullfile(fullpath, ['lfpdata_tt' num2str(i) '.mat']), 'Phase*');
	i = i + 1;
end
if i == 1 % TT14 should be loaded
	filtered = load(fullfile(fullpath, 'lfpdata_tt14.mat'), 'Filtered*');
else
	filtered = load(fullfile(fullpath, ['lfpdata_tt' num2str(i-1) '.mat']), 'Filtered*');
end
if i == 13 % all empty!!
	error('No tetrode has consistent phase information for all trials!!');
end


function varargout = p___restrictToBegins(NlxEvents, t, varargin)
% return NaN separated trial path data

events = {NlxEvents.event};

b = cat(1, NlxEvents.begin);
e = cat(1, NlxEvents.end);

begins = ivlset(b, e);
idx = begins.restrict(t);

varargout = cell(1, 1+nargin-2);

varargout{1} = cellfun(@(i) cat(1, t(i), NaN), idx, 'un', 0);
varargout{1} = cat(1, varargout{1}{:});
for i = 1:length(varargin)
	varargout{i+1} = cellfun(@(j) cat(1, varargin{i}(j), NaN), idx, 'un', 0);
	varargout{i+1} = cat(1, varargout{i+1}{:});
end

varargout{end+1} = sum(cat(2, idx{:}), 2) > 0;
varargout{end+1} = events;

function [x, y] = patchReflectionJumps(t, x, y, jumpTolerance, reflectionTolerance)

dR = [0; eucldist(x(2:end), y(2:end), x(1:end-1), y(1:end-1)) ./ smooth(diff(t), 10)];

jumps = lau.raftidx(lau.close(dR > jumpTolerance, reflectionTolerance));
if isempty(jumps)
	return;
end
jumps(1, :) = jumps(1, :) - 1;
jumps(2, :) = jumps(2, :) + 1;

for k = 1:size(jumps, 2)
	i = jumps(1, k);
	j = jumps(2, k);
	
	x(i+1:j-1) = interp1([i, j], [x(i), x(j)], i+1:j-1, 'linear');
	y(i+1:j-1) = interp1([i, j], [y(i), y(j)], i+1:j-1, 'linear');
	
end

function c = catnan(dim, varargin)

c = cellfun(@(x) cat(dim, x, NaN), varargin, 'un', 0);
c = cat(dim, c{:});

function [x, y] = interpolateNaNs(x, y)

iNaN = isnan(x) | isnan(y);
NaNs = lau.raftidx(lau.close(iNaN, 10));
NaNs = [NaNs(1, :) - 1; NaNs(2, :) + 1];

for i = 1:size(NaNs, 2)
	j = NaNs(1, i);
	k = NaNs(2, i);
	x(j:k) = interp1([j,k], [x(j),x(k)], j:k, 'linear');
	y(j:k) = interp1([j,k], [y(j),y(k)], j:k, 'linear');
end

function sk = rad8maze_skeleton()
rad8maze = nanmax(dataanalyzer.env.rad8.radial8maze(8, 'line'));
STEM_RADIUS = 20;
x = (-rad8maze(1):0.1:rad8maze(1))';
y = zeros(length(x), 1);
[x1, y1] = rotatePoints(x, y, pi/4);
[x2, y2] = rotatePoints(x, y, pi/2);
[x3, y3] = rotatePoints(x, y, 3*pi/4);
x_stem = (-STEM_RADIUS:0.1:STEM_RADIUS)';
y_stem = sqrt(STEM_RADIUS^2 - x_stem.^2);
sk = [x, y; x1, y1; x2, y2; x3, y3; x_stem, y_stem; x_stem, -y_stem];