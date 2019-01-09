function defbatch_btnCallback(src,~,hFig)

srcTag = get(src,'Tag');

switch srcTag
    case 'okay'
        defbatch_getselected(hFig);
        uiresume(hFig);
    case 'quit'
        setappdata(hFig,'toDef',[]);
        uiresume(hFig);
end