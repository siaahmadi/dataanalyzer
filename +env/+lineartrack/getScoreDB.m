function [scoreDB, allTTs, allCLs, scorePage] = getScoreDB(ratNo, numFields)

ttLocDB = 'Y:\Sia\PhD Projects\Recordings\LinearTrackABBA\clusterScores.txt';

fileID = fopen(ttLocDB, 'r');
a = textscan(fileID, repmat('%s', 1, numFields), 'delimiter', '\t', 'EmptyValue', 0);
fclose(fileID);

bInd = find(matchstr(a{1}, ['Rat' num2str(ratNo)]));
ratIdx = find(matchstr(a{1}, 'Rat*'));
if find(ratIdx==bInd) == length(ratIdx)
	eInd = length(a{1});
else
	eInd = ratIdx(find(ratIdx==bInd)+1)-1;
end
bInd = bInd + 1;

scorePage = [a{1}(bInd:eInd) a{2}(bInd:eInd)];
allTTs = [];
allCLs = [];
for i = 1:size(scorePage, 1)
	parsedTname = regexp(scorePage{i, 1}, 'T*?\d{1,2}\_*?', 'match');
	ttNo = str2double(parsedTname{1}(3:end));
	allTTs = [allTTs; ttNo]; %#ok<*AGROW>
	clNo = str2double(parsedTname{2});
	allCLs = [allCLs; clNo];
	
	scoreDB{ttNo, clNo} = scorePage{i, 2};
end