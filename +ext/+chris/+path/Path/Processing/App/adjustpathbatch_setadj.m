function adjustpathbatch_setadj(hFig)
adj = getappdata(hFig,'adj');
currInd = getappdata(hFig,'currInd');
batchAdj = getappdata(hFig,'batchAdj');

batchAdj.xCenter(currInd) = adj.xCenter;
batchAdj.yCenter(currInd) = adj.yCenter;
batchAdj.xScale(currInd) = adj.xScale;
batchAdj.yScale(currInd) = adj.yScale;
batchAdj.rotation(currInd) = adj.rotation;
batchAdj.defined(currInd) = true;
batchAdj.defDate(currInd) = now;

setappdata(hFig,'batchAdj',batchAdj);
