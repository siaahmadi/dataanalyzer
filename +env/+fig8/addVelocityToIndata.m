function pathData = addVelocityToIndata(pathData)
pathData = transposeStructVectors(pathData,'col');
pathData = arrayfun(@(a)setfield(a,'v',velocity(a.x,a.y,a.t)),pathData);
