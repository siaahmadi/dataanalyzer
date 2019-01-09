function mask = createMaskFromParsedComponents(obj, useParsedComponents)
%CREATEMASKFROMPARSEDCOMPONENTS Create a mask object from select parsed
%components
%
% mask = CREATEMASKFROMPARSEDCOMPONENTS(obj, useParsedComponents)
% 
% useParsedComponents
%                     is an array of structs with fields "toUse" and
% "label". The "toUse" label must be a cell array A of cell arrays
% B_1,...,B_N. Each cell array B_i is a list of parsed components
% P_i^(1),...,P_i^(j). These will be OR-ed to produce composite
% components C_i.
% The final mask will be the logical AND of the C_i's.
% Example: A = {{'left'}; {'return', 'delay', 'stem', 'prereward'}};
%           In this example, B_1 = {'left'},
%           and B_2 = {'return', 'delay', 'stem', 'prereward'}
%           P_1^(1) = 'left'
%           P_2^(1) = 'return'
%           P_2^(2) = 'delay'
%           P_2^(3) = 'stem'
%           P_2^(4) = 'prereward'
%
% mask   will be an array of mask objects with length
%        numel(useParsedComponents)

pc = obj.parsedComponents;

if isempty(pc)
	error('No parsed components available. Parse the position data object first.');
end
if ~isvalidcompreq(useParsedComponents)
	error('useParsedComponents (%s) is not in expected format. It must be an array of structs with fields "toUse" and "label".', inputname(2));
end
useParsedComponents = useParsedComponents(:);

reqComp = cat(1, useParsedComponents.toUse);
if ~all(cellfun(@(comp) isavailable(comp, pc), reqComp))
	error('Some requested components are not available as parsed components of the reference positiondata object.');
end

idx = arrayfun(@(use) calculateIdxOfSelectedComponents(pc, use), useParsedComponents, 'un', 0);

t = obj.getTS('unrestr');
selectedperiods = cellfun(@(idx) t(lau.raftidx(idx)), idx, 'un', 0);
selectedperiods = cellfun(@(selectedperiods) ivlset(selectedperiods(1:2:end), selectedperiods(2:2:end)), selectedperiods, 'un', 0);
mask = cellfun(@(period, use) dataanalyzer.mask(period, obj, use.label), selectedperiods, num2cell(useParsedComponents), 'un', 0);
mask = cat(1, mask{:});


function idx = calculateIdxOfSelectedComponents(pc, usePC)

pc = structcat(pc);

fn = fieldnames(pc);

idx = repmat({false(size(pc.(fn{1})))}, size(usePC.toUse));

for i = 1:length(idx)
	for j = 1:length(usePC.toUse{i})
		idx{i} = idx{i} | pc.(usePC.toUse{i}{j}); % OR each useParsedComponents entries
	end
end

idx = prod(cat(2, idx{:}), 2) > 0; % & all idx entries

function pc = structcat(pc)

pc = ezstruct(fieldnames(pc), cellfun(@(col) cat(1, col{:}), row2cell(struct2cell(pc)), 'un', 0)); % concatenate the fields of pc

function I = isavailable(comp, pc)
availableComps = fieldnames(pc);
I = all(ismember(comp, availableComps));

function I = isvalidcompreq(useParsedComponents)
I = all(ismember({'toUse', 'label'}, fieldnames(useParsedComponents)));