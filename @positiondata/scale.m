function scale(obj, scaleFactor)

obj.X = obj.getX('unrestr') * scaleFactor.xScale;
obj.Y = obj.getY('unrestr') * scaleFactor.yScale;