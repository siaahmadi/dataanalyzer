function [rateMap, binRangeX, binRangeY, gaussFit2] = mymake2(spTrains, videoX, videoY, videoTS, spatialRange, nBins)
%[rateMap, binRange, gaussFit1] = mymake2(spTrains, videoX, videoY, videoTS, spatialRange, nBins)
%
% make a 2D place map for a single spiketrain, restricted range whose lower
% and upper bounds are demarcated by the fields of the struct
% 'spatialRange'
%
% Fitting is done through lsqcurvefit()
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
% external calls: smooth2a(), normpdf2()

% Siavash Ahmadi
% 02/23/2015 11:31 AM

% Modified by @author Sia
% @date 10/8/2015 12:52 PM
% @lines definition of binRangeX, rate map estimate, comment for occupancy
% map expected value


rLeft = spatialRange.left;
rRight = spatialRange.right;
rTop = spatialRange.top;
rBottom = spatialRange.bottom;

binSizeX = (rRight - rLeft) / nBins.x;
binSizeY = (rTop - rBottom) / nBins.y;
smKernelSize = [25, 25]; % cm
smKernelSize = round(smKernelSize ./ [binSizeX, binSizeY]);

binRangeX = linspace(rLeft, rRight, 1 + nBins.x);
binRangeY = linspace(rBottom, rTop, 1 + nBins.y);

if isempty(spTrains)
	[~, binidx_occupX] = histc(videoX, binRangeX);
	[~, binidx_occupY] = histc(videoY, binRangeY);
	idx_to_remove = binidx_occupX==0 | binidx_occupY==0;
	binidx_occupX(idx_to_remove) = []; binidx_occupY(idx_to_remove) = []; % ignore out-of-bounds visits
	if max(binidx_occupX) == length(binRangeX), binidx_occupX(binidx_occupX==max(binidx_occupX)) = max(binidx_occupX)-1; end;
	if max(binidx_occupY) == length(binRangeX), binidx_occupY(binidx_occupY==max(binidx_occupY)) = max(binidx_occupY)-1; end;
	bincount_occup = full(sparse(binidx_occupY, binidx_occupX, 1, nBins.y, nBins.x));
	bincount_occup(bincount_occup <= 0) = NaN;
	bincount_occup(bincount_occup > 0) = 0;

	rateMap = bincount_occup;
	gaussFit2 = [];
	return
elseif iscell(spTrains)
	[rateMap, binRangeX, binRangeY] = cellfun(@(sp) dataanalyzer.makePlaceMaps.mymake2(sp, videoX, videoY, videoTS, spatialRange, nBins), spTrains, 'un', 0);
	gaussFit2 = [];
	return;
end

% smoothingKernel = normpdf2(linspace(-1, 1, 5), linspace(-1, 1, 5));
smoothingKernel = 1;
sampFreq = (diff(videoTS));
sampFreq = mean(sampFreq(sampFreq < 0.1)); % esimated sampling frequency


[~, binidx_spikeX] = histc(videoX(spike2ind(spTrains, videoTS)), binRangeX);
idx_to_remove = binidx_spikeX == 0;
if max(binidx_spikeX) == length(binRangeX), binidx_spikeX(binidx_spikeX==max(binidx_spikeX)) = max(binidx_spikeX)-1; end; % converting histc's behavior from treating last interval as [,) to [,]
[~, binidx_spikeY] = histc(videoY(spike2ind(spTrains, videoTS)), binRangeY);
if max(binidx_spikeY) == length(binRangeY), binidx_spikeY(binidx_spikeY==max(binidx_spikeY)) = max(binidx_spikeY)-1; end; % converting histc's behavior from treating last interval as [,) to [,]
idx_to_remove = idx_to_remove | binidx_spikeY==0;
binidx_spikeX(idx_to_remove) = []; % ignore out-of-bounds spikes
binidx_spikeY(idx_to_remove) = []; % ignore out-of-bounds spikes


[~, binidx_occupX] = histc(videoX, binRangeX);
[~, binidx_occupY] = histc(videoY, binRangeY);
idx_to_remove = binidx_occupX==0 | binidx_occupY==0;
binidx_occupX(idx_to_remove) = []; binidx_occupY(idx_to_remove) = []; % ignore out-of-bounds visits
if max(binidx_occupX) == length(binRangeX), binidx_occupX(binidx_occupX==max(binidx_occupX)) = max(binidx_occupX)-1; end;
if max(binidx_occupY) == length(binRangeX), binidx_occupY(binidx_occupY==max(binidx_occupY)) = max(binidx_occupY)-1; end;


bincount_spikes = full(sparse(binidx_spikeY, binidx_spikeX, 1, nBins.y, nBins.x));
bincount_occup = full(sparse(binidx_occupY, binidx_occupX, 1, nBins.y, nBins.x));
a = bincount_spikes(bincount_spikes>0);
b = bincount_occup(bincount_spikes>0);
sem = std(a./b/sampFreq) ./ sqrt(b);w = (1./sem) / sum(1./sem); wn = w*length(w);
bincount_occup(bincount_occup > 0) = (bincount_occup(bincount_occup > 0) - 0) * sampFreq; % expected value of time spent in bin
																			% (given N points, time spent could be anywhere from N-0.5 to N+0.5 point units)

% rateMap = filter2(bincount_spikes./bincount_occup, smoothingKernel);
rmUnsmoothed = bincount_spikes./bincount_occup;
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
rateMap = gsmooth(rmUnsmoothed,smKernelSize, smoothingKernel); % Chris's smoothing method

if nargout > 3
	rateMapFIT = (bincount_spikes./bincount_occup);
	rateMapFIT(isnan(rateMapFIT)) = 0;
	rateMapFIT = smooth2a(rateMapFIT, smoothingKernel);
	rateMapFIT = gsmooth(rateMapFIT,[5, 5], smoothingKernel); % Chris's smoothing method
	
	[X1, X2] = meshgrid(binRangeX, binRangeY);
	[x, m] = mymax(rateMap);
	x0 = [binRangeX(x(2)), binRangeY(x(1)), 12, 0, 12, m];
	opts = optimset('lsqcurvefit');optimset(opts,'Display','off');
	try
		fitparams = lsqcurvefit(@myfitfun, x0, [X1(:), X2(:)], rateMapFIT(:), opts);
		gaussFit2.gauss2fun = @mygauss2;
		gaussFit2.fitparams = fitparams;
		gaussFit2.x1 = X1;
		gaussFit2.x2 = X2;
	catch
		warning('Unsuccessful fitting.');
		gaussFit2 = [];
	end
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