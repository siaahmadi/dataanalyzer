function adjustpathbatch_initdisplay(hFig)
h = getappdata(hFig,'handles');
h.selectBox = imrect(h.ctrlAxes,[0 0 1 1]);
setappdata(hFig,'handles',h);

selResizeFcn = adjustpathbatch_makeMazeResizeFcn(hFig);
addNewPositionCallback(h.selectBox,selResizeFcn);

set(h.sessText,'Position',[1 1 60 22]);
% set(h.refText,'Position',[1 1 60 22]);
set(h.adjSetText,'Position',[1 -2 70 30]);
set(h.rotLabel,'Position',[1 -2 105 22]);

sessions = getappdata(hFig,'sessions');
sessList = arrayfun(@(a)num2str(a),sessions,'uniformoutput',0);
set(h.sessMenu,'String',sessList);
adjSetBBoxPos = get(h.adjSetBBox,'Position');
adjSetBBoxPos(2) = 0.06;
set(h.adjSetBBox,'Position',adjSetBBoxPos);

currInd = getappdata(hFig,'currInd');
adjustpathbatch_changesess(hFig,currInd);


