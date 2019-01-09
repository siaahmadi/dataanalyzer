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

options = dataanalyzer.options(obj.projectname);
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

LFP = cell(length(trials), 1);
nTTs = 14;

subsession = ezstruct({trials.name}, 1:length(trials));

for i = 1:length(trials)
	%% Path data
	if doProcess.pd
		[rawTS, rawX, rawY] = Nlx2MatVT(fullfile(obj.fullPath, trials(i).name, 'VT1.nvt'), [1 1 1 0 0 0], 0, 1, 0);
		TS{i} = rawTS(:) * tsConv;
		startSession(i, :) = extractStartTimeFromCheetahLogFile(fullfile(obj.fullPath, trials(i).name, 'CheetahLogFile.txt')); %#ok<AGROW>

		switch trials(i).environment %obj.spatialEnvironment
			case 'rad8'
				mzTemplate = dataanalyzer.positiondata.layout2bw(dataanalyzer.env.rad8.radial8maze); % @radial8maze private function
				mzTemplate = dataanalyzer.env.rad8.weightArms(mzTemplate);
			case 'fig8'
				mzTemplate = dataanalyzer.positiondata.layout2bw(dataanalyzer.env.fig8.figure8maze); % @fig8maze private function
			case 'square'
				mzTemplate = dataanalyzer.positiondata.layout2bw(dataanalyzer.env.box.squarebox(20)); % @box private function
		end

		[rawX, rawY] = dataanalyzer.routines.spatial.tidy(rawX, rawY);

		if trials(i).useforcentering
			options.ctrXCorrPeakFinderMethod = 'peak';
			centerParams = dataanalyzer.positiondata.ctrposdat(rawX, rawY, mzTemplate, options);
		end
		X{i} = smooth((rawX(:) -centerParams.xCenter) * options.xScale);
		Y{i} = smooth(-(rawY(:) -centerParams.yCenter) * options.yScale);
		[X{i}, Y{i}] = rotatePoints(X{i}, Y{i}, -options.rotation);
		V{i} = dataanalyzer.routines.spatial.velocity(X{i},Y{i},TS{i});
		[W_Theta{i}, W_Rho{i}] = dataanalyzer.routines.spatial.velocity_ang(X{i},Y{i},TS{i});
	end
	
	%% LFP data
	if doProcess.lfp
		LFP{i} = arrayfun(@(eegInd) readCRTsd(fullfile(obj.fullPath, trials(i).name, ['CSC' num2str(eegInd) '.ncs'])), (1:nTTs)', 'un', 0);
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

%% Fix timestamps
if doProcess.pd && doProcess.nlxEvents
	[TS_tsfixed, b_tsfixed, e_tsfixed] = correctAsynchronousTimestamps(startSession, TS, b(:), e(:));
	% |b_tsfixed| is the time-translated |b| such that b_tsfixed{i}
	% indicates the actual "session" start tiem of TS{i}
	% |TS_tsfixed| contains the TS with each cell entry referenced to a
	% common zero starting time stamp.
else
	TS_tsfixed = TS;
end
if doProcess.lfp
	LFP_tsfixed = correctAsynchronousTimestamps(startSession, LFP);
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
	assignment = ezstruct(['unassigned'; ev_sorted(:)], [0; setdiff(unique(subtrial), 0)]); % separated 0 from unique(subtrial) because subtrial might not have unassigned entries if the Nlx events file is cut for each subtrial

	PathData = ezstruct({'t', 'x', 'y', 'v', 'w_theta', 'w_rho', 'subtrial', 'assignment'}, ...
		{TS_sorted, X_sorted, Y_sorted, V_sorted, W_Theta_sorted, W_Rho_sorted, subtrial, assignment});
	
	% Parse
	if doProcess.parse
		switch dataanalyzer.maze(obj.spatialEnvironment)
			case dataanalyzer.maze('fig8') % instead of just {'fig8'} ensures bi-directional translation of maze types by dataanalyzer.maze
				parseInfo = dataanalyzer.fig8.parse(pathData);
				PathData.x_linearized = cat(1, parseInfo.path.linear.x);
		end
	end
end

if doProcess.spikes
	% Spikes
	Spikes = eztable2struct(Spikes_tsfixed);
end

% LFP
if doProcess.lfp
	for tr = 1:length(trials)
		for ttInd = 1:nTTs
			LFPs.(['LFP_', trials(tr).name, num2str(ttInd)]) = LFP_tsfixed{tr}{ttInd};
		end
	end
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
	save(fullfile(obj.fullPath, fn), 'Spikes');
end
if doProcess.lfp
	fprintf('Saving LFP data...\n');
	fn = dataanalyzer.constant('FileName_LfpData_Session');
	save(fullfile(obj.fullPath, fn), '-struct', 'LFPs');
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