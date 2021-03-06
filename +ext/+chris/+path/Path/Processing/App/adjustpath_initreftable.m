function adjustpath_initreftable(hFig)
h = getappdata(hFig,'handles');
colNames = {'Template'};
rowName = {'Path'};
colFmt = {'logical'};
defData = {true};

h.refTable = uitable('Parent',h.refPanel,...
                    'Data',defData,...
                    'ColumnName', colNames,...
                    'ColumnFormat',colFmt,...
                    'ColumnEditable',[true],...
                    'ColumnWidth',{'auto'},...
                    'RowName',rowName,...
                    'CellEditCallback',{@adjustpath_editpathtable,hFig});
setappdata(hFig,'handles',h);
