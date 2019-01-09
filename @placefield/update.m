function update(obj, parentPlaceMap, parentMask, fullRateMap, fieldInfo)
% session-wide boundaries should be constructed and fed into this method.
% trial-wise boundaries can be calculated right here, so no need for them
% being supplied

p___validateParent(parentPlaceMap);
p___validateMask(parentMask);
p___validateRateMap(fullRateMap);
p___validateFieldInfo(fieldInfo, dataanalyzer.placefield.requiredFieldNames);

obj.Parent = parentPlaceMap;
obj.ParentMask = parentMask;

obj.fieldInfo = fieldInfo;
obj.fieldInfo.fullrmap = fullRateMap;

obj.dynProps = obj.cprops();