function adjustpath_refreshpath(hFig)
h = getappdata(hFig,'handles');
currentLoc = getappdata(hFig,'currentLoc');
pathLocs = getappdata(hFig,'pathLocs');
showSelect = find(getappdata(hFig,'showSelect'));
toShow = intersect(find(pathLocs==currentLoc),showSelect');
if isempty(toShow)
    cla(h.pathAxes);
else
    showData = adjustpath_setshowdata(hFig,toShow);
    plot(h.pathAxes,showData.x,showData.y,'k');

    [xLims yLims] = adjustpath_getdisplims(hFig);
    set(h.pathAxes,'XLim',xLims,'YLim',yLims);
    set(h.ctrlAxes,'XLim',xLims,'YLim',yLims);
    set(h.tempAxes,'XLim',xLims,'YLim',yLims);
end