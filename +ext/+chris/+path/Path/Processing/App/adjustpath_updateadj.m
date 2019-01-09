function adjustpath_updateadj(hFig)
h = getappdata(hFig,'handles');
pos = getPosition(h.selectBox);
adj = pos2adj(pos);
adj.rotation = getappdata(hFig,'rotation');
setappdata(hFig,'adj',adj);

adjData = {adj.xCenter,adj.yCenter,adj.xScale,adj.yScale};
set(h.adjTable,'Data',adjData);
set(h.rotText,'String',num2str(-adj.rotation));