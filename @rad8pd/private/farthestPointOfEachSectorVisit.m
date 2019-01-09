function [fp, fpIdx] = farthestPointOfEachSectorVisit(sv, r)
%[fp, fpIdx] = farthestPointOfEachSectorVisit(sv, r)
%
% Return the radius and index of the farthest points for each sector visit
% during a trial.
%
% external calls: @chunkmat

% Siavash Ahmadi
% 10/1/15


[fp, fpIdx] = cellfun(@max, chunkmat(r, sv));

fpIdx = fpIdx + sv(1:end-1) - 1;