function update(obj, varargin)
% compute properties: phase, x, y, displacement, distance, inField

if numel(obj) > 1
	arrayfun(@(o) o.update(), obj); % skipped varargin, because ts, and other properties should change in batch; only recompute props dependent on Parent
	return;
end

if nargin > 1 && isa(varargin{1}, 'double')
	varargin = ['ts', varargin(:)']; % first argument always the ts
end
args = p___parseInputArgs(varargin{:});

if nargin > 1 % change only if provided --> corollary: if numel(obj)>1, this won't run
	obj.ts = args.ts;
end

obj.Ivls = ivlset([obj.ts, obj.ts]);

% pdparent = dataanalyzer.ancestor(obj, 'trial').positionData;

obj.x = interp1(obj.Parent.ts, obj.Parent.x, obj.ts, 'spline');
obj.y = interp1(obj.Parent.ts, obj.Parent.y, obj.ts, 'spline');
% obj.x = closestPoint(obj.Parent.ts, obj.Parent.x, obj.ts);
% obj.y = closestPoint(obj.Parent.ts, obj.Parent.y, obj.ts);

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
if isa(dataanalyzer.ancestor(obj,'neuron'), 'dataanalyzer.neuron') % has a neuron as an ancestor (have to pass through @isa because of the way dataanalyzer.ancestor works as of 11/27/2015)
	obj.getPhaseLFP();
end
if isa(dataanalyzer.ancestor(obj,'placefield'), 'dataanalyzer.placefield') % has a placefield as an ancestor (have to pass through @isa because of the way dataanalyzer.ancestor works as of 12/02/2015)
	obj.getDistance();
	obj.getDisplacement();
end