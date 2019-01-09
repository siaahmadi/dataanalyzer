function [level, rate] = p___getElevation(parent, x, y)

if parent.fieldInfo.dim == 2
	[level, rate] = elev2d(parent, x, y);
elseif parent.fieldInfo.dim == 1
	[level, rate] = elev1d(parent, x);
else
	error('unhandled map dimensionality.');
end

function [level, rate] = elev1d(parent, x)
binx = parent.fieldInfo.bins(:, 2); % in matrix format columns are on the x-coord

X = parent.fieldInfo.binRangeX;
Z = parent.fieldInfo.fullrmap;
rate = interp1(X, Z, x, 'linear', 'extrap');
level = rate  / max(Z(binx));


function [level, rate] = elev2d(parent, x, y)
binx = parent.fieldInfo.bins(:, 2); % in matrix format columns are on the x-coord
biny = parent.fieldInfo.bins(:, 1); % in matrix format rows are on the y-coord

Z = zeros(size(parent.fieldInfo.fullrmap));
Z(min(biny):max(biny), min(binx):max(binx)) = parent.fieldInfo.fullrmap(min(biny):max(biny), min(binx):max(binx));

X = parent.fieldInfo.binRangeX;
Y = parent.fieldInfo.binRangeY;
C = contourc(X, Y, Z, 100);
cm = contour2struct(C);
IN = arrayfun(@(cm) inpolygon(x(:), y(:), cm.boundary(1, :), cm.boundary(2, :)), cm(:), 'un', 0);
IN = cat(2, IN{:});
IN(1, :) = true; % make sure at least one index is valid
idx = cellfun(@(in) find0(in, 1, 'last'), row2cell(IN));
level = [cm(idx).level];
rate = [cm(idx).value];

function i = find0(inarray, num, sorting) % handles cases where a point in path is not contained in any contour. Happens when field is particularly small.
i = find(inarray, num, sorting);
if isempty(i)
	i = 1;
end