function eeg_hilb = hilbert(obj, ttNo, freqBands)
% computes the hilbert transform of the requested ttNo's in the requested
% frequency bands defined by |freqBands| struct. If the transform has
% already been computed and stored in the object, it will not be recomputed
% to save time.
%
% This method is not very useful for direct user call, although it may be
% called by the user. This is mainly used to feed into getPhase and
% getEnvelope to avoid multiple computation of the same information used by
% the two methods.

% Siavash Ahmadi
% 11/27/2015 11:27 PM

if nargin < 3
	freqBands = dataanalyzer.constant('dflt_freqBands');
end

p___validateInputArgs('freqBand', freqBands);

ttNo = mapUserTT(obj, ttNo);

[isthere, Loctt] = findstruct(obj.eeg, 'ttNo', ttNo);
Loctt = [Loctt{:}];

for i = 1:length(ttNo)
	if isthere(i) && isa(obj.eeg(elem(find(Loctt), i)).tsd, 'tsd') % eeg already read -- the @isa part is because if you run this script multiple times without it being completed, ttNo will be written without tsd being read. happens a lot particularly when debugging
		objIdx = elem(find(Loctt), i); % index to struct where ttNo data is stored
		
		eeg = obj.eeg(objIdx).tsd;
	else % must read
		eeg = obj.readEEG(ttNo, true); % true --> save
		if isempty(eeg)
			fprintf('\nMy address is:\ndataanalyzer.lfp.hilbert line 33\n\n');
			% attempt to read eeg_theta_pwr_ratios.mat from expSession's directory
			error('EEG Not Found');
		end
		
		% Asked @readEEG to save the data, so new data will be at the last index
		objIdx = length(obj.eeg); % last item added
	end

	Fs = EEG.Fs(eeg);
	eeg = Data(eeg);
	for b = 1:length(freqBands)
		I = findstruct(obj.eeg(objIdx).hilbert, 'band', freqBands(b).name);
		if ~I % hasn't been computed yet in the "hilbert" substruct of the identified eeg struct
			if egual(freqBands(b).cutoff_high, 50, 0.0099) % for some strange reason XX_Filter doens't like a high cutoff of 50 but works for 49.99! 11/28/2015
				warning('DataAnalyzer:LFP:Hilbert:FilterHighCutoff', 'The filter routine doesn''t like your high cutoff of %d Hz. Changing it to 49.99.', freqBands(b).cutoff_high);
				freqBands(b).cutoff_high = 49.99;
			end
			eeg_filt = XX_Filter(eeg, Fs, freqBands(b).cutoff_low, freqBands(b).cutoff_high);
			eeg_hilb = hilbert(eeg_filt);
			
			hilb_struct = hilbertstruct(1, 1);
			hilb_struct.band = freqBands(b).name;
			hilb_struct.ht = eeg_hilb;
			
			obj.eeg(objIdx).hilbert = [obj.eeg(objIdx).hilbert; hilb_struct];
		end
	end
end

% output of function--not very important
[~, Loctt] = findstruct(obj.eeg, 'ttNo', ttNo);
eeg_hilb = cat(1, obj.eeg([Loctt{:}]).hilbert);