function [fieldBins, boundaryStruct, rateMap, binRangeX, binRangeY, gaussFit2] = computePlaceFields(obj)

X = obj.parentTrial.positionData.getX();
Y = obj.parentTrial.positionData.getY();
TS = obj.parentTrial.positionData.getTS();
S = obj.spikeTrain();

spatialRange.left = -100*ceil(abs(min(X)/100));
spatialRange.right = 100*ceil(abs(max(X)/100));
spatialRange.bottom = -30;
spatialRange.top = 30;
nBins.x = 50;
nBins.y = 20;

[rateMap, binRangeX, binRangeY, gaussFit2] = dataanalyzer.makePlaceMaps. ...
	mymake2(S, X, Y-mean(Y), TS, spatialRange, nBins);

% get pfields (struct array with fields X and Y)

[fieldBins, boundaryStruct] = extractpf(rateMap, binRangeX, binRangeY);