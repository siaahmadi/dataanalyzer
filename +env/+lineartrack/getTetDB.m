function [ttDB, ratNoDB, pageInd] = getTetDB(ratNo, numFields)

ttLocDB = dataanalyzer.constant('ttLocDB_path_lineartrackABBA');

fileID = fopen(ttLocDB, 'r');
fContent = textscan(fileID, repmat('%s', 1, numFields), 'delimiter', '\t', 'EmptyValue', 0);
fclose(fileID);

fContent = reshape(cat(2, fContent{:}), 15, size(fContent{1}, 1) / 15 * numFields);
totalNumPages = size(fContent, 2) / numFields;
ttDB = cell(totalNumPages, 1);
ratNoDB = zeros(size(ttDB));
for i = 1:totalNumPages
	ttDB{i} = fContent(2:end, i:totalNumPages:end);
	ratNoDB(i) = str2double(regexp(fContent{1, i}, '\d\d\d', 'match'));
end

pageInd = ratNoDB==ratNo;

if sum(pageInd) ~= 1
	error('Specified ratNo doesn''t exist or duplicated in database');
end