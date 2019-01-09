function toApp = appbatch_getselected(hFig)
adj = getappdata(hFig,'adj');
h = getappdata(hFig,'handles');

tableData = get(h.appTable,'Data');
tableSess = cellfun(@(u)str2num(u),tableData(:,1));
tableApp = cell2mat(tableData(:,end));
toApp = ismember(adj.sessions,tableSess(tableApp));
setappdata(hFig,'toApp',toApp);