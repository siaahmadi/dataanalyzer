function rmPD(obj, pdObj)

if ~isa(pdObj, 'dataanalyzer.positiondata') && ~ischar(pdObj)
	error('pdObj must be a positiondata object or a label.');
end


if isa(pdObj, 'dataanalyzer.positiondata')
	I = cellfun(@(apd) apd == pdObj, obj.addonPD(:));
else
	I = cellfun(@(apd) strcmp(apd.namestring, pdObj), obj.addonPD(:));
end

obj.addonPD = obj.addonPD(~I);
obj.addonX = obj.addonX(~I);
obj.addonY = obj.addonY(~I);