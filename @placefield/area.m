function a = area(obj, contour)

binRangeX = obj.fieldInfo.binRangeX;
binRangeY = obj.fieldInfo.binRangeY;
fieldBins = obj.fieldInfo.bins;

try
	a = polyarea(obj.fieldInfo.boundary.(contour)(1,:), obj.fieldInfo.boundary.(contour)(2,:));
catch err
	if strcmp(err.identifier, 'MATLAB:UndefinedFunction') % if @polyarea is not available for some reason
		areaOfEachBin = (binRangeX(2)-binRangeX(1)) * (binRangeY(2)-binRangeY(1));
		a = size(fieldBins, 1)*areaOfEachBin;
	else
		rethrow(err);
	end
end
