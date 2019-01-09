function eegst = eegstruct(m, n)

if nargin < 1
	m = 0;
	n = 1;
end

eegst = repmat(struct('ttNo', NaN, 'tsd', [], 'hilbert', hilbertstruct(0, 1)), m, n);