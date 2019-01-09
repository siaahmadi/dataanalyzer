function obj = loadTrials(obj, bgnStr, slpStr) % load all trials of session

epochDirs = dataanalyzer.ancestor(obj, 'expSession').trialDirs;
mainDirs = obj.fullPath;
obj.loadTrialBatch(epochDirs);

error('Todo');
xp = dataanalyzer.ancestor(obj, 'trial');
if ~isa(xp.positionData, 'dataanalyzer.fig8')
	if nargin ~= 3
		bgnStr = 'begin'; slpStr = 'sleep';
	end
	listOfAllTrials = makeListOfAllTrials(obj.fullPath, bgnStr, slpStr);

	obj.loadTrialBatch(listOfAllTrials);
end
