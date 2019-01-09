function [x, y, t, s] = p___handleInput(X, Y, T, S)

allpdGood = false;
allspGood = false;

if iscell(X) && iscell(Y) && iscell(T)
	tx = cellfun(@(x) isnumeric(x) & isvector(x), X);
	ty = cellfun(@(x) isnumeric(x) & isvector(x), Y);
	tt = cellfun(@(x) isnumeric(x) & isvector(x), T);
	
	if any(~tx)
		X(~tx) = cellfun(@extractcell, X(~tx), 'UniformOutput', false);
		[x, y, t, s] = p___handleInput(X, Y, T, S);
		return;
	end
	if any(~ty)
		Y(~ty) = cellfun(@extractcell, Y(~ty), 'UniformOutput', false);
		[x, y, t, s] = p___handleInput(X, Y, T, S);
		return;
	end
	if any(~tt)
		T(~tt) = cellfun(@extractcell, T(~tt), 'UniformOutput', false);
		[x, y, t, s] = p___handleInput(X, Y, T, S);
		return;
	end
	
	lx = cellfun(@length, X);
	ly = cellfun(@length, Y);
	lt = cellfun(@length, T);
	
	if all(tx & ty & tt) && all(lx == ly & lx == lt)
		x = X;
		y = Y;
		t = T;
		
		allpdGood = true;
	end
else
	if ~iscell(X)
		X = {X};
	end
	if ~iscell(Y)
		Y = {Y};
	end
	if ~iscell(T)
		T = {T};
	end
	[x, y, t, s] = p___handleInput(X, Y, T, S);
	return;
end

ts = isa(S, 'double') & (isvector(S) | isempty(S));
if all(ts)
	s = repmat({S}, size(X));
	allspGood = true;
end

if ~allpdGood || ~allspGood
	error('DataAnalyzer:PlaceMapArray:InvalidInput', 'Cannot handle the inputs in the current format yet. All position data inputs must be cell arrays with each entry of the same length as the corresponding entry in all other cell arrays. Spiking data must be a double vector.');
end