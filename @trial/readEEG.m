function [eeg, ts, Fs] = readEEG(obj, ttNo, convertToDouble)
%[eeg, ts, Fs] = readEEG(obj, ttNo, convertToDouble) Read trial's EEG files
%
%
% Read and return the EEG files in trial's directory. ttNo can be an array
% of numbers indicating which tetrodes should be read.
%
% If empty all existing .ncs files will be read and returned.
%
% If an entry of ttNo is not found in the directory it will be skipped and
% a warning will be issued.

% Siavash Ahmadi
% 10/28/15


if ~exist('convertToDouble', 'var')
	convertToDouble = false;
end

[eeg, ts, Fs] = dataanalyzer.routines.EEG.readEEG(obj.fullPath, ttNo, convertToDouble);