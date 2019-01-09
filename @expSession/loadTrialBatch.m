function loadTrialBatch(obj, trialList) % load certain list of trials

	numNoTFiles = 0;
	for i = 1:numel(trialList)
		obj.loadTrial(trialList{i});

		trInd = cellfun(@(x) strcmp(x.namestring, trialList{i}), obj.trials);
		if strcmp(obj.trials{trInd}.neurons.load_status.message, 'DataAnalyzer:ConstructingTrialObj:NoTFilesInTrialDirectory')
			numNoTFiles = numNoTFiles + 1;
		end
	end
	
	if numNoTFiles == numel(trialList) % none of trial directories contained .t files -- try the parent (session) directory
		obj.loadSpikesFromSessionDir(obj.getTrials());
	end
end