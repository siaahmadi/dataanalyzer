function [adj sessInfo] = newadjustbatch(adjFile,sessionsFile)
sessInfo = sessionsFileToStruct(sessionsFile);
nSess = length(sessInfo);
% for s = 1:nSess
%     adj(s).session = sessInfo(s).session;
%     adj(s).included = sessInfo(s).include;
%     adj(s).xCenter = nan;
%     adj(s).yCenter = nan;
%     adj(s).xScale = nan;
%     adj(s).yScale = nan;
%     adj(s).rotation = nan;
%     adj(s).defined = false;
%     adj(s).defDate = nan;
%     adj(s).applied = false;
%     adj(s).appDate = nan;
% end

adj.sessions = [sessInfo.session];
adj.included = [sessInfo.include];
adj.xCenter = nan(1,nSess);
adj.yCenter = nan(1,nSess);
adj.xScale = nan(1,nSess);
adj.yScale = nan(1,nSess);
adj.rotation = nan(1,nSess);
adj.defined = false(1,nSess);
adj.defDate = nan(1,nSess);
adj.applied = false(1,nSess);
adj.appDate = nan(1,nSess);
adj.sessionsFile = sessionsFile;

save(adjFile,'-struct','adj','-mat');