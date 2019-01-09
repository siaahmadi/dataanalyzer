function p___setTs(obj, refIdx, refTS, trueIvl)

% I think refIdx is unnecessary as it can be made using refTS and trueIvl
% but fromIdx is using it. TBD if this is truly required.

trueIvl = trueIvl.collapse('|');
refIdx = p___restrict(refTS, trueIvl);
obj.tIdx = sum([refIdx{:}], 2) > 0; % OR-ing the interval specific logical rafts
obj.tSeq = cellfun(@(x) refTS(x), refIdx, 'UniformOutput', false);

obj.tEffectiveIvls = trueIvl;
obj.tIntervals = cellfun(@(x) [refTS(find(x, 1)), refTS(find(x, 1, 'last'))], refIdx, 'UniformOutput', false);