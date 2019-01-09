function adjustpathbatch_nextPrevBtn(src,~,hFig)
% adjustpathbatch_setadj(hFig);
h = getappdata(hFig,'handles');
iCurrInd = getappdata(hFig,'iCurrInd');
defInds = getappdata(hFig,'defInds');
srcTag = get(src,'Tag');
switch srcTag
    case 'next'
        if iCurrInd == length(defInds)
            iCurrInd = 1;
        else
            iCurrInd = iCurrInd+1;
        end
    case 'prev'
        if iCurrInd == 1
            iCurrInd = length(defInds);
        else
            iCurrInd = iCurrInd-1;
        end
end
sessInd = defInds(iCurrInd);
adjustpathbatch_changesess(hFig,sessInd);