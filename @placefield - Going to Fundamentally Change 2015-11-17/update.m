function update(obj, parentNeuron, sessionRateMap, trialRateMap, sessionwideFieldbins, sessionwideBoundaries, binRangeX, binRangeY)
% session-wide boundaries should be constructed and fed into this method.
% trial-wise boundaries can be calculated right here, so no need for them
% being supplied

if nargin > 1
	obj.parent = parentNeuron;
	
	obj.binRangeX = binRangeX;
	obj.binRangeY = binRangeY;
	
	obj.stuffToDraw.summedRateMapOverAllTrials = sessionRateMap; % least important
	% TODO: add constrained sessionwide maps to obj.stuffToDraw.session.constrained
	
	obj.stuffToDraw.session.unconstrained.fieldBins = sessionwideFieldbins.unconstrained;
	obj.stuffToDraw.session.unconstrained.boundaryStruct = sessionwideBoundaries.unconstrained;
	obj.stuffToDraw.session.constrained.fieldBins = sessionwideFieldbins.constrained;
	obj.stuffToDraw.session.constrained.boundaryStruct = sessionwideBoundaries.constrained;
% 	obj.stuffToDraw.session.binRangeX = obj.binRangeX;
% 	obj.stuffToDraw.session.binRangeY = obj.binRangeY;
	
	buffer = parentNeuron.getPlaceMap();
	obj.stuffToDraw.trial.constrained = buffer.constrained;
	buffer = rmfield(buffer, 'constrained');
	obj.stuffToDraw.trial.unconstrained = buffer;
end

obj.fieldInfo.session.unconstrained = obj.cprops(obj.stuffToDraw.trial.unconstrained.rateMap, ...
	obj.stuffToDraw.session.unconstrained.fieldBins, ...
	obj.stuffToDraw.session.unconstrained.boundaryStruct, ...
	obj.binRangeX, obj.binRangeY);
% the constrained versions:
allCstr = obj.parent.parentTrial.parentSession.getOptions('UpdatePlaceFields').constraints;
for cstrnInd = 1:length(obj.stuffToDraw.session.constrained.boundaryStruct) % the number of constraints
	if isempty(obj.stuffToDraw.session.constrained.boundaryStruct{cstrnInd}) % if, given the constraint, no field was detected this would be true
		% create an empty struct with the same fields and set
		obj.fieldInfo.session.constrained(cstrnInd).constraintName = obj.stuffToDraw.trial.constrained(cstrnInd).constraintName;
	else
		buffer = obj.cprops(obj.stuffToDraw.trial.constrained(cstrnInd).rateMap, ...
			obj.stuffToDraw.session.constrained.fieldBins{cstrnInd}, ...
			obj.stuffToDraw.session.constrained.boundaryStruct{cstrnInd}, ...
			obj.binRangeX, obj.binRangeY, allCstr(cstrnInd));
		buffer = arrayfun(@(x) setfield(x, 'constraintName', obj.stuffToDraw.trial.constrained(cstrnInd).constraintName), buffer); %#ok<SFLD>
		if length(buffer) > 1
			1; % make sure the case where a condition has more than one field is handled properly
		end
		obj.fieldInfo.session.constrained = augmentStructFields(buffer, obj.fieldInfo.session.constrained);
		obj.fieldInfo.session.constrained = [obj.fieldInfo.session.constrained;buffer(:)];
	end
end

% Extract fields of the trial (not sessionwide ones which have already been
% computed and supplied to this method) for both the constained and the
% unconstrained versions of the trial:
[trialspecificFieldbins, trialspecificBoundaries] = dataanalyzer.makePlaceMaps.extractpf(obj.stuffToDraw.trial.unconstrained.rateMap, obj.binRangeX, obj.binRangeY);
obj.fieldInfo.trial.unconstrained = obj.cprops(obj.stuffToDraw.trial.unconstrained.rateMap, ...
	trialspecificFieldbins, trialspecificBoundaries, obj.binRangeX, obj.binRangeY);
obj.stuffToDraw.trial.unconstrained.fieldBins = trialspecificFieldbins;
obj.stuffToDraw.trial.unconstrained.boundaryStruct = trialspecificBoundaries;
for cstrnInd = 1:length(obj.stuffToDraw.trial.constrained)
	[trialspecificFieldbins, trialspecificBoundaries] = ...
		dataanalyzer.makePlaceMaps.extractpf(...
		obj.stuffToDraw.trial.constrained(cstrnInd).rateMap, obj.binRangeX, obj.binRangeY);
	obj.stuffToDraw.trial.constrained(cstrnInd).fieldBins = trialspecificFieldbins;
	obj.stuffToDraw.trial.constrained(cstrnInd).boundaryStruct = trialspecificBoundaries;
	if isempty(trialspecificFieldbins)
		obj.fieldInfo.trial.constrained(cstrnInd).constraintName = obj.stuffToDraw.trial.constrained(cstrnInd).constraintName;
	else
		buffer = obj.cprops(obj.stuffToDraw.trial.constrained(cstrnInd).rateMap, ...
			obj.stuffToDraw.trial.constrained(cstrnInd).fieldBins, ...
			obj.stuffToDraw.trial.constrained(cstrnInd).boundaryStruct, ...
			obj.binRangeX, obj.binRangeY, allCstr(cstrnInd));
		buffer = arrayfun(@(x) setfield(x, 'constraintName', obj.stuffToDraw.trial.constrained(cstrnInd).constraintName), buffer); %#ok<SFLD>
		obj.fieldInfo.trial.constrained = augmentStructFields(buffer, obj.fieldInfo.trial.constrained);
		obj.fieldInfo.trial.constrained = [obj.fieldInfo.trial.constrained;buffer(:)];
	end
end

obj.Parent = obj.parent;

function smallStruct = augmentStructFields(bigStruct, smallStruct)
if isempty(smallStruct)
% 	smallStruct = bigStruct;
	return
end
fnamesOld = fieldnames(smallStruct);
fnamesBuffer = fieldnames(bigStruct);
if numel(fnamesOld) == numel(fnamesBuffer)
	return
end
if numel(bigStruct) ~= 1
	1; % make sure if the number of structs is not 1 the case is handled properly
end
x = setdiff(fnamesBuffer,fnamesOld, 'stable');
for xxx = 1:length(smallStruct)
	for xx = 1:length(x)
		smallStruct(xxx).(x{xx}) = [];
	end
end