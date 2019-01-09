function [adj sessInfo] = updateadjbatch(adjFile)
adjOld = load(adjFile,'-mat');
sessInfo = sessionsFileToStruct(adjOld.sessionsFile);
adj.sessions  = [sessInfo.session];
adj.included = [sessInfo.include];
nSess = length(sessInfo);


iNewSess = ~ismember(adj.sessions,adjOld.sessions);

adjFields = fields(adjOld);

for af = 1:length(adjFields)
    switch adjFields{af}
        case {'defined','applied'}
            adj.(adjFields{af}) = false(1,nSess);
        case {'sessions','included'}
            continue;
        otherwise
            adj.(adjFields{af}) = nan(1,nSess);
    end
    adj.(adjFields{af})(~iNewSess) = adjOld.(adjFields{af});
end
save(adjFile,'-struct','adj','-mat');