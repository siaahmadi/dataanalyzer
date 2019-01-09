function [Z0 parameters] = preprocessMap(map,mapSizeInterp)

% SYNTAX:  [Z0 parameters] = preprocessMap(map,parameters)
%
% This is an inner workings function that you are unlikely to call
% directly.
% Given a map and a set of parameters (created with setUpFieldParameters),
% this interpolates the map from its original size to the size given in
% parameters.mapSizeInterp. This generally leads to smoother contours. In
% addition, zeros are added around the edge of the map to ensure that all
% contours that Matlab creates on the map will be closed loops.
%
% Emily Mankin, 2012
% Modified from code created by Trygve Solstad

if isnan(map)
    Z0 = zeros(mapSizeInterp);
else
    map = replaceNans(map);
    nBins=mapSizeInterp;
    %interpolate map to have nBins
    [Ly,Lx]=size(map);
    L=min(Lx,Ly);
    [X,Y]=meshgrid(1:Lx,1:Ly);
    if length(nBins) == 1
        [X0,Y0]=meshgrid(1:L/nBins:Lx,1:L/nBins:Ly);
    else
        [X0,Y0]=meshgrid(1:Lx/nBins(2):Lx,1:Ly/nBins(1):Ly);
    end
    if Ly == 1
        Z0 = interp1(X,map,X0);
        Z0 = repmat(Z0,nBins(1),1);
    elseif Lx == 1
        Z0 = interp1(Y,map,Y0);
        Z0 = repmat(Z0,1,nBins(2));
    else
        Z0=interp2(X,Y,map,X0,Y0);
    end
    
    %add padding because we lose the edges to interpolation
    %note that this is also a critical step for parsing contours
    %later, so we do this even if no interpolation was done
    if length(nBins) == 1
        ydistFromSize = mapSizeInterp-size(Z0,1);
    else
        ydistFromSize = mapSizeInterp(1)-size(Z0,1);
    end
    yPad = max(ceil(ydistFromSize/2),1);
    Z0 = [zeros(yPad,size(Z0,2));...
        Z0;zeros(yPad,size(Z0,2))];
    
    if length(nBins) == 1
        xdistFromSize = mapSizeInterp-size(Z0,2);
    else
        xdistFromSize = mapSizeInterp(2)-size(Z0,2);
    end
    xPad = max(ceil(xdistFromSize/2),1);
    Z0 = [zeros(size(Z0,1),xPad),...
        Z0,zeros(size(Z0,1),xPad)];
    
    parameters.xPad = xPad;
    parameters.yPad = yPad;
    
    if length(nBins) == 1
        parameters.mapSizeInterp = size(Z0,1);
    else
        parameters.mapSizeInterp = size(Z0);
    end
end