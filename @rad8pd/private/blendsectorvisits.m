function idx = blendsectorvisits(sv, r, options)
%IDX = BLENDSECTORVISITS(SV, R, TOLRAD)
%
% Take an array of sector visit numbers and for each sequence of the same
% number from i to j, if |visits(i:j)| does not include a point that's
% beyond a tolerated radius of |tolRad|, convert that sequence to its
% neighboring sequences.
%
% The point where the two neighboring sequences meet is determined by the
% smallest angle between the bisectors of the arms of the neighboring
% sequences.
% 
% If the beginning and end of the sequences fall inside the stem, they will
% not be changed.
%
% INPUT:
% 
% SV
%	Array containing begin indices of arm/sector visits
%
% R
%	Array containing the vector magnitude of each point of the path
%
% OPTIONS
%	Options struct with the following optional fields:
% 
%		- trailingOutwardMovementLengthThreshold (default: .333 seconds)
%			How long should the path be in the outward direction (defined
%			as the points' vector magnitude being increasing) for a sector
%			visit to be considered an actual, valid visit (and not just a
%			quick peek).
%
%		- tolRad (default: 25 cm)
%			Outward movement radius tolerance. Movements within this radius
%			will not be designated as valid arm visits.
%
%		- videoFR (default: 30 Fps)
%			The frame rate at which the path data was acquired.
%
%		- veryFarThreshold (default: 50 cm)
%			Points that are farther than this limit are considered valid
%			arm visits.
%			The logic is that if the animal is far enough it must be on the
%			arm (and not cannot be jumping across arms).
%
%
% OUTPUT:
%
% IDX
%	Array containing the indices of the beginning of arm visits. The first
%	and the last elements of this array will be 1 and |length(r)|,
%	respectively.

% Siavash Ahmadi
% 10/3/15

trailingOutwardMovementLengthThreshold = 1/3;
tolRad = 25; % cm
videoFR = 30;
veryFarThreshold = 50; % cm

if exist('options', 'var') && ~isempty(tolRad) && isstruct(options)
	if isfield(options, 'trailingOutwardMovementLengthThreshold')
		trailingOutwardMovementLengthThreshold = options.trailingOutwardMovementLengthThreshold;
	end
	if isfield(options, 'tolRad')
		tolRad = options.tolRad;
	end
	if isfield(options, 'videoFR')
		videoFR = options.videoFR;
	end
	if isfield(options, 'veryFarThreshold')
		veryFarThreshold = options.veryFarThreshold;
	end
end

trailingNumFramesThreshold = trailingOutwardMovementLengthThreshold * videoFR;


trueVisits = phaprec.parsemz.rad8.findtruevisits(sv, r, tolRad, veryFarThreshold, trailingNumFramesThreshold);

if r(sv(1)) > veryFarThreshold
	idx = [sv(trueVisits); length(r)]; % trial began when the animal was inside the arm (and beyond arm threshold)
else
	idx = [1; sv(trueVisits); length(r)];
end

sameIdx = find(idx(1:end-1) == idx(2:end))*2; % sometimes the visit is too short (only 1 timestamp) that two consecutive points will have the same index value. Since I'm using a Python style indexing scheme, I need to +1 the end of the interval. Although: shouldn't then I do this for every visits index?? 12/13/2015 7:59 PM
if ~isempty(sameIdx)
	idx(sameIdx) = idx(sameIdx) + 1;
end