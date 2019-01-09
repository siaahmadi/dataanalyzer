function dist = getDistance(obj)

pfparent = dataanalyzer.ancestor(obj, 'placefield');

allContour = regexp(fieldnames(pfparent.fieldInfo.boundary), '^c\d{2}$', 'match', 'once');
allContour = allContour(cellfun(@(x) ~isempty(x), allContour )); % remove non-contour field names

contour = 'c50'; % gotta get this from dataanalyzer.option() later.
				% Ideally this method will have two output args and the
				% second one would be the distance struct for every
				% available contour. 11/28/2015


if isa(pfparent, 'dataanalyzer.placefield')
	% pfparent can't be empty (because this spike is part of it), so I'm not checking
	runparent = dataanalyzer.ancestor(obj, 'mazerun');
	
	runpath = [runparent.x(:), runparent.y(:)]'; % will be 2xN
	
	d = diff(runpath');
	steps = eucldist(d(:, 1), d(:, 2), 0, 0);
	if length(steps) < 2
		total_distance = [0; steps];
	else
		total_distance = [interp1(1:length(steps), cumsum(steps), 0, 'spline'); cumsum(steps)];
	end
	parametric_distance = interp1(runparent.ts, total_distance, obj.ts, 'spline') / runparent.distanceTraversed;
	
	proDist = struct('cm', (1 - parametric_distance) * runparent.distanceTraversed, 'second', (1 - parametric_distance) * runparent.duration, 'normalized', 1 - parametric_distance);
	retroDist = struct('cm', parametric_distance * runparent.distanceTraversed, 'second', parametric_distance * runparent.duration, 'normalized', parametric_distance);
	
	obj.distance.fromField.prospective = proDist;
	obj.distance.fromField.retrospective = retroDist;
	obj.distance.fromField.contour = contour;
	
	obj.inField = true;
else
	neurparent = dataanalyzer.ancestor(obj, 'neuron');
	% TODO
	error('There''s a todo...');
	
	obj.inField = false;
end

dist = obj.distance;