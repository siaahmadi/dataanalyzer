function varargout = p___restrictToBegins(NlxEvents, t, varargin)
% return NaN separated trial path data

events = {NlxEvents.event};

[idxBegin, idxEnd] = findNlxEventBeginsAndCorrespondingEnds(events);

b = cat(1, NlxEvents(idxBegin).timestamp);
e = cat(1, NlxEvents(idxEnd).timestamp);

varargout = cell(1, 1+nargin-2);

[varargout{1}, I, iNaN] = restr(t, b, e, true);

for i = 1:length(varargin)
	varargout{i+1} = varargout{1};
	varargout{i+1}(~iNaN) = varargin{i}(I);
end

varargout{end+1} = I;
varargout{end+1} = events(idxBegin);