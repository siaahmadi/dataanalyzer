function adjustpathbatch_updateadj(hFig)
iCurrInd = getappdata(hFig,'iCurrInd');
modified = getappdata(hFig,'modified');
saved = getappdata(hFig,'saved');
adj = getappdata(hFig,'adj');
h = getappdata(hFig,'handles');
pos = getPosition(h.selectBox);
tmpAdj = pos2adj(pos);
adjFields = fields(tmpAdj);
for af = 1:length(adjFields)
    if ~isequal(adj(iCurrInd).(adjFields{af}),tmpAdj.(adjFields{af}))
        adj(iCurrInd).(adjFields{af}) = tmpAdj.(adjFields{af});
        %         if ~isnan(adj(iCurrInd).(adjFields{af}))
        modified(iCurrInd) = true;
        saved(iCurrInd) = false;
        %         end
    end
end
rotation = getappdata(hFig,'rotation');
if ~isequal(adj(iCurrInd).rotation,rotation);
    adj(iCurrInd).rotation = rotation;
    modified(iCurrInd) = true;
    saved(iCurrInd) = false;
end
setappdata(hFig,'adj',adj);
setappdata(hFig,'modified',modified);
setappdata(hFig,'saved',saved);
adjustpathbatch_setsaverevert(hFig);
adjustpathbatch_setsessmenu(hFig);
adjData = {adj(iCurrInd).xCenter,adj(iCurrInd).yCenter,adj(iCurrInd).xScale,adj(iCurrInd).yScale};
set(h.adjTable,'Data',adjData);
set(h.rotText,'String',num2str(-adj(iCurrInd).rotation));