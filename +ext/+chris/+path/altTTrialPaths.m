function altTTrialPaths(sessionsFile)
% changes made to code by @author: Sia @date 9/15/15 7:26 PM

% [adj sessInfo] = adjustpathbatch_open(adjFile);

sessInfo = sessionsFileToStruct(sessionsFile);
adj.included = [sessInfo.include];
adj.applied = true(size(adj.included));
adj.sessions = [sessInfo.session];

iInc = adj.sessions(adj.included & adj.applied);
for i = iInc
    clc;
    disp(['Calculating Alt-T paths for...']);
    disp(['Session: ' num2str(i)]);
    nPaths = length(sessInfo(i).sessDirs);
    for p = 1:nPaths
        disp(['Loading path: ' sessInfo(i).sessDirs{p}]);
        pathDir = [sessInfo(i).mainDir '\' sessInfo(i).sessDirs{p}];
        pathData = load([pathDir '\pathData.mat']);
        disp(['Idealizing...']);
        [pathDataIdeal, locInfo, maze] = idealizepath(pathData); %#ok<ASGLU>
        disp(['Getting trials...']);
        trialInfo = altTTrials(locInfo);
        disp(['Linearizing...']);
        pathDataLin = linearizepath(pathDataIdeal,trialInfo);
        save([pathDir '\pathDataIdeal_SIA_TEST.mat'],'-struct','pathDataIdeal');
        save([pathDir '\pathDataLinear_SIA_TEST.mat'],'-struct','pathDataLin');
        save([pathDir '\locInfo_SIA_TEST.mat'],'-struct','locInfo');
        save([pathDir '\trialInfo_SIA_TEST.mat'],'-struct','trialInfo');
    end
end