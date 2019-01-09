function displacement = getDisplacement(obj)

pfparent = dataanalyzer.ancestor(obj, 'placefield');

allContour = regexp(fieldnames(pfparent.fieldInfo.boundary), '^c\d{2}$', 'match', 'once');
allContour = allContour(cellfun(@(x) ~isempty(x), allContour )); % remove non-contour field names

contour = 'c20'; % gotta get this from dataanalyzer.option() later.
				% Ideally this method will have two output args and the
				% second one would be the distance struct for every
				% available contour. 11/28/2015


if isa(pfparent, 'dataanalyzer.placefield')
	% pfparent can't be empty (because this spike is part of it), so I'm not checking
	
	pfpolyg = pfparent.fieldInfo.boundary.(contour); % assume 2xN
	
	obj.displacement.fromField = polydist([obj.x, obj.y], pfpolyg);
	
	obj.inField = true;
else
	neurparent = dataanalyzer.ancestor(obj, 'neuron');
	% TODO: return displacement from nearest field
	error('There''s a todo...');
	
	obj.inField = false;
end

displacement = obj.displacement;