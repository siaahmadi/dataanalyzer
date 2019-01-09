function theScore = ttScore(ratNo, varargin)

numFields = 2;

[scoreDB, allTTs, allCLs, scorePage] = lineartrackABBA.getScoreDB(ratNo, numFields);


if length(varargin) == 1 % .t file name given
	if sum(matchstr(scorePage(:, 1), varargin{1})) == 0
		error(['Record for ' varargin{1} ' missing in database'])
	end
	if sum(matchstr(scorePage(:, 1), varargin{1})) > 1
		error(['Record for ' varargin{1} ' duplicated in database'])
	end
	theScore = str2double(scorePage{matchstr(scorePage(:, 1), varargin{1}), 2});
elseif length(varargin) == 2 % ttNo and cluster number given
	theScore = str2double(scoreDB{varargin{1}, varargin{2}});
else
	error('I need one (.t file name, without the .t extension) or two (ttNo, clusterNo) additional inputs after ratNo')
end