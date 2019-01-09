regToUse = {'center','choice','base'};
trialCorrectness = 'correct';
trialDirection = 'any';

switch trialCorrectness
    case 'any'
        correctInclude = {'success',[true false]};
    case 'correct'
        correctInclude = {'success',true};
    case 'incorrect'
        correctInclude = {'success',false};
end
switch trialDirection
    case 'any'
        dirInclude = {'direction',{'L','R'}};
    case 'left'
        dirInclude = {'direction',{'L'}};
    case 'right'
        dirInclude = {'direction',{'R'}};
end
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
    
epochDirs = {'delay2','delay10','nodelay1','nodelay2'};
mainDirs = {'X:\Marta\G2a\Rat3656\Recording_02-21-15_Day3',...
    'X:\Marta\G2a\Rat3661\Recording_02-19-15_Day3'};
adjustmentFile = {'Y:\Chris\binFinderRedux\Path\Processing\test3.adj';'Y:\Chris\binFinderRedux\Path\Processing\test2.adj'};
TFile = 'TTList.txt';
for dirNum = 1:length(mainDirs)
	sessDirs = cell(4,1);
	for s = 1:4
		sessDirs{s} = [mainDirs{dirNum} '\' epochDirs{s}];
	end
	pathData = adjustpath(sessDirs,adjustmentFile{dirNum});
	[pathDataIdeal, locInfo, maze] = idealizepath(pathData);
	trialInfo = altTTrials(locInfo);
	pathDataLin = linearizepath(pathDataIdeal,trialInfo);
	[tSp, TList] = loadspikes(sessDirs,fullfile(mainDirs{dirNum}, TFile));

	subTrialInfo = selecttrials(trialInfo,trialCriteria,locsToUse);
	tSpTrial = extracttrials(subTrialInfo,tSp);
	trialPaths = extracttrials(subTrialInfo,pathDataLin);
end