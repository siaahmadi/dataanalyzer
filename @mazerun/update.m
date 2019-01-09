function update(obj, idx) % I don't know what |idx| is for as it can be retrieved by obj.idx; maybe for user calls? 11/25/2015
% Among other functions, this overrides positiondata's update which alters X and Y

if numel(obj) > 1
	arrayfun(@(o) o.update(), obj, 'un', 0);
	return;
end

empty = isempty(obj); % calls obj's isempty(), which checks for obj's fields being empty;

if empty && nargin < 2 % empty obj
	return;
end

X = obj.parentPD.getX();
Y = obj.parentPD.getY();
T = obj.parentPD.getTS();
V = obj.parentPD.getVelocity();

obj.ts = T(obj.idx_pd);
obj.x = X(obj.idx_pd);
obj.y = Y(obj.idx_pd);
obj.V = V(obj.idx_pd);
% |obj| is a positiondata object by inheritance; the stock values were set
% in the constructor. 
TS = obj.ts;

obj.duration = obj.ts(end) - obj.ts(1);
obj.distanceTraversed = sum(eucldist(obj.x(2:end), obj.y(2:end), obj.x(1:end-1), obj.y(1:end-1)));
obj.avgVelocity = obj.distanceTraversed / obj.duration;

if isa(obj.Parent, 'dataanalyzer.placefield')
	if ~isequal(obj.x, obj.y)
		[obj.field_elevation, obj.field_rate] = p___getElevation(obj.Parent, obj.x, obj.y);
	end
else
	obj.field_elevation = NaN(size(obj.x));
	obj.field_rate = NaN(size(obj.x));
end

if numel(obj.spikes) > 1 % with the current constructor (12/06/2015) this will not run as spikes are only created after @update() is complete. but this should be here for future user calls
	obj.spikes.update();
end

function TS = getTopTSableParentTimeStamps(obj)
anc = dataanalyzer.ancestor(obj, 'trial');
if ~isa(anc, 'dataanalyzer.tsable') % the best way to do this is to define dataanalyzer.ancestor with an extra argument specifying that the top-level object is desired
	anc = dataanalyzer.ancestor(obj, 'expSession');
end
TS = anc.getTS();