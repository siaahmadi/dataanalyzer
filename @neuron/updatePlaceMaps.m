function pm = updatePlaceMaps(obj, varargin)

% Siavash Ahmadi
% 4/6/2015 9:16 PM
% 11/17/2015 5:34 PM

% Name changed from @updatePlaceFields to @updatePlaceMaps 11/18/2015

% First get the neuron objects across all begintrials of the parent trial's
% parent, then compute their respective rateMaps. Next, combine (sum) these
% rate maps to obtain a session map, extractpf(sessionMap), and finally
% update each placefield object of the respective neurons with the computed
% boundaries.

if obj.isOrphan()
	error('Cannot compute place fields without a parent trial')
end

% if ~obj.istidy()
% 	obj.update();
% end

if nargin == 0
	fprintf(2, '\nUpdating %s''s maps for all current Masks.\n\n', obj.namestring);
else
	msgLayout = ['\nAttempting to update %s''s map' ...
		repmat('s', 1, nargin-2) ' for Mask' repmat('s', 1, nargin-2) ...
		' ' repmat('"%s", ', 1, nargin-2) repmat('and ', 1, double(nargin-2>0)) '"%s".\n\n'];
	masknames = char(cat(1, varargin{:}));
	if iscell(masknames)
		fprintf(2, msgLayout, obj.namestring, masknames{:});
	else
		fprintf(2, msgLayout, obj.namestring, masknames);
	end
end
mapOpt = dataanalyzer.constant('makeMap2D');
obj.placeMaps = dataanalyzer.placemaparray(obj, mapOpt, varargin{:}); % will generate one placemap for each Mask
obj.placeMaps.namestring = 'original';

warning('The following line needs to be moved out of this function.');
mapOpt = dataanalyzer.constant('makeMapLinear');

% Compute alternate maps:
if ~isempty(obj.Parent.positionData.addonPD)
	alternativePlaceMaps = dataanalyzer.placemaparray(obj, mapOpt, obj.Parent.positionData.addonPD{:}, varargin{:});
	% Set each alternate map's label:
	alternatePdLabels = cellfun(@(pd) pd.namestring, obj.Parent.positionData.addonPD, 'un', 0);
	cellfun(@(pm,lbl) setMapLabels(pm,lbl), num2cell(alternativePlaceMaps), alternatePdLabels);

	% Add the alternate maps to the neuron's map array
	% Keep in mind that each maparray could contain multiple placemaps due to
	% the masks; each placemaparray is due to a set of position data
	obj.placeMaps = [obj.placeMaps; alternativePlaceMaps];
end

if nargin == 1
	obj.peakFiringRate = max(obj.placeMaps.Maps(1).RMap.map(:));
	fprintf(2, '\nDone updating all of %s''s maps.\n\n', obj.namestring);
else
	fprintf(2, '\nDone updating %s''s maps under the requested Masks.\n\n', obj.namestring);
end

pm = obj.placeMaps;

% tr = obj.parentTrial.parentSession.getBeginTrials();
% thisNeuronAcrossTrials = cell(length(tr), 1);
% 
% for i = 1:length(tr)
% 	thisNeuronAcrossTrials(i) = tr{i}.getNeurons(obj.namestring);
% 	if ~isempty(thisNeuronAcrossTrials(i))		
% 		thisNeuronAcrossTrials{i}.computeTrialMaps();
% 	end
% end


% sessionMap = sum(cell2mat(permute(trialWiseMaps, [2 3 1])), 3);
% 
% [fieldBins.unconstrained, boundaryStruct.unconstrained] = dataanalyzer.makePlaceMaps.extractpfSession(trialWiseMaps, binRangeX, binRangeY);
% allConstrainedRateMaps =cat(2,constrainedRateMaps{:});
% for i = 1:length(constraints)
% 	currConstraintRateMap = {allConstrainedRateMaps(i:length(constraints):end).rateMap}';
% 	[fieldBins.constrained{i}, boundaryStruct.constrained{i}] = dataanalyzer.makePlaceMaps.extractpfSession(currConstraintRateMap, binRangeX, binRangeY);
% end
% 
% % dataanalyzer.neuron.setPlaceFields can set the trialwise placefields
% % itself (because computeTrialWisePlaceMap stores these in the neuron
% % object's placefield child), but I have to supply it with the sessionwide
% % map over here:
% for i = 1:length(tr)
% 	if ~isempty(thisNeuronAcrossTrials{i})
% 		thisNeuronAcrossTrials{i}.setPlaceFields(sessionMap, fieldBins, boundaryStruct, binRangeX, binRangeY); % I'm assuming binRangeX and binRangeY are the same for all trials
% 	end
% end
% 
% pf = obj.placeFields;
% 
% if ~isempty(varargin)
% 	if isa(varargin{1}, 'dataanalyzer.meta.placefieldarray')
% 		
% 	else
% 	end
% end


function setMapLabels(alternativePlaceMaps, alternatePdLabels)
alternativePlaceMaps.namestring = alternatePdLabels;