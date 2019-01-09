function idx = farthestPointInVisit(r, visits, rewardRadiusThreshold)

[m, I] = cellfun(@max, chunkmat(r, visits));

idx = I(m > rewardRadiusThreshold) + visits(m > rewardRadiusThreshold);

if numel(idx)
	if idx(1) > 1
		idx = [1; idx];
	end
else
	idx = I;
end

if length(r) > idx(end)
	idx = [idx; length(r)];
else
	error('Radial8MazeParser:RunsParser:InputPathDataNotEndingInStem', 'Path data not in the expected format');
end