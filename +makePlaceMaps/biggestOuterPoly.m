function [x,y] = biggestOuterPoly(x,y)
if ~any(isnan(x))
	return
end
outerPoly = ispolycw(x,y);
numPoly = length(outerPoly);
polyDelimit = [0 find(isnan(x)) length(x)+1];
outerPolyArea = zeros(sum(outerPoly), 1);
for i = 1:numPoly
	if ~outerPoly(i) % only look at outer countours
		continue;
	end
	thisPolyIdx = polyDelimit(i)+1:polyDelimit(i+1)-1;
	
	outerPolyArea(i) = polyarea(x(thisPolyIdx), y(thisPolyIdx));
end
[~, I] = max(outerPolyArea);
biggestPolyIdx = polyDelimit(I)+1:polyDelimit(I+1)-1;
x = x(biggestPolyIdx);
y = y(biggestPolyIdx);