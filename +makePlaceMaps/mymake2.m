function [rateMap, binRangeX, binRangeY, bincount_occup, preRM, gaussFit2] = mymake2(spTrains, videoX, videoY, videoTS, videoV, opt)
%MYMAKE2 Make 2-dimensional time-normalized density map (i.e. place map)
%
%[rateMap, binRangeX, binRangeY, bincount_occup, preRM, gaussFit2] = MYMAKE2(spTrains, videoX, videoY, videoTS, videoV, opt)
%
% Make a 2D place map for a single or multiple spiketrains
% 
% VideoV can be an m-by-n matrix where n = [1, 2, 3]. First column, is
% linear velocity, second column is angular velocity, third column is rdot
% (?)
%
% opt:
%    - spatialRange
%    - nBins
%    - filtVel
%       - velRange
%    - filtAngVel
%       - wRange
%       - rdotRange
%    - smoothingMethod
%    - validIvls
%    - minValidLength
%
% Fitting is done using lsqcurvefit()
% The fit will be performed on the rateMap with its NaN's replaced by 0's
%
%
% The fitting results are returned as a struct with the following fields:
%
% gaussFit2.gauss2fun
%			auxiliary function handle allowing user to reproduce modelled
%			placefield from parameters. For usage, see EXAMPLE below.
%
% gaussFit2.fitparams
%			fitting parameters: the entries are as follows:
%			(1) mean of fit along X axis
%			(2) mean of fit along Y axis
%			(3) standard deviation along X axis
%			(4) correlation between X and Y axes
%			(5) standard deviation along Y axis
%			(6) peak of gaussian fit
%
% gaussFit2.x1
%			mesh grid along X axis
%
% gaussFit2.x2
%			mesh grid along Y axis
%
% 
% To reproduce the model numerically, follow this example:
%
% EXAMPLE:
%		pfModelled = reshape(...
%			gaussFit2.gauss2fun(gaussFit2.x1(:), gaussFit2.x2(:), gaussFit2.fitparams), ...
%			size(gaussFit2.x1, 1), size(gaussFit2.x1, 2));
%
% pfModelled will be a matrix that can be plotted by running
%	surf(binRangeX, binRangeY, pfModelled)
% 
% external calls: spike2ind(), normpdf2(), gsmooth()

% Siavash Ahmadi
% 02/23/2015 11:31 AM

% Modified by @author Sia
% @date 10/8/2015 12:52 PM
% @lines definition of binRangeX, rate map estimate, comment for occupancy
% map expected value

% Modifed by @author Sia
% @date 4/18/2017 7:10 PM
% Cleaned up; added velocity filters, validity intervals, etc

% If multiple spike trains:
if iscell(spTrains)
	if isempty(videoV)
		if iscell(videoTS)
			videoV = cell(size(videoTS));
		else
			videoV = NaN(size(videoTS));
		end
	end
	if iscolumn(spTrains) % multiple cells
		[rateMap, binRangeX, binRangeY, bincount_occup, preRM, gaussFit2] = ...
			cellfun(@(sp) dataanalyzer.makePlaceMaps.mymake2(sp(:), videoX(:)', videoY(:)', videoTS(:)', videoV, opt), spTrains(:), 'un', 0);
		bincount_occup = bincount_occup{1};
		if iscell(videoX)
			rateMap = cat(1, rateMap{:});
			preRM = cat(1, preRM{:});
		end
	elseif isrow(spTrains) % one neuron separated into multiple trials (can be merged with |else| to make a single |else| for the |if| statement)
		[rateMap, binRangeX, binRangeY, bincount_occup, preRM, gaussFit2] = ...
			cellfun(@(sp,x,y,t,v) dataanalyzer.makePlaceMaps.mymake2(sp,x,y,t,v,opt), spTrains(:)', videoX(:)', videoY(:)', videoTS(:)', videoV, 'un', 0);
		preRM = cat(2, preRM{:});
		gaussFit2 = cat(2, gaussFit2{:});
	else % matrix of spike times whose rows are the neurons, and columns are the trials
		spTrains = row2cell(spTrains);
		rateMap = cell(1, length(spTrains));
		bincount_occup = cell(1, length(spTrains));
		preRM = cell(1, length(spTrains));
		gaussFit2 = cell(1, length(spTrains));
		for cellIdx = 1:length(spTrains)
			[rateMap{cellIdx}, binRangeX, binRangeY, bincount_occup{cellIdx}, preRM{cellIdx}, gaussFit2{cellIdx}] = ...
				cellfun(@(sp,x,y,t,v) dataanalyzer.makePlaceMaps.mymake2(sp,x,y,t,v,opt), spTrains{cellIdx}, videoX, videoY, videoTS, videoV, 'un', 0);
		end
		rateMap = cat(1, rateMap{:});
		bincount_occup = cat(1, bincount_occup{:});
		preRM = cat(1, preRM{:});
		gaussFit2 = cat(1, gaussFit2{:});
	end
	
	binRangeX = binRangeX{1};
	binRangeY = binRangeY{1};
	
	return;
end

if iscell(videoTS) % multiple place data
	
	[rateMap, binRangeX, binRangeY, bincount_occup, preRM, gaussFit2] = ...
		cellfun(@(x,y,t,v) dataanalyzer.makePlaceMaps.mymake2(spTrains(:),x,y,t,v,opt), videoX(:)', videoY(:)', videoTS(:)', videoV(:)', 'un', 0);
	
	preRM = cat(2, preRM{:});
	gaussFit2 = cat(2, gaussFit2{:});
	binRangeX = binRangeX{1};
	binRangeY = binRangeY{1};
	
	return;
end

videoTS = videoTS(:);
videoX = videoX(:);
videoY = videoY(:);

if isempty(videoTS)
	rateMap = [];
	bincount_occup = [];
	preRM = [];
	gaussFit2 = [];
	binRangeX = [];
	binRangeY = [];
	
	return;
end

% Parse options:
[binEdgeX, binEdgeY, smKernelSize, smoothingKernel, velRng, filtVel, wRng, rdotRng, filtAngVel, smoothingMethod, validIvls, minValidLength] = parseOptions(opt, videoTS);
binRangeX = midpt(binEdgeX);
binRangeY = midpt(binEdgeY);

% Estimate frame length in time:
sampFreq = (diff(videoTS));
sampFreq = mean(sampFreq(sampFreq < 0.1)); % esimated sampling frequency

% Get the valid velocity index (will include every index if velocity
% filtering not requested):
vfidx = filterVelocity(filtVel, filtAngVel, velRng, wRng, rdotRng, videoTS, videoX, videoY, videoV);

% Drop valid periods of shorter than opt.minValidLength
valid_ivls = validIvls.restrict(videoTS);
valid_ivls = lau.open(sum(cat(2, valid_ivls{:}), 2) > 0 & vfidx, floor(minValidLength / sampFreq));

% Apply velocity + interval validity filter:
videoX(~valid_ivls) = NaN;
videoY(~valid_ivls) = NaN;

% Discard the spikes outside valid intervals (crucial for the interpolation
% further down in @spike2ind to make sense):
[~, spTrains] = validIvls.restrict(spTrains, spTrains);

if isempty(spTrains) % No spikes in the valid intervals
	bincount_occup = computeBinCount(videoX, videoY, binEdgeX, binEdgeY) * sampFreq;

	rateMap = bincount_occup;
	rateMap(rateMap > 0) = 0; % A matrix of 0's and NaNs where positive occupancy sets the entry to 0
	preRM.spikemap = zeros(size(bincount_occup));
	preRM.occupmap = bincount_occup;
	gaussFit2 = [];
	return;
end

% smoothingKernel = normpdf2(linspace(-1, 1, 5), linspace(-1, 1, 5));

x_spikes = videoX(spike2ind(spTrains, videoTS));
y_spikes = videoY(spike2ind(spTrains, videoTS));
bincount_occup = computeBinCount(videoX, videoY, binEdgeX, binEdgeY);
bincount_spikes = computeBinCount(x_spikes, y_spikes, binEdgeX, binEdgeY);

bincount_occup = bincount_occup * sampFreq; % Convert to seconds

% rateMap = filter2(bincount_spikes./bincount_occup, smoothingKernel);
rmUnsmoothed = bincount_spikes./bincount_occup;
preRM.spikemap = bincount_spikes;
preRM.occupmap = bincount_occup;
% a = bincount_spikes(bincount_spikes>0);
% b = bincount_occup(bincount_spikes>0);
% sem = std(a./b/sampFreq) ./ sqrt(b);w = (1./sem) / sum(1./sem); wn = w*length(w);
% rmUnsmoothed(bincount_spikes>0) = rmUnsmoothed(bincount_spikes>0) .* wn;%
% this will reduce the variance of estimate @comment added @date 10/8/2015
% @author Sia: this seems stupid. I have no idea how this idea came to me
% and I don't see why it's correct. This is commented out until a later
% time when I can fix it. Essentially, the idea is that the higher a bin's
% occupancy time is, the higher our confidence in the rate we obtain for
% that bin by dividing its number of spikes by its occupancy time, and
% somehow we should use this fact to arrive at a better estimate of the
% true rate map.
% rateMap = smooth2a(rmUnsmoothed, smoothingKernel);

rateMap = dataanalyzer.makePlaceMaps.ext.gsmooth(rmUnsmoothed,smKernelSize, smoothingKernel, smoothingMethod); % Chris's smoothing method

if nargout == 4
	rateMapFIT = (bincount_spikes./bincount_occup);
	rateMapFIT(isnan(rateMapFIT)) = 0;
	rateMapFIT = smooth2a(rateMapFIT, smoothingKernel);
	rateMapFIT = gsmooth(rateMapFIT,[5, 5], smoothingKernel); % Chris's smoothing method
	
	[X1, X2] = meshgrid(binEdgeX, binEdgeY);
	[x, m] = mymax(rateMap);
	x0 = [binEdgeX(x(2)), binEdgeY(x(1)), 12, 0, 12, m];
	opts = optimset('lsqcurvefit');optimset(opts,'Display','off');
	try
		fitparams = lsqcurvefit(@myfitfun, x0, [X1(:), X2(:)], rateMapFIT(:), opts);
		gaussFit2.gauss2fun = @mygauss2;
		gaussFit2.fitparams = fitparams;
		gaussFit2.x1 = X1;
		gaussFit2.x2 = X2;
	catch
		warning('DataAnalyzer:PlaceMaps:BadFitting', 'Unsuccessful fitting.');
		gaussFit2 = [];
	end
else
	gaussFit2 = [];
end

function F = myfitfun(x, xdata)
X1 = xdata(:, 1); X2 = xdata(:, 2);
F = mygauss2(X1, X2, x);

function F = mygauss2(x1, x2, params)
SIGMA = [params(3) params(4);params(4) params(5)];
F = mvnpdf([x1 x2], [params(1) params(2)], SIGMA);
F = F/max(F)*params(6); F(isnan(F)) = 0;

function [x0, m] = mymax(A)
[~, m] = max(A);
idx = sub2ind(size(A), m, 1:size(A, 2));
m1 = A(idx);
[~, m1] = max(m1);
x1 = m(m1);
x2 = m1;
x0 = [x1, x2];
m = A(x1, x2);

function [binEdgeX, binEdgeY, smKernelSize, smoothingKernel, velRng, filtVel, wRng, rdotRng, filtAngVel, smoothingMethod, validIvls, minValidLength] = parseOptions(opt, t)
spatialRange = opt.spatialRange;
nBins = opt.nBins;
if isfield(opt, 'velRange')
	velRng = opt.velRange;
else
	velRng = [0, Inf];
end
if isfield(opt, 'filtVel')
	filtVel = opt.filtVel;
else
	filtVel = false;
end
if isfield(opt, 'wRange')
	wRng = opt.wRange;
else
	wRng = [-Inf, Inf];
end
if isfield(opt, 'rdotRange')
	rdotRng = opt.rdotRange;
else
	rdotRng = [-Inf, Inf];
end
if isfield(opt, 'filtAngVel')
	filtAngVel = opt.filtAngVel;
else
	filtAngVel = false;
end
if isfield(opt, 'smoothingMethod')
	smoothingMethod = opt.smoothingMethod;
else
	smoothingMethod = 'sia';
end
if isfield(opt, 'validIvls')
	validIvls = opt.validIvls;
elseif isempty(t)
	validIvls = ivlset(0, 0);
else
	validIvls = ivlset(t(1), t(end)); % the entire t
end
if isfield(opt, 'minValidLength')
	minValidLength = opt.minValidLength;
else
	minValidLength = 0; % intervals of any duration are valid
end


if isnumeric(velRng) && size(velRng, 2) == 2
	velRng = ivlset(velRng(:, 1), velRng(:, 2));
elseif ~isa(velRng, 'ivlset')
	error('Wrong options format: velRange must be an ivlset or an N x 2 numeric array.');
end
if isnumeric(wRng) && size(wRng, 2) == 2
	wRng = ivlset(wRng(:, 1), wRng(:, 2));
elseif ~isa(wRng, 'ivlset')
	error('Wrong options format: wRng must be an ivlset or an N x 2 numeric array.');
end
if isnumeric(rdotRng) && size(rdotRng, 2) == 2
	rdotRng = ivlset(rdotRng(:, 1), rdotRng(:, 2));
elseif ~isa(rdotRng, 'ivlset')
	error('Wrong options format: rdotRng must be an ivlset or an N x 2 numeric array.');
end

rLeft = spatialRange.left;
rRight = spatialRange.right;
rTop = spatialRange.top;
rBottom = spatialRange.bottom;

binSizeX = (rRight - rLeft) / nBins.x;
binSizeY = (rTop - rBottom) / nBins.y;

if isfield(opt, 'smoothingKernel')
	smoothingKernel = opt.smoothingKernel;
else
	smoothingKernel = 1;
end
if isfield(opt, 'smKernelSize')
	smKernelSize = opt.smKernelSize;
else
	smKernelSize = round([25, 25] ./ [binSizeX, binSizeY]); % cm
end

binEdgeX = linspace(rLeft, rRight, 1 + nBins.x);
binEdgeY = linspace(rBottom, rTop, 1 + nBins.y);

function vfidx = filterVelocity(filtVel, filtAngVel, velRng, wRng, rdotRng, videoTS, videoX, videoY, videoV)
if isfat(videoV) && size(videoV, 1) <= 3
	videoV = videoV';
end

% by default everything is valid for velocity purposes
if ~filtVel
	vfidx = true(size(videoTS));
	return;
end


if size(videoV, 1) == length(videoTS) && size(videoV, 2) == 3
	V = videoV(:, 1);
	W = videoV(:, 2);
	Rdot = videoV(:, 3);
elseif size(videoV, 2) == 1 && filtAngVel
	V = videoV(:, 1);
	[W, Rdot] = dataanalyzer.routines.spatial.velocity_ang(videoX,videoY,videoTS);
elseif size(videoV, 2) == 2 && filtAngVel
	V = videoV(:, 1);
	[~, Rdot] = dataanalyzer.routines.spatial.velocity_ang(videoX,videoY,videoTS);
elseif size(videoV, 1) == length(videoTS) && ~all(isnan(videoV)) && ~filtAngVel % V given but no angular velocity requested
	V = videoV(:, 1);
else % V not given
	V = dataanalyzer.routines.spatial.velocity(videoX,videoY,videoTS);
	if filtAngVel
		[W, Rdot] = dataanalyzer.routines.spatial.velocity_ang(videoX,videoY,videoTS);
	end
end
velfidx = velRng.restrict('unsorted', V);
if filtAngVel
	wfidx = wRng.restrict(W);
	rdotfidx = rdotRng.restrict(Rdot);
	wfidx = sum(cat(2, wfidx{:}), 2) > 0;
	rdotfidx = sum(cat(2, rdotfidx{:}), 2) > 0;
end
velfidx = sum(cat(2, velfidx{:}), 2) > 0;
if filtAngVel
	vfidx = prod([velfidx, wfidx, rdotfidx], 2) > 0;
else
	vfidx = velfidx;
end

function bincount_evnt = computeBinCount(x_event, y_event, binEdgeX, binEdgeY)
nBinsX = length(binEdgeX) - 1;
nBinsY = length(binEdgeY) - 1;
[~, binidx_occupX] = histc(x_event, binEdgeX);
[~, binidx_occupY] = histc(y_event, binEdgeY);
if max(binidx_occupX) == length(binEdgeX), binidx_occupX(binidx_occupX==max(binidx_occupX)) = max(binidx_occupX)-1; end;
if max(binidx_occupY) == length(binEdgeX), binidx_occupY(binidx_occupY==max(binidx_occupY)) = max(binidx_occupY)-1; end;
idx_to_remove = binidx_occupX==0 | binidx_occupY==0;
binidx_occupX(idx_to_remove) = []; % ignore out-of-bounds visits and NaN values
binidx_occupY(idx_to_remove) = []; % ignore out-of-bounds visits and NaN values
bincount_evnt = full(sparse(binidx_occupY, binidx_occupX, 1, nBinsY, nBinsX));