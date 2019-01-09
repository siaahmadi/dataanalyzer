function adjustpath_setadj(hFig,adj)
setappdata(hFig,'rotation',adj.rotation);
pos = adj2pos(adj);
setPosition(h.selectBox,pos);
set(h.rotText,'String',num2str(-adj.rotation));
adjustpath_refreshpath(hFig);