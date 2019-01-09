function adjustpathbatch_saveMenu(src,~,hFig)
if ~isempty(src)
tag = get(src,'Tag');
else
    tag = 'save';
end
batchAdj = getappdata(hFig,'batchAdj');
if strcmp(tag,'saveas')
   [adjFile adjDir] = uiputfile('*.adj','Save adjustment as...',batchAdj.adjFile);
   if adjFile == 0
       return;
   end
   adjFile = [adjDir adjFile];
   batchAdj.adjFile = adjFile;
   setappdata(hFig,'batchAdj',batchAdj);
end
save(batchAdj.adjFile,'-struct','batchAdj','-mat');
figTitle = ['Adjust path - ' batchAdj.adjFile];
set(hFig,'Name',figTitle);
fileModified = false;
setappdata(hFig,'fileModified',fileModified);