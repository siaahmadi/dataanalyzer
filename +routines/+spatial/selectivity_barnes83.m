function selectivity = selectivity_barnes83(placemap, occupancy, placefield_bins)
%SELECTIVITY_BARNES83 Spatial selectivity of spike train as defined
%in Barnes, McNaughton, O'Keefe (1983) Neurobiol. Aging.
%
% si = SELECTIVITY_BARNES83(placemap, occupancy, placefield_boundary)
%    Both arguments are required. |placemap| is a matrix containing mean
%    firing rate of a cell for each spatial bin in its corresponding
%    elements. |occupancy| is a matrix, same size as |placemap|, containing
%    the time duration spent in each spatial bin. The unit must be in
%    spikes per second and second, respectively.
%
%	placefield_bins is a 2xN matrix with the boundaries of N placefield(s)
%	of the neuron. MATLAB's polygon representation rules must be used.
%
%	|selectivity| will be a value in interval [1, Inf].
%
% See also: dataanalyzer.routines.spatial.selectivity_skaggs96

if ~isequal(size(placemap), size(occupancy))
	error('The arguments must be of the same size.');
end

validateattributes(placefield_bins, {'numeric'}, {'ncols', 2, 'positive', 'integer'}, 'selectivity_barnes83', 'placefield_bins', 3);

% some convenience pre-calc
placemap(~isfinite(placemap)) = 0;
placemap(~occupancy) = 0;

FIELD = sub2ind(size(placemap), placefield_bins(:, 1), placefield_bins(:, 2));
OUT = occupancy; OUT(FIELD) = 0; OUT = OUT > 0;
outoffield_mean = sum(placemap(OUT(:)) .* occupancy(OUT(:))) / sum(occupancy(OUT(:)));

selectivity = max(placemap(:)) / outoffield_mean;