function PF = getFields(obj, fieldScope, pfInd)

if nargin == 1
	PF = obj.fieldInfo.session;
elseif nargin == 2
	if strcmp(fieldScope, 'session')
		PF = obj.fieldInfo.session;
	elseif strcmp(fieldScope, 'trial')
		PF = obj.fieldInfo.trial;
	else
		error('Unkown Place Field Scope')
	end
elseif nargin == 3
	if strcmp(fieldScope, 'session')
		PF = obj.fieldInfo.session(pfInd);
	elseif strcmp(fieldScope, 'trial')
		PF = obj.fieldInfo.trial(pfInd);
	else
		error('Unkown Place Field Scope')
	end
end