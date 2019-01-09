function adjustpathbatch_changesess(hFig,sessInd)
pathDirs = getappdata(hFig,'pathDirs');
batchPaths = getappdata(hFig,'batchPaths');
batchLabels = getappdata(hFig,'batchLabels');
defInds = getappdata(hFig,'defInds');
iInd = find(defInds == sessInd);
% if isequal(iOldInd,iInd)
%     return;
% end
if isempty(pathDirs{iInd})
    sessInfo = getappdata(hFig,'sessInfo');
    thisSess = sessInfo(sessInd);
    batchLabels{iInd} = thisSess.sessDirs;
    
    nPaths = length(batchLabels{iInd});
    pathDirs{iInd} = cell(nPaths,1);
    for path = 1:nPaths
        pathDirs{iInd}{path} = [thisSess.mainDir '\' batchLabels{iInd}{path}];
    end
    batchPaths{iInd} = getPreprocessedIndata(pathDirs{iInd});
    setappdata(hFig,'pathDirs',pathDirs);
    setappdata(hFig,'batchPaths',batchPaths);
    setappdata(hFig,'batchLabels',batchLabels);
end

setappdata(hFig,'pathLabels',batchLabels{iInd});
setappdata(hFig,'pathData',batchPaths{iInd});

adj = getappdata(hFig,'adj');
if isnan(adj(iInd).rotation)
    rotation = 0;
else
rotation = adj(iInd).rotation;
end
setappdata(hFig,'rotation',rotation);
showData = adjustpath_setshowdata(hFig);

if ~isnan(adj(iInd).xCenter)
    selectPos = adj2pos(adj(iInd));
else
    wSelect = diff(minmax(showData.x));
    hSelect = diff(minmax(showData.y));
    xCorner = min(showData.x);
    yCorner = min(showData.y);
    selectPos = [xCorner yCorner wSelect hSelect];
    tmpAdj = pos2adj(selectPos);
%     tmpAdj = rmfield(tmpAdj,'boundary');
    adjFields = fields(tmpAdj);
    for af = 1:length(adjFields)
       adj(iInd).(adjFields{af}) = tmpAdj.(adjFields{af}); 
    end
    adj(iInd).rotation = 0;
    setappdata(hFig,'adj',adj);
end
setappdata(hFig,'selectPos',selectPos);


DEF_CURRLOC = 1;
DEF_PATHLOCS = ones(length(batchPaths{iInd}),1);
DEF_SHOWSEL = true(length(batchPaths{iInd}),1);
setappdata(hFig,'currentLoc',DEF_CURRLOC);
setappdata(hFig,'pathLocs',DEF_PATHLOCS);
setappdata(hFig,'showSelect',DEF_SHOWSEL);
setappdata(hFig,'iCurrInd',iInd);
setappdata(hFig,'currInd',sessInd);

adjustpath_updatedisplay(hFig);

