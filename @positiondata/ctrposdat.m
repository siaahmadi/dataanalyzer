function centerParams = ctrposdat(rawX, rawY, mzTemplate, optORxScale, yScale, rotation)
%centerParams = ctrposdat(rawX, rawY, mzTemplate, optORxScale, yScale, rotateBy)
%
% Center maze position data by correlation with template

% Siavash Ahmadi
% 12/14/2015 11:56 AM


mzlayout = mzTemplate;

res = 1e3;
upperFrame = ceil(max([max(abs(rawX)), max(abs(rawY))]))+1;
lowerFrame = -upperFrame;

if isstruct(optORxScale)
	xScale = optORxScale.xScale;
	yScale = optORxScale.yScale;
	rotation = optORxScale.rotation;
	method = optORxScale.ctrXCorrPeakFinderMethod;
% 	res = optORxScale.res;
else
	xScale = optORxScale;
	method = 'peak';
end

if ~(xScale > .1 && xScale <= 1) || ~(yScale > .1 && yScale <= 1)
	error('Scales should be in the interval (0.1, 1].');
end

edges = linspace(lowerFrame, upperFrame, res+1);

% frame the raw data in the res x res square:
% adjustedRawX = (rawX-min(rawX))/range(rawX)*(res-1)+1;
% adjustedRawY = (rawY-min(rawY))/range(rawY)*(res-1)+1;
adjustedRawX = rawX;
adjustedRawY = rawY;

[~, ~, binsx] = histcounts(adjustedRawX, edges);
[~, ~, binsy] = histcounts(adjustedRawY, edges);
idxToKeep = binsx>0 & binsy>0;
binsx = binsx(idxToKeep);
binsy = binsy(idxToKeep);

mzlayoutScaleX = abs(prctile(binsx, 99.5)-prctile(binsx, .5));
mzlayoutScaleY = abs(prctile(binsy, 97.5)-prctile(binsy, 2.5));

h = round(res*range(adjustedRawX)/(2*upperFrame));
% h = round(mzlayoutScaleY);
w = round(100/mzlayoutScaleY);

% R = round(max(size(mzlayout)) / max([h, w]));
% mzlayout = imclose(mzlayout, strel('disk', R));

mzlayout = imshrink(mzlayout, h, h);

% Could add a for loop to try different rotations to obviate manual specification of rotation
mzlayout = imrotate(mzlayout, rad2deg(rotation), 'bilinear', 'crop');



poslayout = double(full(sparse(binsy, binsx, 1, res, res))>0); % of absolute importance that this be a 0-1 double matrix

C = xcorr2(poslayout, mzlayout);
% [~, I] = max(C(:));
X_max = max(C);
Y_max = max(C, [], 2);
if strcmpi(method, 'fwhm')
	[~, X_trail, X_lead] = fwhm(1:length(X_max), X_max);
	[~, Y_trail, Y_lead] = fwhm(1:length(Y_max), Y_max);
	X_rafts = [X_trail, X_lead];
	Y_rafts = [Y_trail, Y_lead];
	% todo: if more than one peak
	indX = round(mean(X_rafts));
	indY = round(mean(Y_rafts));
elseif strcmpi(method, 'peak')
	indX = round(mean(find(X_max == max(X_max))));
	indY = round(mean(find(Y_max == max(Y_max))));
else
	error('Undefined peak finding method for centering path data.');
end

% [indY, indX] = ind2sub(size(C), I);
centerParams.xCenter = (indX - res) / res * (upperFrame-lowerFrame);
centerParams.yCenter = (indY - res) / res * (upperFrame-lowerFrame);
