function maze = radial8maze(nArms, renderingMethod)
%
% |renderingMethod| can be 'patch' or 'line'

% Siavash Ahmadi
% 9/17/15
renderingMethods = {'patch', 'line'};

if ~exist('renderingMethod', 'var')
	renderingMethod = 'patch';
end
if ~exist('nArms', 'var')
	nArms = 8;
end
if ~ismember(renderingMethod, renderingMethods)
	buffer = cateach(10, renderingMethods);
	error(['Only the following rendering methods have been defined:' [buffer{:}]]);
end

INCH = 2.54; % inch-to-centimeter

% Measurements:
stemDiameter = (10+7/8)*INCH;
armWidth = 4.5 * INCH;
stem2armGap = 1/4 * INCH;
armHingeGap = 1/2 * INCH;
armComponentLength = 15.5 * INCH;

stem = regpolygon(nArms, stemDiameter / 2, 'in');
arm = [armComponent1(), [NaN; NaN], armHinge(), [NaN; NaN], armComponent2()];

maze = stem;
for armNo = 1:nArms
	newArm = [[NaN; NaN], rot_mat((armNo-1)*2*pi/nArms) * arm]';
	maze = [maze; newArm]; %#ok<AGROW>
end

	function ah = armHinge()
		armHinge.x0 = stemDiameter/2 + stem2armGap + armComponentLength;
		armHinge.y0 = -armWidth/2;
		armHinge.l = armHingeGap;
		armHinge.w = armWidth;
		ah = [armHinge.x0, armHinge.x0 + armHinge.l, armHinge.x0 + armHinge.l, armHinge.x0, armHinge.x0; ...
			armHinge.y0, armHinge.y0, armHinge.y0 + armHinge.w, armHinge.y0 + armHinge.w, armHinge.y0];
	end

	function ac1 = armComponent1()
		armComponent1.x0 = stemDiameter/2 + stem2armGap;
		armComponent1.y0 = -armWidth/2;
		armComponent1.l = armComponentLength;
		armComponent1.w = armWidth;
		ac1 = [armComponent1.x0, armComponent1.x0 + armComponent1.l, armComponent1.x0 + armComponent1.l, armComponent1.x0, armComponent1.x0; ...
			armComponent1.y0, armComponent1.y0, armComponent1.y0 + armComponent1.w, armComponent1.y0 + armComponent1.w, armComponent1.y0];
	end

	function ac2 = armComponent2()
		ac1 = armComponent1();
		ac2 = [ac1(1, :) + armComponentLength + armHingeGap; ac1(2, :)];
	end
end

function r = rot_mat(angle)
	r = [cos(angle) -sin(angle); sin(angle) cos(angle)];
end