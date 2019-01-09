function h = visualize(obj, varargin)

x = obj.Parent.positionData.getX('unrestr');
y = obj.Parent.positionData.getY('unrestr');
t = obj.Parent.positionData.getTS('unrestr');
sp = obj.getSpikeTrain();

% sp may be returned as a cell array if there are more than one
% masks in effect. I have intentionally left the handling of this situation
% out as I am not sure how I would want the code to behave yet. 11/10/2015

idx = spike2ind(sp, t);

if nargin<2 || ~isvalidhandle(varargin{1})
	figure;
else
	cla;
end
plot(x, y, 'Color', ones(1, 3) * .8);
hold on;
if isempty(varargin)
	h0 = plot(x(idx), y(idx), 'r*');
else
	if isvalidhandle(varargin{1})
		if length(varargin) == 1
			varargin{2} = 'r*';
		end
		h0 = plot(varargin{1}, x(idx), y(idx), varargin{2:end});
	else
		h0 = plot(x(idx), y(idx), varargin{:});
	end
end

if nargout > 0
	h = h0;
end