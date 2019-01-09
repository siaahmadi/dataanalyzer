%% Use adjustpath
function indata = adjustPathCoordinates(indata,iRotationRef,iAdjust,boxSize,dPhi0,edgeSuppression,locIDs,postCenter)
if nargin<8
    postCenter = [];
end
if nargin<7 || isempty(locIDs)
    locIDs = ones(1,length(indata));
end
if size(boxSize,1)~=length(indata)
    boxSize = repmat(boxSize,length(indata),1);
end
if size(boxSize,2)==1
    boxSize = repmat(boxSize,1,2);
end
if nargin<5
    dPhi0 = 1;
end

indata = transposeStructVectors(indata,'row');

unqLoc = unique(locIDs(union(iRotationRef,iAdjust)));
if length(unqLoc)>1
    multilocation = 1;
else
    multilocation = 0;
end
iRotationRef = setdiff(iRotationRef,postCenter);
for loc = unqLoc
    locTrials = find(locIDs==loc);
    locRef = iRotationRef(ismember(iRotationRef,locTrials));
    locAdj = iAdjust(ismember(iAdjust,locTrials));
    if isempty(locAdj) && ~isempty(locRef)
        locAdj = locRef;
        if multilocation
            disp(['Location ' num2str(loc) ' rotation references were specified without adjustment coordinates; adjusting reference coordinates instead']);
        else
            disp(['Rotation references were specified without adjustment coordinates; adjusting reference coordinates instead']);
        end
        dPhi = dPhi0;
    elseif isempty(locRef)
        locRef = locAdj;
        dPhi = 0;
        if multilocation
            disp(['No rotation references specified for location ' num2str(loc) '; scaling and centering only']);
        else
            disp('No rotation references specified; scaling and centering only');
        end
    else
        dPhi = dPhi0;
    end
    
    if dPhi > 0
        xRef = [indata(locRef).x];
        yRef = [indata(locRef).y];
        [~, ~, C.dPhi] = rotateByAreaMinimization(xRef,yRef,dPhi);
        %     end
        %     boxSizeRef = [max(boxSize(locRef,1)) max(boxSize(locRef,2))];
        %     C = getPathCorrectionsFromReference(xRef,yRef,dPhi,boxSizeRef,edgeSuppression);
        %     if dPhi>0
        if C.dPhi~=0
            if multilocation
                disp(['Location ' num2str(loc) ' coordinates rotated ' num2str(C.dPhi) ' degrees']);
            else
                disp(['Coordinates rotated ' num2str(C.dPhi) ' degrees']);
            end
        else
            if multilocation
                disp(['Location ' num2str(loc) ' coordinates require no rotation; scaling and centering only']);
            else
                disp(['No rotation necessary']);
            end
        end
    else
        C.dPhi = 0;
    end

    widths = arrayfun(@(u)diff(minmax(u.x)),indata(locAdj),'uniformoutput',1)';
    heights = arrayfun(@(u)diff(minmax(u.y)),indata(locAdj),'uniformoutput',1)';
    C.scale = [widths'\boxSize(locAdj,1) heights'\boxSize(locAdj,2)];
    xRef = [indata(locAdj).x]*C.scale(1);
    yRef = [indata(locAdj).y]*C.scale(2);
    [~,~,C.center] = rotateAndCenterPath(xRef,yRef,deg2rad(C.dPhi));
    for iA = locAdj
        extremal = 0.5*[boxSize(iA,1)*[-1 1] boxSize(iA,2)*[-1 1]];
        [indata(iA).x,indata(iA).y] = correctPath(indata(iA).x,indata(iA).y,C.dPhi,C.center,C.scale,extremal);
    end
    
    iCenter = postCenter(ismember(postCenter,locAdj));
    if ~isempty(iCenter)
        xRef = [indata(iCenter).x];
        yRef = [indata(iCenter).y];
        [xC yC] = getPathCenter(xRef,yRef);
        for iC = iCenter
            indata(iC).x = indata(iC).x-xC;
            indata(iC).y = indata(iC).y-yC;
        end
    end
end
indata = transposeStructVectors(indata,'col');
