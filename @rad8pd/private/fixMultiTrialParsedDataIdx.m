function parsedVisits = fixMultiTrialParsedDataIdx(parsedVisits, l)
%pathData = fixMultiTrialParsedDataIdx(parsedVisits, l)
%
% Adds |l| to each and every index value in parsedVisits

% Siavash Ahmadi
% 12/14/2015 7:52 PM Used to work for pathData.visits
% 12/15/2015 10:30 AM Now works for parsedVisits (accepts pathData.visits
% as input rather than pathData)

fn = fieldnames(parsedVisits);

for i = 1:length(fn)
	if isnumeric(parsedVisits.(fn{i})) % do it only for indices, not for trial name
		parsedVisits.(fn{i}) = parsedVisits.(fn{i}) + l;
	end
end