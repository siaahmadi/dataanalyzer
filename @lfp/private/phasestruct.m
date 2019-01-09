function phst = phasestruct(m, n)

if nargin < 1
	m = 0;
	n = 1;
end

phst = repmat(struct('ttNo', NaN, 'band', '', 'phase', NaN, 'ts', NaN), m, n);