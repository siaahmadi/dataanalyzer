function cvxHull = convhull(obj, contour)

boundaryStruct = obj.fieldInfo.boundary;

if isempty(boundaryStruct) % phantom field (rate too low to be a field)
	return;
end

% convex hull
x = boundaryStruct.(contour)(1, :); x = x(isfinite(x));
y = boundaryStruct.(contour)(2, :); y = y(isfinite(y));
% the isfinite line is because extractpfSession takes the union of
% multiple fields and that may introduce discontinuities in the
% representation of the polygons in MATLAB (i.e. the borders must be
% separated by a NaN).
if obj.fieldInfo.dim > 1
	[K,A] = convhull(x,y);
	cvxHull.x_cm = x(K);
	cvxHull.y_cm = y(K);
	cvxHull.area = A;
else
	cvxHull.x_cm = x([1 2]);
	cvxHull.y_cm = y([1 2]);
	cvxHull.area = 0;
end