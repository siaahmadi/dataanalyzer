function wtIdx = selectTrials(obj, whichTrials)

if iscell(whichTrials)
	wtIdx = cell2mat(cellfun(@(x, n) n*strcmp(obj.trialList(:), x), whichTrials, num2cell(1:length(whichTrials)), 'UniformOutput', false));
	[r, ~] = find(wtIdx); % must use [r, ~] style to enforce nargout == 2 in find
	
	wtIdx = r;
elseif ischar(whichTrials)
	wtIdx = strcmp(obj.trialList, whichTrials);
else
	wtIdx = whichTrials;
end

if ~any(wtIdx)
	error('Requested trials are either not within index bounds or not found')
end