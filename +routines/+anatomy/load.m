function anatomy = load(obj, tFileNames)

obj = dataanalyzer.ancestor(obj, 'expSession');

[~, opt] = dataanalyzer.options(obj.projectname);
rat = str2double(regexp(obj.fullPath, '(?<=Rat)\d{3,4}', 'match', 'once'));
day = str2double(regexp(obj.fullPath, '(?<=Day)\d{1,2}', 'match', 'once'));
if ~exist('tFileNames', 'var')
	tFileNames = {obj.sessionSpikeTrains.tFileName}';
end
tts = str2double(regexp(tFileNames(:), '(?<=TT)\d{1,2}(?=\_)', 'match', 'once'));

db = textreadtable(opt.(obj.projectname).routines_anatomy_load.ttdbfile);

ttPos = arrayfun(@(tt) dataanalyzer.routines.anatomy.lookup(db, rat, tt, 'Day', day), tts, 'un', 0);
anatomy = cat(1, ttPos{:});
