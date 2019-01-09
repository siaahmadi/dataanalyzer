function pathData = addvelocity(pathData)
if ~isfield(pathData,'v')
    pathData = transposeStructVectors(pathData,'col');
    pathData = arrayfun(@(a)setfield(a,'v',velocity(a.x,a.y,a.t)),pathData);
end
