function pf = setPlaceFields(obj, sessionMap, fieldBins, boundaryStruct, binRangeX, binRangeY)

if isempty(obj.placeFields)
	obj.placeFields = dataanalyzer.placefield(obj, sessionMap, obj.getPlaceMap().rateMap, fieldBins, boundaryStruct, binRangeX, binRangeY);
else
	obj.placeFields.update(obj, sessionMap, obj.getPlaceMap().rateMap, fieldBins, boundaryStruct, binRangeX, binRangeY);
end

pf = obj.placeFields;