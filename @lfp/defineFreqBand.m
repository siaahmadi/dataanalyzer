function bandStruct = defineFreqBand(name, low, high)
%DEFINEFREQBAND Generate valid frequency band definition structs for
%@dataanalyzer.lfp objects.
%
% To generate several frequency band definitions use @cellfun to call this
% method.

% Siavash Ahmadi
% 11/27/2015 12:43 PM

if ~ischar(name)
	error('name must be a string');
end

if ~isnumeric(low)
	error('Lower cutoff frequency must be a non-negative numeric value.');
end

if ~isnumeric(high) || high <= low
	error('Higher cutoff frequency must be a numeric value strictly larger than the lower cutoff value.');
end

bandStruct.name = name;
bandStruct.cutoff_low = low;
bandStruct.cutoff_high = high;

% just to make sure this function is working in tandem with
% validateInputArgs:
p___validateInputArgs('freqBand', bandStruct);