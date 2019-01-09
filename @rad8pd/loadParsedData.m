function obj = loadParsedData(obj, parsedVisits)
% Loads everything from parsedVisits

% % Prior to 5/9/2018:
% fn = setdiff(fieldnames(parsedVisits), 'trial');
% 
% if numel(parsedVisits) > 1 % from more than one trial
% 	begintrialStartIdx = find(lau.rton(beginsGlobalIdx)) - 1;
% 	parsedVisits = arrayfun(@fixMultiTrialParsedDataIdx, parsedVisits, begintrialStartIdx(:), 'un', 0);
% 	parsedVisits = cat(1, parsedVisits{:});
% end
% 
% for trInd = 1:length(parsedVisits)
% 	for i = 1:length(fn)
% 		Runs(trInd, 1).(fn{i}) = obj.runsFromParsedData(parsedVisits(trInd).(fn{i})); %#ok<AGROW>
% 	end
% 	Runs(trInd, 1).trial = parsedVisits(trInd).trial;
% end
% 
% obj.parsedComponents = Runs;

parsedVisits.readme = 'If this leads to an error, trace it in rad8pd.loadParsedData';
obj.parsedComponents = parsedVisits;