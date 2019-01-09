function update(obj, varargin)
% compute properties: phase, x, y, displacement, distance, inField

% if numel(obj) > 1
% 	arrayfun(@(o) o.update(), obj); % skipped varargin, because ts, and other properties should change in batch; only recompute props dependent on Parent
% 	return;
% end

Ivls = cellfun(@ivlset, {obj.ts}, {obj.ts}, 'un', 0);
arrayfun(@accFunc_assgnIvls, obj, cat(1, Ivls{:}));

if isempty(obj)
	return;
end

% pdparent = dataanalyzer.ancestor(obj, 'trial').positionData;

if ~isempty(obj(1).Parent)
	t = obj(1).Parent.getTS();
	ts = [obj.ts];
	X = interp1(t, obj(1).Parent.getX(), ts, 'spline');
	Y = interp1(t, obj(1).Parent.getY(), ts, 'spline');
	V = interp1(t, obj(1).Parent.getVelocity(), ts, 'spline');
	T = interp1(t, t, ts, 'spline');
	arrayfun(@accFunc_assgnXYV, obj(:), X(:), Y(:), V(:));
end

% When a mazerun is being extracted by asking a positiondata to return
% passes through a polygon (as is the case when computing placefields and
% their dynamic properties (cf. cprops()), the grandparent of this spike
% object will be the positiondata object.
%
% However, to compute those
% properties of this spike that rely on the computation of other
% placefields (in cases where more than a single field exists, or when the
% spike is out-of-field (e.g. when a spike object is being created as a
% direct child of a neuron object--hence no placefields may exist yet at the
% time)), the following two if blocks will ensure that computation takes
% place only if appropriate data is available and accessible.
%
% That if or when such data is available depends on the object creating the
% spike object. A couple of examples where the ancestor object must call
% this update method for every one of its spikes after having created them
% all include:
% @placemap.update
% @neuron constructor
%
% by @author Sia @date 11/27/2015 11:11 AM

% The following block is deprecated as phases are extracted during
% preprocessing and loaded upon construction. 4/20/2017
% if isa(dataanalyzer.ancestor(obj,'neuron'), 'dataanalyzer.neuron') % has a neuron as an ancestor (have to pass through @isa because of the way dataanalyzer.ancestor works as of 11/27/2015)
% % 	arrayfun(@getPhaseLFP, obj);
% 	obj.getPhaseLFP(); % compute |obj|s' phase
% end

if isa(dataanalyzer.ancestor(obj,'placefield'), 'dataanalyzer.placefield') % has a placefield as an ancestor (have to pass through @isa because of the way dataanalyzer.ancestor works as of 12/02/2015)
	arrayfun(@getDistance, obj);
	arrayfun(@getDisplacement, obj);
end

function accFunc_assgnXYV(obj, x, y, v)
obj.x = x;
obj.y = y;
obj.v = v;

function accFunc_assgnIvls(obj, Ivl)
obj.Ivls = Ivl;