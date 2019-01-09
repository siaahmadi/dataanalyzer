function box = circularbox(diameter)

if ~exist('diameter', 'var') || isempty(diameter)
	diameter = 100; % cm
end

radius = diameter / 2;

x_base = (radius:-diameter/100:-radius)';
x_top = (-radius+diameter/100:diameter/100:radius)';

y = [-sqrt(radius.^2 - x_base.^2); sqrt(radius.^2 - x_top.^2)];

box = [[x_base; x_top], y];