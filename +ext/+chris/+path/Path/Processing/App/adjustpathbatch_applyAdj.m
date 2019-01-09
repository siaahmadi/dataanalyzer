function adjustpathbatch_applyAdj(src,~,hFig)
set(hFig,'Visible','off');
sessInfo = getappdata(hFig,'sessInfo');
batchAdj = getappdata(hFig,'batchAdj');
toApp = appbatch_create(batchAdj);
appInds = find(toApp);
nInds = length(appInds);
for a = 1:nInds;
    clc;
    disp('Applying path adjustments for...');
    disp(['Session: ' num2str(batchAdj.sessions(appInds(a))) ' (' num2str(a) ' of ' num2str(nInds)]);
    
    adj.xCenter = batchAdj.xCenter(appInds(a));
    adj.yCenter = batchAdj.yCenter(appInds(a));
    adj.xScale =  batchAdj.xScale(appInds(a));
    adj.yScale = batchAdj.yScale(appInds(a));
    adj.rotation = batchAdj.rotation(appInds(a));
    
    nPaths = length(sessInfo(appInds(a)).sessDirs);
    for p = 1:nPaths
        pathDir = [sessInfo(appInds(a)).mainDir '\' sessInfo(appInds(a)).sessDirs{p}];
        pathData = adjustpath(pathDir,adj);
        save([pathDir '\pathData.mat'],'-struct','pathData');
    end
    batchAdj.applied(appInds(a)) = true;
    batchAdj.appDate(appInds(a)) = now;
    save(batchAdj.adjFile,'-struct','batchAdj');
    setappdata(hFig,'batchAdj',batchAdj);
end
set(hFig,'Visible','on');