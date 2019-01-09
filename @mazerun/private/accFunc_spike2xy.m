function [x, y] = accFunc_spike2xy(spike, ts, x, y)

if isempty(spike)
	x = [];
	y = [];
	return;
else
	[x, y] = spike2xy([spike.ts], ts, x, y);
end