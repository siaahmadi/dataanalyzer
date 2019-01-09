function [rateMap, binRangeX, bincount_occup, preRM, gaussFit1] = mymake1(spTrains, videoX, videoTS, videoV, opt)
%MYMAKE1 Make 1-dimensional time-normalized density map (i.e. place map)
%
%[rateMap, binEdgeX, bincount_occup] = MYMAKE1(spTrains, videoX, videoTS, videoV, opt)
%
% make a 1D place map for a single spiketrain, restricted range whose lower
% and upper bounds are demarcated by 'rangeLeft' and 'rangeRight'


% Set opt such that make2 will operate robustly on 1-D data:
videoY = zeros(size(videoX));
opt.spatialRange.bottom = -1;
opt.spatialRange.top = 1;
opt.nBins.y = 1;
opt.smoothingMethod = 'gauss1';
opt.smoothingKernel = 1;
opt.smKernelSize = [1, 5];

% Make the 1-D map(s):
[rateMap, binRangeX, ~, bincount_occup, preRM] = dataanalyzer.makePlaceMaps.mymake2(spTrains, videoX, videoY, videoTS, videoV, opt);

if nargout > 4
	try
		gaussFit1 = fit(binRangeX.', rateMap.', 'gauss1');
	catch
		[~, mi] = max(rateMap);
		buffer = binRangeX;
		if mi == 1
			idx = length(rateMap)+1:length(rateMap)*2;
			binRangeX = linspace(2*rangeLeft-rangeRight, rangeRight, nBins*2);
			rateMap = [fliplr(rateMap) rateMap];
		elseif mi==length(rateMap)
			idx = 1:length(rateMap);
			binRangeX = linspace(rangeLeft, 2*rangeRight-rangeLeft, nBins*2);
			rateMap = [rateMap fliplr(rateMap)];
		else
			gaussFit1 = [];
			return
		end
		try
			gaussFit1 = fit(binRangeX.', rateMap.', 'gauss1');
		catch
			gaussFit1 = [];
		end
		binRangeX = buffer;
		rateMap = rateMap(idx);
	end
end