function trialInfo = trialsFromLoc(locInfo)
% Using the new definition of a trial in the Figure 8 maze paradigm to mark
% the start and end of trials in each recorded experimental Block.
%
% Additional information regarding the trial is extracted, such as
% start/end time stamps, indices, direction, success, and degeneracy of
% each trial.

% Siavash Ahmadi
% 2/4/2016

trialInfo = struct([]);

nSessions = length(locInfo);
for path = 1:nSessions
    locInds = locInfo(path).inds;
    locInts = locInfo(path).tInt;
    locLabels = locInfo(path).labelSeq;
    nLocs = size(locInds,1);
    labelSeq = fixsuccarmseq(fillSeqHole(locInfo(path).labelSeq));
	
	t_lbl = translate(labelSeq);
	
	[direction, start_loc, end_loc] = extractdirection(t_lbl);
	degen = extractdegenerate(t_lbl, start_loc, end_loc);
	
    degenIDs = find(degen);
    nTrials = length(direction);
    trialNums = (1:nTrials)';
    trialInfo(path,1).trial = trialNums;
    trialInfo(path,1).inds = arrayfun(@(s,e) locInds(s:e, :)', start_loc(:), end_loc(:), 'un', 0);
    trialInfo(path,1).tInt = arrayfun(@(s,e) locInts(s:e, :)', start_loc(:), end_loc(:), 'un', 0);
    trialInfo(path,1).loc = arrayfun(@(s,e) labelSeq(s:e, :), start_loc(:), end_loc(:), 'un', 0);
    trialInfo(path,1).degenInds = cell2mat(arrayfun(@(s,e) [locInds(s, 1), locInds(e, 2)], start_loc(degen)', end_loc(degen)', 'un', 0));
    trialInfo(path,1).direction = direction(:);
    trialInfo(path,1).success = trial_success(direction, t_lbl, start_loc);
    trialInfo(path,1).degen = degen(:);
    trialInfo(path,1).degenIDs = degenIDs;
    trialInfo(path,1).mazeType = locInfo(path).mazeType;
	
	[trialInfo(path,1).simp_loc, trialInfo(path,1).simp_ind] = cellfun(@simplify_locseq2, trialInfo(path,1).loc, 'un', 0);
	trialInfo(path,1).simp_tInt = cellfun(@accFunc_tInt, trialInfo(path,1).tInt, trialInfo(path,1).simp_ind, 'un', 0);
end

end


function lblseq = translate(lblseq)

lblseq(cellfun(@isempty, lblseq)) = repmat({' '}, sum(cellfun(@isempty, lblseq)), 1);
lblseq = strrep(lblseq, ' ', 'Z');

lexicon.N1 = 'B';
lexicon.N2 = 'D';
lexicon.N3 = 'J';
lexicon.N4 = 'H';
lexicon.N5 = 'F';
lexicon.N6 = 'M';
lexicon.A16 = 'A';
lexicon.A12 = 'C';
lexicon.A23 = 'K';
lexicon.A25 = 'E';
lexicon.A34 = 'I';
lexicon.A45 = 'G';
lexicon.A56 = 'L';
lexicon.Z = '';

lblseq = cellfun(@(lbl) lexicon.(lbl), lblseq, 'un', 0);

lblseq = cat(2, lblseq{:});

end

function [direction, start_ind, end_ind] = extractdirection(t_lbl)

trial_start_postleft = regexp(t_lbl, 'MAB')+1;
trial_start_postright = regexp(t_lbl, 'HIJ')+1;

if isempty(trial_start_postleft) && isempty(trial_start_postright)
	direction = {'L'};
	start_ind = 1;
	end_ind = length(t_lbl);
	return;
end

[start_ind, I] = sort([trial_start_postleft, trial_start_postright]);
rightIdx = circshift(I > length(trial_start_postleft), -1, 2);

end_ind = start_ind(2:end) - 1;
lastTurn{1} = regexp(t_lbl(start_ind(end):end), 'M')+start_ind(end)-1;
lastTurn{2} = regexp(t_lbl(start_ind(end):end), 'H')+start_ind(end)-1;
if isempty(lastTurn{1})
	rightIdx(end) = ~isempty(lastTurn{2});
	if ~isempty(lastTurn{2})
		end_ind(end+1) = max(lastTurn{2});
	else
		end_ind(end+1) = length(t_lbl);
	end
elseif isempty(lastTurn{2})
	rightIdx(end) = isempty(lastTurn{1});
	if ~isempty(lastTurn{1})
		end_ind(end+1) = max(lastTurn{1});
	else
		end_ind(end+1) = length(t_lbl);
	end
elseif ~isempty(lastTurn{1}) && ~isempty(lastTurn{2})
	% here the animal has visited both reward locations (N4 ('H') & N6
	% ('M')). It should be decided whether the first or the last visit to a
	% reward location should determine the direction of trial (currently:
	% first visit).
	rightIdx(end) = lastTurn{2}(1) < lastTurn{1}(1);
	if rightIdx(end)
		end_ind(end+1) = max(lastTurn{2});
	else
		end_ind(end+1) = max(lastTurn{1});
	end
else
	% pass -- degenerate case
	end_ind(end+1) = length(t_lbl);
end

direction = repmat('L', 1, length(rightIdx));
direction(rightIdx) = 'R';
direction = num2cell(direction);
end

function degenerate = extractdegenerate(t_lbl, start_loc, end_loc)
% DEF: The rat made a roundabout to reward (didn't go through stem)
% JIH or BIM: following a non-degerate trial (starting from reward
% location), the rat ran to a point and BACK to a reward location withouth
% going through the CHOICE_POINT --> BASE_ARM --> REWARD_LOCATION

degenerate = arrayfun(@(s,e) isempty(regexp(t_lbl(s:e), 'DEF', 'once')) || ~isempty(regexp(t_lbl(s:e), '(JIH)|(BIM)', 'once')), start_loc, end_loc);

end

function s = trial_success(direction, t_lbl, start_ind)
dirs = [direction{:}];
lexicon.M = 'L';
lexicon.H = 'R';

s = regexp(dirs, '(?<=R)L|(?<=L)R');
s = num2logical(s, length(direction));
lastTurnBeforeStart = regexp(fliplr(t_lbl(1:start_ind(1))), 'M|H', 'match', 'once');
if isempty(lastTurnBeforeStart)
	if direction{1} == 'L'
		lastTurnBeforeStart = 'M';
	else
		lastTurnBeforeStart = 'H';
	end
end
s(1) = ~strcmp(lexicon.(lastTurnBeforeStart), dirs(1));
s = s(:);
end

function ti = accFunc_tInt(t,i)

try
	ti = t(:, i);
catch
	ti = t;
end

end