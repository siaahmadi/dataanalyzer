function cxt = readContextFile(obj)

cxt = ''; % default value

pathstr = fileparts(obj.contextFile);

try
	if isempty(pathstr)
		fID = fopen(fullfile(obj.fullPath, obj.contextFile), 'r');
	else % user has changed |contextFile| to a full path
		fID = fopen(obj.contextFile, 'r');
	end
catch
	warning('Couldn''t open context file');
	return
end

try
	cxt = textscan(fID, '%s');
	cxt = cxt{1};
catch
	warning('Couldn''t read context file');
	return
end
fclose(fID);