function adjustpathbatch_saveadjBtn(src,~,hFig)
iCurrInd = getappdata(hFig,'iCurrInd');
defInds = getappdata(hFig,'defInds');
sessInd = defInds(iCurrInd);
saved = getappdata(hFig,'saved');
modified = getappdata(hFig,'modified');
defined = getappdata(hFig,'defined');

modified(iCurrInd) = false;
saved(iCurrInd) = true;
defined(iCurrInd) = true;
setappdata(hFig,'modified',modified);
setappdata(hFig,'saved',saved);
setappdata(hFig,'defined',defined);

adj = getappdata(hFig,'adj');
batchAdj = getappdata(hFig,'batchAdj');
adjFields = fields(adj);
for af = 1:length(adjFields)
   batchAdj.(adjFields{af})(sessInd) = adj(iCurrInd).(adjFields{af}); 
end
batchAdj.defined(sessInd) = true;
batchAdj.defDate(sessInd) = now;
setappdata(hFig,'batchAdj',batchAdj);
figTitle = ['Adjust path - ' batchAdj.adjFile '*'];
set(hFig,'Name',figTitle);
fileModified = true;
setappdata(hFig,'fileModified',fileModified);
adjustpathbatch_setsaverevert(hFig);
adjustpathbatch_setsessmenu(hFig);