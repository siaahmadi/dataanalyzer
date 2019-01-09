function adjustpath_initdisplay(hFig)
showData = getappdata(hFig,'showData');
[xLims yLims] = adjustpath_getdisplims(hFig);
h = getappdata(hFig,'handles');
pos = [0 0 1 1];
plot(h.pathAxes,showData.x,showData.y,'Color',[0 0 0]);
set(h.pathAxes,'Units','Normalized','Position',pos,'XLim',xLims,'YLim',yLims,'NextPlot','replaceChildren');

set(h.ctrlAxes,'XLim',xLims,'YLim',yLims,'Position',pos);
set(h.tempAxes,'XLim',xLims,'YLim',yLims,'Position',pos);
selectPos = getappdata(hFig,'selectPos');
h.selectBox = imrect(h.ctrlAxes,selectPos);
setappdata(hFig,'handles',h);

selResizeFcn = makeMazeResizeFcn(hFig);
addNewPositionCallback(h.selectBox,selResizeFcn);
setPosition(h.selectBox,selectPos);

set(h.locText,'Position',[1 1 60 22])
set(h.refText,'Position',[1 1 60 22])
set(h.adjSetText,'Position',[1 -2 70 30]);
set(h.rotLabel,'Position',[1 -2 105 22]);

adjSetBBoxPos = get(h.adjSetBBox,'Position');
adjSetBBoxPos(2) = 0.06;
set(h.adjSetBBox,'Position',adjSetBBoxPos);



