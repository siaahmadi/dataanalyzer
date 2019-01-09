function [simp_seq, idx] = simplify_locseq(locseq, lookupdirection_arms, lookupdirection_nodes)

if ~exist('lookupdirection_arms', 'var') || isempty(lookupdirection_arms)
	lookupdirection_arms = 'first';
end
if ~exist('lookupdirection_nodes', 'var') || isempty(lookupdirection_nodes)
	lookupdirection_nodes = 'last';
end

validatestring(lookupdirection_arms, {'first', 'last'});
validatestring(lookupdirection_nodes, {'first', 'last'});

locseq = fixsuccarmseq(locseq);

nodes = ~cellfun(@isempty, regexp(locseq, 'N', 'once'));
nodeseq = locseq(nodes);
nodeseq{end+1} = 'EE'; % indicator for end of seq
nonrepeats = cellfun(@(lag,lead) ~strcmp(lag, lead), nodeseq(1:end-1), nodeseq(2:end));
nonrepeatNodes = nodeseq(nonrepeats);

armseq = cellfun(@namearm, nonrepeatNodes(1:end-1), nonrepeatNodes(2:end), 'un', 0);
armseq = [locseq{1}, armseq(:)']; % first in locseq is always OK and must be included

simp_seq = [armseq(:)'; nonrepeatNodes(:)'];
simp_seq = simp_seq(:);

idx_nodes = lookupnode(simp_seq(2:2:end), locseq);
idx_arms = arrayfun(@(loc,i1,i2) find(loc==translate(locseq(i1+1:i2)), 1, lookupdirection_arms), translate(simp_seq(1:2:end)),[0;idx_nodes(1:end-1)]', idx_nodes') + [0;idx_nodes(1:end-1)]';

idx = sort([idx_arms(:); idx_nodes(:)]);


function lblSeq = fillSeqHole(lblSeq)
idx = strcmpi(lblSeq, '');
idx(1) = false; idx(end) = false; % for the first and last indices we can never be sure what the previous location of the animal has been (unless we look at the videoData)

for i = find(idx(:)')
	lblSeq{i} = ['N', setdiff(intersect(lblSeq{i-1}, lblSeq{i+1}), 'A')];
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

function idx = lookupnode(simp_seq, locseq)
direction = 'last';
armOrNode = 'N';

idxOfInterest = find(~cellfun(@isempty, regexp(locseq, armOrNode, 'match')));

if strcmpi(direction, 'last')
	idx = idxOfInterest(regexp(translate(locseq(idxOfInterest)), ['(?<node>[' unique(translate(simp_seq)) '])(?!\k<node>)']));
else
	idx = idxOfInterest(regexp(translate(locseq(idxOfInterest)), ['(?<node>[' unique(translate(simp_seq)) '])(?!\k<node>)'])) + idxOfInterest(2) - 1;
	idx(end) = [];
	idx = [ismember(translate(locseq(idxOfInterest(1))), unique(translate(simp_seq))), idx];
end

function armName = namearm(nodeBehind, nodeForward)

nodeNumber(1)= str2double(regexp(nodeBehind, '\d{1}', 'match', 'once'));
nodeNumber(2) = str2double(regexp(nodeForward, '\d{1}', 'match', 'once'));

armName = ['A', num2str(min(nodeNumber)), num2str(max(nodeNumber))];

function locseq = fixsuccarmseq(locseq)
% put a node in between two successive arms

succArms = cellfun(@(lag,lead) ~isempty(regexp(lag, 'A', 'once')) && strcmp(regexp(lag, 'A', 'match', 'once'), regexp(lead, 'A', 'match', 'once')), locseq(1:end-1), locseq(2:end));
succArms = [false; succArms];

fixedseq = repmat({''}, length(locseq)+sum(succArms), 1);
succArms = num2logical(find(succArms), length(fixedseq));
fixedseq(~succArms) = locseq;
fixedseq = fillSeqHole(fixedseq);

locseq = fixedseq;
