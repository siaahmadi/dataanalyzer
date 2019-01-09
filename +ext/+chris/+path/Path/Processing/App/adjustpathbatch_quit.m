function adjustpathbatch_quit(src,~)
fileModified = getappdata(src,'fileModified');
if fileModified
    batchAdj = getappdata(src,'batchAdj');
    [~,fileName] = fileparts(batchAdj.adjFile);
    qStr = ['Save changes to ' fileName '?'];
    answer = questdlg(qStr,'Adjust Path');
    switch answer
        case 'Yes'
            adjustpathbatch_saveMenu([],[],src);
            delete(src);
        case 'No'
            delete(src);
        otherwise
            return;            
    end
else
    delete(src)
end