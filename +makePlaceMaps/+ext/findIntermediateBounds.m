function [c80,c60,c50,c40,smoothBound,hasMultiPeaks] = findIntermediateBounds(Z0,mapSize,mapPad,boundary,center,xRange,yRange)
if ~isempty(boundary)
    bw = poly2mask(boundary(1,:),boundary(2,:),mapSize,mapSize);
    Z0=Z0.*bw;
end
for nCont = [9,15]
    C = contourc(Z0,nCont);
    cs = parseContours(C,0);
    vals = arrayfun(@(x)x.value,cs);
    if length(vals)~=nCont
        newContours = [];
        uniqueVals = unique(vals);
        for u=1:length(uniqueVals)
            inds = vals==uniqueVals(u);
            if sum(inds)==1
                xdata = cell2mat(arrayfun(@(x)x.xdata,cs(inds),'UniformOutput',0));
                ydata = cell2mat(arrayfun(@(x)x.ydata,cs(inds),'UniformOutput',0));
                hasMultiPeaks1(u) = 0;
            else
                % Don't concatenate 2 contours, just choose the one whose
                % center is closest to the center of the field
                hasMultiPeaks1(u) = 1;
                xdata = arrayfun(@(x)x.xdata,cs(inds),'UniformOutput',0);
                ydata = arrayfun(@(x)x.ydata,cs(inds),'UniformOutput',0);
                
                % center of field should be inside center of contour
                % chosen:
                isIn = cellfun(@(xx,yy)inpolygon(center(1),center(2),xx,yy),xdata,ydata);
                
                if sum(isIn)==1
                    xdata = xdata{isIn};
                    ydata = ydata{isIn};
                else
                    if sum(isIn)>1
                        xdata = xdata(isIn);
                        ydata = ydata(isIn);
                    end
                    xcenters = cellfun(@(x)mean(x),xdata);
                    ycenters = cellfun(@(x)mean(x),ydata);
                    distToCenter = arrayfun(@(x,y)(x-center(1))^2+(y-center(2))^2,xcenters,ycenters);
                    [~,closest] = min(distToCenter);
                    xdata = xdata{closest};
                    ydata = ydata{closest};
                end
            end
            newContours = [newContours struct('value',u,'xdata',xdata,'ydata',ydata)];
        end
        cs = newContours;
    else
        hasMultiPeaks1(nCont) = 0;
    end
    
    switch nCont
        case 9
            c80 = scaleToUnitSquare([cs(8).xdata;cs(8).ydata],mapSize,mapPad,xRange,yRange);
            c60 = scaleToUnitSquare([cs(6).xdata;cs(6).ydata],mapSize,mapPad,xRange,yRange);
            c50 = scaleToUnitSquare([cs(5).xdata;cs(5).ydata],mapSize,mapPad,xRange,yRange);
            c40 = scaleToUnitSquare([cs(4).xdata;cs(4).ydata],mapSize,mapPad,xRange,yRange);
            hasMultiPeaks = hasMultiPeaks1(5);
        case 15
            areas = arrayfun(@(c)polyarea(c.xdata,c.ydata),cs);
            ratios = areas(2:end)./areas(1:end-1);
            jumps = ratios<.5;
            if jumps(1)
                boundToUse = 1;
            elseif jumps(2)
                boundToUse = 2;
            else
                boundToUse = 3;
            end
            smoothBound = scaleToUnitSquare([cs(boundToUse).xdata;cs(boundToUse).ydata],mapSize,mapPad,xRange,yRange);
    end
end


function data = scaleToUnitSquare(data,mapSize,mapPad,xRange,yRange)
if length(mapSize) == 1
data(data>mapSize-mapPad) = mapSize-mapPad;
data(data<mapPad) = mapPad;
dBound = mapSize/2-xRange(2);
%data = 2*(data-mapSize/2)/(mapSize-mapPad);
data(1,:) = 2*(data(1,:)-dBound-mapSize/2)/(mapSize-mapPad);
data(2,:) = 2*(data(2,:)-mapSize/2)/(mapSize-mapPad);
else
    rowData = data(1,:);
    rowData(rowData>mapSize(2)-mapPad) = mapSize(2)-mapPad;
    rowData(rowData<mapPad) = mapPad;
    colData = data(2,:);
    colData(colData>mapSize(1)-mapPad) = mapSize(1)-mapPad;
    colData(colData<mapPad) = mapPad;

rowData = 2*(rowData-mapSize(2)/2)/(mapSize(2)-mapPad);
colData = 2*(colData-mapSize(1)/2)/(mapSize(1)-mapPad);
data = [rowData;colData];
end