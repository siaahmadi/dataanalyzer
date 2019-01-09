function I = issleep(objOrStr)

if ischar(objOrStr)
	I = regexp(sth, '^sleep\d{0,2}$|^s\d{0,2}$') == 1;
elseif isa(objOrStr, 'dataanalyzer.trial')
	if isa(objOrStr, 'dataanalyzer.begintrial')
		I = false;
	elseif isa(objOrStr, 'dataanalyzer.sleeptrial')
		I = true;
	else
		error('Undefined');
	end
else
	error('Input not of recognized type. Enter String or dataanalyzer.trial')
end