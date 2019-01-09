function subTrialInfo = selecttrials(trialInfo,trialCriteria,regions)
dataFields = fields(trialInfo);
criteriaFields = fields(trialCriteria);
nCriteria = length(criteriaFields);
nSets = length(trialInfo);
subTrialInfo = struct([]);
for s = 1:nSets
    nTrials = size(trialInfo(s).tInt,1);
    iUse = true(nTrials,1);
    for c = 1:nCriteria
        
        if ~ismember(criteriaFields{c},dataFields)
            error([criteriaFields{c} ' not found in trial struct']);
        end
        criteria = trialCriteria.(criteriaFields{c});
        if isempty(criteria)
            continue;
        end
        meetsCriteria = ismember(trialInfo(s).(criteriaFields{c}),criteria);
        iUse = iUse & meetsCriteria;
    end
    
    for df = 1:length(dataFields)
        if size(trialInfo(s).(dataFields{df}),1) == nTrials
            subTrialInfo(s,1).(dataFields{df}) = trialInfo(s).(dataFields{df})(iUse,:);
        else
            subTrialInfo(s,1).(dataFields{df}) = trialInfo(s).(dataFields{df});
        end
    end
    nTrials = length(find(iUse));
    
    for tr = 1:nTrials
        iUse = ismember(subTrialInfo(s).loc{tr},regions);
		if size(subTrialInfo(s).tInt{tr}, 1) ~= 2
			subTrialInfo(s).tInt{tr} = subTrialInfo(s).tInt{tr}';
		end
		if size(subTrialInfo(s).loc{tr}, 1) ~= 2
			subTrialInfo(s).loc{tr} = subTrialInfo(s).loc{tr}';
		end
        subTrialInfo(s).tInt{tr} = subTrialInfo(s).tInt{tr}(:, iUse); % with Chris's code this should be (iUse, :)
        subTrialInfo(s).loc{tr} = subTrialInfo(s).loc{tr}(:, iUse); % with Chris's code this should be (iUse, :)
    end
end
