function handle = p___spikepatch(x, y, scale, color, shape, transparency, varargin)
	c = [1, 0, 0];
	t = 0.1;
	s = 1;
	if exist('scale', 'var') && ~isempty(scale)
		s = scale;
	end
	if exist('color', 'var') && ~isempty(color)
		c = color;
	end
	if ~exist('shape', 'var') || isempty(shape)
		shape = 'rectangle';
	end
	if exist('transparency', 'var') && ~isempty(transparency)
		t = transparency;
	end

	[x,y] = p___xy2vertex(x,y,shape,s);

	handle = patch(x,y,c, 'FaceAlpha', t, 'EdgeColor', 'none', varargin{:});
end