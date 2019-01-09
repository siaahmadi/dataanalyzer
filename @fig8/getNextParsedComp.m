function [x, y, t, idx] = getNextParsedComp(obj, whatToGet)

persistent currInd

if isempty(currInd) || isempty(currInd.(whatToGet))
	currInd.(whatToGet) = 1;
else
	currInd.(whatToGet) = currInd.(whatToGet) + 1;
end

[x, y, t, idx] = obj.getParsedComp(whatToGet, currInd.(whatToGet));

if currInd.(whatToGet) == obj.getNumParsedComp(whatToGet)
	warning('DataAnazlyer:PositionData:ParsedComponents:QueueReachedLast', 'Reached last. Resetting to index 1.');
	currInd.(whatToGet) = 0;
end