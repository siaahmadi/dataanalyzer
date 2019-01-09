function [adj, sessInfo] = loadbatchadj(projectDir,sessionsFile)
% changes made to code by @author: Sia @date 9/15/15 7:18 PM
dirStruct = dir(projectDir);
adjFile = 'adjustbatchSia.adj';
dirContents = arrayfun(@(a)a.name,dirStruct,'uniformoutput',0);
if ~ismember(adjFile,dirContents)
   [adj, sessInfo] = newadjustbatch(fullfile(projectDir, adjFile),sessionsFile);
else
   [adj, sessInfo] = updateadjbatch(fullfile(projectDir, adjFile),sessionsFile); 
end