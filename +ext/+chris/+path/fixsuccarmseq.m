function [locseq, succArms] = fixsuccarmseq(locseq)
% put a node in between two successive arms

succArms = cellfun(@(lag,lead) ~isempty(regexp(lag, 'A', 'once')) && strcmp(regexp(lag, 'A', 'match', 'once'), regexp(lead, 'A', 'match', 'once')), locseq(1:end-1), locseq(2:end));
succArms = [false; succArms];

fixedseq = repmat({''}, length(locseq)+sum(succArms), 1);
succArms = num2logical(find(succArms), length(fixedseq));
fixedseq(~succArms) = locseq;
fixedseq = fillSeqHole(fixedseq);

locseq = fixedseq;