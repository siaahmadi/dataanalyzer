function obj = loadSpikesFromSessionDir(obj, trials)


obj.loadSessionNeurons();

S = {obj.sessionSpikeTrains.ts}';
tFileList = {obj.sessionSpikeTrains.tFileName}';

if ~iscell(trials) % if expSession didn't have sleep OR begin trials, |trials| will not be a cell
	trials = num2cell(trials);
end

% Restrict each S{i} to trials{j}.beginTS and trials{j}.endTS and
% then set trials{j}.loadNeurons(restricted_S{:}).
% Make sure loadNeurons accepts actual spiketrains

ivls = interleave(cellfun(@(x) x.beginTS, trials), cellfun(@(x) x.endTS, trials));

S = oddelem(restr2cell(S, ivls), 2); % takes only odd elements of restr2cell --> only from begin to end, not from end to begin

cellfun(@(t, s) t.loadNeuronBatch(s, tFileList), trials(:)', column2cell(S), 'UniformOutput', false); % no output desired

% error('There''s a TODO: check it out');
% 
% sessTrial = dataanalyzer.trial(obj.fullPath, 'sessionWide', 'rad8');
