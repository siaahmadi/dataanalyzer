function adjustpathbatch_setsaverevert(hFig)
h = getappdata(hFig,'handles');
iCurrInd = getappdata(hFig,'iCurrInd');
defined = getappdata(hFig,'defined');
modified = getappdata(hFig,'modified');
if defined(iCurrInd) && modified(iCurrInd)
    set(h.adjRevertBtn,'enable','on')
else
    set(h.adjRevertBtn,'enable','off');
end
if modified(iCurrInd)
    set(h.adjSaveBtn,'enable','on')
else
    set(h.adjSaveBtn,'enable','off');
end
