function rateMaps = make(spTrains, videoX, videoY, videoTS)

sLength = 100; % side length
smoothingFactor = 5;
nBins = 30;
numTrials = size(spTrains, 2);
numCells = size(spTrains, 1);

% Read the input data
binWidth = sLength/nBins;
timeMaps = cell(numTrials,1);
pathCoord = cell(numTrials,3);
rateMaps = cell(numTrials,numCells);
timeStamps = cell(numTrials,numCells);
mapAxis = (-sLength/2+binWidth/2):binWidth:(sLength/2-binWidth/2);
peakRate = zeros(numTrials,numCells);
NaFile = cell(numTrials, 1);

for ii = 1:numTrials
% 	beginTS = trialTimeStamps(fullPathToTrial{ii});
	x = videoX{ii}; y = videoY{ii}; t = videoTS{ii};
    % Smoothing the position samples with a simple mean filter
    for cc=8:length(x)-7
        x(cc) = nanmean(x(cc-7:cc+7));
        y(cc) = nanmean(y(cc-7:cc+7));
% 		headingAngle(cc) = nanmean(headingAngle(cc-7:cc+7));
    end
    
    [x,y] = dataanalyzer.makePlaceMaps.centreBox(x,y);
% 	if strcmp(rotationAlgorithm, 'mid')
% 		rp_x1 = x(x>5 & x<15);rp_x2 = x(x>-15 & x<-5);
% 		rp_y1 = y(x>5 & x<15);rp_y2 = y(x>-15 & x<-5);
% 		rotateBy =  -atan2(mean(rp_y1) - mean(rp_y2), mean(rp_x1) - mean(rp_x2));
% 		[x,y] = rotatePoints(x,y,rotateBy);% for best results, use PCA in order
% 											% to maximize variability along X
% 											% and minimize it along Y
% 		headingAngle = headingAngle/360*2*pi - rotateBy;
% 	elseif strcmp(rotationAlgorithm, 'pca')
% 		[~, newBasis] = pca([x;y]');
% % 		rotateBy = atan2(coeff(1,1),coeff(2,1));
% % 		[x,y] = rotatePoints(x,y, rotateBy-pi/2);
% 		P = newBasis' * [x;y]';
% 	end

      % Calculate the time map for this session
    timeMaps{ii,1} = dataanalyzer.makePlaceMaps.findTimeMap(x,y,t,nBins,sLength,binWidth);
    % Store path
    pathCoord{ii,1} = x;
    pathCoord{ii,2} = y;
    pathCoord{ii,3} = t;
    % END COMPUTING POSITION DATA
	
	S = spTrains(:, ii);
	
    disp('Start calculating the ratemaps for the cells');
    for jj=1:numCells
        disp(sprintf('%s%i',' Cell ',jj));
        if isempty(S{jj}) % Empty cell in this session
            map = zeros(nBins);
            ts = 1e64; % use a single ridicilous time stamp if the cell is silent
        else
            % Convert t-file data to timestamps in second
            ts = S{jj};
            % Get position to spikes
            [spkx,spky] = dataanalyzer.makePlaceMaps.spikePos(ts,x,y,t,'interpolate',.05);
            inds = isnan(spkx);
            ts(inds) = []; spkx(inds) = []; spky(inds) = [];
            % Calculate rate map
            map = dataanalyzer.makePlaceMaps.ratemap(ts,spkx,spky,x,y,t,smoothingFactor,mapAxis);
        end
        rateMaps{ii,jj} = map;
        peakRate(ii,jj) = max(max(map));
% 		try
% 			meanRate(ii,jj) = length(Data(S{jj})) / (endTS-beginTS) * 1e6;
% 		catch
% 			meanRate(ii,jj) = 0;
% 		end
        timeStamps{ii,jj} = ts;
    end
end