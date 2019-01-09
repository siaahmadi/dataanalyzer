function Runs = runsFromParsedData(obj, visitIdx)
% Returns X, Y and TS of parsedVisit (Run, Reward, etc)--appropriate
% sub-struct must be supplied

restriction = 'unrestricted'; % there's no point to parse restricted data. One should parse the data first and then restrict it. 11/9/2015 7:58 PM @author Sia

x = obj.getX(restriction);
y = obj.getY(restriction);
t = obj.getTS(restriction);

if numel(visitIdx) == 1
	visitIdx = [visitIdx, visitIdx];
end

for i = 1:length(visitIdx)-1
	idx = visitIdx(i):visitIdx(i+1);
	try
		Runs(i) = dataanalyzer.mazerun(obj, x(idx), y(idx), t(idx), 1:length(idx), []); % 1:length(idx) is THIS Run's index -- global_idx will be calculated from t
	catch err
		if strcmp(err.identifier, 'MATLAB:badsubscript');
			error('DataAnalyzer:PositionData:LoadingParsedData', 'Visit indices do not match X, Y, and TS data. Parsing data deemed corrupt. (Was parsing done on restricted position data?)');
		else
			rethrow(err)
		end
	end
end