function [eeg, ts, Fs] = readEEG(fullPath, ttNo, convertToDouble)
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

if ~isnumeric(ttNo)
	error('DataAnalyzer:EEG:ttNoNotNumeric', 'Please enter a numeric array of tetrode numbers for ttNo.');
end

if ~exist('ttNo', 'var') || isempty(ttNo)
	d = dir(fullfile(fullPath, '*.ncs'));
	
	ttNo = sort(str2double(regexp({d.name}', '(?<=^CSC)\d{1,2}(?=.ncs)', 'match', 'once')));
end

% repeating the ['CSC' ... '.ncs'] etc because this will work regardless of whether or not ttNo is supplied
f = fullfile(fullPath, cellfun(@(x) ['CSC' num2str(x) '.ncs'], num2cell(ttNo), 'UniformOutput', false));

eeg = cell(size(f));
Fs = cell(size(f));
ts = cell(size(f));

for i = 1:length(f)
	[~, nm, xt] = fileparts(f{i});
	if exist(f{i}, 'file') ~= 2 % EEG file doesn't exist
		warning('DataAnalyzer:EEG:FileNonExistent', ['EEG file ''' nm, xt, ''' not found. Skipping...']);
		continue;
	end
	try
		[eeg{i}, Fs{i}] = readCRTsd(f{i});
	catch err
		if strcmp(err.identifier, 'readCRTsd:FileEmpty') % EEG file empty
			warning('DataAnalyzer:Trial:EEG:FileEmpty', ['EEG file ''' nm, xt, ''' empty. Skipping...']);
			continue;
		else
			rethrow(err)
		end
	end
	ts{i} = EEG.toSecond(eeg{i});
	Fs{i} = dataanalyzer.routines.EEG.Fs(eeg{i}); % More precise Fs than the one recorded in the .ncs file.
	if exist('convertToDouble', 'var') && convertToDouble
		eeg{i} = Data(eeg{i});
	end
end

if length(f) == 1
	eeg = eeg{1};
	Fs = Fs{1};
	ts = ts{1};
end