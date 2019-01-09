% Changes made to Chris's code by @author: Sia on @date 9/18/15 2:01 PM
bInd = 1; % dummy variable for debuggin -- should be set to 1 otherwise
if bInd ~= 1
	warning('In DEBUG mode...')
end

sessInfo = sessionsFileToStruct('X:\Marta\Fig8Project\Sessions_Marta.m');
overwrite = false;

regToUse = {'center','choice','base', 'return', 'reward', 'choiceEnd'}; % used to be just first 3: changed on @date 9/18/15 by @author: Sia
% trialCorrectness = 'correct';
% trialDirection = 'any';
% 
% switch trialCorrectness
%     case 'any'
%         correctInclude = {'success',[true false]};
%     case 'correct'
%         correctInclude = {'success',true};
%     case 'incorrect'
%         correctInclude = {'success',false};
% end
% switch trialDirection
%     case 'any'
%         dirInclude = {'direction',{'L','R'}};
%     case 'left'
%         dirInclude = {'direction',{'L'}};
%     case 'right'
%         dirInclude = {'direction',{'R'}};
% end
trialCriteria.direction = {'L'};
trialCriteria.success = [];
trialCriteria.trial = [1:10];

regLocs.center = {'A25'};
regLocs.choice = {'N5'};
regLocs.base = {'A56','A45'};
regLocs.return = {'A16','N1','A12','A23','N3','A34'};
regLocs.reward = {'N6','N4'};
regLocs.choiceEnd = {'N2'};

allRegions = fields(regLocs);
locsToUse = [];
for r = 1:length(regToUse)
   locsToUse = cat(2,locsToUse,regLocs.(regToUse{r})); 
end

epochDirs = {sessInfo.sessDirs}';
% mainDirs = {'X:\Marta\G2a\Rat3656\Recording_02-21-15_Day3',...
%     'X:\Marta\G2a\Rat3661\Recording_02-19-15_Day3'};
mainDirs = {sessInfo.mainDir}';
adjustmentFile = repmat({'Y:\Chris\binFinderRedux\Path\Processing\test3.adj'}, size(mainDirs));
TFile = {sessInfo.tList}';

locInfo = cell(length(mainDirs), 1);
pathData = cell(length(mainDirs), 1);
pathDataIdeal = cell(length(mainDirs), 1);
pathDataLin = cell(length(mainDirs), 1);
trialInfo = cell(length(mainDirs), 1);
didntWork = [];
for dirNum = bInd:length(mainDirs)
	try
		sessDirs = cellfun(@(x) fullfile(mainDirs{dirNum}, x), epochDirs{dirNum}, 'UniformOutput', false);

		pathData{dirNum} = adjustpath(sessDirs(:),adjustmentFile{dirNum});
		[pathDataIdeal{dirNum}, locInfo{dirNum}, maze] = idealizepath(pathData{dirNum});
		trialInfo{dirNum} = altTTrials(locInfo{dirNum});
		pathDataLin{dirNum} = linearizepath(pathDataIdeal{dirNum},trialInfo{dirNum});
% 		[tSp, TList] = loadspikes(sessDirs,fullfile(mainDirs{dirNum}, TFile{dirNum}));
% 
% 		subTrialInfo = selecttrials(trialInfo,trialCriteria,locsToUse);
% 		tSpTrial = extracttrials(subTrialInfo,tSp);
% 		trialPaths = extracttrials(subTrialInfo,pathDataLin);
	catch err
		warning([num2str(dirNum), ' didn''t work'])
		didntWork = [didntWork; dirNum];
		continue;
	end
end

% separate by subtrial (block) and save in respective folder:
% locInfo, pathData, pathDataIdeal, pathDataLin, trialInfo
rememberWhoDidntGetSaved = [];
for dirNum = setdiff(bInd:length(mainDirs), didntWork)
	sessDirs = cellfun(@(x) fullfile(mainDirs{dirNum}, x), epochDirs{dirNum}, 'UniformOutput', false);

	for s = 1:length(sessDirs)
		li = locInfo{dirNum}(s);
		pd = pathData{dirNum}(s);
		pdi = pathDataIdeal{dirNum}(s);
		pdl = pathDataLin{dirNum}(s);
		ti = trialInfo{dirNum}(s);
		
		if ~exist(fullfile(sessDirs{s}, 'locInfo.mat'), 'file') || overwrite
			save(fullfile(sessDirs{s}, 'locInfo.mat'),'-struct','li');
		else
			rememberWhoDidntGetSaved{end+1} = fullfile(sessDirs{s}, 'locInfo.mat');
		end
		if ~exist(fullfile(sessDirs{s}, 'pathData.mat'), 'file') || overwrite
			save(fullfile(sessDirs{s}, 'pathData.mat'),'-struct','pd');
		else
			rememberWhoDidntGetSaved{end+1} = fullfile(sessDirs{s}, 'pathData.mat');
		end
		if ~exist(fullfile(sessDirs{s}, 'pathDataIdeal.mat'), 'file') || overwrite
			save(fullfile(sessDirs{s}, 'pathDataIdeal.mat'),'-struct','pdi');
		else
			rememberWhoDidntGetSaved{end+1} = fullfile(sessDirs{s}, 'pathDataIdeal.mat');
		end
		if ~exist(fullfile(sessDirs{s}, 'pathDataLinear.mat'), 'file') || overwrite
			save(fullfile(sessDirs{s}, 'pathDataLinear.mat'),'-struct','pdl');
		else
			rememberWhoDidntGetSaved{end+1} = fullfile(sessDirs{s}, 'pathDataLinear.mat');
		end
		if ~exist(fullfile(sessDirs{s}, 'trialInfo.mat'), 'file') || overwrite
			save(fullfile(sessDirs{s}, 'trialInfo.mat'),'-struct','ti');
		else
			rememberWhoDidntGetSaved{end+1} = fullfile(sessDirs{s}, 'trialInfo.mat');
		end
	end
end