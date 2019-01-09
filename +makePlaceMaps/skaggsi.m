function skg_info = skaggsi(spikeTrain, locationInfo, sumMask, minSpikes)
% skg_info = skaggsi(spikeTrain, locationInfo, sumMask)
% Compute the Skaggs spatial information
%
% USAGE:
%
% INPUT:
% spikeTrain    vector containing a cell's spikes
% locationInfo  a 3xN matrix containing the cartesian coordinates of
%               animal's location on the first two rows and timing
%               information on the third row
% sumMask       how to mask the information content value
%               must be a matrix
%               the XY coordinates will be normalized according to the size
%               of this matrix
%               can be all 1's, but if one arm in the 8-arm maze is sought,
%               only the entries corresponding to that arm need be 1's
%
% OUTPUT:
% skg_info      the Skaggs spatial information content

% Siavash Ahmadi (c) 2013
% Leutgeb lab, University of California, San Diego
% La Jolla, CA, USA
%
% Last edited: September 25, 2013  |  Ver. 1.0

if iscell(spikeTrain)
	skg_info = zeros(size(spikeTrain));
	for i = 1:numel(spikeTrain)
		skg_info(i) = skaggsi(spikeTrain{i}, locationInfo, sumMask, minSpikes);
		if length(spikeTrain{i})<minSpikes
			skg_info(i) = NaN;
		end
	end
	return
end

fieldLongit = size(sumMask, 2);
fieldLatit = size(sumMask, 1);

% extreme values of video tracking data
longitExtreme = [min(locationInfo(1, :)); max(locationInfo(1, :))];
latitExtreme = [min(locationInfo(2, :)); max(locationInfo(2, :))];
% the length in video tracking data units that each matrix bin covers
longitBin = (longitExtreme(2)-longitExtreme(1))/fieldLongit;
latitBin = (latitExtreme(2)-latitExtreme(1))/fieldLatit;
% make the occupancy matrix (non-normalized)
occupancy = nan(fieldLatit, fieldLongit);
for i = 1:size(locationInfo, 2)
	occ_X = floor((locationInfo(1, i)-longitExtreme(1))/longitBin)+1;
	occ_Y = floor((locationInfo(2, i)-latitExtreme(1))/latitBin)+1;
	occ_X = occ_X - floor(occ_X/(fieldLongit+1));
	occ_Y = occ_Y - floor(occ_Y/(fieldLongit+1));
	if isnan(occupancy(occ_X, occ_Y))
		occupancy(occ_X, occ_Y) = 1;
	else
		occupancy(occ_X, occ_Y) = occupancy(occ_X, occ_Y) + 1;
	end
end
% make the rate map
rate_map = heat(locationInfo(1, :), locationInfo(2, :), locationInfo(3, :),...
	spikeTrain, 4, size(sumMask, 1)/10, 30, true);
% apply the mask
sumMask = (1./sumMask)-(1./sumMask)+1; % replace 0s with NaNs
rate_map = rate_map .* sumMask;
occupancy = occupancy .* sumMask;
% normalize the occupancy matrix
occupancy(:, :) = occupancy(:, :) ./ nansum(nansum(occupancy));

% compute the information content
F = nanmean(nanmean(rate_map, 1), 2);
X = repmat(F, size(rate_map, 1), size(rate_map, 2));
skg_info = nansum(nansum(occupancy.*rate_map.*log2(rate_map./X), 1), 2) ./ F;
if length(spikeTrain) < minSpikes
	skg_info = NaN;
end