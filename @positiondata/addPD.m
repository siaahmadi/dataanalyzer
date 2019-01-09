function addPD(obj, pdObj)

if ~isa(pdObj, 'dataanalyzer.positiondata')
	error('pdObj must be a positiondata object.');
end
t = obj.getTS('unrestr');
x = pdObj.getX('unrestr');
y = pdObj.getY('unrestr');

if ~isequal(size(t), size(x), size(y))
	error('pdObj must be a variation on the original object''s position data. It must be the same size.');
end

obj.addonPD = [obj.addonPD; {pdObj}];
obj.addonX = [obj.addonX; {x}];
obj.addonY = [obj.addonY; {y}];
% todo: addonV