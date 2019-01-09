function adjustpathbatch_setsessmenu(hFig)
h = getappdata(hFig,'handles');
iCurrInd = getappdata(hFig,'iCurrInd');
modified = getappdata(hFig,'modified');
defined = getappdata(hFig,'defined');
sessions = getappdata(hFig,'sessions');
nBatch = getappdata(hFig,'nBatch');
sessStrings = cell(nBatch,1);

sessStrings(modified) = arrayfun(@(a)[num2str(a) '*'],sessions(modified),'uniformoutput',0);
sessStrings(~modified) = arrayfun(@(a)num2str(a),sessions(~modified),'uniformoutput',0);
sessStrings(~defined) = cellfun(@(u)['<HTML><I>' u '</I></HTML>'],sessStrings(~defined),'uniformoutput',0);
set(h.sessMenu,'String',sessStrings,'Value',iCurrInd);