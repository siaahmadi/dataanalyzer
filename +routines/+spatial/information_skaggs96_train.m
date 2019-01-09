function [si_persecond, si_perspike] = information_skaggs96_train(trains, pd)
%INFORMATION_SKAGGS96 Spatial firing information of spike train as defined
%in Skaggs, McNaughton, Wilson, and Barnes (1996) Hippocampus.
%
% [si_persecond, si_perspike] = INFORMATION_SKAGGS96(placemap, occupancy)
%    Both arguments are required. |placemap| is a matrix containing mean
%    firing rate of a cell for each spatial bin in its corresponding
%    elements. |occupancy| is a matrix, same size as |placemap|, containing
%    the time duration spent in each spatial bin. The unit must be in
%    spikes per second and second, respectively.
%
%	The unit of |si|, will be bits per second.

opt.spatialRange.left = -100;
opt.spatialRange.right = 100;
opt.spatialRange.bottom = -100;
opt.spatialRange.top = 100;
opt.nBins.x = 50;
opt.nBins.y = 50;

spikes = cat(1, trains.s);

[rm, ~, ~, occup] = dataanalyzer.makePlaceMaps.mymake2(spikes, pd.x, pd.y, pd.t, pd.v, opt);

[si_persecond, si_perspike] = dataanalyzer.routines.spatial.information_skaggs96(rm, occup);