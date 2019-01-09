function pathData = rotatePathData(pathData,phi)
nSess = size(pathData,1);

for s = 1:nSess
   [pathData(s).x pathData(s).y] = rotatePath(pathData(s).x,pathData(s).y,deg2rad(phi)); 
end