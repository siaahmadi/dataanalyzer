function initialize(obj, residencePath, nameString, spatialEnvironment)
obj.residencePath = residencePath;
obj.namestring = nameString;
obj.fullPath = fullfile(residencePath, nameString);
obj.trialSeqInd = str2double(regexp(nameString, '\d*', 'match', 'once'));
if ~isempty(residencePath)
	obj.duration = obj.getDuration();
end

ratNo = regexp(residencePath, '(R|r)at\d{3,4}', 'match', 'once');
ratNo = str2double(ratNo(4:end));
obj.ratNo = ratNo;