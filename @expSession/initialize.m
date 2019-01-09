function initialize(obj, fullPath, allOptions)

obj.Mask = dataanalyzer.maskarray(dataanalyzer.mask(ivlset(-Inf, Inf), obj, 'default'), obj);
obj.setOptions(allOptions);
sepIdx = find(fullPath == filesep);
if sepIdx(end) == length(fullPath), fullPath = fullPath(1:end-1); end % to ensure fullPath doesn't end in a filesep
[obj.residencePath, obj.namestring] = fileparts(fullPath); % changed on @date 10/23/15 11:34 AM by @author Sia
obj.fullPath = fullPath;
obj.ratNo = getRatNo(obj.residencePath);

trialsFile = fullfile(obj.fullPath, 'trials.txt');
if ~exist(trialsFile, 'file')
	error('Cannot initialize. trials.txt not found.');
end
epochDirs = textreadtable(trialsFile);
obj.trialDirs = epochDirs;
obj.spatialEnvironment = {obj.trialDirs.environment}';

function ratNo = getRatNo(residencePath)

ratNo = regexpi(residencePath, 'Rat\d{3,4}', 'match', 'once');
ratNo = str2double(ratNo(4:end));
