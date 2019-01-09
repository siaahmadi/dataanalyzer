function [p, si_ci, spa_ci, sel_ci, sel83_ci] = p___tuningMeasureCI(projectname, x, y, t, s, N_shuffle, prct)

if ~exist('prct', 'var') || isempty(prct)
	prct = 95;
end
if ~exist('N_shuffle', 'var') || isempty(N_shuffle)
	N_shuffle = 100;
end

validateattributes(prct, {'double'}, {'>', 0, '<', 100}, 'p___tuningMeasureCI', 'prct');

dt = mean(diff(t));
tr_begin = t(1) - dt/2;
tr_end = t(end) + dt/2;
fieldInfo.bins = []; % for sel83 -- todo...

distro.si = nan(N_shuffle, 1);
distro.spa = nan(N_shuffle, 1);
distro.sel = nan(N_shuffle, 1);
distro.sel83 = nan(N_shuffle, 1);

[Map, ~, ~, ~, occup] = p___MakeMap(projectname, x, y, t, s);
[si, spa, sel, sel83] = p___computeTuningMeasures(Map, occup, fieldInfo);

for i = 1:N_shuffle
	s_shuffled = shuffle(s, tr_begin, tr_end);
	[Map, ~, ~, ~, occup] = p___MakeMap(projectname, x, y, t, s_shuffled);
	
	[distro.si(i), distro.spa(i), distro.sel(i), distro.sel83(i)] = p___computeTuningMeasures(Map, occup, fieldInfo);
end

prct_low = (100 - prct) / 2;
prct_hi = 100 - prct_low;

si_lower = prctile(distro.si, prct_low);
si_upper = prctile(distro.si, prct_hi);
spa_lower = prctile(distro.spa, prct_low);
spa_upper = prctile(distro.spa, prct_hi);
sel_lower = prctile(distro.sel, prct_low);
sel_upper = prctile(distro.sel, prct_hi);
sel83_lower = prctile(distro.sel83, prct_low);
sel83_upper = prctile(distro.sel83, prct_hi);

si_ci = [si - si_lower, si + si_upper];
spa_ci = [spa - spa_lower, spa + spa_upper];
sel_ci = [sel - sel_lower, sel + sel_upper];
sel83_ci = [sel83 - sel83_lower, sel83 + sel83_upper];

p.si = centile(distro.si, si);
p.spa = centile(distro.spa, spa);
p.sel = centile(distro.sel, sel);
p.sel83 = centile(distro.sel83, sel83);

function shuffled_s = shuffle(s, lower, upper)

tr_duration = upper - lower;

shift = rand(1) * tr_duration;

shuffled_s = s + shift;
shuffled_s(shuffled_s > tr_duration) = shuffled_s(shuffled_s > tr_duration) - tr_duration;

function c = centile(array, q)
nless = sum(array < q);
nequal = sum(array == q);
c = 100 * (nless + 0.5*nequal) / length(array);