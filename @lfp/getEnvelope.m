function envStruct = getEnvelope(obj, ttNo, freqBands)

if nargin < 3
	freqBands = dataanalyzer.constant('dflt_freqBands');
end

p___validateInputArgs('freqBand', freqBands);

numBandsReqt = length(freqBands);

envStruct = envstruct(numBandsReqt, 1);

obj.hilbert(ttNo, freqBands);

for tt = ttNo(:)'
	% TODO check if has been computed already
	[ttisthere, idxTT] = findstruct(obj.envelope, 'ttNo', tt);
	for i = 1:numBandsReqt
		if ttisthere
			[bandisthere, idxBand] = findstruct(obj.envelope, 'band', freqBands(i).name);
			idxTTBand = [idxBand{:}] & [idxTT{:}];
		end
		if ttisthere && bandisthere % phase has been computed
			envStruct(i) = obj.envelope(idxTTBand);
		else
			% find the hilbert transform:
			[~, I] = findstruct(obj.eeg, 'ttNo', tt);
			eeg_struct = obj.eeg([I{:}]);
			[~, I] = findstruct(eeg_struct.hilbert, 'band', freqBands(i).name);
			eeg_hilb = eeg_struct.hilbert([I{:}]).ht;

			% compute the envelope
			envelope = abs(eeg_hilb);
			
			% construct the struct
			envStruct(i).ttNo = tt;
			envStruct(i).band = freqBands(i).name;
			envStruct(i).envelope = envelope;
			envStruct(i).ts = EEG.toSecond(eeg_struct.tsd, 'Range');
		end
	end
	
	isthere = findstruct(obj.envelope, 'ttNo', [envStruct.ttNo]) & findstruct(obj.envelope, 'band', {envStruct.band});
	if any(~isthere)
		% store it
		obj.envelope = [obj.envelope; envStruct(~isthere)];
	end
end

% output of function--not very important
[~, Loctt] = findstruct(obj.envelope, 'ttNo', ttNo);
envStruct = cat(1, obj.envelope([Loctt{:}]));