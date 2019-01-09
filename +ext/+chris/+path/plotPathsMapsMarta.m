% preprocessPathData;
spatialRange.left = -80; spatialRange.right = 80; spatialRange.bottom = -80; spatialRange.top = 80;
nBins.x = 32; nBins.y = 32;

plotDir = ['C:\Users\Sia\Desktop\test\MapPathPlots_' date];
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
boundLabels = {'CTR','C','B','R','RTN','END'}; % "(C)en(t)e(r)", "(C)hoice", "(B)ase arm", "(R)eward", "(R)e(t)ur(n)", "(End)"
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
h = figure;
for g = 1:length(groups)
    group = groups{g};
    sessToUse = find(ismember(sessGroups,group) & iIncluded); % sessions in current exp. condition and desired to be analyzed
    for i = sessToUse % should swap this line with next for print purposes
        for block = sessInfo(i).sessDirs
			fileName = [fileName0 '_' group '_' block{1}];
            session = sessInfo(i).session;
            day = sessInfo(i).day;
            blockDir = fullfile(sessInfo(i).mainDir, block{1});
            
            trialInfo = load([blockDir '\trialInfo.mat']);
            pathData = load([blockDir '\pathData.mat']);
            pathDataIdeal = load([blockDir '\pathDataIdeal.mat']);
            pathDataLin = load([blockDir '\pathDataLinear.mat']);
            
            [tSp, TList] = loadspikes(blockDir, [sessInfo(i).mainDir '\' sessInfo(i).tList{1}]);
            cellIDs = cellfun(@(u)ttid(u),TList);
            rates = cellfun(@(u)length(u)/nansum(diff(pathData.t)),tSp);
            iUse = arrayfun(@(u)inint(u,rateLims),rates); % rate-thresholded cell indices logical
			if ~any(iUse)
				warning('No cells passed the rate criterion'); % this is not printing the message- why??
				continue;
			end
            
            %% All Trials
            % Actual path
            xSp = cell(size(tSp)); % x-coord of individual spikes (velocity-thresholded)
            ySp = cell(size(tSp)); % y-coord of individual spikes (velocity-thresholded)
            [xSp(iUse), ySp(iUse)] = cellfun(@(u)eventpos(u,pathData.x,pathData.y,pathData.t,pathData.v, vThresh),tSp(iUse),'uniformoutput',0);
            
			tic;
			M = buildRateMap(pathData,tSp,xRange,yRange,binWidth);
% 			toc;

% 			M = dataanalyzer.makePlaceMaps.makecr2d(tSp(:), {pathData.x}, {pathData.y}, {pathData.t}, spatialRange, nBins)';
			
            peakRate = cellfun(@(u)nanmax(u(:)),M);
            % Ideal path
            xSpIdeal = cell(size(tSp));
            ySpIdeal = cell(size(tSp));
            [xSpIdeal(iUse), ySpIdeal(iUse)] = cellfun(@(u)eventpos(u,pathDataIdeal.x,pathDataIdeal.y,pathDataIdeal.t,vThresh),tSp(iUse),'uniformoutput',0);
			
            MIdeal = buildRateMap(pathDataIdeal,tSp,xRange,yRange,binWidth);
% 			MIdeal = dataanalyzer.makePlaceMaps.makecr2d(tSp(:), {pathDataIdeal.x}, {pathDataIdeal.y}, {pathDataIdeal.t}, spatialRange, nBins)';
			
            peakRateIdeal = cellfun(@(u)nanmax(u(:)),MIdeal);
            % Linear path
            xSpLin = cell(size(tSp));
            ySpLin = cell(size(tSp));
            [xSpLin(iUse), ySpLin(iUse)] = cellfun(@(u)eventpos(u,pathDataLin.x,pathDataLin.y,pathDataLin.t,vThresh),tSp(iUse),'uniformoutput',0);
            
			MLin = buildRateMap(pathDataLin,tSp,xRangeLin,yRangeLin,binWidth);
			spatialRange.left = xRangeLin(1); spatialRange.right = xRangeLin(2);
			spatialRange.bottom = yRangeLin(1); spatialRange.top = yRangeLin(2);
			nBins.x = (spatialRange.right - spatialRange.left) / binWidth;
			nBins.y = (spatialRange.top - spatialRange.bottom) / binWidth;
% 			MLin = dataanalyzer.makePlaceMaps.makecr2d(tSp(:), {pathDataLin.x}, {pathDataLin.y}, {pathDataLin.t}, spatialRange, nBins)';
			
            peakRateLin = cellfun(@(u)nanmax(u(:)),MLin);
            cToUse = find(iUse);
            
            %% Left linear trials
            trialCriteria.direction = {'L'};
            leftTrialInfo = selecttrials(trialInfo,trialCriteria,mazeRegions);
            leftTrialNums = leftTrialInfo.trial;
            
            % Separate
            trialPathsLSep = extracttrials(leftTrialInfo,pathDataLin);
            tSpLSep = extracttrials(leftTrialInfo,tSp);
            xSpLSep = cell(size(tSpLSep));
            ySpLSep = cell(size(tSpLSep));
            nTrials = size(tSpLSep,1);
			for tr = 1:nTrials
                [xSpLSep(tr,iUse), ySpLSep(tr,iUse)] = cellfun(@(u)eventpos(u,trialPathsLSep(tr).x,trialPathsLSep(tr).y,trialPathsLSep(tr).t,trialPathsLSep(tr).v,vThresh),tSpLSep(tr,iUse),'uniformoutput',0);
			end
			
            MLSep = buildRateMap(trialPathsLSep,tSpLSep,xRangeLin,yRangeLin,binWidth);
% 			MLSep = dataanalyzer.makePlaceMaps.makecr2d(tSpLSep', {trialPathsLSep.x}, {trialPathsLSep.y}, {trialPathsLSep.t}, spatialRange, nBins)';
			
			[xSpLin(iUse), ySpLin(iUse)] = cellfun(@(u)eventpos(u,pathDataLin.x,pathDataLin.y,pathDataLin.t,vThresh),tSp(iUse),'uniformoutput',0);
            % Combined
            trialPathsLComb = contracttrials(leftTrialInfo,pathDataLin);
            tSpLComb = contracttrials(leftTrialInfo,tSp);
            xSpLComb = cell(size(tSpLComb));
            ySpLComb = cell(size(tSpLComb));
            [xSpLComb(iUse), ySpLComb(iUse)] = cellfun(@(u)eventpos(u,trialPathsLComb.x,trialPathsLComb.y,trialPathsLComb.t,trialPathsLComb.v,vThresh),tSpLComb(:,iUse),'uniformoutput',0);
            
			MLComb = buildRateMap(trialPathsLComb,tSpLComb,xRangeLin,yRangeLin,binWidth);
% 			MLComb = dataanalyzer.makePlaceMaps.makecr2d(tSpLComb(:), {trialPathsLComb.x}, {trialPathsLComb.y}, {trialPathsLComb.t}, spatialRange, nBins)';
            
            %% Right linear trials
            trialCriteria.direction = {'R'};
            rightTrialInfo = selecttrials(trialInfo,trialCriteria,mazeRegions);
            rightTrialNums = rightTrialInfo.trial;
            % Separate
            trialPathsRSep = extracttrials(rightTrialInfo,pathDataLin);
            tSpRSep = extracttrials(rightTrialInfo,tSp);
            xSpRSep = cell(size(tSpRSep));
            ySpRSep = cell(size(tSpRSep));
            nTrials = size(tSpRSep,1);
			for tr = 1:nTrials
                [xSpRSep(tr,iUse), ySpRSep(tr,iUse)] = cellfun(@(u)eventpos(u,trialPathsRSep(tr).x,trialPathsRSep(tr).y,trialPathsRSep(tr).t,trialPathsRSep(tr).v,vThresh),tSpRSep(tr,iUse),'uniformoutput',0);
			end
			
			MRSep = buildRateMap(trialPathsRSep,tSpRSep,xRangeLin,yRangeLin,binWidth);
% 			MRSep = dataanalyzer.makePlaceMaps.makecr2d(tSpRSep', {trialPathsRSep.x}, {trialPathsRSep.y}, {trialPathsRSep.t}, spatialRange, nBins)';
			
            % Combined
            trialPathsRComb = contracttrials(rightTrialInfo,pathDataLin);
            tSpRComb = contracttrials(rightTrialInfo,tSp);
            xSpRComb = cell(size(tSpRComb));
            ySpRComb = cell(size(tSpRComb));
            [xSpRComb(iUse), ySpRComb(iUse)] = cellfun(@(u)eventpos(u,trialPathsRComb.x,trialPathsRComb.y,trialPathsRComb.t,trialPathsRComb.v,vThresh),tSpRComb(:,iUse),'uniformoutput',0);
            
			MRComb = buildRateMap(trialPathsRComb,tSpRComb,xRangeLin,yRangeLin,binWidth);
% 			MRComb = dataanalyzer.makePlaceMaps.makecr2d(tSpRComb(:), {trialPathsRComb.x}, {trialPathsRComb.y}, {trialPathsRComb.t}, spatialRange, nBins);
            
            %% Plotting
            yLims = [-2 max(trialInfo.trial)+1];
            xLims = [0 360];
            yTicksL = [-2 -1 0 leftTrialNums' yLims(2)];
            yTicksR = [-2 -1 0 rightTrialNums' yLims(2)];
            yTickLabelsL = arrayfun(@(a)num2str(a),yTicksL,'uniformoutput',0);
            yTickLabelsL{1} = '';
            yTickLabelsL{2} = 'All';
            yTickLabelsL{3} = '';
            yTickLabelsL{end} = '';
            yTickLabelsR = arrayfun(@(a)num2str(a),yTicksR,'uniformoutput',0);
            yTickLabelsR{1} = '';
            yTickLabelsR{2} = 'All';
            yTickLabelsR{3} = '';
            yTickLabelsR{end} = '';
            
            iPlot = 0;
            clf;
			toc;
			for c = cToUse
                yLimRate = [0 ceil(max(max(MLComb{c}),max(MRComb{c})))];
                title0 = ['S' num2str(session) 'D' num2str(day) ' - C' num2str(cellIDs(c))];
                
                %% All trials
                iPlot = iPlot+1;
                subplot(nRows,nCols,iPlot)
                plot(pathData.x,pathData.y,'Color',[0.7 0.7 0.7]);
                hold on;
                plot(xSp{c},ySp{c},'r.');
                axis([xRange yRange]), axis square;
                title(title0,'FontSize',9);
                
                iPlot = iPlot+1;
                subplot(nRows,nCols,iPlot)
                plot(pathDataIdeal.x,pathDataIdeal.y,'Color',[0.7 0.7 0.7]);
                hold on;
                plot(xSpIdeal{c},ySpIdeal{c},'r.');
                axis([xRange yRange]), axis square;
                title(title0,'FontSize',9);
                
                iPlot = iPlot+1;
                subplot(nRows,nCols,iPlot)
                xTicks = plotLinearBounds(linBnds,diff(xRangeLin)/2*[-1 1]);
                hold on;
                plot(pathDataLin.x,pathDataLin.y,'Color',[0.7 0.7 0.7]);
                plot(xSpLin{c},ySpLin{c},'r.');
                
                axis([xRangeLin diff(xRangeLin)/2*[-1 1]]), %axis square;                
                title(title0,'FontSize',9);
                set(gca,'FontSize',9);
                set(gca,'XTick',xTicks,'XTickLabel',boundLabels,'FontSize',6);
                
                iPlot = iPlot+1;
                subplot(nRows,nCols,iPlot)
                pcolor(xAxis,yAxis,M{c}); shading flat;
                axis([xRange yRange]), axis square;
                title(title0,'FontSize',9);
                xlabel(['Peak: ' num2str(peakRate(c)) ' Hz'],'FontSize',9)
                
                iPlot = iPlot+1;
                subplot(nRows,nCols,iPlot)
                pcolor(xAxis,yAxis,MIdeal{c}); shading flat;
                axis([xRange yRange]), axis square;
                title(title0,'FontSize',9);
                xlabel(['Peak: ' num2str(peakRateIdeal(c)) ' Hz'],'FontSize',9)
                
                iPlot = iPlot+1;
                subplot(nRows,nCols,iPlot), hold on;        
                xTicks = plotLinearBounds(linBnds,diff(xRangeLin)/10*[-1 1],'line', [0.8 0.8 0.8]);
                pcolor(xAxisLin,binWidth/2*[-1 1],repmat(MLin{c},2,1)); shading flat;                
                axis([xRangeLin diff(xRangeLin)/10*[-1 1]]), % axis square;
                title(title0,'FontSize',9);
                xlabel(['Peak: ' num2str(peakRateLin(c)) ' Hz'],'FontSize',9)
                set(gca,'XTick',xTicks,'XTickLabel',boundLabels,'FontSize',6);
                
                %% Left trials
                iPlot = iPlot+1;
                subplot(nRows,nCols,iPlot); hold on;
                xTicks = plotLinearBounds(linBnds,yLims);
                % Path-Spike rasters - Separate
                for tr = 1:length(leftTrialNums);
                    trNum = leftTrialNums(tr);
                    plot(trialPathsLSep(tr).x,trNum*ones(size(trialPathsLSep(tr).x)),'Color',[0.7 0.7 0.7]);
                    plot(xSpLSep{tr,c},trNum*ones(size(xSpLSep{tr,c})),'r.');
                end
                % Path-Spike rasters - Combined
                plot(xAxisLin,zeros(size(xAxisLin)),'k','LineWidth',1);
                plot(trialPathsLComb.x,-1*ones(size(trialPathsLComb.x)),'Color',[0.7 0.7 0.7]);
                plot(xSpLComb{c},-1*ones(size(xSpLComb{c})),'r.');
                
                xlim(xLims),ylim(yLims);
                title('Left trials','FontSize',9);
                xlabel('Position (cm)','FontSize',9);
                ylabel('Trial number','FontSize',9);
                set(gca,'XTick',xTicks,'XTickLabel',boundLabels,'YTick',yTicksL,'YTickLabel',yTickLabelsL,'FontSize',6);
                
                iPlot = iPlot+1;
                subplot(nRows,nCols,iPlot); hold on; 
                xTicks = plotLinearBounds(linBnds,yLims,'line', [0.8 0.8 0.8]);
                % Rate maps - Separate
                for tr = 1:length(leftTrialNums)
                    trNum = leftTrialNums(tr);
                    pcolor(xAxisLin,trNum+[-0.5 0.5],repmat(MLSep{tr,c},2,1)); shading flat;
                end
                % Rate maps - Combined
                plot(xAxisLin,zeros(size(xAxisLin)),'k','LineWidth',1);
                pcolor(xAxisLin,-1+[-0.5 0.5],repmat(MLComb{c},2,1)); shading flat;
                xlim(xLims),ylim(yLims);
                title('Left trials','FontSize',9);
                xlabel('Position (cm)','FontSize',9);
                ylabel('Trial number','FontSize',9);
                set(gca,'XTick',xTicks,'XTickLabel',boundLabels,'YTick',yTicksL,'YTickLabels',yTickLabelsL,'FontSize',6);
                
                iPlot = iPlot+1;
                subplot(nRows,nCols,iPlot); hold on;
                % Rate v. Position
                interpRates = interp1(xAxisLin, MLComb{c},0:360,'linear');
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
                subplot(nRows,nCols,iPlot); hold on;
                xTicks = plotLinearBounds(linBnds,yLims);
                % Path-Spike rasters - Separate
                for tr = 1:length(rightTrialNums);
                    trNum = rightTrialNums(tr);
                    plot(trialPathsRSep(tr).x,trNum*ones(size(trialPathsRSep(tr).x)),'Color',[0.7 0.7 0.7]);
                    plot(xSpRSep{tr,c},trNum*ones(size(xSpRSep{tr,c})),'r.');
                end
                % Path-Spike rasters - Combined
                plot(xAxisLin,zeros(size(xAxisLin)),'k','LineWidth',1);
                plot(trialPathsRComb.x,-1*ones(size(trialPathsRComb.x)),'Color',[0.7 0.7 0.7]);
                plot(xSpRComb{c},-1*ones(size(xSpRComb{c})),'r.');
                xlim(xLims),ylim(yLims);
                title('Right trials','FontSize',9);
                xlabel('Position','FontSize',9);
                ylabel('Trial number','FontSize',9);
                set(gca,'XTick',xTicks,'XTickLabel',boundLabels,'YTick',yTicksR,'YTickLabels',yTickLabelsR,'FontSize',6);
                
                iPlot = iPlot+1;
                subplot(nRows,nCols,iPlot); hold on;
                xTicks = plotLinearBounds(linBnds,yLims,'line', [0.8 0.8 0.8]);
                % Rate maps - Separate
                for tr = 1:length(rightTrialNums)
                    trNum = rightTrialNums(tr);
                    pcolor(xAxisLin,trNum+[-0.5 0.5],repmat(MRSep{tr,c},2,1)); shading flat;
                end
                % Rate maps - Combined
                plot(xAxisLin,zeros(size(xAxisLin)),'k','LineWidth',1);
                pcolor(xAxisLin,-1+[-0.5 0.5],repmat(MRComb{c},2,1)); shading flat;
                
                xlim(xLims),ylim(yLims);
                title('Right trials','FontSize',9);
                xlabel('Position','FontSize',9);
                ylabel('Trial number','FontSize',9);
                set(gca,'XTick',xTicks,'XTickLabel',boundLabels,'YTick',yTicksR,'YTickLabels',yTickLabelsR,'FontSize',6);
                
                iPlot = iPlot+1;
                subplot(nRows,nCols,iPlot); hold on;
                % Rate v. Position
                interpRates = interp1(xAxisLin, MRComb{c},0:360,'linear');
                
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
				pdfInd(strcmpi(allBlockNames, block)) = pdfInd(strcmpi(allBlockNames, block)) + 1;

				pdfpage(h,[fileName, '_c', num2str(pdfInd(strcmpi(allBlockNames, block)))]);
				iPlot = 0;
				clf;                
			end
        end
%         addLast = iPlot > 0;
%         pdfpage(h,fileName,1,0);
    end
end
