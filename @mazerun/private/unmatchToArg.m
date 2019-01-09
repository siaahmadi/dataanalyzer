function args = unmatchToArg(unmatched)

fn = fieldnames(unmatched);
unmatchedVals = cell(size(fn));
for i = 1:length(fn)
	unmatchedVals{i} = unmatched.(fn{i});
end

args = cell(1, length(fn)*2);
args(1:2:end) = fn(:);
args(2:2:end) = unmatchedVals;