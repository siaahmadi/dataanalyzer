% To structify the passes of the field

function hc = hardcopy(obj)

if numel(obj) == 0
	hc = [];
	return;
end

contours = fieldnames([obj.dynProps]);
nFields = numel(obj);

for iF = 1:nFields
	for cInd = 1:length(contours)
		hc(iF).(contours{cInd}).area = obj(iF).dynProps.(contours{cInd}).area;
		hc(iF).(contours{cInd}).avgVelocity = obj(iF).dynProps.(contours{cInd}).avgVelocity;
		hc(iF).(contours{cInd}).peakRate = obj(iF).dynProps.(contours{cInd}).peakRate;
		hc(iF).(contours{cInd}).meanRate = obj(iF).dynProps.(contours{cInd}).meanRate;
		hc(iF).(contours{cInd}).boundary = obj(iF).fieldInfo.boundary.(contours{cInd});
		hc(iF).(contours{cInd}).bins = obj(iF).fieldInfo.bins;
		hc(iF).(contours{cInd}).ctrOfMass = obj(iF).dynProps.(contours{cInd}).ctrOfMass;
		hc(iF).(contours{cInd}).passes = obj(iF).dynProps.(contours{cInd}).passes.hardcopy;
	end
end