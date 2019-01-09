function level = getElevation(obj)
%GETELEVATION Return highest contour level that includes the spike.
%
% If the spike object is out-of-field, level will be 0.
%
% level will be a number between [0, 100] corresponding to percentage of
% field peak.

% Siavash Ahmadi
% 11/29/2015 12:54 PM

pf = dataanalyzer.ancestor(obj, 'placefield');

if ~isa(pf, 'dataanalyzer.placefield') % out-of-(recognized)-field (recognized means passes criteria)
	level = 0;
	return;
end

X = arrayfun(@(x, y) mean([x, y]), pf.fieldInfo.binRangeX(1:end-1), pf.fieldInfo.binRangeX(2:end));
Y = arrayfun(@(x, y) mean([x, y]), pf.fieldInfo.binRangeY(1:end-1), pf.fieldInfo.binRangeY(2:end));
C = contourc(X, Y, pf.fieldInfo.fullrmap, 100);
cm = contour2struct(C);
IN = arrayfun(@(cm) inpolygon(obj.x, obj.y, cm(1).boundary(1, :), cm(1).boundary(2, :)), cm);
idx = find(IN, 1, 'last'); % index to highest contour containing obj
level = cm(idx).level;