function [tr, tr_beginIdx] = getTrials(obj, whichTrials)
%getTrials Access session's trials by name
%
% Recommended over accessing them through expSession.trials{i} as the
% ordering in trials is not guaranteed to follow a certain convention.
%
% SYNTAX:
%	[tr, tr_beginIdx] = getTrials(obj, whichTrials)
% 
%	|whichTrials| can be a cell array of strings containing the namestrings
%	of desired trials. Ordering will be preserved in output.
%
%	|whichTrials| can be a single string as well.
%
%	|whichTrials| can be a numeric array as well in which case the ordering
%	will follow expSession.trials (SYNTAX NOT RECOMMENDED).

% Siavash Ahmadi
% 11/10/2015

tr = obj.trials;
tr_beginIdx = obj.isBeginTrial;

if nargin > 1
	wtIdx = obj.selectTrials(whichTrials);

	tr = tr(wtIdx);
	if (length(wtIdx) > 1 && sum(wtIdx) == 1) || length(wtIdx) == 1 % only one trial matches |whichTrials|
		tr = tr{1}; % pull it out of cell
	end
	tr_beginIdx = tr_beginIdx(wtIdx);
end

if iscell(tr) && all(tr_beginIdx) || all(~tr_beginIdx) % all of same type, begin or sleep
	tr = cat(1, tr{:});
end