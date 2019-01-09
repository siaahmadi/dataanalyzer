function adjustpath_saveadj(hFig)
[saveFile saveDir] = uiputfile({'*.adj','Path Adjustment (*.adj)'},'Save adjustment','untitled.adj');
if ~saveFile
    return;
else
    adj = getappdata(hFig,'adj');
    save([saveDir saveFile],'-struct','adj','-mat');
end