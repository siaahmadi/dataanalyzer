% To structify the spikes of the mazerun pass

function hc = hardcopy(obj)

hc = arrayfun(@hardcopy_single, obj, 'un', 0);
hc = cat(1, hc{:});

function hc = hardcopy_single(obj)
hc.x = obj.x;
hc.y = obj.y;
hc.t = obj.ts;
hc.v_bar = obj.avgVelocity;
hc.d_tra = obj.distanceTraversed;
hc.duration = obj.ts_duration;
hc.field_elevation = obj.field_elevation;
hc.field_rate = obj.field_rate;
hc.displacement = obj.displacement;
hc.distance = obj.distance;
if numel(obj.spikes) > 0
	hc.spikes = obj.spikes.hardcopy();
else
	hc.spikes = struct('x', [], 'y', [], 't', [], 'phase', struct('theta', [], 'sgamma', [], 'fgamma', []));
end