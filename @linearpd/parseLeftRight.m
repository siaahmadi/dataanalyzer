function obj = parseLeftRight(obj) % maybe it's better to just say 'parse'
LEFT = 1; RIGHT = 2;

x = obj.getX(); y = obj.getY(); t = obj.getTS();

hdOptions.wedge = pi/20; hdOptions.threshold = obj.videoFR; hdOptions.tolerance = 9/30*obj.videoFR;
[hdEpochsBinary, movementEpochs] = getEpochs(x, y, obj.parentTrial.fullPath, hdOptions);
obj.hdEpochsBinary = hdEpochsBinary;
obj.movementEpochs = movementEpochs;

x_left = x(hdEpochsBinary{LEFT});
y_left = y(hdEpochsBinary{LEFT});
t_left = t(hdEpochsBinary{LEFT});

x_right = x(hdEpochsBinary{RIGHT});
y_right = y(hdEpochsBinary{RIGHT});
t_right = t(hdEpochsBinary{RIGHT});

obj.Left = dataanalyzer.positiondata(x_left, y_left, t_left / obj.stockTimeUnit);
obj.Right = dataanalyzer.positiondata(x_right, y_right, t_right / obj.stockTimeUnit);