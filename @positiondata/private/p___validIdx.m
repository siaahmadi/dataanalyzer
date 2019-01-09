function I = p___validIdx(idx, range)

I = false;

if islogical(idx)
	I = numel(idx) == range;
elseif isnumeric(idx)
	I = ~isempty(idx) && (allWholeNumbers(idx) & inRange(idx, range));
end

function I = allWholeNumbers(idx)
I = all(idx == floor(idx));

function I = inRange(idx, range)
I = min(idx(:)) >= 1 & max(idx(:)) <= range;