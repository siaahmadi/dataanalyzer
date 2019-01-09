function update(obj, refPD, refMask, refNeuron, mapOpt)
%UPDATE Update placemap object with most current position data and mask(s)

obj.set('pd', refPD, 'mask', refMask, 'neuron', refNeuron, 'opt', mapOpt);

S = obj.RefNeuron.getTS('unrestr');
if isa(obj.RefMask, 'dataanalyzer.mask') % if a valid mask provided, it will be applied,
	T = obj.RefPD.getTS('unrestr');
	X = obj.RefPD.getX('unrestr');
	Y = obj.RefPD.getY('unrestr');
	
	[idx, t, x, y] = obj.RefMask.apply(T, T, X, Y); %#ok<ASGLU>
	[~, s] = obj.RefMask.apply(S, S);
	refMask = obj.RefMask;
else % otherwise, refPD's masks will be applied
	t = obj.RefPD.getTS('restr');
	x = obj.RefPD.getX('restr');
	y = obj.RefPD.getY('restr');
	s = S;
	refMask = obj.RefPD.Mask;
end


[Map, binRangeX, binRangeY, occup, ~, gaussFit] = obj.MakeMap(dataanalyzer.projectname(obj), x,y,t,s,ivlset(refMask.mask2ivl), obj.mapOpt);

obj.RMap.map = Map;
obj.RMap.x = binRangeX;
obj.RMap.y = binRangeY;
obj.RMap.occup = occup;
obj.RMap.gfit = gaussFit;

fieldInfo = dataanalyzer.makePlaceMaps.extractpf(dataanalyzer.projectname(obj), Map, binRangeX, binRangeY);
[fieldInfo.dim] = deal(obj.Dim);

Fields = arrayfun(@(fi) dataanalyzer.placefield(obj, refMask, Map, fi), fieldInfo, 'UniformOutput', false);
obj.PFields = cat(1, Fields{:});
if numel(obj.PFields) == 1 && obj.PFields.isempty() % this will cause this placemap to have a 0x1 placefield object in its PFields field which is more intuitive than having a 1x1 "empty" placefield object
	obj.PFields = repmat(obj.PFields, 0, 1);
end

obj.SpatialTuningMeasures = p___computeTuningMeasures(Map, occup, fieldInfo);
% p_tuning = p___tuningMeasureCI(dataanalyzer.projectname(obj), X, Y, T, S);
p_tuning = 'set in placemap.update@line:28';
obj.SpatialTuningMeasures.pvalues = p_tuning;

% Update mazerun passes of each PF (THIS MUST BE DONE RIGHT
% HERE AS THIS IS WHERE ALL PLACEFIELDS HAVE BEEN CONSTRUCTED
% AND UPDATING THE PASSES' DYNAMIC PROPERTIES (E.G. DISTANCE
% FROM FIELDS) MAKES SENSE):
% Updating mazerun now happens inside @mazerun at construction
% arrayfun(@accFunc_updateFieldPasses, obj.PFields); % for each PField, for each cXX contour in dynProps of PField, for each pass in dynProps.cXX

function accFunc_updateFieldPasses(pfield)
passesPerContour = structfun(@(contour) contour.passes, pfield.dynProps, 'un', 0); % allPasses struct of passes per each contour
contours = fieldnames(pfield.dynProps);
for contourInd = 1:length(contours)
	arrayfun(@(pass) pass.update, passesPerContour.(contours{contourInd}));
end