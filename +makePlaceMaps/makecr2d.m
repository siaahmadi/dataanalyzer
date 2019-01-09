function [rateMaps, binX, binY, gaussFit2, occupmap] = makecr2d(spTrains, videoX, videoY, videoTS, videoV, opt)
%[rateMaps, binRangeX, binRangeY, gaussFit2] = makecr2d(spTrains, videoX, videoY, videoTS, opt)
%
% make a Constant-Range 2D place map for an array of spiketrains
%
% INPUT:
% 
% spTrains
%	M x N cell array of spike trains, where M = number of cells and
%	N = number of trials.
% 
% videoX
%	Array of X coordinates. Length must be N.
%
% videoY
%	Array of Y coordinates. Length must be N.
%
% videoTS
%	Array of time stamps. Length must be N.
%
% spatialRange (optional)
%	Range of the map. Must be big enough to include every videoX and videoY
%	point.
%
% nBins
%	Number of nBins.



% Siavash Ahmadi
% 2/23/15

if ~exist('opt', 'var') || isempty(opt)
	opt.spatialRange.left = -100;
	opt.spatialRange.right = 100;
	opt.spatialRange.bottom = -100;
	opt.spatialRange.top = 100;
	opt.wBin.x = 5;
	opt.wBin.y = 5;
	opt.nBins.x = 200/opt.wBin.x;
	opt.nBins.y = 200/opt.wBin.y;
	opt.velRange = [2, Inf];
	opt.filtVel = true;
else
	if ~isfield(opt, 'spatialRange')
		opt.spatialRange.left = -100;
		opt.spatialRange.right = 100;
		opt.spatialRange.bottom = -100;
		opt.spatialRange.top = 100;		
	end
	if ~isfield(opt, 'wBin')
		opt.wBin.x = 5;
		opt.wBin.y = 5;
	end
	if ~isfield(opt, 'nBins') || isfield(opt, 'wBin') % wBin overrides nBins
		opt.nBins.x = (opt.spatialRange.right - opt.spatialRange.left) / opt.wBin.x;
		opt.nBins.y = (opt.spatialRange.top - opt.spatialRange.bottom) / opt.wBin.y;
	end
	if ~isfield(opt, 'velRange')
		opt.velRange = [2, Inf];
	end
	if ~isfield(opt, 'filtVel')
		opt.filtVel = true;
	end
end

if ~iscell(videoX) || ~iscell(videoY) || ~iscell(videoTS)
	error('Input position data as 1 x n cell arrays')
end

videoX = videoX(:)';
videoY = videoY(:)';
videoTS = videoTS(:)';
videoV = videoV(:)';
if isempty(videoV)
	videoV = repmat({videoV}, size(videoX));
end


[rateMaps, binRangeX, binRangeY, ~, occupmap] = cellfun(@(x,y,t,v) dataanalyzer.makePlaceMaps.mymake2(spTrains(:), x, y, t, v, opt), ...
	videoX, videoY, videoTS, videoV, ...
	'UniformOutput', false);

rateMaps = cat(2, rateMaps{:});
binRangeX = cat(2, binRangeX{:});
binX = arrayfun(@(x,y) (x+y)/2, binRangeX{1}(1:end-1), binRangeX{1}(2:end));
binRangeY = cat(2, binRangeY{:});
binY = arrayfun(@(x,y) (x+y)/2, binRangeY{1}(1:end-1), binRangeY{1}(2:end));
occupmap = cat(2, occupmap{:});
occupmap = occupmap(1, :);
gaussFit2 = [];