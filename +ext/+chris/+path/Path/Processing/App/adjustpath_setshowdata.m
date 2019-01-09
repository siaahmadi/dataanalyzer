function showData = adjustpath_setshowdata(hFig,toShow)
pathData = getappdata(hFig,'pathData');
rotation = getappdata(hFig,'rotation');
if nargin<2
    toShow = 1:length(pathData);
end
showData.x = [];
showData.y = [];

for i = toShow
    if rotation ~= 0
        [pathData(i).x pathData(i).y] = rotatePath(pathData(i).x,pathData(i).y,deg2rad(rotation));
    end
    showData.x = cat(1,showData.x,[pathData(i).x; nan]);
    showData.y = cat(1,showData.y,[pathData(i).y; nan]);
end
setappdata(hFig,'showData',showData);