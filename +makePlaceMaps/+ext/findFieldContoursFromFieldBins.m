function boundaryStruct = findFieldContoursFromFieldBins(map,fieldBins,mapInterpFactor,xRange,yRange)

if numel(map)==1
    fieldBins = cell(0,2);
else
  map(isnan(map))=0;
  mapSizeInterp = size(map)*mapInterpFactor;
end
nFields = size(fieldBins,1);
if nFields>0
    boundaryStruct(nFields) = struct('boundary','c80','c60','c50','c40','hasMultiPeaks');
    for f = 1:nFields
%         x = fieldBins{f,2};
%         y = fieldBins{f,1};
        x = fieldBins{f}(:,2);
        y = fieldBins{f}(:,1);
        inds = false(size(x));
        inds(x>size(map,2))=1; inds(y>size(map,1))=1;
        x(inds) = []; y(inds) = [];
        m2 = zeros(size(map));
        for i=1:length(x),
            m2(y(i),x(i)) = 1;
        end;
        newmap = (m2.*map);
        
        [smoothMap parameters] = dataanalyzer.makePlaceMaps.ext.preprocessMap(newmap,mapSizeInterp);
        [m,ind] = max(smoothMap);
        [m, ind2] = max(m);
        [boundaryStruct(f).c80,boundaryStruct(f).c60,boundaryStruct(f).c50,...
            boundaryStruct(f).c40,boundaryStruct(f).boundary,boundaryStruct(f).hasMultiPeaks]...
            = dataanalyzer.makePlaceMaps.ext. ...
			findIntermediateBounds(smoothMap,mapSizeInterp,2,[],[ind2,ind(ind2)],xRange,yRange);
        
    end
else
    boundaryStruct = [];
    fieldInds = [];
end

