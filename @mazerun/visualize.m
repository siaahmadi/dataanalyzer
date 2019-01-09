function h = visualize(obj, varargin)
import dataanalyzer.figure
figure;
h_passes = obj.plot(varargin{:});
if nargout > 0
	h = h_passes;
end