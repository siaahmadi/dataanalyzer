function defbatch_settabledata(hFig)
adj = getappdata(hFig,'adj');
nSess = length(adj.sessions);
h = getappdata(hFig,'handles');

sessCol = arrayfun(@(a)num2str(a),adj.sessions','uniformoutput',0);
defCol = repmat({'No'},nSess,1);
defCol(adj.defined) = {'Yes'};
defDateCol  = cell(nSess,1);
defDateCol(adj.defined) = arrayfun(@(u)datestr(u),adj.defDate(adj.defined),'uniformoutput',0);
defDateCol(~adj.defined) = {''};
appCol = repmat({'No'},nSess,1);
appCol(adj.applied) = {'Yes'};
appDateCol  = cell(nSess,1);
appDateCol(adj.applied) = arrayfun(@(u)datestr(u),adj.appDate(adj.applied),'uniformoutput',0);
appDateCol(~adj.applied) = {''};
selDefCol = false(nSess,1);
selDefCol(~adj.defined) = true;
selDefCol = num2cell(selDefCol);

tableData = [sessCol,defCol,defDateCol,appCol,appDateCol,selDefCol];
tableData = tableData(adj.included,:);
set(h.defTable,'Data',tableData);


