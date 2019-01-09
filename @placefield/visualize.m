function h = visualize(obj, varargin)

import dataanalyzer.figure

figure;

h_fields = obj.plot(varargin{:});

if nargout > 0
	h = h_fields;
end