function adjustpathbatch_sessMenu(src,~,hFig)
defInds = getappdata(hFig,'defInds');
iNewInd = get(src,'Value');
newInd = defInds(iNewInd);
adjustpathbatch_changesess(hFig,newInd);
