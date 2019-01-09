function [comps, x, y, t, idx] = getParsedComp(obj, whatToGet, N, superCompNum)

numPComp = obj.getNumParsedComp(whatToGet);

if numPComp == 0
	error('DataAnalyzer:PositionData:ParsedComponents:NoPCsFound', 'The requested PC is empty. Please check Parser.');
end

if ~exist('superCompNum', 'var') || isempty(superCompNum)
	superCompNum = 1:length(numPComp);
end
numPComp = numPComp(superCompNum);
if ~exist('N', 'var') || isempty(N)
	N = arrayfun(@(npc) 1:npc, numPComp, 'un', 0);
elseif ~iscell(N)
	N = num2cell(N);
end

if length(numPComp) ~= length(N)
	error('DataAnalyzer:PositionData:ParsedComponents:MismatchedIndices', 'The number of super components requested (superCompNum) does not match the number of indices provided (N).');
end

if any(cellfun(@(n) any(mod(n, 1)), N)) || ...
		any(cellfun(@(n) any(n(:) < 1), N)) || ...
		any(cellfun(@(n,npc) any(n(:) > npc), N, num2cell(numPComp))) % non-integer, less than 1, more than numPComp are invalid indices
	if numPComp == 1
		validNs = '1';
	elseif numPComp == 2
		validNs = '[1, 2]';
	else
		validNs = ['[1,...,', num2str(numPComp), ']'];
	end
	
	error('DataAnalyzer:PositionData:ParsedComponents:InvalidNumberRequested', ['Please enter a valid N. N = ' validNs ' for the requested Parsed Component.'])
end

x = cellfun(@(pc,n) {pc.(whatToGet)(n).x}', num2cell(obj.parsedComponents(superCompNum)), N, 'un', 0);
y = cellfun(@(pc,n) {pc.(whatToGet)(n).y}', num2cell(obj.parsedComponents(superCompNum)), N, 'un', 0);
t = cellfun(@(pc,n) {pc.(whatToGet)(n).ts}', num2cell(obj.parsedComponents(superCompNum)), N, 'un', 0);
idx = cellfun(@(pc,n) {pc.(whatToGet)(n).idx_global}', num2cell(obj.parsedComponents(superCompNum)), N, 'un', 0);
trials = {obj.parsedComponents(superCompNum).trial}';

comps = cellfun(@(tr,x,y,t,i) struct('trial', tr, 'run', struct('x', x, 'y', y, 't', t, 'idx', i)), trials, x, y, t, idx, 'un', 0);
comps = cat(1, comps{:});

if nargout < 2
	warning('DataAnalyzer:PositionData:ParsedComponents:MoreOutputArgsAvailable', 'The output is only the X coordinate. Provide more output arguments to capture the Y coordinate, timestamps, and indices.');
elseif nargout < 3
	warning('DataAnalyzer:PositionData:ParsedComponents:MoreOutputArgsAvailable', 'The output is only the X and Y coordinate. Provide more output arguments to capture the timestamps and indices.');
elseif nargout < 4
	warning('DataAnalyzer:PositionData:ParsedComponents:MoreOutputArgsAvailable', 'Provide a fourth output argument to capture the indices.');
end