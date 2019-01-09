function h = draw(obj,Fs, varargin)
if nargin == 1
	Fs = 1;
end
spikeTimes = obj.s;
if isa(spikeTimes, 'double')
	if isvector(spikeTimes)
		spikeTimes = {spikeTimes};
	else
		error('spikeTimes must be either a vector of doubles or a cell of double vectors')
	end
elseif islogical(spikeTimes)
	spikeTimes = find(spikeTimes)/Fs;
	spikeTimes = {spikeTimes};
elseif ~isa(spikeTimes, 'cell')
	error('spikeTimes must be either a vector of doubles or a cell of double vectors')
end

hold on;
h = cell(length(spikeTimes), 1);
for i = 1:length(spikeTimes)
	A = nan(3*length(spikeTimes{i}), 1);
	A(1:3:end) = spikeTimes{i};
	A(2:3:end) = spikeTimes{i};
	if ~isempty(varargin)
		h{i} = plot(A, repmat([.55;1.45;NaN] + i - 1, length(spikeTimes{i}), 1), varargin{:});
	else
		h{i} = plot(A, repmat([.55;1.45;NaN] + i - 1, length(spikeTimes{i}), 1));
	end
	
	h{i}.UserData.CellIndex = i;
	h{i}.UserData.Parent = obj;
end
set(gca,'ytick',[])
dcm_obj = datacursormode(gcf);dcm_obj.UpdateFcn = @testfunc; % experimental
h = [h{:}]';