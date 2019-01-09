function timeMap = findTimeMap(posx,posy,post,bins,sLength,binWidth)

naninds = isnan(posx+posy+post);
posx(naninds) = []; posy(naninds)=[]; post(naninds) = [];

% Duration of trial
duration = post(end)-post(1);
% Average duration of each position sample
sampDur = duration/length(posx);

% X-coord for current bin position
pcx = -sLength/2-binWidth/2;
timeMap = zeros(bins);
% Find number of position samples in each bin
for ii = 1:bins
    % Increment the x coordinate
    pcx = pcx + binWidth;
    I = find(posx >= pcx & posx < pcx+binWidth);
    % Y-coord for current bin position
    pcy = -sLength/2-binWidth/2;
    for jj=1:bins
        % Increment the y coordinate
        pcy = pcy + binWidth;
        J = find(posy(I) >= pcy & posy(I) < pcy+binWidth);
        % Number of position samples in the current bin
        timeMap(jj,ii) = length(J);
    end
end
% Convert to time spent in bin
timeMap = timeMap * sampDur;