function [rm, binX, binY] = getMaps(obj, mapScope)

if nargin == 1
	rm = obj.stuffToDraw.trial.rateMap;
elseif nargin == 2
	junk = regexp(mapScope, '[^:\w*]', 'once');
	if ~isempty(junk)
		error('Please follow the SCOPE:CONSTRAINT convention. CONSTRAINT is optional.')
	end
	parsed = regexp(mapScope,'\w*', 'match');
	mapScope = parsed{1};
	idx = 1;
	if length(parsed) > 1 % find out which constraint to return
		requestedConstraint = parsed{2};
		sessionConstraints = obj.parent.parentTrial.parentSession.getOptions('UpdatePlaceFields');
		idx = matchstr({sessionConstraints.name}', requestedConstraint);
		if ~any(idx)
			error('Requested constraint not found.')
		end
	end
	if strcmp(mapScope, 'trial')
		if ~any(idx) % no constrained requested
			rm = obj.stuffToDraw.trial.rateMap;
		else
			rm = obj.stuffToDraw.trial.constrained(idx).rateMap;
		end
	elseif strcmp(mapScope, 'session')
		rm = obj.stuffToDraw.session.map{idx};
	else
		error('Uknown map scope')
	end
end
binX = obj.binRangeX;
binY = obj.binRangeY;