function fs = Fs(eeg)
%fs = FS(EEG)
%
% Sample rate of Neuralynx LFP recordings. Accepts a TSD object containing
% EEG data.

if ~isa(eeg, 'tsd')
	error('EEG:InputClassNotTSD', 'The input type must be a tsd.');
end

conversionRate = dataanalyzer.routines.EEG.toSecond(eeg);

trialLength = (EndTime(eeg) - StartTime(eeg)) * conversionRate;
numSamples = length(eeg);

fs = round(numSamples / trialLength, 1);