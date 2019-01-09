function s = sector(x, y, interArmOffset)
%S = SECTOR(X, Y)
%
% return sector of points on radial 8-arm maze

if ~exist('interArmOffset', 'var') || isempty(interArmOffset)
	interArmOffset = 0;
	warning('Setting offset = 0');
end
armAngle = pi/4;

s = floor(mod(atan2_correctRange(y, x)+interArmOffset, 2*pi)/armAngle)+1;

function p = atan2_correctRange(y, x)

p = mod(atan2(y, x)+2*pi, 2*pi);