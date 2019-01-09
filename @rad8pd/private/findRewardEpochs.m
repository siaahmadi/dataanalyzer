function rw = findRewardEpochs(r, options)
%FINDREWARDEPOCHS Indices of putative reward consumption periods
%
% |rw| will be a struct with fields |begin| and |end| of the same length,
% indicating the start and end indices of |r| that are desginated as
% putative reward consumption periods.
% The start is defined as the first index where the position tracking data
% moves toward the center (i.e. |r| decreases), and the end is defined as
% the last such point.
%
% rw = FINDREWARDEPOCHS(r, options)
%
% r         distance of the animal from the origin (0, 0)
% options   struct with field |rewardRadiusThreshold| (typical = 70cm)
%
% rw        struct with fields |start| and |end|

rw_thr_onset = find(lau.rton(r > options.rewardRadiusThreshold));
rw_thr_offset = find(lau.rtoff(r > options.rewardRadiusThreshold));
revisit_thr_onset = lau.rton(r > options.revisitRadiusThreshold);
revisit_thr_offset = lau.rtoff(r > options.revisitRadiusThreshold);

if isempty(rw_thr_onset) || isempty(rw_thr_offset)
	rw.begin = [];
	rw.end = [];
	return;
end

ivl_reward = ivlset(rw_thr_onset, rw_thr_offset);
ivl_revisit = ivlset(find(revisit_thr_onset), find(revisit_thr_offset));
ivl_valid_rw = ivl_revisit ^ ivl_reward;

rdot = diff([r(1); r]);

on = rw_thr_onset(cellfun(@(i) find(i,1), ivl_valid_rw.restrict(rw_thr_onset)));
off = rw_thr_offset(cellfun(@(i) find(i,1,'last'), ivl_valid_rw.restrict(rw_thr_offset)));

[rw_b, rw_e] = arrayfun(@(i,j) find_rewards(i,j,rdot), on, off);

rw.begin = rw_b;
rw.end = rw_e;

function [rw_b, rw_e] = find_rewards(i,j, rdot)
rw_b = i-1+uniform(find(rdot(i:j)<0, 1), j-i);
rw_e = uniform(i-1+find(rdot(i:j)>0, 1, 'last'), j);
% if the |r| vector is an inverted U shape (monotoically non-decreasing to 
% some x and then monotoically non-increasing from x+1 onwards, then we
% want to swap rw_b and rw_e. This happens rarely but it's probably when
% then animal decided not to approach the reward well after crossing the
% rewardThreshold radius and turned right around. 5/24/2018
if rw_b > rw_e
	buffer = rw_b;
	rw_b = rw_e - 1; % this is to make sure the reward is at least 3 frames long
	rw_e = buffer;
end