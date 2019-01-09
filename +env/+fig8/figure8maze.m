function maze = figure8maze(mazeType)

if nargin == 0
    mazeType = 'fig8rat';
end

maze = dataanalyzer.env.fig8.fig8maze(mazeType);

maze = maze.whole.locs;

xminmax = [nanmin(maze(:, 1)), nanmax(maze(:, 1))];
yminmax = [nanmin(maze(:, 2)), nanmax(maze(:, 2))];

maze = [maze(:, 1) - mean(xminmax), maze(:, 2) - mean(yminmax)];