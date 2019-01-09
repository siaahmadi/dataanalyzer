function h = plot(obj, varargin)

if isempty(obj)
	return
end

contour = fieldnames(obj(1).dynProps);

passes = cat(1, obj.dynProps.(contour{1}).passes);
numPasses = numel(passes);

opt = p___validateAndParseVarargin(obj, varargin{:});

passes = passes(opt.passes);

ax = gca;
if strcmp(ax.NextPlot, 'add')
	washeld = true;
else
	washeld = false;
	cla;
end
hold on;

h_field = hggroup;

if opt.mazeoutline
	mz = radial8maze;
	h_maze = plot(mz(:, 1), mz(:, 2), 'Color', ones(1,3)*.15);
	h_maze.Tag = 'Radial 8 Arm Maze Outline';
	h_maze.Parent = h_field;
end


ax.DataAspectRatioMode = 'manual';

h_sp = [];
if numel(passes > 0)
	h_passes = passes.plot('spike', 'on', 'mazeoutline', 'off');
	h_pass = h_passes.Children(1).Children(2);
	h_passes.Parent = h_field;
	h_sp = h_passes.Children(1).Children(1);
end

if ~isfield(obj.fieldInfo.boundary, opt.contour)
	error('Cannot find the requested contour, %s', opt.contour);
end
pf = obj.fieldInfo.boundary.(opt.contour);
h_pf = patch(pf(1, :), pf(2, :), 'w','Parent',h_field, 'LineWidth', 2.5);
h_pf.EdgeColor = opt.invertcolor;
h_pf.FaceAlpha = opt.solidbg;

cvh = [obj.dynProps.(contour{1}).cvxHull.x_cm; obj.dynProps.(contour{1}).cvxHull.y_cm];
h_cvh = patch(cvh(1, :), cvh(2, :), 'w','Parent',h_field, 'LineWidth', 2);
h_cvh.LineStyle = ':';
h_cvh.EdgeColor = opt.invertcolor;
h_cvh.FaceAlpha = opt.solidbg;


if ~washeld
	hold off;
end

figpretty;
ax.XTick = linspace(ax.XLim(1), ax.XLim(2), 3);

drawnow;
if opt.legendRqstd
	idx_firstNonEmptySpikeScatter = find(arrayfun(@(x) ~isempty(x.XData), h_sp), 1);
	if ~isempty(h_pass)
		h_pass = h_pass(1);
	elseif numPasses > 0
		warning('You have requested that no Passes be displayed.');
	end
	warning off MATLAB:legend:IgnoringExtraEntries
	lg = legend(ax, [h_pf(1); h_cvh(1); h_pass; h_sp(idx_firstNonEmptySpikeScatter)], opt.contour, 'Convex Hull', 'Individual Passes', 'Spikes');
	warning on MATLAB:legend:IgnoringExtraEntries
	lg.FontSize = 12;
end

if nargout > 0
	h = h_field;
end