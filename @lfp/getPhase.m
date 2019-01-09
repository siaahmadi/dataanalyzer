function phaseStruct = getPhase(obj, ttNo, freqBands)

if nargin < 3
	freqBands = dataanalyzer.constant('dflt_freqBands');
end

p___validateInputArgs('freqBand', freqBands);

numBandsReqt = length(freqBands);

phaseStruct = phasestruct(numBandsReqt, 1);

obj.hilbert(ttNo, freqBands);

mappedTT = mapUserTT(obj, ttNo);

for tt = mappedTT(:)'
	% TODO check if has been computed already
	[ttisthere, idxTT] = findstruct(obj.phase, 'ttNo', tt);
	for i = 1:numBandsReqt
		if ttisthere
			[bandisthere, idxBand] = findstruct(obj.phase, 'band', freqBands(i).name);
			idxTTBand = [idxBand{:}] & [idxTT{:}];
		end
		if ttisthere && bandisthere % phase has been computed
			phaseStruct(i) = obj.phase(idxTTBand);
		else
			% find the hilbert transform:
			[~, I] = findstruct(obj.eeg, 'ttNo', tt);
			eeg_struct = obj.eeg([I{:}]);
			try
				[~, I] = findstruct(eeg_struct.hilbert, 'band', freqBands(i).name);
			catch
				1;
			end
			eeg_hilb = eeg_struct.hilbert([I{:}]).ht;

			% compute the phase
			phase = mod(atan2(imag(eeg_hilb), real(eeg_hilb)) + 2*pi, 2*pi);
			
			% construct the struct
			phaseStruct(i).ttNo = tt;
			phaseStruct(i).band = freqBands(i).name;
			phaseStruct(i).phase = phase;
			phaseStruct(i).ts = EEG.toSecond(eeg_struct.tsd, 'Range');
		end
	end
	
	isthere = findstruct(obj.phase, 'ttNo', [phaseStruct.ttNo]) & findstruct(obj.phase, 'band', {phaseStruct.band});
	if any(~isthere)
		% store it
		obj.phase = [obj.phase; phaseStruct(~isthere)];
	end
end

% output of function--not very important
[~, Loctt] = findstruct(obj.phase, 'ttNo', mappedTT);
phaseStruct = cat(1, obj.phase([Loctt{:}]));