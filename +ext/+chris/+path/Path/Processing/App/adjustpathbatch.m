function adjustpathbatch(adjFile)
if nargin==0 || isempty(adjFile)
    [adj sessInfo] = adjustpath_start();
else
    [adj sessInfo] = adjustpathbatch_open(adjFile);
end
toDef = defbatch_create(adj);
if ~isempty(toDef)
    hFig = adjustpathbatch_create(adj,sessInfo,toDef);
end