function ts = getTS(obj, restriction)

if isa(obj.positionData, 'dataanalyzer.positiondata')
	ts = obj.positionData.getTS('unrestr');
else
	ts = obj.positionData;
end