function I = isidx(testIdx, referenceArray)

I = false;

if islogical(testIdx)
	I = numel(testIdx) == numel(referenceArray);
elseif isnumeric(testIdx)
	if all(iswholenumber(testIdx)) && min(testIdx) >= 1 && max(testIdx) <= numel(referenceArray)
		I = true;
	end
end

function I = iswholenumber(N)
I = mod(N, 1) == 0;