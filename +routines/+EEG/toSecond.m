function t = toSecond(eeg, whichFunction)
%t = toSecond(eeg, whichFunction)
%
% The conversion factor of the |eeg| tsd object to seconds. If a second
% argument |whichFunction| is provided that function will be called on EEG
% and the results coverted to seconds and returned.
%
%
% Available |whichFunction|s:
%
%    tsd/Range     - Timestamps used
%    tsd/DT        - Returns the DT value (mean diff(timestamps))
%    tsd/StartTime - First timestamp
%    tsd/EndTime   - Last timestamp

% Siavash Ahmadi
% 10/3/15

if ~isa(eeg, 'tsd')
	error('EEG:InputClassNotTSD', 'The input type must be a tsd.');
end

switch Units(eeg)
	case {'sec', 's'}
		conversionRate = 1;
	case 'ms'
		conversionRate = 1e-6;
	case 'ts'
		conversionRate = 1e-4;
end

if nargin < 2
	t = conversionRate;
else
	switch whichFunction
		case 'Range'
			t = Range(eeg)*conversionRate;
		case 'DT'
			t = DT(eeg)*conversionRate;
		case 'StartTime'
			t = StartTime(eeg)*conversionRate;
		case 'EndTime'
			t = EndTime(eeg)*conversionRate;
		otherwise
			error('EEG:InvalidConversionRequested', 'Check spelling. The functions available are only: Range, DT, StartTime, EndTime.')
	end
end