function [mb, sb] = mazeBoundaries(pathToFile, pngFileName)
if ~exist('pathToFile', 'var') || isempty(pathToFile)
	pathToFile = 'Y:\Sia\scripts\+phaprec\+parsemz\+rad8';
end
if ~exist('pngFileName', 'var') || isempty(pngFileName)
	pngFileName = 'r8mArmTips';
end

[armtips, ~] = imread(fullfile(pathToFile, pngFileName), 'png');
armtips = im2bw(armtips);
c = regionprops(~flipud(armtips), 'Centroid'); % @flipud is because the image is read upside down; ~ is because black = 0, and @regionprops works on 1's, not 0's
mb = reshape([c.Centroid], 2, length(c))';

% register coordinates with the 960 x 720 recorded video:
mb = register(mb);

[mb, sb] = sortmb(mb);

end

function mb = register(mb)
mb = mb*(5/4);
mb(:, 1) = mb(:, 1) + 30;
end

function [mb, sb] = sortmb(mb)
mbz = zscore(mb);
inner = eucldist(0, 0, mbz(:, 1), mbz(:, 2)) < 1;
[~, I] = sort(atan2(mbz(:, 1), mbz(:, 2)));
mb = mb(I, :);
sb = mb(inner(I), :);
end