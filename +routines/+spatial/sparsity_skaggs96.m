function [sparsity, C] = sparsity_skaggs96(placemap, occupancy)
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

if ~isequal(size(placemap), size(occupancy))
	error('The arguments must be of the same size.');
end

% some convenience pre-calc
placemap(~isfinite(placemap)) = 0;
placemap(~occupancy) = 0;
visited = occupancy(:) > 0;
total_occup = sum(occupancy(:));

% params
lambda = placemap(visited); lambda = lambda(:);
p = occupancy(visited) ./ total_occup;

sparsity = sum(p.*lambda).^2 / sum(p.*lambda.^2);

C = sqrt((1/sparsity)-1);