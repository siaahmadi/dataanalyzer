function pathData = adjustpath(paths, adj)

inType = class(paths);
switch inType
    case 'char'
        [fn,fp,ext] = fileparts(paths);
        switch ext
            case ''
                pathDirs = {paths};
            case '.txt'
                pathDirs = ReadFileList(paths);
            case '.nvt'
                pathDirs = {[fn '\' fp]};
        end
        pathData = loadpath(pathDirs);
    case 'cell'
        pathDirs = paths;
        pathData = loadpath(pathDirs);
    case 'struct'
        pathData = paths;
end

inType = class(adj);
switch inType
    case 'char'
        adj = load(adj,'-mat');
    case 'struct'
    case 'double'
        assert(ismember(size(1),[1 1;1 2;2 1],'rows'),...
            'boxSize must be 2x1, 1x2 or scalar (1x1)')
        boxSize = adj;
        adj = autoadjustpath(pathData,boxSize);
end


nPaths = length(pathData);
for p = 1:nPaths
    pathData(p).x = (pathData(p).x - adj.xCenter) * adj.xScale;
    pathData(p).y = (pathData(p).y - adj.yCenter) * adj.yScale;
    [pathData(p).x, pathData(p).y] = rotatePath(pathData(p).x,pathData(p).y,deg2rad(adj.rotation));
end
pathData = addVelocityToIndata(pathData);