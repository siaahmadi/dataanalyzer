function mzbw = layout2bw(mzlayout, res)

if ~exist('res', 'var') || isempty(res)
	res = 1e3;
end
mzbw = false(res);

m = nanmin(mzlayout(:));
M = nanmax(mzlayout(:));

linx = linspace(m, M, res);
liny = linspace(m, M, res);
[xg, yg] = meshgrid(linx, liny);

IN = inpolygon(xg(:),yg(:), mzlayout(:, 1), mzlayout(:, 2));

mzbw(IN) = true;