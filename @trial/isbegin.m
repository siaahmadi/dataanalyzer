function I = isbegin(objOrStr)

if ischar(objOrStr)
	I = regexp(sth, '^begin\d{0,2}$|^b\d{0,2}$') == 1;
elseif isa(objOrStr, 'dataanalyzer.trial')
	if isa(objOrStr, 'dataanalyzer.begintrial')
		I = true;
	elseif isa(objOrStr, 'dataanalyzer.sleeptrial')
		I = false;
	else
		error('Undefined');
	end
else
	error('Input not of recognized type. Enter String or dataanalyzer.trial')
end