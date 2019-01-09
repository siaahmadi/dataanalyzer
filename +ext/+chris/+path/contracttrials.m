function trialData = contracttrials(trialInfo,data,tData)

nSets = length(trialInfo);
if nargin<3
    tData = zeros(nSets,0);
end
if nSets > 1
    if isequal(size(data,1),nSets)
        trialData = cell(nSets,1);
        for s = 1:nSets
            if nargin<3 || isempty(tData)
                tDataSet = [];
            else
                tDataSet = tData(s,:);
            end
            trialData{s} = contracttrials(trialInfo(s),data(s,:),tDataSet);
        end
    else
        error('DATA must have the same number of rows as TRIALINFO')
    end
else
    nTrials = size(trialInfo.inds,1);
    dataType = class(data);
    switch dataType
        case 'struct'
            if nargin< 3 || isempty(tData)
                tFields = {'t','ts','timestamps'};
                tField = tFields{isfield(data,tFields)};
                if isempty(tField) || length(tField)>1
                    error('Need to specify time field or time data for struct DATA');
                else
                    tData = data.(tField);
                end
            end
            
            dataFields = fields(data);
            tInt = cat(2,trialInfo.tInt{:});
            %             for tr = 1:nTrials
            %                 tInt = trialInfo.tInt{tr};
            for df = 1:length(dataFields)
                trialData.(dataFields{df}) = ...
                    subdata(data.(dataFields{df}),tInt,tData,'restrict');
            end
            %             end
        case 'cell'
            if nargin<3 || isempty(tData)
                tData = data;
            elseif ~isequal(size(data),size(tData))
                error('DATA and TDATA must be the same size');
            end
            iUse = cellfun(@(u,v)~isempty(u) & ~isempty(v),data,tData);
            trialData = cell(1,size(data,2));
            tInt = cat(2,trialInfo.tInt{:});
%             for tr = 1:nTrials
%                 tInt = trialInfo.tInt{tr};
                %                 tInt = [trialInfo.tInt(tr,1) trialInfo.tInt(tr,2)];
                trialData(1,iUse) = cellfun(@(u,v)subdata(u,tInt,v),data(iUse),tData(iUse),'uniformoutput',0);
%             end
            
        case 'double'
    end
end