function Spikes = loadtb(path, lmode, trials, ttlist)
%SPIKES.LOADTB Load spikes easily (output a table)
%
% Spikes = SPIKES.LOADTB(path, lmode, trials, ttlist)
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
% Spikes  N x T table of spikes where the variables of the table are the
%         subdirectories, and row names the .t file names.

% Siavash Ahmadi 9/22/2016 11:01 AM

if ~exist('lmode', 'var') || isempty(lmode)
	lmode = 'default';
end

Spikes = {};

fprintf('\nLoading in %s mode...\n\n', lmode);

if exist('ttlist', 'var')
	if ischar(ttlist)
		tfiles = ReadFileList(fullfile(path, ttlist));
	elseif iscellstr(ttlist)
		tfiles = ttlist;
	end
	[~, ~, ~, sdir] = listAllTFiles(path);
else
	[tfiles, ~, ~, sdir] = listAllTFiles(path);
end

if exist('trials', 'var') && ~isempty(trials)
	sdir = trials;
else
	sdir = dir(path);
	sdir = {sdir(arrayfun(@(x) x.isdir, sdir)).name}';
	sdir = sdir(3:end);
end

if strcmpi(lmode, 'session')
	Spikes = loadspikes(path, tfiles, 'seconds');
	Spikes = Spikes(:);
end
if strcmpi(lmode, 'trial')
	Spikes = cellfun(@(subdir) loadspikes(fullfile(path, subdir), tfiles), sdir, 'un', 0);
	Spikes = cat(1, Spikes{:})';
	Spikes = array2table(Spikes, 'VariableNames', sdir, 'RowNames', tfiles);
end
if strcmpi(lmode, 's2t')
	[ts, strings] = Nlx2MatEV(fullfile(path, 'Events.nev'), [1, 0, 0, 0, 1, 0], 0, 1, 0);
	ts = ts * 1e-6;
	i = ismember(strings, sdir);
	ts_begin = ts(i);
	ts_end = ts(circshift(i, 1));
	Spikes = dataanalyzer.routines.spikes.loadtb(path, 'session', sdir, tfiles);
	Spikes = cellfun(@(sp) arrayfun(@(b,e) restr(sp, b, e), ts_begin, ts_end, 'un', 0), Spikes, 'un', 0);
	Spikes = cat(1, Spikes{:});
end
if strcmpi(lmode, 't2s')
	Spikes = table2array(dataanalyzer.routines.spikes.loadtb(path, 'trial', sdir, tfiles));
	Spikes = cellfun(@(c) sort(cat(1, c{:})), row2cell(Spikes), 'un', 0);
end
if strcmpi(lmode, 'default')
	Spikes = dataanalyzer.routines.spikes.loadtb(path, 'session', sdir, tfiles);
	if all(cellfun(@isempty, Spikes.Session))
		fprintf('No .t files read. Attempting to read in t2s mode...\n\n');
		Spikes = dataanalyzer.routines.spikes.loadtb(path, 't2s', sdir, tfiles);
	end
end
if strcmpi(lmode, 'defaulttrial')
	Spikes = dataanalyzer.routines.spikes.loadtb(path, 'trial', sdir, tfiles);
	if all(cellfun(@isempty, Spikes))
		Spikes = dataanalyzer.routines.spikes.loadtb(path, 's2t', sdir, tfiles);
	end
end

if ~istable(Spikes)
	if length(sdir) == size(Spikes, 2)
		Spikes = array2table(Spikes, 'VariableNames', sdir, 'RowNames', tfiles);
	else
		Spikes = array2table(Spikes, 'VariableNames', {'Session'}, 'RowNames', tfiles);
	end
end