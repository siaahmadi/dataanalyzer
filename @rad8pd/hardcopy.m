function hc = hardcopy(obj)

x = obj.getX('unrestr');
y = obj.getY('unrestr');
t = obj.getTS('unrestr');
v = obj.getVelocity('unrestr');
try
	runs = obj.getRun([], []);
catch err
	if strcmp(err.identifier, 'DataAnalyzer:PositionData:ParsedComponents:NoPCsFound')
		runs = [];
	end
end

[b, e]  = cellfun(@(tr) deal(tr.beginTS, tr.endTS), obj.Parent.trials);
[b, I] = sort(b);
e = e(I);
trialnames = cellfun(@(tr) tr.namestring, obj.Parent.trials, 'un', 0);
trialnames = trialnames(I);
trialno = str2double(strrep(strrep(trialnames, 'begin', ''), 'sleep', '-'));

tridx = arrayfun(@(tridx, b, e) tridx*double(b<= t & t <= e), trialno, b, e, 'un', 0);
tridx = sum(cat(1, tridx{:}));

maskidx = arrayfun(@(m) m.mask2idx, obj.Parent.Mask.List, 'un', 0);

hc = struct('x', x(:), 'y', y(:), 't', t(:), 'v', v(:), 'mask', maskidx, 'runs', runs, 'trials', tridx(:));