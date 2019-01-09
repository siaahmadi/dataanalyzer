function phaseStruct = getPhaseLFP(obj, freqBands)

if nargin < 2
	freqBands = dataanalyzer.constant('dflt_freqBands');
end

trparent = dataanalyzer.ancestor(obj, 'trial');

neurparent = dataanalyzer.ancestor(obj, 'neuron');
ttNo = str2double(regexp(neurparent.namestring, '(?<=^TT)\d{1,2}', 'match', 'once'));

if ~isnumeric(ttNo)
	error('Cannot find tetrode number.');
end

if ~any(trparent.lfp.ttMapping)
	xp = dataanalyzer.ancestor(obj, 'expSession');
	ratios = xp.loadThetaRatiosFile();
	[~, thetaMax] = max(cat(1, ratios.peaktobase));
	remappedTT = ratios(thetaMax).ttNo;
	fprintf(2, '\nRemapping tetrode #%d to tetrode #%d\nAt line 20 in dataanalyzer.spike.getPhaseLFP\n', ttNo, remappedTT);
	
	trparent.lfp.defineTetrodeMapping([1:16;ones(1, 16)*remappedTT]); % map everything to tetrode with strongest theta for now
end
phases = trparent.lfp.getPhase(ttNo, freqBands);

phase = cell(1, length(phases)); % must be row vector
for b = 1:length(phases)
	
	ts = phases(b).ts;
	ph = phases(b).phase;
	idx = arrayfun(@(objts) dataanalyzer.utils.binsearch(ts,objts), cat(1, obj.ts)); % ts is sorted, thus restricting @interp1's inputs to a narrow range is possible, which in turn dramatically enhances @interp1's performance
	
	idx(idx == 1) = idx(idx == 1) + 1;
	idx(idx == length(ts)) = idx(idx == length(ts)) - 1;
	
	tss = ts([idx-1, idx, idx+1]');
	phs = ph([idx-1, idx, idx+1]'); % this introduces the possibility of a timestamp repeating but that would be rare
	
	[~, ia] = unique(tss(:));
	phase{b} = interp1(tss(ia), phs(ia), cat(1, obj.ts));
end

phaseStruct = cellfun(@(ph) accFunc_constructPhStr(ph, freqBands), row2cell(cat(2, phase{:})), 'un', 0);

arrayfun(@accFunc_assgnPhStr, obj, cat(1, phaseStruct{:}));


% function I = validateInputArgs(varargin)

% dataanalyzer.

function phaseStruct = accFunc_constructPhStr(phase, freqBands)
for b = 1:length(phase)
	phaseStruct.(freqBands(b).name) = phase(b);
end

function accFunc_assgnPhStr(obj, phaseStruct)
obj.phase = phaseStruct;