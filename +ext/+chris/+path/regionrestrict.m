function data = regionrestrict(data,locInfo,regions,outMethod)
if nargin<4
    outMethod = 'exclude';
end
if ischar(regions)
    regions = {regions};
end
nSets = size(data,1);
for s = 1:nSets
    nCoords = length(data(s).x);
    posInds = [1:nCoords]';
    inReg = false(nCoords,1);
    locs = locInfo(s).labelSeq;
    tInt = locInfo(s).tInt;
    iReg = ismember(locs,regions);
    tInt = tInt(iReg,:);
    nVisits = size(tInt,1);
    for v = 1:nVisits
        inReg = inReg | inint(posInds,tInt(v,:));
    end
    dataFields = fields(data);
    for df = 1:length(dataFields)
        switch outMethod
            case 'exclude'
                data(s).(dataFields{df}) = data(s).(dataFields{df})(inReg);
            case 'restrict'
                if strcmp(dataFields{df},'t')
                    continue;
                end
                data(s).(dataFields{df})(~inReg) = nan;
        end
    end
end