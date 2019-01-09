function adjustpath_initguidata(pathDirs,hFig)
[~,pathLabels] = cellfun(@(u)fileparts(remfilesep(u)),pathDirs,'uniformoutput',0);
pathData = getPreprocessedIndata(pathDirs);
setappdata(hFig,'pathLabels',pathLabels);
setappdata(hFig,'pathData',pathData);
showData = adjustpath_setshowdata(hFig);
wSelect = diff(minmax(showData.x));
hSelect = diff(minmax(showData.y));
xCorner = min(showData.x);
yCorner = min(showData.y);
selectPos = [xCorner yCorner wSelect hSelect];
setappdata(hFig,'selectPos',selectPos);

DEF_ROTATION = 0;
DEF_CURRLOC = 1;
DEF_PATHLOCS = ones(length(pathData),1);
DEF_SHOWSEL = true(length(pathData),1);
setappdata(hFig,'rotation',DEF_ROTATION);
setappdata(hFig,'currentLoc',DEF_CURRLOC);
setappdata(hFig,'pathLocs',DEF_PATHLOCS);
setappdata(hFig,'showSelect',DEF_SHOWSEL);