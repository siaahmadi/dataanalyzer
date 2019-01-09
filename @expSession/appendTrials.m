function trials = appendTrials(obj, TrialList, TrialTypes)
	if ~samesize(TrialList, TrialTypes)
		error('TrialList and TrialTypes size not consistent')
	end
	TrialList = TrialList(:);
	TrialTypes= TrialTypes(:);
	if ~(prod(cellfun(@isa, TrialList, repmat({'dataanalyzer.trial'}, size(TrialList)))))
		error('Please input a list of objects, each of type ''trial''')
	end
	obj.trials = [obj.trials; TrialList];
	obj.isBeginTrial = [obj.isBeginTrial; TrialTypes];
	trials = obj.trials;
	neuronList = [];
	for i = 1:length(TrialList)
		neuronList = union(neuronList, TrialList{i}.getNeuronList());
	end
	if ~isempty(neuronList)
		obj.sessionNeuronList = union(obj.sessionNeuronList, neuronList);
	end
end