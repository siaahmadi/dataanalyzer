function [sparsity, C] = sparsity_skaggs96_bytrain(trains, pd)
%SPARSITY_SKAGGS96 Sparsity of spike train as defined
%in Skaggs, McNaughton, Wilson, and Barnes (1996) Hippocampus.
%
% si = SPARSITY_SKAGGS96(placemap, occupancy)
%    Both arguments are required. |placemap| is a matrix containing mean
%    firing rate of a cell for each spatial bin in its corresponding
%    elements. |occupancy| is a matrix, same size as |placemap|, containing
%    the time duration spent in each spatial bin. The unit must be in
%    spikes per second and second, respectively.
%
%	|sparsity| will be a value in interval [0, 1].
%
%	|C| is the spatial coefficient of variations.

% some convenience pre-calc

opt.spatialRange.left = -100;
opt.spatialRange.right = 100;
opt.spatialRange.bottom = -100;
opt.spatialRange.top = 100;
opt.nBins.x = 50;
opt.nBins.y = 50;

spikes = cat(1, trains.s);

[rm, ~, ~, occup] = dataanalyzer.makePlaceMaps.mymake2(spikes, pd.x, pd.y, pd.t, pd.v, opt);

[sparsity, C] = dataanalyzer.routines.spatial.sparsity_skaggs96(rm, occup);