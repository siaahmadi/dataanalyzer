function I = p___isIncreasingUpTo(A, idx, incFor)
%I = p___isIncreasingUpTo(A, idx, incFor)
%
% Returns a logical vector the same length as |idx| indicating whether or
% not A(idx) are trailed by an increasing sequence of length |incFor|.
%
% External calls: @chunkmat

% Siavash Ahmadi
% 10/1/15

if ~issorted(idx)
	error('|idx| must be sorted.')
end
if any(idx < incFor) || any(idx < 1) || any(idx > numel(A))
	error('WTF?!');
end

IDX = repmat(idx(:), 2, 1);
IDX(1:2:end) = idx - incFor;
IDX(2:2:end) = idx + 1;

C = chunkmat(A(:), IDX);
C = C(1:2:end);

I = cellfun(@issorted, C);