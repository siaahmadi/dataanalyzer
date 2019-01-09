function [isidx, Idx] = p___validateIndex(putativeIdx, referenceObject)
%[isidx, Idx] = p___validateIndex(putativeIdx, parent) Verify the validity
% of input |putativeIdx| as being a valid index range with respect to |referenceObject|
%
% If |putativeIdx| is a logical array and it has the same number of
% elements as |referenceObject| it will be returned as a valid index range.
% 
% If |putativeIdx| is a non-logical numeric array, every element in it must
% a whole number. All elements within |referenceObject|'s time stamp array
% will be part of the output index range. If these elements are flanked by
% elements outside the range [1, ... , numel(t)], where t is the time stamp
% array of |referenceObject|, they will be replaced by -Inf or Inf where
% appropriate.
%
% For a non-logical numeric array, the input must be sorted.
%
% If none of the above conditions are met, |putativeIdx| will be judged an
% invalid index range.

% Siavash Ahmadi
% 11/3/2015 11:02 AM

isidx = false;
Idx = [];

if length(referenceObject) == 0 %#ok<ISMT> % This can't be replaced with |isempty|. A referenceObject may be "empty" but have a positive length.
	return;
end

t = referenceObject.getTS();

if iscell(t)
	t = extractcell(first(t));
end

if islogical(putativeIdx)
	if numel(putativeIdx) == numel(t)
		isidx = true;
		Idx = find(putativeIdx(:));
	end
elseif isnumeric(putativeIdx)
	if all(floor(putativeIdx) == putativeIdx) % all whole numbers
		mn = min(putativeIdx);
		mx = max(putativeIdx);
		if ~issorted(putativeIdx)
			return;
		end
		if mn >= 1 && mx <= numel(t) % every value in index range
			isidx = true;
			Idx = putativeIdx(:);
		else
			validIdx = find(putativeIdx(:) >= 1 & putativeIdx(:) <= numel(t));
			if mn < 1
				validIdx = [-Inf; validIdx(:)];
			end
			if mx > numel(t)
				validIdx = [validIdx(:); Inf];
			end
			Idx = validIdx;
		end
	end
end