function evnt = loadSessionNlxEvents(obj)

if strcmp(obj.trialDirs(1).name, '.')
	evnt = loadFromSession(obj);
else
	evnt = loadFromTrial(obj);
end

obj.NlxEvents = evnt;

function evnt = loadFromSession(obj)

[TimeStamps, EventStrings] = Nlx2MatEV(fullfile(obj.fullPath, 'Events_fixed.nev'), [1 0 0 0 1 0], 0, 1, 1);
TimeStamps = TimeStamps * 1e-6;


obj.beginTS = TimeStamps(1);
obj.endTS = TimeStamps(end);

nlxEvents = cellfun(@(str,ts) struct('event', str, 'timestamp', ts), EventStrings(:), num2cell(TimeStamps(:)), 'un', 0);

evnt = cat(1, nlxEvents{:});

function evnt = loadFromTrial(obj)

[TimeStamps, EventStrings] = arrayfun(@(tr) Nlx2MatEV(fullfile(obj.fullPath, tr.name, 'Events_fixed.nev'), [1 0 0 0 1 0], 0, 1, 1), obj.trialDirs, 'un', 0);
EventStrings = cellfun(@(ev) ev(:), EventStrings, 'un', 0);
TimeStamps = cellfun(@(ts) ts(:) * 1e-6, TimeStamps, 'un', 0);


obj.beginTS = cellfun(@(ts) ts(1), TimeStamps);
obj.endTS = cellfun(@(ts) ts(end), TimeStamps);

EventStrings = cat(1, EventStrings{:});
TimeStamps = cat(1, TimeStamps{:});

nlxEvents = cellfun(@(str,ts) struct('event', str, 'timestamp', ts), EventStrings(:), num2cell(TimeStamps(:)), 'un', 0);

evnt = cat(1, nlxEvents{:});