function [adj sessInfo] = adjustpath_start()

hFig = figure('Position',[901 693 226 143]);
VBBox = uiextras.VButtonBox('Parent',hFig,'Padding',10,'Spacing',3);
uicontrol('Parent',VBBox,'Tag','new','style','pushbutton','String','New adjustment batch','Callback',@startcallbacks);
uicontrol('Parent',VBBox,'Tag','open','style','pushbutton','String','Open adjustment batch','Callback',@startcallbacks);
set(VBBox,'ButtonSize',[200 50])
uiwait(hFig);
adj = getappdata(hFig,'adj');
sessInfo = getappdata(hFig,'sessInfo');
delete(hFig);


    function startcallbacks(src,~)
        tag = get(src,'Tag');
        switch tag
            case 'new'
                [sessFile sessFileDir] = uigetfile('*.m','Select a sessions file...');
                if sessFile == 0
                    return;
                end
                sessFile = [sessFileDir sessFile];
                [adjFile adjDir] = uiputfile('*.adj','Save batch adjustment file...','batchadjust');
                if adjFile == 0
                    return;
                end
                adjFile = [adjDir adjFile];
                [adj sessInfo] = adjustpathbatch_new(adjFile,sessFile);
            case 'open'
                [adjFile adjDir] = uigetfile('*.adj','Open batch adjustment file...');
                if adjFile == 0
                    return;
                end
                adjFile = [adjDir adjFile];
                [adj sessInfo] = adjustpathbatch_open(adjFile);
        end
        setappdata(hFig,'adj',adj);
        setappdata(hFig,'sessInfo',sessInfo);
        uiresume(hFig);
        
    end
end