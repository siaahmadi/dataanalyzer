function [rateMap, binRange, gaussFit1] = makeConstRange1D(spTrains, videoX, videoTS, rangeLeft, rangeRight, nBins)
% make full map myself (inside makePlaceMaps.make)

% figure;plot(videoX{1}, videoY{1}, '.')
% hold on; plot(mean(videoX{1}), mean(videoY{1}), 'r.', 'markersize', 50);
% figure;plot(videoTS{1}, videoX{1}, '.'); hold on; plot(videoTS{1}(spike2ind(spTrains{1}, videoTS{1})), videoX{1}(spike2ind(spTrains{1}, videoTS{1})), 'ro')
% figure;hist(videoX{1}(spike2ind(spTrains{1}, videoTS{1})), 30); title('spike counts in bins')

if nargin < 4
	rangeLeft = repmat({-200}, size(spTrains));
	rangeRight = repmat({200}, size(spTrains));
	nBins = repmat({400/20*3}, size(spTrains));
elseif nargin == 4
	error('Specify rangeRight')
elseif nargin == 5
	rangeLeft = repmat({rangeLeft}, size(spTrains));
	rangeRight = repmat({rangeRight}, size(spTrains));
	nBins = repmat({400/20*3}, size(spTrains));
elseif nargin == 6
	rangeLeft = repmat({rangeLeft}, size(spTrains));
	rangeRight = repmat({rangeRight}, size(spTrains));	
	nBins = repmat({nBins}, size(spTrains));
end
videoX = repmat(videoX, size(spTrains, 1), 1); % assumes videoX 1 x n cell array
videoTS = repmat(videoTS, size(spTrains, 1), 1); % assumes videoTS 1 x n cell array

[rateMap, binRange, gaussFit1] = cellfun(@dataanalyzer.makePlaceMaps.mymake1, ...
	spTrains, videoX, videoTS,...
	rangeLeft, rangeRight, nBins, ...
	'UniformOutput', false);


