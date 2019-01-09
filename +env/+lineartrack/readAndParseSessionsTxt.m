function inputData = readAndParseSessionsTxt(pathToSessionTxt)

% @Version 1.0
% @Date 01/25/2015 8:53 PM

fID = fopen(pathToSessionTxt);
txtContents = textscan(fID, '%s', 'delimiter', '[');
fclose(fID);
txtContents = reshape(txtContents{1}, 2, size(txtContents{1}, 1)/2)';

ratList = zeros(size(txtContents, 1), 1);
sessionNames = cell(size(txtContents, 1), 1);

for i = 1:size(txtContents, 1)
	lastWhiteSpaceInd = regexp(txtContents{i, 1}, ' $', 'once');
	txtContents{i, 1} = txtContents{i, 1}(1:lastWhiteSpaceInd-1);
	
	ratName = regexp(txtContents{i, 1}, 'Rat\d{3,4}','match','once', 'ignorecase');
	ratList(i) = str2double(ratName(4:end));
	sessionNames{i} = regexp(txtContents{i, 1}, '\d+-\d+-\d+(\_\S*)*', 'match', 'once'); % indices of \ except for the one at the very end
end

inputData.sessionList = txtContents(:, 1);
inputData.trialList = parseTrials(txtContents(:, 2));
inputData.ratList = ratList;
inputData.sessionNames = sessionNames;
inputData.cxtOrder = lineartrackABBA.readCxtOrder(inputData.sessionList);



function trialList = parseTrials(trialBracket)

if ~iscell(trialBracket)
	trialList = parseTrials({trialBracket});
else
	trialList = cell(size(trialBracket));
	for i = 1:length(trialBracket)
		trialList{i} = [];

		thisTrialInterval = trialBracket{i};
		thisTrialInterval = regexp(thisTrialInterval, '[^\[][\S*| ]*[^\]]', 'match','once'); % remove the brackets, include whitespaces
		intervals = regexp(thisTrialInterval, '[[\d+-\d+]|\d+]+[\,*?|[\, ]*?]*?', 'match'); % parse with "," or ", " being the separator
		for j = 1:length(intervals)
			boundsOfInterval = regexp(intervals{j}, '[\d+][^-]?', 'match');
			if length(boundsOfInterval) == 1 % single number
				trialList{i} = [trialList{i} str2double(boundsOfInterval)];
			else
				lowerBound = str2double(boundsOfInterval{1});
				upperBound = str2double(boundsOfInterval{2});
				
				trialList{i} = [trialList{i} lowerBound:upperBound];
			end
		end
	end
end