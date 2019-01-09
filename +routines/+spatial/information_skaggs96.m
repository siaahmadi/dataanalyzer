function [si_persecond, si_perspike] = information_skaggs96(placemap, occupancy)
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
Lambda = sum(placemap(:) .* occupancy(:)) / total_occup;
p = occupancy(visited) ./ total_occup;

% plug it in
L = lambda/Lambda;
L(L==0) = 1; % to avoid getting NaNs from log2: log2(1)=0, therefore, these won't contribute to |si|
si_persecond = sum(p.*lambda.*log2(L));
% the above formula is wrong in the Skaggs96 paper. The correct form is published in
% "An Information-Theoretic Approach to Deciphering the Hippocampal Code"
% by Skaggs, McNaughton, Gothard, and Markus (1992) in NIPS

si_perspike = si_persecond / Lambda;