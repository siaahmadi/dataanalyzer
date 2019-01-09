function [fieldInfo, nFields] = extractpf(projectname, rateMap, binRangeX, binRangeY)


opt = dataanalyzer.options(projectname);
opt.contours = dataanalyzer.constant('fieldDetectionContours');

% Determine what method to use:
%%%% TEMPORARY Todo: need a better way of selecting the method
if isequal(binRangeY, 0)
	method = '1D';
else
	method = '2D Emily';
end

switch method
	case '2D Emily'
		[fieldInfo, nFields] = extractpf2d_emily(rateMap, binRangeX, binRangeY, opt);
	case '1D'
		[fieldInfo, nFields] = extractpf1d(rateMap, binRangeX, opt);
end

function [fieldInfo, nFields] = handleEmptyMap(binRangeX, binRangeY)
boundaryStruct = repmat(struct('c20', [], 'c40', [], 'c50', [], 'c60', [], 'c80', [], 'hasMultiPeaks', false), 0, 1);
bins = [];
fieldInfo = struct('bins', bins, 'boundary', boundaryStruct, 'binRangeX', binRangeX, 'binRangeY', binRangeY);
nFields = 0;

function [fieldInfo, nFields] = extractpf2d_emily(rateMap, binRangeX, binRangeY, opt)

if all(~rateMap(:))
	[fieldInfo, nFields] = handleEmptyMap(binRangeX, binRangeY);
	return;
end


areaOfEachBin = (binRangeX(2) - binRangeX(1)) * (binRangeY(2) - binRangeY(1));
xRange = [binRangeX(1) binRangeX(end)];
yRange = [binRangeY(1) binRangeY(end)];

minNumBins = ceil(opt.minArea/areaOfEachBin);

fieldBins = dataanalyzer.makePlaceMaps.ext.findFieldBinsByPixel(rateMap, 2, .2, minNumBins);

if isempty(fieldBins)
	[fieldInfo, nFields] = handleEmptyMap(binRangeX, binRangeY);
	return;
end

boundaryStruct = dataanalyzer.makePlaceMaps.ext. ...
	findFieldContoursFromFieldBins(rateMap,fieldBins,opt.mapInterpFactor,xRange,yRange);

% fix Emily's naming convention (in her code 'c20' is called 'boundary')
if isfield(boundaryStruct, 'boundary')
	for i = 1:length(boundaryStruct)
		boundaryStruct(i).c20 = boundaryStruct(i).boundary;
	end
	boundaryStruct = rmfield(boundaryStruct, 'boundary');
end

boundaryStruct = orderfields(boundaryStruct, sort(fieldnames(boundaryStruct)));
fn = fieldnames(boundaryStruct);
for i = 1:length(fn)
	for l = 1:length(boundaryStruct)
		if ~isempty(regexp(fn{i}, 'c\d{2}', 'match', 'once'))
			boundaryStruct(l).(fn{i})(1, :) = boundaryStruct(l).(fn{i})(1, :) * max(abs(binRangeX)); % convert from relative to cm
			boundaryStruct(l).(fn{i})(2, :) = boundaryStruct(l).(fn{i})(2, :) * max(abs(binRangeY)); % convert from relative to cm
		end
	end
end

% I DO NOT know how the relative boundaries that Emily's code generates are
% organized relative to the binRange. Specifically, which point does 0
% correspond to in an asymmetric binRangeX? 11/18/2015 5:43 PM

fieldInfo = cell2mat(cellfun(@(bins, boundary) struct('bins', bins, 'boundary', boundary, 'binRangeX', binRangeX, 'binRangeY', binRangeY),...
	fieldBins(:), num2cell(boundaryStruct(:)), 'UniformOutput', false));
nFields = length(boundaryStruct);

function [fieldInfo, nFields] = extractpf1d(rateMap, binRangeX, opt)

[fieldInfo, nFields] = handleEmptyMap(binRangeX, 0);
if all(~rateMap(:))
	return;
end

[extents, fieldSize] = findPlaceFieldExtents1D(rateMap(:), binRangeX(:), opt);
fieldSize = diff(extents, [], 2);

invalid = fieldSize < opt.minLength;

if ~isfield(opt, 'contours')
	opt.fieldContour = 0.2;
else
	% Won't work for more than 1 contour
	contours = regexp(opt.contours, '(?<=^c)\d{2}', 'match', 'once');
	contours = str2double(contours) / 100;
	opt.fieldContour = contours;
end

opt.positiveFiringThreshold = opt.fieldContour * opt.minPeakHeight;

extents = extents(~invalid, :);
fieldSize = fieldSize(~invalid);
nFields = sum(~invalid);
try
	bins = arrayfun(@(x) find(x==binRangeX), extents);
catch
	bins = [];
end

if all(isnan(extents))
	return;
end

bins = cellfun(@(x) struct('bins', [ones(diff(x)+1, 1), [x(1):x(2)]']), row2cell(bins));
[x, y] = rectangle(extents);
boundary = cellfun(@(x, y) struct('c20', [x;y]), row2cell(x), row2cell(y));
binRangeX = repmat(struct('binRangeX', binRangeX), size(bins));
binRangeY = zeros(size(bins));

fieldInfo = arrayfun(@(bins, boundary, binx, biny, size) ...
	struct('bins', bins.bins, 'boundary', boundary, 'binRangeX', binx.binRangeX, 'binRangeY', biny, 'size', size), ...
	bins, boundary, binRangeX, binRangeY, fieldSize);

function [x, y] = rectangle(x)
x = [x fliplr(x) x(:, 1)];
y = zeros(size(x, 1), 5);