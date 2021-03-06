function adjustpath_updatedisplay(hFig)
showData = getappdata(hFig,'showData');
[xLims yLims] = adjustpath_getdisplims(hFig);
h = getappdata(hFig,'handles');
pos = [0 0 1 1];

plot(h.pathAxes,showData.x,showData.y,'Color',[0 0 0]);
set(h.pathAxes,'Units','Normalized','Position',pos,'XLim',xLims,'YLim',yLims,'NextPlot','replaceChildren');
set(h.ctrlAxes,'XLim',xLims,'YLim',yLims,'Position',pos);
set(h.tempAxes,'XLim',xLims,'YLim',yLims,'Position',pos);

selectPos = getappdata(hFig,'selectPos');
setPosition(h.selectBox,selectPos);
adjustpath_refreshpathtable(hFig);