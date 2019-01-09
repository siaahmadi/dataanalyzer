function [obj, trialToAdd] = loadTrial(obj, trialName) % load a single trial
	if isbegin(trialName)
		trialToAdd = dataanalyzer.begintrial(obj.fullPath, trialName, obj.spatialEnvironment, true, true, obj);
		trialType = true;
	elseif issleep(trialName)
		trialToAdd = dataanalyzer.sleeptrial(obj.fullPath, trialName, obj.spatialEnvironment, true, obj);
		trialType = false;
	else
		error('wtf')
	end
	obj.appendTrials({trialToAdd}, trialType);
end