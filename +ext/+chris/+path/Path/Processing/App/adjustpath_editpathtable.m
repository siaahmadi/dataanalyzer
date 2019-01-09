function adjustpath_editpathtable(src,evt,hFig)
colNames = get(src,'ColumnName');
iCol = evt.Indices(2);
selCol = colNames{iCol};
iPath = evt.Indices(1);
switch lower(selCol)
    case 'maze'
        tblData = get(src,'Data');
        defMazes = defmazes();
        iMaze = find(strcmp({defMazes.name},evt.NewData));
        iW = strcmp(colNames,'Width');
        iH = strcmp(colNames,'Height');
        tblData{iPath,iW} = defMazes(iMaze).w;
        tblData{iPath,iH} = defMazes(iMaze).h;
        set(src,'Data',tblData);
    case 'location'
        if strcmp(evt.NewData,'New location...')
            
        else
        pathLocs = getappdata(hFig,'pathLocs');
        pathLocs(iPath) = str2num(evt.NewData);
        setappdata(hFig,'pathLocs',pathLocs);
        end
        adjustpath_refreshpath(hFig);
    case 'show'
        showSelect = getappdata(hFig,'showSelect');
        showSelect(iPath) = evt.NewData;
        setappdata(hFig,'showSelect',showSelect);
        adjustpath_refreshpath(hFig);
end