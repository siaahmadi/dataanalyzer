function idx = sectorvisits(sector)
%IDX = SECTORVISITS(SECTOR)
%
% Returns the indices of the begininng and end of the stretches of
% consectutive points that fall into a sector, called sector visits.
%
% For N sector visits, |idx| will contain N + 1 entries. Each consecutive
% pair of values in |idx| will indicate the beginning index, b, and end
% index, e, of a visit à la Python: [b, e).
%
% Therefore, for the i-th visit, read |visits(idx(i):idx(i+1)-1)|

% Siavash Ahmadi
% 10/1/15

idx = 1;

t = diff([sector(1); sector(:)])~=0;

idx = [idx; find(t(:)); length(t)+1];