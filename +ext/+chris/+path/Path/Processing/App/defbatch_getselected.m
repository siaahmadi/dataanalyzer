function toDef = defbatch_getselected(hFig)
adj = getappdata(hFig,'adj');
h = getappdata(hFig,'handles');

tableData = get(h.defTable,'Data');
tableSess = cellfun(@(u)str2num(u),tableData(:,1));
tableDef = cell2mat(tableData(:,end));
toDef = ismember(adj.sessions,tableSess(tableDef));
setappdata(hFig,'toDef',toDef);