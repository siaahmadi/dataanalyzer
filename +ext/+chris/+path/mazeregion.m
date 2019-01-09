function [xReg yReg] = mazeregion(mazeType,regions)
if ~iscell(regions);
    regions = {regions};
end
xReg = [];
yReg = [];
switch mazeType
    case 'fig8'
        maze = fig8maze();
        locNames = fields(maze.locs);
        if ~all(ismember(lower(regions),lower(locNames)))
            error(['Invalid region. Valid regions include ' locNames(:)]);
        else
            regions = locNames(ismember(lower(locNames),lower(regions)));
        end
        for r = 1:length(regions)
           xReg = cat(1,xReg,maze.locs.(regions{r})(:,1));
           yReg = cat(1,yReg,maze.locs.(regions{r})(:,2));
        end
end