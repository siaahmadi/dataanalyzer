function es = envstruct(m, n)

if nargin < 1
	m = 0;
	n = 1;
end

es = repmat(struct('ttNo', NaN, 'band', '', 'env', NaN, 'ts', NaN), m, n);