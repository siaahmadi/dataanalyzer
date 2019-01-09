		function [x,y] = p___xy2vertex(x,y,shape,scale)

		[x_dflt, y_dflt] = p___shapeEngine(shape);
		if isempty(x_dflt)
			x = [];
			y = [];
			return
		end

		x = arrayfun(@(x) x_dflt(:) * scale + x(:), x, 'UniformOutput', false);
		y = arrayfun(@(x) y_dflt(:) * scale + x(:), y, 'UniformOutput', false);
		x = cell2mat(x');
		y = cell2mat(y');