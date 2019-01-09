function spine = mazespine()
%SPINE = MAZESPINE()
%
% return a struct of line segments that represent the spine of the radial
% 8-arm maze

% Siavash Ahmadi
% 9/29/15

armNames = {'ne', 'n', 'nw', 'w', 'sw', 's', 'se', 'e'; ...
			pi/4, pi/2, 3*pi/4, pi, 5*pi/4, 3*pi/2, 7*pi/4, 0};

maze = phaprec.parsemz.rad8.radial8maze();
stemIdx = find(eucldist(0, 0, maze(:, 1), maze(:, 2))<=.01+min(eucldist(0, 0, maze(:, 1), maze(:, 2)))); % 0.01 is to account for roundoff errors in computations
mzRadius = max(eucldist(0, 0, maze(:, 1), maze(:, 2)));
spine = repmat(struct('coord', [], 'component', '', 'name', ''), 1+length(armNames), 1);

spine(1).coord = [0, 0];
spine(1).component = 'stem';
spine(1).name = 'center';

for armInd = 1:length(armNames)
	anglePoints = maze(stemIdx([armInd, mod(armInd, length(armNames))+1]), :);
	theta = mod(cart2pol(anglePoints(:, 1), anglePoints(:, 2))+2*pi, 2*pi);
	[farPoint(1), farPoint(2)] = pol2cart(circmean(theta), mzRadius);
	
	spineTheta = circmean(theta);
	sInd = find(egual([armNames{2,:}], spineTheta, 1e-10));
	spine(sInd+1).coord = [0, 0; farPoint];
	spine(sInd+1).component = 'arm';
	spine(sInd+1).name = armNames{1, sInd};
end

function mtheta = circmean(theta)
[m, I] = min([abs(diff(theta)), 2*pi-abs(diff(theta))]);
if I == 1
	mtheta = mean(theta);
else
	mtheta = mod(m / 2 + max(theta) + 2*pi, 2*pi);
end