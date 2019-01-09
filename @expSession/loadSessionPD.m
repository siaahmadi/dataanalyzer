function obj = loadSessionPD(obj)

positionData = dataanalyzer.positiondata.createEnvPD(obj.spatialEnvironment, obj);

positionData.load(obj.fullPath, 'pathdata.mat', obj);
% parsedData = load(fullfile(obj.fullPath, 'parseinfo_all.mat'));
% positionData.loadParsedData(parsedData);

% options = dataanalyzer.options('phaprecTakuya');
% positionData = p___parse(positionData, options);

obj.positionData = positionData;

function varargout = p___restrictToBegins(NlxEvents, t, varargin)
% return NaN separated trial path data

events = {NlxEvents.event};

[idxBegin, idxEnd] = findNlxEventBeginsAndCorrespondingEnds(events);

b = cat(1, NlxEvents(idxBegin).timestamp);
e = cat(1, NlxEvents(idxEnd).timestamp);

begins = ivlset(b, e);
idx = begins.restrict(t);

varargout = cell(1, 1+nargin-2);

varargout{1} = cellfun(@(i) cat(1, t(i), NaN), idx, 'un', 0);
varargout{1} = cat(1, varargout{1}{:});
for i = 1:length(varargin)
	varargout{i+1} = cellfun(@(j) cat(1, varargin{i}(j), NaN), idx, 'un', 0);
	varargout{i+1} = cat(1, varargout{i+1}{:});
end

varargout{end+1} = sum(cat(2, idx{:}), 2) > 0;
varargout{end+1} = events(idxBegin);

function positionData = p___parse(positionData, options)

x = positionData.getX('unrestr');
y = positionData.getY('unrestr');
t = positionData.getTS('unrestr');
[t, x, y, beginsGlobalIdx, trNameStrings] = p___restrictToBegins(dataanalyzer.ancestor(positionData).NlxEvents, t, x, y);

options.trNameStrings = trNameStrings(:);
parsedData = dataanalyzer.rad8pd.parse(t, x, y, options);

positionData.loadParsedData(parsedData);