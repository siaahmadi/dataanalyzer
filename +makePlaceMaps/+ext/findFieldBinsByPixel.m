function fieldBins = findFieldBinsByPixel(map,minPeakRate,fieldThreshold,minNumBins)
% Counter for the number of fields
nFields = 0;

% Holds the bin numbers
% 1: row bins
% 2: col bins
fieldBins = cell(100,1); %,2);

% Allocate memory to the arrays
[numRow,numCol] = size(map);
% Array that contain the bins of the map this algorithm has visited
visited = zeros(numRow,numCol);
nanInd = isnan(map);
visited(nanInd) = 1; 

globalPeak = nanmax(nanmax(map));

visited(map<globalPeak*fieldThreshold) = 1;

% Go as long as there are unvisited parts of the map left
while ~prod(prod(visited))
    
    visited2 = visited;
    
    % Find the current maximum
    [peak,r] = max(map,[],1);
    [peak,pCol] = max(peak);
    
    % Check if peak rate is high enough
    if peak < minPeakRate
        break;
    end
    
    pCol = pCol(1);
    pRow = r(pCol);
    
    binCounter = 1;
    binsRow = zeros(numRow*numCol,1);
    binsCol = zeros(numRow*numCol,1);
    
    % Array that will contain the bin positions to the current placefield
    binsRow(binCounter) = pRow;
    binsCol(binCounter) = pCol;
    
    
    visited2(map<fieldThreshold*peak) = 1;
    current = 0;
    
    while current < binCounter
        current = current + 1;
        [visited2, binsRow, binsCol, binCounter] = checkNeighbours2(visited2, binsRow, binsCol, binCounter, binsRow(current)-1, binsCol(current), numRow, numCol);
        [visited2, binsRow, binsCol, binCounter] = checkNeighbours2(visited2, binsRow, binsCol, binCounter, binsRow(current)+1, binsCol(current), numRow, numCol);
        [visited2, binsRow, binsCol, binCounter] = checkNeighbours2(visited2, binsRow, binsCol, binCounter, binsRow(current), binsCol(current)-1, numRow, numCol);
        [visited2, binsRow, binsCol, binCounter] = checkNeighbours2(visited2, binsRow, binsCol, binCounter, binsRow(current), binsCol(current)+1, numRow, numCol);
    end
    
    binsRow = binsRow(1:binCounter);
    binsCol = binsCol(1:binCounter);
    
    if isempty(binsRow)
        binsRow = pRow;
        binsCol = pCol;
    end
    
    if length(binsRow) >= minNumBins % Minimum size of a placefield
        nFields = nFields + 1;
        fBins = unique([binsRow binsCol],'rows');
%         fieldBins{nFields,1} = fBins(:,1);
%         fieldBins{nFields,2} = fBins(:,2);
fieldBins{nFields} = fBins;
    end
    visited(binsRow,binsCol) = 1;
    map(visited == 1) = 0;
end

fieldBins = fieldBins(1:nFields); %,:);


function [visited2, binsRow, binsCol, binCounter] = checkNeighbours2(visited2, binsRow, binsCol, binCounter, cRow, cCol, numRow, numCol)

if cRow < 1 || cRow > numRow || cCol < 1 || cCol > numCol
    return
end

if visited2(cRow, cCol)
    % Bin has been checked before
    return
end

binCounter = binCounter + 1;
binsRow(binCounter) = cRow;
binsCol(binCounter) = cCol;
visited2(cRow, cCol) = 1;