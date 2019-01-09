function I = convertTimeUnit(obj, newTimeUnit)
try
	obj.timeUnit = newTimeUnit;
	I = 0;
catch
	I = -1;
	error('Failed')
end