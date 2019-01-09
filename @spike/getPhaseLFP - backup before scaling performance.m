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

for b = 1:length(phases)
	ts = phases(b).ts;
	ph = phases(b).phase;
	idx = binsearch(ts,obj.ts); % ts is sorted, thus restricting @interp1's inputs to a narrow range is possible, which in turn dramatically enhances @interp1's performance
	
	if idx == 1
		idx = idx + 1;
	elseif idx == length(ts)
		idx = idx - 1;
	end
	phase = interp1(ts(idx-1:idx+1), ph(idx-1:idx+1), obj.ts);
	phaseStruct.(freqBands(b).name) = phase;
end

obj.phase = phaseStruct;


% function I = validateInputArgs(varargin)

% dataanalyzer.