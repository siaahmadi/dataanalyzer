function [fieldBins, boundaryStruct] = extractpfSession(trialMaps, binRangeX, binRangeY, options)

areaOfEachBin = (binRangeX(2) - binRangeX(1)) * (binRangeY(2) - binRangeY(1));
minArea = 60; % cm^2
sessionFieldMinOverlap = .25;	% if the intersection of the convex hull of 
								% two or more fields is at least this proportion
								% of each respective area they will be considered
								% the same
minFieldPeakRate = 2;
targetCountour = .2; % 20%
mapInterpFactor = 5;
xRange = [binRangeX(1) binRangeX(end)];
yRange = [binRangeY(1) binRangeY(end)];

minNumBins = ceil(minArea/areaOfEachBin);

trfieldBins = cell(size(trialMaps));
trBoundary = cell(size(trialMaps));

for testTrInd = 1:length(trialMaps)
	trfieldBins{testTrInd} = dataanalyzer.makePlaceMaps.ext. ...
		findFieldBinsByPixel(trialMaps{testTrInd}, minFieldPeakRate, targetCountour, minNumBins);

	trBoundary{testTrInd} = dataanalyzer.makePlaceMaps.ext. ...
		findFieldContoursFromFieldBins(trialMaps{testTrInd},trfieldBins{testTrInd},mapInterpFactor,xRange,yRange);
end

allBoundary = [trBoundary{:}]';
allBins = cat(1,trfieldBins{:});
f = groupFields(allBoundary, sessionFieldMinOverlap);
boundaryStruct = repmat(struct('boundary', [], 'c60', [], 'c40', [], 'c80', [], 'c50', [], 'hasMultiPeaks', []),length(f), 1);
fieldBins = cell(length(f), 1);
for j = 1:length(f)
	boundaryStruct(j) = mergeFieldBoundaries(allBoundary(f{j}));
	fieldBins{j} = mergeFieldBins(allBins, f{j});
end

function f = groupFields(trBoundary, sessionFieldMinOverlap)
% Using the Bron-Kerbosch algorithm, iteratively find the maximum clique of
% fields with at least 'sessionFieldMinOverlap' intersection

%%% for debugging:
% rects = {[0 0 1 1 0; 0 1 1 0 0], [[1.1 1.1 2.5 2.5 1.1]+.3; [0 1 1 0 0]+0], [4 4 4.5 4.5 4; 0 1 1 0 0], [[0 0 1.25 1.25 0]+.301; 0 1 1 0 0], [2.3 2.3 4.6 4.6 2.3; 0 1 1 0 0], [1.2 1.2 2.6 2.6 1.2; [0 1 1 0 0]+.2], [.9 .9 2.2 2.2 .9; 0 1 1 0 0]};
% for i = 1:length(rects)
% 	trBoundary(i).boundary = rects{i};
% end
% figure;hold on
% jj = [ 1 1 1 2 2 3 4];
% for i = 1:length(rects)
% plot(rects{i}(1,:), rects{i}(2,:)*.8+ 1.2*jj(i))
% end
% axis ij
% 
% allCliques = [     1     0     0     0     0
% 0     1     0     0     0
% 0     1     1     0     0
% 1     0     1     0     1
% 0     0     0     0     0
% 0     0     0     0     0
% 0     0     0     0     1];
% currentCliques = [1 2 3 5];
% allCliques(2,3) = true;
% allCliques(4,3) = false;
% a = [a(2) a(2) a(1) a(1)]'

A = calculateIntersectionProportion(trBoundary);
allCliques = maximalCliques(A >= sessionFieldMinOverlap);
[s, Is] = sort(sum(allCliques), 'descend');
u = unique(s(s>1)); u = u(end:-1:1);

for iu = 1:length(u)
	currentCliques = Is(s==u(iu));
	a = zeros(length(currentCliques), 1);
	ia = 0;
	for i = currentCliques
		ia = ia + 1;
		buffer = calculateIntersectionProportion(trBoundary(find(allCliques(:, i))), 'all'); %#ok<FNDSB>
		try
			a(ia) = buffer(2);
		catch
			1;
		end
		if a < sessionFieldMinOverlap
			allCliques(:, i) = false;
		end
	end
	commonNodes = sum(allCliques(:, currentCliques), 2)>1;
	if any(commonNodes) % currentCliques have one or more nodes in common
		[conflictingCliques, nodesOfConflict] = getConflictingCliques(allCliques, currentCliques);

		oldWinner = [];
		for cc = 1:length(conflictingCliques)
			m = max(sum(allCliques(:, conflictingCliques{cc})));
			m = sum(allCliques(:, conflictingCliques{cc}))==m;
			sizeWinners = conflictingCliques{cc}(:, m);
			if length(sizeWinners) == 1
				winnerClique = sizeWinners;
			else
				currConflCliques = intersect(conflictingCliques{cc}, sizeWinners);
				[~, Locb] = ismember(currConflCliques, currentCliques);
				[~, I] = max(a(Locb));
				winnerClique = currentCliques(Locb(I));
				newLosers = setdiff(currConflCliques, winnerClique);
				if ~isempty(oldWinner) && ismember(oldWinner, newLosers)
					[~, Locb] = ismember(oldLosers, currentCliques);
					[~, I] = max(a(Locb));
					allCliques(oldPointOfConflict,:) = false;
					allCliques(oldPointOfConflict,oldLosers(I)) = true;
				end
				oldLosers = newLosers;
				oldWinner = winnerClique;
				oldPointOfConflict = nodesOfConflict{cc};
			end
			a(winnerClique) = -1; %%%%%%%%%%%%%%%%%%%%
			allCliques(nodesOfConflict{cc}, :) = false;
			allCliques(nodesOfConflict{cc}, winnerClique) = true;
		end
	end
end

allCliques = allCliques(:, sum(allCliques)>1);
accountedForInCliques = sum(allCliques, 2);
f = num2cell(find(~accountedForInCliques));
f = [f; cell(size(allCliques, 2), 1)];
j = 0;
for i = find(cellfun(@isempty, f))'
	j = j + 1;
	f{i} = find(allCliques(:, j));
end

function s = calculateIntersectionProportion(fieldBoundary, method)

if nargin > 1	% this segment intersects N - 1 of the boundaries and essentially
				% runs the rest of the code which was designed for two
				% boundaries only. This is a hack.
	if strcmp(method, 'all')
		if length(fieldBoundary) > 2
			lastBoundary = fieldBoundary(end);
			fieldBoundary = intersectBoundaries(fieldBoundary(1:end-1));
			buffer = lastBoundary;
			buffer.boundary = fieldBoundary.boundary;
			fieldBoundary = [buffer;lastBoundary];
		end
	end
end

s = zeros(length(fieldBoundary));

for i = 2:length(s)
	for j = 1:i-1
		[K1, A1] = convhull(fieldBoundary(i).boundary(1,:), fieldBoundary(i).boundary(2,:));
		[K2, A2] = convhull(fieldBoundary(j).boundary(1,:), fieldBoundary(j).boundary(2,:));
		
		[x1,y1] = poly2cw(fieldBoundary(i).boundary(1,K1), fieldBoundary(i).boundary(2,K1));
		[x2,y2] = poly2cw(fieldBoundary(j).boundary(1,K2), fieldBoundary(j).boundary(2,K2));
		
		[iPoly.x, iPoly.y] = polybool('&',x1,y1,x2,y2);
		iA = polyarea(iPoly.x, iPoly.y);
		
		s(i,j) = iA / max(A1, A2);
	end
end

s = s + s';

function ib = intersectBoundaries(fieldBoundary)
% if intersection produces a disconnected polygon, the biggest polygon will
% be returned
if length(fieldBoundary) <= 1
	ib = fieldBoundary;
	return
end

x = fieldBoundary(1).boundary(1,:);
y = fieldBoundary(1).boundary(2,:);
for i = 2:length(fieldBoundary)
	[x, y] = polybool('&', x, y, fieldBoundary(i).boundary(1,:), fieldBoundary(i).boundary(2,:));
end

%%% pull out the largest contour in case the result is disconnected
[x,y] = dataanalyzer.makePlaceMaps.biggestOuterPoly(x,y);
%%%

ib.boundary = [x;y];

function [conflictingCliques, nodesOfConflict] = getConflictingCliques(allCliques, currentCliques)

%%%% for debugging:
% currentCliques = [1 2 3 5];
% allCliques = [     1     0     0     0     0
%      0     1     0     0     0
%      0     1     1     0     0
%      1     0     1     0     1
%      0     0     0     0     0
%      0     0     0     0     0
%      0     0     0     0     1];

s = sum(allCliques(:, currentCliques));
if any(s-s(1)) % cliques not of same size
	error('Cliques must be of same size or else conflict cannot be resolved')
end

conflictingCliques = cell(size(allCliques, 1), 1);
nodesOfConflict = conflictingCliques;
for i = 1:size(allCliques, 1)
	conflictingCliques{i} = find(allCliques(i, currentCliques));
	if length(conflictingCliques{i}) < 2
		conflictingCliques{i} = [];
	else
		conflictingCliques{i} = currentCliques(conflictingCliques{i});
		nodesOfConflict{i} = i;
	end
end
idx_to_remove = cellfun(@isempty, conflictingCliques);
conflictingCliques(idx_to_remove) = [];
nodesOfConflict(idx_to_remove) = [];
[~, I] = sort(cellfun(@length, conflictingCliques), 'descend');
conflictingCliques = conflictingCliques(I);
nodesOfConflict = nodesOfConflict(I);

function mergedBoundaries = mergeFieldBoundaries(fieldBoundary)

mergedBoundaries = fieldBoundary(1);
if length(fieldBoundary) <= 1
	mergedBoundaries = fieldBoundary;
	return
end

x = fieldBoundary(1).boundary(1,:);
y = fieldBoundary(1).boundary(2,:);
for i = 2:length(fieldBoundary)
	[x,y] = poly2cw(x,y);
	[fieldBoundary(i).boundary(1,:), fieldBoundary(i).boundary(2,:)] = poly2cw(fieldBoundary(i).boundary(1,:), fieldBoundary(i).boundary(2,:));
	[x, y] = polybool('|', x, y, fieldBoundary(i).boundary(1,:), fieldBoundary(i).boundary(2,:));
end
[x,y] = dataanalyzer.makePlaceMaps.biggestOuterPoly(x,y);
mergedBoundaries.boundary = [x;y];

function A = mergeFieldBins(fieldBins, whichToJoin)
buffer = cat(1,fieldBins{whichToJoin});
buffer = unique(complex(buffer(:, 1), buffer(:, 2)));
buffer = [real(buffer) imag(buffer)];
[buffer(:, 2), I] = sort(buffer(:, 2));
buffer(:, 1) = buffer(I, 1);
[buffer(:, 1), I] = sort(buffer(:, 1));
buffer(:, 2) = buffer(I, 2);
A = buffer;