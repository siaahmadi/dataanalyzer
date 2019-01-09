function selectivity = selectivity_skaggs96(placemap, occupancy)
%SELECTIVITY_SKAGGS96 Spatial selectivity of spike train as defined
%in Skaggs, McNaughton, Wilson, and Barnes (1996) Hippocampus.
%
%"The selectivity measure is equal to the spatial maximum
%firing rate divided by the mean firing rate of the cell.
%The more tightly concentrated the cell’s activity, the
%higher the selectivity. A cell with no spatial tuning at
%all will have a selectivity of 1; there is in principle
%no upper limit."
%
%
% si = SELECTIVITY_SKAGGS96(placemap, occupancy)
%    Both arguments are required. |placemap| is a matrix containing mean
%    firing rate of a cell for each spatial bin in its corresponding
%    elements. |occupancy| is a matrix, same size as |placemap|, containing
%    the time duration spent in each spatial bin. The unit must be in
%    spikes per second and second, respectively.
%
%	|selectivity| will be a value in interval [1, Inf].
%
% From Skaggs et al., (1996):
% "A similar measure was used by Barnes et al. (1983),
% except that the “out-of-field” firing rate was used
% instead of the mean rate. The present definition is
% preferable because it does not depend on identifying
% a “place field,” and because it is much less sensitive
% to noise."
%
% See also: dataanalyzer.routines.spatial.selectivity_barnes83

if ~isequal(size(placemap), size(occupancy))
	error('The arguments must be of the same size.');
end

% some convenience pre-calc
placemap(~isfinite(placemap)) = 0;
placemap(~occupancy) = 0;
total_occup = sum(occupancy(:));

Lambda = sum(placemap(:) .* occupancy(:)) / total_occup;
selectivity = max(placemap(:)) / Lambda;