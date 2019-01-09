function option = getOptions(obj, whichFunctionsOptions)

st = dbstack;
display(['My name is expSession:getOptions. This dude is calling me: ' st(2).name]);

if strcmpi(whichFunctionsOptions, 'all')
	if ~isstruct(obj.functionOptions)
		option = obj.paramOptions;
	elseif ~isstruct(obj.paramOptions)
		option = obj.functionOptions;
	else % both structs
		option = catstruct(obj.functionOptions, obj.paramOptions);
	end
	return
else
	
end

emptyStructErrorID = {'MATLAB:nonStrucReference', 'MATLAB:structRefFromNonStruct', 'MATLAB:nonExistentField'}; %2014b and 2015b versions call the same error by different names

try
	option = obj.functionOptions.(whichFunctionsOptions);
catch err1
	if any(strcmp(err1.identifier, emptyStructErrorID))
		try
			option = obj.paramOptions.(whichFunctionsOptions);
		catch err2
			if any(strcmp(err2.identifier, emptyStructErrorID))
				error('DataAnalyzer:expSessionOptionRetrieval:OptionNotFound', 'Beast!');
			else
				rethrow(err2);
			end
		end
	else
		rethrow(err1);
	end
end
% if strcmpi(whichFunctionsOptions, 'UpdatePlaceFields')
% 	options = obj.functionOptions.UpdatePlaceFields;
% 	return
% end