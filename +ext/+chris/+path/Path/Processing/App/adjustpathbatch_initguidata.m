function adjustpathbatch_initguidata(batchAdj,sessInfo,toDef,hFig)
setappdata(hFig,'sessInfo',sessInfo);
setappdata(hFig,'batchAdj',batchAdj);
defInds = find(toDef);
setappdata(hFig,'defInds',defInds);
nBatch = length(defInds);
setappdata(hFig,'nBatch',nBatch);
adj = struct([]);
for i = 1:nBatch
    adj(i).xCenter = batchAdj.xCenter(defInds(i));
    adj(i).yCenter = batchAdj.yCenter(defInds(i));
    adj(i).xScale = batchAdj.xScale(defInds(i));
    adj(i).yScale = batchAdj.yScale(defInds(i));
    adj(i).rotation = batchAdj.rotation(defInds(i));
end
sessions = batchAdj.sessions(toDef);
setappdata(hFig,'sessions',sessions);
setappdata(hFig,'adj',adj);
modified = false(nBatch,1);
setappdata(hFig,'modified',modified);
defined = batchAdj.defined(defInds);
saved = defined;
setappdata(hFig,'defined',defined);
setappdata(hFig,'saved',saved);
defDate = nan(nBatch,1);
setappdata(hFig,'defDate',defDate);
iCurrInd = 1;
setappdata(hFig,'iCurrInd',iCurrInd);
currInd = defInds(iCurrInd);
setappdata(hFig,'currInd',currInd);
batchPaths = cell(nBatch,1);
setappdata(hFig,'batchPaths',batchPaths);
pathDirs = cell(nBatch,1);
setappdata(hFig,'pathDirs',pathDirs);
batchLabels = cell(nBatch,1);
setappdata(hFig,'batchLabels',batchLabels);
fileModified = false;
setappdata(hFig,'fileModified',fileModified);