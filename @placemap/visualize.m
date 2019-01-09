function fig_h = visualize(obj, varargin)
fig = figure; ax = cla();
if obj.Dim == 2
	plot2d(obj, fig, ax, varargin{:});
elseif obj.Dim == 1
	 plot1d(obj, fig, ax, varargin{:})
end

if nargout > 0
	fig_h = fig;
end

function plot1d(obj, fig, ax, varargin)
ax.NextPlot = 'add';
T = {obj.PFields.dynProps.c20.passes.ts};
X = {obj.PFields.dynProps.c20.passes.x};
plot(obj.RefPD.getTS(), obj.RefPD.getX(), 'k.');
cellfun(@(t,x) plot(t, x, 'r', 'linewidth', 4), T, X);

function plot2d(obj, fig, ax, varargin)
im = imagesc(obj.RMap.x, obj.RMap.y, obj.RMap.map);
axis xy;
colormap jet;
alpha(im, double(obj.RMap.occup));
xlabel('X (cm)');
ylabel('Y (cm)');
ax.TickDir = 'out';
ax.Box = 'off';
ax.FontName = 'Arial';
ax.DataAspectRatioMode = 'manual';
ax.DataAspectRatio = [range(obj.RMap.x), range(obj.RMap.y), ax.DataAspectRatio(3)];
whitebg(fig, ones(1,3)*.6)
ax.Title.Interpreter = 'none';
ax.Title.String = ['" ' dataanalyzer.ancestor(obj, 'neuron').namestring ' " (' dataanalyzer.ancestor(obj, 'trial').namestring ')'];
ax.Title.FontName = 'Courier New';
ax.Title.FontSize = 14;
ax.Title.Color = ones(1,3)*.15;
cb = colorbar;
cb.Color = ones(1,3)*.15;
cb.Box = 'off';
cb.TickDirection = 'out';

[params, vals] = p___validateAndParseVarargin(varargin{:});
for p = 1:length(params)
	par = params{p};
	val = vals{p};
	switch par
		case 'pf'
			if strcmp(val, 'on')
				hold on;
				arrayfun(@(x) x.plot, obj.PFields, 'UniformOutput', false);
				hold off;
			end
		case 'otheroptions'
			% TODO
	end
end