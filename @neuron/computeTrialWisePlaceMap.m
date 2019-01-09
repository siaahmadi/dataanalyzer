function [rateMap, binRangeX, binRangeY, gaussFit2] = computeTrialWisePlaceMap(obj, options)

X = obj.parentTrial.positionData.getX();
Y = obj.parentTrial.positionData.getY();
T = obj.parentTrial.positionData.getTS();
S = obj.getSpikeTrain('unrestr');

dft_opt = dataanalyzer.internal.p___loadConstantsDB('phaprecTakuya');

%% 11/18/2015
% I must decide whether this script is going to be a user-accessible function or not. If not, there's no point in allowing the overriding of options via input arguments.
% if nargin >= 2
% 	if isfield(options, 'spatialRange')
% 		if isfield(options.spatialRange, 'left')
% 			dft_opt.spatialRange.left = options.spatialRange.left;
% 		end
% 		if isfield(options.spatialRange, 'right')
% 			dft_opt.spatialRange.right = options.spatialRange.right;
% 		end
% 		if isfield(options.spatialRange, 'top')
% 			dft_opt.spatialRange.top = options.spatialRange.top;
% 		end
% 		if isfield(options.spatialRange, 'bottom')
% 			dft_opt.spatialRange.bottom = options.spatialRange.bottom;
% 		end
% 	end
% 	if isfield(options, 'nBins')
% 		if isfield(options.nBins, 'x')
% 			dft_opt.nBins.x = options.nBins.x;
% 		end
% 		if isfield(options.nBins, 'y')
% 			dft_opt.nBins.y = options.nBins.y;
% 		end
% 	end
% end

%%
[rateMap, binRangeX, binRangeY, gaussFit2, occup] = cellfun(@(x,y,t) dataanalyzer.makePlaceMaps. ...
		mymake2(S, x,y,t, dft_opt.spatialRange, dft_opt.nBins), X, Y, T, 'UniformOutput', false);

obj.placeMap.rateMap = rateMap;
obj.placeMap.X = binRangeX;
obj.placeMap.Y = binRangeY;
obj.placeMap.gaussFit2 = gaussFit2;
obj.placeMap.occupancyMap = occup;