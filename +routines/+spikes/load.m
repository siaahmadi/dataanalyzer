function [Spikes, tFiles, anatomy] = load(path, lmode, trials, ttlist)
%SPIKES.LOAD Load spikes easily
%
% [Spikes, tFiles, anatomy] = SPIKES.LOAD(path, lmode, trials, ttlist)
%
% path    Path to Session
%
% lmode   (Loading Mode)
%           'default'      Load session .t files from session or trial dirs
%           'defaulttrial' Load trial .t files from session or trial dirs
%           'session'      Load the .t files in the session directory
%           'trial'        Load the .t files from the trial directories
%           's2t'          Load session .t files and split them up into trials
%           't2s'          Load trial .t files and concat them to make session .t files
%
% 
% Spikes  N x T cell array of spikes where N is the number of .t files
%         found in all subdirectories of the specified session and T is 1 if
%         session is requested and is equal to # trials otherwise.

% Siavash Ahmadi 8/17/2016 4:13 PM
% Modified 4/1/2016

if ~exist('lmode', 'var') || isempty(lmode)
	lmode = 'default';
end

Spikes = {};

fprintf('\nLoading in %s mode...\n\n', lmode);

if exist('ttlist', 'var')
	if ischar(ttlist)
		tFiles = ReadFileList(fullfile(path, ttlist));
	elseif iscellstr(ttlist)
		tFiles = ttlist;
	end
	[~, ~, ~, sdir] = listAllTFiles(path);
else
	[tFiles, ~, ~, sdir] = listAllTFiles(path);
end

if exist('trials', 'var') && ~isempty(trials)
	sdir = trials;
end

if strcmpi(lmode, 'session')
	Spikes = loadspikes(path, tFiles, 'seconds');
	Spikes = Spikes(:);
end
if strcmpi(lmode, 'trial')
	Spikes = cellfun(@(subdir) loadspikes(fullfile(path, subdir), tFiles), sdir, 'un', 0);
	Spikes = cat(1, Spikes{:})';
end
if strcmpi(lmode, 's2t')
	[ts, strings] = Nlx2MatEV(fullfile(path, 'Events.nev'), [1, 0, 0, 0, 1, 0], 0, 1, 0);
	ts = ts * 1e-6;
	i = ismember(strings, sdir);
	ts_begin = ts(i);
	ts_end = ts(circshift(i, 1));
	Spikes = dataanalyzer.routines.spikes.load(path, 'session');
	Spikes = cellfun(@(sp) arrayfun(@(b,e) restr(sp, b, e), ts_begin, ts_end, 'un', 0), Spikes, 'un', 0);
	Spikes = cat(1, Spikes{:});
end
if strcmpi(lmode, 't2s')
	Spikes = dataanalyzer.routines.spikes.load(path, 'trial');
	Spikes = cellfun(@(c) sort(cat(1, c{:})), row2cell(Spikes), 'un', 0);
end
if strcmpi(lmode, 'default')
	Spikes = dataanalyzer.routines.spikes.load(path, 'session');
	if all(cellfun(@isempty, Spikes))
		fprintf('No .t files read. Attempting to read in t2s mode...\n\n');
		Spikes = dataanalyzer.routines.spikes.load(path, 't2s');
	end
end
if strcmpi(lmode, 'defaulttrial')
	Spikes = dataanalyzer.routines.spikes.load(path, 'trial', sdir, tFiles);
	if all(cellfun(@isempty, Spikes))
		Spikes = dataanalyzer.routines.spikes.load(path, 's2t', sdir, tFiles);
	end
end