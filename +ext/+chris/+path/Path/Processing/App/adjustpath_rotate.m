function adjustpath_rotate(src,~,hFig)
h = getappdata(hFig,'handles');
srcTag = get(src,'Tag');
rotation = getappdata(hFig,'rotation');
switch srcTag
    case 'rotCCW'
        dRot = 1;
    case 'rowCW'
        dRot = -1;
end
rotation = rotation+dRot;
setappdata(hFig,'rotation',rotation);
set(h.rotText,'String',num2str(-rotation));
adjustpath_refreshpath(hFig);
adjustpath_updateadj(hFig)