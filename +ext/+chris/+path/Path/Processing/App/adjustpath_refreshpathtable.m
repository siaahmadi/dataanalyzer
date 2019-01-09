function adjustpath_refreshpathtable(hFig)
h = getappdata(hFig,'handles');
pathLabels = getappdata(hFig,'pathLabels');
defData = repmat({'-', '1','-','-',true},length(pathLabels),1);
set(h.pathTable,'Data',defData,'RowName',pathLabels);