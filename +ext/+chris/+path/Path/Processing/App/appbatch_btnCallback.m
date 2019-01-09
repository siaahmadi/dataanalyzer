function appbatch_btnCallback(src,~,hFig)

srcTag = get(src,'Tag');

switch srcTag
    case 'okay'
        appbatch_getselected(hFig);
        uiresume(hFig);
    case 'quit'
        setappdata(hFig,'toApp',[]);
        uiresume(hFig);
end