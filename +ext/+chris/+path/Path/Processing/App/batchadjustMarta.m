function batchadjustMarta()
sessionsFile = 'Sessions_Marta.m';
projectDir = 'X:\Marta\Fig8Project';
addpath(projectDir);
[adj sessInfo] = loadbatchadj(projectDir,sessionsFile); % changed by @author: Sia @date 9/15/15
toDef = defbatch_create(adj);
if ~isempty(toDef)
    hFig = adjustpathbatch_create(adj,sessInfo,toDef);
end