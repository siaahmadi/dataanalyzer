function [x,y,t,s] = handleTrialwiseMapConstraints(X, Y, T, S, constraints)
% warning('This is going to be one of the boringly complex scripts')
x = cell(length(constraints), 1); y = x; t = x; s = x;
for i = 1:length(constraints) % apply constraints and produce new X, Y, T, S
	polygROI = constraints(i).spatialMask.delimiter;
	inEdge = constraints(i).spatialMask.trajectory.entranceEdge;
	outEdge = constraints(i).spatialMask.trajectory.exitEdge;
	
	[off2on, on2off, ~, sequenceOfEvents, entranceEdges, departureEdges] = ...
		dataanalyzer.positiondata.computeEntranceDepartureEdges(X, Y, polygROI);
	
	idx = [off2on; on2off];
	idx_pass = idx(:, entranceEdges==inEdge & departureEdges==outEdge);
	idx = int2intset(idx_pass(:)');
	x{i} = X(idx);
	y{i} = Y(idx);
	t{i} = T(idx);
	if isempty(idx_pass)
		s{i} = [];
	else
		t_idx = idx_pass; t_idx(:) = T(idx_pass(:));
		s{i} = restrictSpikeTrain(S, t_idx);
	end
end

function s = restrictSpikeTrain(S, intervals)

s = cell(size(intervals, 2), 1);
for i = 1:length(s)
	s{i} = Restrict(S, intervals(1,i)-1/60, intervals(2,i)+1/60); % the 1/60 is half of videoFR
end
s = cat(2,s{:});