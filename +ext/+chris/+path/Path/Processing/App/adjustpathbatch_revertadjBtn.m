function adjustpathbatch_revertadjBtn(src,~,hFig)
iCurrInd = getappdata(hFig,'iCurrInd');
defInds = getappdata(hFig,'defInds');
sessInd = defInds(iCurrInd);
saved = getappdata(hFig,'saved');
modified = getappdata(hFig,'modified');

modified(iCurrInd) = false;
saved(iCurrInd) = true;
setappdata(hFig,'modified',modified);
setappdata(hFig,'saved',saved);

adj = getappdata(hFig,'adj');
batchAdj = getappdata(hFig,'batchAdj');
adjFields = fields(adj);
for af = 1:length(adjFields)
   adj(iCurrInd).(adjFields{af}) = batchAdj.(adjFields{af})(sessInd); 
end
setappdata(hFig,'adj',adj);
rotation = adj(iCurrInd).rotation;
setappdata(hFig,'rotation',rotation);
selectPos = adj2pos(adj(iCurrInd));
setappdata(hFig,'selectPos',selectPos);
adjustpath_setshowdata(hFig);
adjustpath_updatedisplay(hFig);