function idx = p___findRangeForTimeable(t, ts)

[b, e] = t.toIvl;
b = interp1(ts, 1:length(ts), b, 'nearest');
e = interp1(ts, 1:length(ts), e, 'nearest');
idx = arrayfun(@(b,e) sparse(b:e, 1, 1, length(ts), 1), b, e, 'un', 0);
idx = full(sum(cat(2, idx{:}), 2) > 0);