function adjustpath_loadadj(hFig)
h = getappdata(hFig,'handles');
[loadFile loadDir] = uigetfile({'*.adj','Path Adjustment (*.adj)'},'Load adjustment');
if ~loadFile
    return
else
    adj = load([loadDir loadFile],'-mat');
    adjustpath_setadj(hFig,adj)
end