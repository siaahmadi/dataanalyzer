function preprocess(obj)

error('recheck preprocessing from expSession');

parsemode = 'fig8:rdscr';

epochDirs = dataanalyzer.ancestor(obj, 'expSession').trialDirs;
mainDirs = obj.Parent.fullPath;
adjustmentFile = dataanalyzer.constant('fig8adjfile');

trials = cellfun(@(x) fullfile(mainDirs, x), epochDirs, 'UniformOutput', false);

import dataanalyzer.ext.chris.path.*

pathData = adjustpath(trials(:),adjustmentFile);
[pathDataIdeal, locInfo] = idealizepath(pathData);
trialInfo = trialsFromLoc(locInfo);
pathDataLin = linearizepath(pathDataIdeal,trialInfo);
parseInfo = parsepath(pathDataIdeal,parsingtemplate(parsemode));
parseInfo = parseinfo2trial(parseInfo, trialInfo);


%%
% separate by subtrial (block) and save in respective folder:
% locInfo, pathData, pathDataIdeal, pathDataLin, trialInfo

for s = 1:length(trials)
	li = locInfo(s); %#ok<NASGU>
	pd = pathData(s); %#ok<NASGU>
	pdi = pathDataIdeal(s); %#ok<NASGU>
	pdl = pathDataLin(s); %#ok<NASGU>
	ti = trialInfo(s);

	pri.inds = parseInfo{s};
	pri.tInt = ti.tInt;
	pri.direction = ti.direction;
	pri.success = ti.success;

	save(fullfile(trials{s}, 'locInfo.mat'),'-struct','li');
	save(fullfile(trials{s}, 'pathData.mat'),'-struct','pd');
	save(fullfile(trials{s}, 'pathDataIdeal.mat'),'-struct','pdi');
	save(fullfile(trials{s}, 'pathDataLinear.mat'),'-struct','pdl');
	save(fullfile(trials{s}, 'trialInfo.mat'),'-struct','ti');
	save(fullfile(trials{s}, 'parsingInfo.mat'),'-struct','pri');
end