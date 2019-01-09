function pathData = linearizePathData(pathData)

nSess = length(pathData);

for s = 1:nSess
   iNan = isnan(pathData(s).x) | isnan(pathData(s).y);
   pathData(s).x(~iNan) = getPathDistance(pathData(s).x(~iNan),pathData(s).y(~iNan));
   pathData(s).y(~iNan) = zeros(size(pathData(s).y(~iNan)));
end