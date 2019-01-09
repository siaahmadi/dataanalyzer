function s = stretchoflittlemovement(lin_prjpath, runs, immobilitythreshold, rwdRadiusThreshold, r)
%s = stretchoflittlemovement(lin_prjpath, runs, immobilitythreshold, radiusThreshold, r)
%
% Return the last index of each reward visit.
%
%
% Algorithm:
% 
% From the beginning of a visit (defined by previous scripts as the
% the point in an Arm Visit with the largest radius greater than
% |radiusThreshold|) to the last point whose radius is greater than
% |radiusThreshold|, finds the last point before which the animal is
% immobile. If not such point exists, the index will be the last point
% whose raius is greater than |radiusThreshold|.

% Siavash Ahmadi
% 10/2/15


c = chunkmat(r, runs);
try
	rwdRadThrIdx = cellfun(@(x) accFunc_find(x, rwdRadiusThreshold), c) + runs(1:end-1);
catch err
	if strcmp(err.identifier, 'MATLAB:cellfun:NotAScalarOutput')
		if ~any(c{end} < rwdRadiusThreshold) && all(cellfun(@(x) any(x<rwdRadiusThreshold), c(1:end-1))) % only the last chunk doesn't have a < radiusThreshold --> rat didn't return to center arm
			rwdRadThrIdx = cellfun(@(x) find(x < rwdRadiusThreshold, 1), c(1:end-1));
			[~, rwdRadThrIdx(end+1)] = min(c{end});
			
			rwdRadThrIdx = rwdRadThrIdx + runs(1:end-1);
		else
			rethrow(err)
		end
	end
end

m = smooth(diff(lin_prjpath(:, 1)), 10);

newIdx = [rwdRadThrIdx; runs];
newIdx(1:2:end) = runs;
newIdx(2:2:end) = rwdRadThrIdx;
m = chunkmat(m, newIdx);
m = m(1:2:end); % for each run, contains displacements from beginning of each run up to |radiusThreshold|

mm = cellfun(@(x) x<immobilitythreshold, m, 'UniformOutput', false);
movementDoesntMeetThresholdIdx = cellfun(@(x) ~any(x), mm);

s = cellfun(@(x) find(lau.rtoff(x), 1, 'last'), mm, 'UniformOutput', false); % for robustness
[~, s(movementDoesntMeetThresholdIdx)] = cellfun(@min, m(movementDoesntMeetThresholdIdx), 'un', 0);

% I = cellfun(@isempty, s); % takes care of 
% buffer = rwdRadThrIdx(I)-1;
% s(I) = num2cell(buffer); % for robustness

s = cell2mat(s) + runs(1:end-1);

s = s(2:end); % Assumes trial starts on the stem, therefore by definition no reward is present

function f = accFunc_find(x,radiusThreshold)
f = find(x < radiusThreshold, 1);
if isempty(f)
	f = length(x);
end