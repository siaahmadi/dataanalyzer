function [rateMaps, binRangeX, binRangeY, gaussFit2] = makecr2d(spTrains, videoX, videoY, videoTS, spatialRange, nBins)
%[rateMaps, binRangeX, binRangeY, gaussFit2] = makecr2d(spTrains, videoX, videoY, videoTS, spatialRange, nBins)
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


if nargin < 5
	spatialRange.left = -100;
	spatialRange.right = 100;
	spatialRange.bottom = -100;
	spatialRange.top = 100;
	spatialRange = repmat({spatialRange}, size(spTrains));
	nBins.x = 200/(10/3);
	nBins.y = 200/(10/3);
	nBins = repmat({nBins}, size(spTrains));
elseif nargin == 5
	if ~isfield(spatialRange, 'left') || ~isfield(spatialRange, 'right') || ~isfield(spatialRange, 'bottom') || ~isfield(spatialRange, 'top')
		error('struct ''spatialRange'' must have four fields (i.e. left, right, bottom, top) to demarcated the place map.')
	end
	nBins.x = (spatialRange.right-spatialRange.left)/(10/3);
	nBins.y = (spatialRange.right-spatialRange.left)/(10/3);
	nBins = repmat({nBins}, size(spTrains));
elseif nargin == 6
	opt.spatialRange = spatialRange;
	opt.nBins = nBins;
end

if ~iscell(videoX) || ~iscell(videoY) || ~iscell(videoTS)
	error('Input position data as 1 x n cell arrays')
end

videoX = reshape(videoX, 1, numel(videoX));
videoY = reshape(videoY, 1, numel(videoY));
videoTS = reshape(videoTS, 1, numel(videoTS));
videoX = repmat(videoX, size(spTrains, 1), 1); % assumes videoX 1 x n cell array
videoY = repmat(videoY, size(spTrains, 1), 1); % assumes videoY 1 x n cell array
videoTS = repmat(videoTS, size(spTrains, 1), 1); % assumes videoTS 1 x n cell array

if nargout > 3
	[rateMaps, binRangeX, binRangeY, gaussFit2] = cellfun(@(sp,x,y,t) dataanalyzer.makePlaceMaps.mymake2(sp,x,y,t,opt), ...
		spTrains, videoX, videoY, videoTS,...
		'UniformOutput', false);
else
	[rateMaps, binRangeX, binRangeY] = cellfun(@(sp,x,y,t) dataanalyzer.makePlaceMaps.mymake2(sp,x,y,t,opt), ...
		spTrains, videoX, videoY, videoTS,...
		'UniformOutput', false);
end