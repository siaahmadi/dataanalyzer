function h = plot(obj, varargin)
p = inputParser();
p.addParameter('spike', 'off', @ischar);
p.addParameter('reference', 'on', @ischar);
p.addParameter('mazeoutline', 'on', @ischar);
p.parse(varargin{:});
opt.spike = strcmpi(p.Results.spike, 'on');
opt.reference = ~(strcmpi(p.Results.reference, 'off') | strcmpi(p.Results.mazeoutline, 'off'));

ax = gca;
if strcmp(ax.NextPlot, 'add')
	washeld = true;
else
	washeld = false;
	cla;
end
hold on;
h_maze = [];
if opt.reference
	mz = radial8maze;
	h_maze = plot(mz(:, 1), mz(:, 2), 'Color', ones(1,3)*.15);
	h_maze.Tag = 'Radial 8 Arm Maze Outline';
end

h_allPass = hggroup;
for pInd = 1:numel(obj)
	h_eachPass(pInd, 1) = hggroup; %#ok<AGROW>
end
arrayfun(@(pass, parent) plot(pass.x, pass.y, 'Color', ones(1,3)*.15, 'LineWidth', 3, 'Parent', parent, 'DisplayName', 'Path Shade'), obj(:), h_eachPass(:), 'UniformOutput', false);
arrayfun(@(pass, parent) plot(pass.x, pass.y, 'Color', ones(1,3)*.9, 'LineWidth', 1.5, 'Parent', parent, 'DisplayName', 'Path Foreground'), obj(:), h_eachPass(:), 'UniformOutput', false);

ax.DataAspectRatioMode = 'manual';
figpretty;
ax.XTick = linspace(ax.XLim(1), ax.XLim(2), 3);

if opt.spike
	[x_sp, y_sp] = arrayfun(@(pass) accFunc_spike2xy(pass.spikes, pass.ts, pass.x, pass.y), obj, 'UniformOutput', false);
	cellfun(@(x, y, h) ...
		scatter(x, y, 49, 'wo', 'filled','MarkerEdgeColor', 'w', 'MarkerFaceColor', 'r', 'LineWidth', 1, 'Parent',h, 'DisplayName', 'Spikes'),...
		x_sp, y_sp, num2cell(h_eachPass), 'UniformOutput', false);
end
if ~washeld
	hold off;
end

drawnow;

arrayfun(@(h, dn) set(h, 'DisplayName', ['Pass #' num2str(dn)]), h_eachPass, (1:length(h_eachPass))');
set(h_eachPass, 'Parent', h_allPass)

h_allPass.DisplayName = 'Single Pass(es)';

if nargout > 0
	h = [h_maze; h_allPass];
end