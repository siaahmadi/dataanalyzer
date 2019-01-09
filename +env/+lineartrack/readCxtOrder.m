function cxt = readCxtOrder(pathToSession)

cxt = cell(length(pathToSession), 1);
for i = 1:length(pathToSession)
	fID = fopen(fullfile(pathToSession{i}, 'contextorder.txt'), 'r');
	a = textscan(fID, '%s');cxt{i} = a{1}{1};
	fclose(fID);
end