% preprocessPathData;
spatialRange.left = -80; spatialRange.right = 80; spatialRange.bottom = -100; spatialRange.top = 100;
nBins.x = 32; nBins.y = 40;
writeToFile = false;

plotDir = ['C:\Users\Sia\Desktop\Marta\RateMaps\MapPathPlots_' date];
mkdir(plotDir);
fileName0 = [plotDir '\MapPathPlots'];

nCols = 3;		% # columns in displayed figures
nRows = 5;		% # rows in displayed figures
binWidth = 5;	% rate map bin width (cm)
vThresh = 0;	% velocity threshold (cm/s)
rateLims = [0.25 inf]; % neuronal firing rate filter interval (Hz; [low_end, high_end])
mazeRegions = {'N1','A12','N2','A23','N3','A34','N4','A45','N5','A56','N6','A16','A25'};

sessInfo = sessionsFileToStruct('X:\Marta\Fig8Project\Sessions_Marta.m');
iIncluded = [sessInfo.include];
sessGroups = {sessInfo.group};
groups = unique(sessGroups);
% blocks = {sessInfo.sessDirs};

[~, linBnds] = fig8trialtemplate();
boundLabels = {'Return','D','S','C','R','END'}; % "(C)en(t)e(r)", "(C)hoice", "(B)ase arm", "(R)eward", "(R)e(t)ur(n)", "(End)"
maze = fig8maze();
[xC, yC] = getPathCenter(maze.whole.basic(:,1),maze.whole.basic(:,2));
maze.whole.locs(:,1) = maze.whole.locs(:,1)-xC;
maze.whole.locs(:,2) = maze.whole.locs(:,2)-yC;
Lx0 = diff(minmax(maze.whole.basic(:,1)));
Lx = Lx0-mod(Lx0,binWidth)+binWidth; % Length of map X direction once binned
xRange = [-80 80]; %mean(minmax(maze.whole.basic(:,1)))+Lx/2*[-1 1];
Ly0 = diff(minmax(maze.whole.basic(:,2)));
Ly = Ly0-mod(Ly0,binWidth)+binWidth; % Length of map Y direction once binned
yRange = [-80 80]; %mean(minmax(maze.whole.basic(:,2)))+Ly/2*[-1 1];
maxLim = round(max(abs([xRange yRange])));
xAxis = linspace(xRange(1),xRange(2),diff(xRange)/binWidth);
yAxis = linspace(yRange(1),yRange(2),diff(yRange)/binWidth);

xRangeLin = [0 360];
yRangeLin = binWidth/2*[-1 1];
yAxisLin = 0;
xAxisLin = linspace(xRangeLin(1),xRangeLin(2),xRangeLin(2)/binWidth);
%%

allBlockNames = unique([sessInfo.sessDirs]);
pdfInd = zeros(size(allBlockNames));
overallCellNo = 0;
h = figure;
for g = 1:length(groups)
    group = groups{g};
    sessToUseIdx = find(ismember(sessGroups,group) & iIncluded); % sessions in current exp. condition and desired to be analyzed
	
	%%%%%%%% FOR SfN POSTER ONLY %%%%%%%%
% 	error('Make sure you want this bit to run!');
	if g == 1
		sessToUseIdx = [4];
	else
		sessToUseIdx = [14];
	end
	%%%%%%%% FOR SfN POSTER ONLY %%%%%%%%
	
    for i = sessToUseIdx
		display(['About to do session ' sessInfo(i).mainDir]);
		blockInd = 0;
		for block = sessInfo(i).sessDirs
			blockInd = blockInd + 1;
            blockDir = fullfile(sessInfo(i).mainDir, block{1});
            
            trialInfo = load([blockDir '\trialInfo.mat']);
            pathData{blockInd} = load([blockDir '\pathData.mat']); %#ok<*SAGROW>
            pathDataIdeal{blockInd} = load([blockDir '\pathDataIdeal.mat']);
            pathDataLin{blockInd} = load([blockDir '\pathDataLinear.mat']);
            
            [tSp, TList] = loadspikes(blockDir, [sessInfo(i).mainDir '\' sessInfo(i).tList{1}]);
            cellIDs{blockInd} = cellfun(@(u)ttid(u),TList);
            rates = cellfun(@(u)length(u)/nansum(diff(pathData{blockInd}.t)),tSp);
            iUse = arrayfun(@(u)inint(u,rateLims),rates); % rate-thresholded cell indices logical
			if ~any(iUse)
				warning('No cells passed the rate criterion'); % this is not printing the message- why??
				continue;
			end
            
            %% All Trials
            % Actual path
            xSp{blockInd} = cell(size(tSp)); % x-coord of individual spikes (velocity-thresholded)
            ySp{blockInd} = cell(size(tSp)); % y-coord of individual spikes (velocity-thresholded)
            [xSp{blockInd}(iUse), ySp{blockInd}(iUse)] = cellfun(@(u)eventpos(u,pathData{blockInd}.x,pathData{blockInd}.y,pathData{blockInd}.t,pathData{blockInd}.v, vThresh),tSp(iUse),'uniformoutput',0);
            
			tic;
			M{blockInd} = buildRateMap(pathData{blockInd},tSp,xRange,yRange,binWidth);
% 			toc;

% 			M = dataanalyzer.makePlaceMaps.makecr2d(tSp(:), {pathData.x}, {pathData.y}, {pathData.t}, spatialRange, nBins)';
			
            peakRate{blockInd} = cellfun(@(u)nanmax(u(:)),M{blockInd});
            % Ideal path
            xSpIdeal{blockInd} = cell(size(tSp));
            ySpIdeal{blockInd} = cell(size(tSp));
            [xSpIdeal{blockInd}(iUse), ySpIdeal{blockInd}(iUse)] = cellfun(@(u)eventpos(u,pathDataIdeal{blockInd}.x,pathDataIdeal{blockInd}.y,pathDataIdeal{blockInd}.t,vThresh),tSp(iUse),'uniformoutput',0);
			
            MIdeal{blockInd} = buildRateMap(pathDataIdeal{blockInd},tSp,xRange,yRange,binWidth);
% 			MIdeal = dataanalyzer.makePlaceMaps.makecr2d(tSp(:), {pathDataIdeal.x}, {pathDataIdeal.y}, {pathDataIdeal.t}, spatialRange, nBins)';
			
            peakRateIdeal{blockInd} = cellfun(@(u)nanmax(u(:)),MIdeal{blockInd});
            % Linear path
            xSpLin{blockInd} = cell(size(tSp));
            ySpLin{blockInd} = cell(size(tSp));
            [xSpLin{blockInd}(iUse), ySpLin{blockInd}(iUse)] = cellfun(@(u)eventpos(u,pathDataLin{blockInd}.x,pathDataLin{blockInd}.y,pathDataLin{blockInd}.t,vThresh),tSp(iUse),'uniformoutput',0);
            
			MLin{blockInd} = buildRateMap(pathDataLin{blockInd},tSp,xRangeLin,yRangeLin,binWidth);
			spatialRange.left = xRangeLin(1); spatialRange.right = xRangeLin(2);
			spatialRange.bottom = yRangeLin(1); spatialRange.top = yRangeLin(2);
			nBins.x = (spatialRange.right - spatialRange.left) / binWidth;
			nBins.y = (spatialRange.top - spatialRange.bottom) / binWidth;
% 			MLin = dataanalyzer.makePlaceMaps.makecr2d(tSp(:), {pathDataLin.x}, {pathDataLin.y}, {pathDataLin.t}, spatialRange, nBins)';
			
            peakRateLin{blockInd} = cellfun(@(u)nanmax(u(:)),MLin{blockInd});
            cToUse{blockInd} = find(iUse);
            
            %% Left linear trials
            trialCriteria.direction = {'L'};
            leftTrialInfo = selecttrials(trialInfo,trialCriteria,mazeRegions);
            leftTrialNums{blockInd} = leftTrialInfo.trial;
            
            % Separate
            trialPathsLSep{blockInd} = extracttrials(leftTrialInfo,pathDataLin{blockInd});
            tSpLSep = extracttrials(leftTrialInfo,tSp);
            xSpLSep{blockInd} = cell(size(tSpLSep));
            ySpLSep = cell(size(tSpLSep));
            nTrials = size(tSpLSep,1);
			for tr = 1:nTrials
                [xSpLSep{blockInd}(tr,iUse), ySpLSep(tr,iUse)] = cellfun(@(u)eventpos(u,trialPathsLSep{blockInd}(tr).x,trialPathsLSep{blockInd}(tr).y,trialPathsLSep{blockInd}(tr).t,trialPathsLSep{blockInd}(tr).v,vThresh),tSpLSep(tr,iUse),'uniformoutput',0);
			end
			
%             MLSep{blockInd} = buildRateMap(trialPathsLSep{blockInd},tSpLSep,xRangeLin,yRangeLin,binWidth);
			MLSep{blockInd} = dataanalyzer.makePlaceMaps.makecr2d(tSpLSep', {trialPathsLSep{blockInd}.x}, {trialPathsLSep{blockInd}.y}, {trialPathsLSep{blockInd}.t}, spatialRange, nBins)';
			
			[xSpLin{blockInd}(iUse), ySpLin{blockInd}(iUse)] = cellfun(@(u)eventpos(u,pathDataLin{blockInd}.x,pathDataLin{blockInd}.y,pathDataLin{blockInd}.t,vThresh),tSp(iUse),'uniformoutput',0);
            % Combined
            trialPathsLComb{blockInd} = contracttrials(leftTrialInfo,pathDataLin{blockInd});
            tSpLComb = contracttrials(leftTrialInfo,tSp);
            xSpLComb{blockInd} = cell(size(tSpLComb));
            ySpLComb = cell(size(tSpLComb));
            [xSpLComb{blockInd}(iUse), ySpLComb(iUse)] = cellfun(@(u)eventpos(u,trialPathsLComb{blockInd}.x,trialPathsLComb{blockInd}.y,trialPathsLComb{blockInd}.t,trialPathsLComb{blockInd}.v,vThresh),tSpLComb(:,iUse),'uniformoutput',0);
            
			MLComb{blockInd} = buildRateMap(trialPathsLComb{blockInd},tSpLComb,xRangeLin,yRangeLin,binWidth);
% 			MLComb = dataanalyzer.makePlaceMaps.makecr2d(tSpLComb(:), {trialPathsLComb.x}, {trialPathsLComb.y}, {trialPathsLComb.t}, spatialRange, nBins)';
            
            %% Right linear trials
            trialCriteria.direction = {'R'};
            rightTrialInfo = selecttrials(trialInfo,trialCriteria,mazeRegions);
            rightTrialNums{blockInd} = rightTrialInfo.trial;
            % Separate
            trialPathsRSep{blockInd} = extracttrials(rightTrialInfo,pathDataLin{blockInd});
            tSpRSep = extracttrials(rightTrialInfo,tSp);
            xSpRSep{blockInd} = cell(size(tSpRSep));
            ySpRSep = cell(size(tSpRSep));
            nTrials = size(tSpRSep,1);
			for tr = 1:nTrials
                [xSpRSep{blockInd}(tr,iUse), ySpRSep(tr,iUse)] = cellfun(@(u)eventpos(u,trialPathsRSep{blockInd}(tr).x,trialPathsRSep{blockInd}(tr).y,trialPathsRSep{blockInd}(tr).t,trialPathsRSep{blockInd}(tr).v,vThresh),tSpRSep(tr,iUse),'uniformoutput',0);
			end
			
			MRSep{blockInd} = buildRateMap(trialPathsRSep{blockInd},tSpRSep,xRangeLin,yRangeLin,binWidth);
% 			MRSep = dataanalyzer.makePlaceMaps.makecr2d(tSpRSep', {trialPathsRSep.x}, {trialPathsRSep.y}, {trialPathsRSep.t}, spatialRange, nBins)';
			
            % Combined
            trialPathsRComb{blockInd} = contracttrials(rightTrialInfo,pathDataLin{blockInd});
            tSpRComb = contracttrials(rightTrialInfo,tSp);
            xSpRComb{blockInd} = cell(size(tSpRComb));
            ySpRComb = cell(size(tSpRComb));
            [xSpRComb{blockInd}(iUse), ySpRComb(iUse)] = cellfun(@(u)eventpos(u,trialPathsRComb{blockInd}.x,trialPathsRComb{blockInd}.y,trialPathsRComb{blockInd}.t,trialPathsRComb{blockInd}.v,vThresh),tSpRComb(:,iUse),'uniformoutput',0);
            
			MRComb{blockInd} = buildRateMap(trialPathsRComb{blockInd},tSpRComb,xRangeLin,yRangeLin,binWidth);
% 			MRComb = dataanalyzer.makePlaceMaps.makecr2d(tSpRComb(:), {trialPathsRComb.x}, {trialPathsRComb.y}, {trialPathsRComb.t}, spatialRange, nBins);
            
            %% Plotting
            yLims{blockInd} = [-2 max(trialInfo.trial)+1];
            xLims = [0 360];
            yTicksL{blockInd} = [-2 -1 0 leftTrialNums{blockInd}' yLims{blockInd}(2)];
            yTicksR{blockInd} = [-2 -1 0 rightTrialNums{blockInd}' yLims{blockInd}(2)];
            yTickLabelsL{blockInd} = arrayfun(@(a)num2str(a),yTicksL{blockInd},'uniformoutput',0);
            yTickLabelsL{blockInd}{1} = '';
            yTickLabelsL{blockInd}{2} = 'All';
            yTickLabelsL{blockInd}{3} = '';
            yTickLabelsL{blockInd}{end} = '';
            yTickLabelsR{blockInd} = arrayfun(@(a)num2str(a),yTicksR{blockInd},'uniformoutput',0);
            yTickLabelsR{blockInd}{1} = '';
            yTickLabelsR{blockInd}{2} = 'All';
            yTickLabelsR{blockInd}{3} = '';
            yTickLabelsR{blockInd}{end} = '';
            
            iPlot = 0;
            clf;
			toc;
		end
		
		display(['Still doing session ' num2str(i) '...']);
		
		% time to print...
		% TODO: make it so that the |c| for loop is external to the |block|
		% for loop:
		% get all cell indices:
		allCells = unique(cell2mat(cellfun(@(x) x(:)', cToUse,'UniformOutput', false)));
		% make sure the |c| for loop runs only on those cells that are
		% available
		% may need to introduce new indexing array to keep track of
		% everything...
		% 10/8/15 @4:01 PM @author Sia
		for c = allCells
			overallCellNo = overallCellNo + 1;
			blockInd = 0;
			for block = sessInfo(i).sessDirs
				% block stuff
				blockInd = blockInd + 1;
				fileName = [fileName0 '_' group '_' block{1}];
				session = sessInfo(i).session;
				day = sessInfo(i).day;
				iPlot = 0;
				% END block stuff
				
				if ~ismember(c, cToUse{blockInd}) % run the block only if this cell, |c|, was active in |block|
					continue;
				end
				
				% c stuff
				title0 = ['S' num2str(session) 'D' num2str(day) ' - C' num2str(cellIDs{blockInd}(c))];
				plotPeaks_L = cellfun(@(x) max(x{c}), MLComb(:));
				plotPeaks_R = cellfun(@(x) max(x{c}), MRComb(:));
				yLimRate = [0 ceil(max([plotPeaks_L; plotPeaks_R]))];
				rmapPeak = max(cellfun(@(x) x(c), peakRate(:)));
				linrmapPeak = max(max(cell2mat(cellfun(@(x) x{c}, MLComb(cellfun(@(x) ismember(c, x), cToUse)), 'UniformOutput', false))));
				% END c stuff

				%% All trials
				iPlot = iPlot+1;
				subplot(nRows,nCols,iPlot)
				plot(pathData{blockInd}.x,pathData{blockInd}.y,'Color',[0.7 0.7 0.7]);
				hold on;
				plot(xSp{blockInd}{c},ySp{blockInd}{c},'r.');
				axis([xRange yRange]), axis square;
				title(title0,'FontSize',9);

				iPlot = iPlot+1;
% 				subplot(nRows,nCols,iPlot)
% 				plot(pathDataIdeal{blockInd}.x,pathDataIdeal{blockInd}.y,'Color',[0.7 0.7 0.7]);
% 				hold on;
% 				plot(xSpIdeal{blockInd}{c},ySpIdeal{blockInd}{c},'r.');
% 				axis([xRange yRange]), axis square;
% 				title(title0,'FontSize',9);

				iPlot = iPlot+1;
% 				subplot(nRows,nCols,iPlot)
% 				xTicks = plotLinearBounds(linBnds,diff(xRangeLin)/2*[-1 1]);
% 				hold on;
% 				plot(pathDataLin{blockInd}.x,pathDataLin{blockInd}.y,'Color',[0.7 0.7 0.7]);
% 				plot(xSpLin{blockInd}{c},ySpLin{blockInd}{c},'r.');
% 
% 				axis([xRangeLin diff(xRangeLin)/2*[-1 1]]), %axis square;                
% 				title(title0,'FontSize',9);
% 				set(gca,'FontSize',9);
% 				set(gca,'XTick',xTicks,'XTickLabel',boundLabels,'FontSize',6);

				iPlot = iPlot+1;
				subplot(nRows,nCols,iPlot)
				pcolor(xAxis,yAxis,M{blockInd}{c}); shading flat;
				axis([xRange yRange]), axis square;
				title(title0,'FontSize',9);
				xlabel(['Peak: ' num2str(peakRate{blockInd}(c)) ' Hz'],'FontSize',9)
				caxis([0, rmapPeak]);

				iPlot = iPlot+1;
% 				subplot(nRows,nCols,iPlot)
% 				pcolor(xAxis,yAxis,MIdeal{blockInd}{c}); shading flat;
% 				axis([xRange yRange]), axis square;
% 				title(title0,'FontSize',9);
% 				xlabel(['Peak: ' num2str(peakRateIdeal{blockInd}(c)) ' Hz'],'FontSize',9)

				iPlot = iPlot+1;
% 				subplot(nRows,nCols,iPlot), hold on;        
% 				xTicks = plotLinearBounds(linBnds,diff(xRangeLin)/10*[-1 1],'line', [0.8 0.8 0.8]);
% 				pcolor(xAxisLin,binWidth/2*[-1 1],repmat(MLin{blockInd}{c},2,1)); shading flat;                
% 				axis([xRangeLin diff(xRangeLin)/10*[-1 1]]), % axis square;
% 				title(title0,'FontSize',9);
% 				xlabel(['Peak: ' num2str(peakRateLin{blockInd}(c)) ' Hz'],'FontSize',9)
% 				set(gca,'XTick',xTicks,'XTickLabel',boundLabels,'FontSize',6);

				%% Left trials
				iPlot = iPlot+1;
% 				subplot(nRows,nCols,iPlot); hold on;
% 				xTicks = plotLinearBounds(linBnds,yLims{blockInd});
% 				% Path-Spike rasters - Separate
% 				for tr = 1:length(leftTrialNums{blockInd});
% 					trNum = leftTrialNums{blockInd}(tr);
% 					plot(trialPathsLSep{blockInd}(tr).x,trNum*ones(size(trialPathsLSep{blockInd}(tr).x)),'Color',[0.7 0.7 0.7]);
% 					plot(xSpLSep{blockInd}{tr,c},trNum*ones(size(xSpLSep{blockInd}{tr,c})),'r.');
% 				end
% 				% Path-Spike rasters - Combined
% 				plot(xAxisLin,zeros(size(xAxisLin)),'k','LineWidth',1);
% 				plot(trialPathsLComb{blockInd}.x,-1*ones(size(trialPathsLComb{blockInd}.x)),'Color',[0.7 0.7 0.7]);
% 				plot(xSpLComb{blockInd}{c},-1*ones(size(xSpLComb{blockInd}{c})),'r.');
% 
% 				xlim(xLims),ylim(yLims{blockInd});
% 				title('Left trials','FontSize',9);
% 				xlabel('Position (cm)','FontSize',9);
% 				ylabel('Trial number','FontSize',9);
% 				set(gca,'XTick',xTicks,'XTickLabel',boundLabels,'YTick',yTicksL{blockInd},'YTickLabel',yTickLabelsL{blockInd},'FontSize',6);

				iPlot = iPlot+1;
				subplot(nRows,nCols,iPlot); hold on; 
				xTicks = plotLinearBounds(linBnds,yLims{blockInd},'line', [0.8 0.8 0.8]);
				% Rate maps - Separate
				for tr = 1:length(leftTrialNums{blockInd})
					trNum = leftTrialNums{blockInd}(tr);
					pcolor(xAxisLin,trNum+[-0.5 0.5],repmat(MLSep{blockInd}{tr,c},2,1)); shading flat;
				end
				% Rate maps - Combined
				plot(xAxisLin,zeros(size(xAxisLin)),'k','LineWidth',1);
				pcolor(xAxisLin,-1+[-0.5 0.5],repmat(MLComb{blockInd}{c},2,1)); shading flat;
				xlim(xLims),ylim(yLims{blockInd});
				title('Left trials','FontSize',9);
				
				%%%%%%---------- Heat map scale ----------%%%%%%
				xlabel(['Scaled to: ' num2str(max([rmapPeak, yLimRate, linrmapPeak])) ' Hz'],'FontSize',9);
				
				ylabel('Trial number','FontSize',9);
				set(gca,'XTick',xTicks,'XTickLabel',boundLabels,'YTick',yTicksL{blockInd},'YTickLabels',yTickLabelsL{blockInd},'FontSize',6);
				caxis([0, max([rmapPeak, yLimRate, linrmapPeak])]);

				iPlot = iPlot+1;
				subplot(nRows,nCols,iPlot); hold on;
				% Rate v. Position
				interpRates = interp1(xAxisLin, MLComb{blockInd}{c},0:360,'linear');
				plot(0:360,interpRates)
				xTicks = plotLinearBounds(linBnds,yLimRate,'fill');
				plot(0:360,interpRates,'k','LineWidth',1);
				xlim(xLims)
				ylim(yLimRate);
				title('Left trials','FontSize',9);
				xlabel('Position (cm)','FontSize',9);
				ylabel('Rate (Hz)','FontSize',9);
				set(gca,'XTick',xTicks,'XTickLabel',boundLabels,'FontSize',6);

				%% Right trials
				iPlot = iPlot+1;
% 				subplot(nRows,nCols,iPlot); hold on;
% 				xTicks = plotLinearBounds(linBnds,yLims{blockInd});
% 				% Path-Spike rasters - Separate
% 				for tr = 1:length(rightTrialNums{blockInd});
% 					trNum = rightTrialNums{blockInd}(tr);
% 					plot(trialPathsRSep{blockInd}(tr).x,trNum*ones(size(trialPathsRSep{blockInd}(tr).x)),'Color',[0.7 0.7 0.7]);
% 					plot(xSpRSep{blockInd}{tr,c},trNum*ones(size(xSpRSep{blockInd}{tr,c})),'r.');
% 				end
% 				% Path-Spike rasters - Combined
% 				plot(xAxisLin,zeros(size(xAxisLin)),'k','LineWidth',1);
% 				plot(trialPathsRComb{blockInd}.x,-1*ones(size(trialPathsRComb{blockInd}.x)),'Color',[0.7 0.7 0.7]);
% 				plot(xSpRComb{blockInd}{c},-1*ones(size(xSpRComb{blockInd}{c})),'r.');
% 				xlim(xLims),ylim(yLims{blockInd});
% 				title('Right trials','FontSize',9);
% 				xlabel('Position','FontSize',9);
% 				ylabel('Trial number','FontSize',9);
% 				set(gca,'XTick',xTicks,'XTickLabel',boundLabels,'YTick',yTicksR{blockInd},'YTickLabels',yTickLabelsR{blockInd},'FontSize',6);

				iPlot = iPlot+1;
				subplot(nRows,nCols,iPlot); hold on;
				xTicks = plotLinearBounds(linBnds,yLims{blockInd},'line', [0.8 0.8 0.8]);
				% Rate maps - Separate
				for tr = 1:length(rightTrialNums{blockInd})
					trNum = rightTrialNums{blockInd}(tr);
					pcolor(xAxisLin,trNum+[-0.5 0.5],repmat(MRSep{blockInd}{tr,c},2,1)); shading flat;
				end
				% Rate maps - Combined
				plot(xAxisLin,zeros(size(xAxisLin)),'k','LineWidth',1);
				pcolor(xAxisLin,-1+[-0.5 0.5],repmat(MRComb{blockInd}{c},2,1)); shading flat;

				xlim(xLims),ylim(yLims{blockInd});
				title('Right trials','FontSize',9);
				xlabel('Position','FontSize',9);
				ylabel('Trial number','FontSize',9);
				set(gca,'XTick',xTicks,'XTickLabel',boundLabels,'YTick',yTicksR{blockInd},'YTickLabels',yTickLabelsR{blockInd},'FontSize',6);
				caxis([0, max([rmapPeak, yLimRate, linrmapPeak])]);

				iPlot = iPlot+1;
				subplot(nRows,nCols,iPlot); hold on;
				% Rate v. Position
				interpRates = interp1(xAxisLin, MRComb{blockInd}{c},0:360,'linear');

				plot(0:360,interpRates)
				xTicks = plotLinearBounds(linBnds,yLimRate,'fill');
				plot(0:360,interpRates,'k','LineWidth',1);
				xlim(xLims)
				ylim(yLimRate);
				title('Right trials','FontSize',9);
				xlabel('Position','FontSize',9);
				ylabel('Rate (Hz)','FontSize',9);
				set(gca,'XTick',xTicks,'XTickLabel',boundLabels,'FontSize',6);

	% 				waitforbuttonpress
	% 				clf;
				colormap(jet(256));
				
% 				pdfInd(strcmpi(allBlockNames, block)) = pdfInd(strcmpi(allBlockNames, block)) + 1;
% 				pdfpage(h,[fileName, '_c', num2str(pdfInd(strcmpi(allBlockNames, block)))]);

				if writeToFile
					pdfpage(h,[fileName, '_c', num2str(overallCellNo)]);
				end
				iPlot = 0;
				clf;                
			end
		end
%         end
%         addLast = iPlot > 0;
%         pdfpage(h,fileName,1,0);
	display(['Finished session ' num2str(i)]);
    end
end
