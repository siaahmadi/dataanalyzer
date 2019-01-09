function [indata p] = adjust_coordinates_LT(indata,useAdaptiveBounds,wholeTrackLength,pctRewardDist)
n_sessions = length(indata);
xAll = [];
yAll = [];
tAll = [];
aAll = [];

for ii = 1:n_sessions
    xAll = cat(1,xAll,indata(ii).x);
    yAll = cat(1,yAll,indata(ii).y);
    tAll = cat(1,tAll,indata(ii).t);
    aAll = cat(1,aAll,indata(ii).angle);
end
xCutoff = target/4;
hFig = figure;
[~,~,~,p] = adjustToHorizontal(xAll,yAll,wholeTrackLength,xCutoff,1,hFig);
indata_L(n_sessions,1) = struct('x',[],'y',[],'t',[],'angle',[],'v',[]);
indata_R = indata_L;
velocityLeft{n_sessions,1} = [];
velocityRight = velocityLeft;
speedLeft(n_sessions,1) = 0;
speedRight = speedLeft;

p.xCutoff = pctRewardDist/100*rewardDistance/2;
for ii=1:n_sessions
    [indata(ii).x,indata(ii).y,inBounds{ii}] = ...
        adjustToHorizontal(indata(ii).x,indata(ii).y,p);
    indata(ii).v = calcVel(indata(ii).x,indata(ii).t);
    speed(ii) = mean(abs(velocity{ii}));
    lefts = indata(ii).v<-2 & inBounds{ii};
    leftRuns{ii} = eliminateShortRuns(lefts);
    rights = indata(ii).v>2 & inBounds{ii};
    rightRuns{ii} = eliminateShortRuns(rights);
    dataFields = fields(indata);
    for dF = 1:length(dataFields)
        indata_L(ii).(dataFields(dF)) = indata(ii).(dataFields(dF));
        indata_R(ii).(dataFields(dF)) = indata(ii).(dataFields(dF));
        indata_L(ii).(dataFields(dF))(~leftRuns{ii}) = NaN;
        indata_R(ii).(dataFields(dF))(~rightRuns{ii}) = NaN;
        indata_L(ii).(dataFields(dF)) = removeExcessNans(indata_L(ii).(dataFields(dF)));
        indata_R(ii).(dataFields(dF)) = removeExcessNans(indata_R(ii).(dataFields(dF)));
    end
end
if adjustForOneSidedTracking
    meanLeftY = nanmean([indata_L.y]);
    meanRightY = nanmean([indata_R.y]);
    p.adjustForOneSidedTracking = 1;
    p.leftShift = -meanLeftY;
    p.rightShift = -meanRightY;
    for ii=1:n_sessions
        indata_L(ii).y = indata_L(ii).y-meanLeftY;
        indata_R(ii).y = indata_R(ii).y-meanRightY;
    end
else
    p.adjustForOneSidedTracking = 0;
    p.leftShift = 0;
    p.rightShift = 0;
end
subplot(3,3,4)
plot(indata_L(ii).x,indata_L(ii).y); set(gca,'ylim',[-75 75],'xlim',[-75 75])
subplot(3,3,7)
plot(indata_R(ii).x,indata_R(ii).y); set(gca,'ylim',[-75 75],'xlim',[-75 75])

p.maxDeviationFromZero = maxDeviationFromZero;
if maxDeviationFromZero<inf
    for ii=1:n_sessions
        if useAdaptiveBounds
            indata_L(ii).x = -indata_L(ii).x;
            [xBoundL yBoundL] = getAdaptiveTrackBounds(indata_L(ii).x,indata_L(ii).y,maxDeviationFromZero,p,5);
            maxDevL = min(yBoundL,maxDeviationFromZero);
            [indata_L(ii) vl] = eliminateDeviatingPassesAdaptive(indata_L(ii),indata_L(ii).v,maxDevL,xBoundL);%maxDeviationFromZero);            
            indata_L(ii).x = -indata_L(ii).x;
            xBoundL = sort(-xBoundL);
            [xBoundR yBoundR] = getAdaptiveTrackBounds(indata_R(ii).x,indata_R(ii).y,maxDeviationFromZero,p,8);
            maxDevR = min(yBoundR,maxDeviationFromZero);
            [indata_R(ii) vr] = eliminateDeviatingPassesAdaptive(indata_R(ii),indata_R(ii).v,maxDevR,xBoundR);%maxDeviationFromZero);
            indata_R(ii).xBoundL = xBoundL;
            indata_R(ii).xBoundR = xBoundR;
            
        else
            [indata_L(ii) vl] = eliminateDeviatingPasses(pathDataLeft(ii),velocityLeft{ii},maxDeviationFromZero);
            [indata_R(ii) vr] = eliminateDeviatingPasses(pathDataRight(ii),velocityRight{ii},maxDeviationFromZero);
        end
        indata_L(ii).v = vl;
        indata_R(ii).v = vr;
        
        indata_L(ii).n_samples = length(vl(~isnan(vl)));
        indata_L(ii).n_trackingPoints = indata_L(ii).n_samples;
        indata_L(ii).n_NaNPoints = length(vl(isnan(vl)));
        
        indata_R(ii).n_samples = length(vr(~isnan(vr)));
        indata_R(ii).n_trackingPoints = indata_R(ii).n_samples;
        indata_R(ii).n_NaNPoints = length(vr(isnan(vr)));
    end
end
subplot(3,3,6)
plot(indata_L(ii).x,indata_L(ii).y); set(gca,'ylim',[-75 75],'xlim',[-75 75])
subplot(3,3,9)
plot(indata_R(ii).x,indata_R(ii).y); set(gca,'ylim',[-75 75],'xlim',[-75 75])
set(figure(hFig),'PaperUnits','inches','PaperPosition',[0 0 8.5 11],'PaperSize',[8.5 11])

indata(n_sessions,1) = struct('x',[],'y',[],'t',[],'angle',[],'v',[],'n_samples',[],'n_trackingPoints',[],'n_NaNPoints',[]);
for ii=1:n_sessions
    t = [indata_L(ii).t indata_R(ii).t];
    [~,ti] = sort(t);
    dataFields = fields(indata);
    for dF = 1:length(dataFields)
        tmp.(dataField(dF)) = [indata_L(ii).(dataField(dF)) indata_R(ii).(dataField(dF))];
        indata(ii).(dataField(dF)) = tmp.(dataField(dF))(ti);
    end
    indata(ii).n_samples = length(t(~isnan(t)));
    indata(ii).n_trackingPoints = length(t(~isnan(t)));
    indata(ii).n_NaNPoints = length(t(isnan(t)));
end
tmpData.L = indata_L;
tmpData.R = indata_R;
tmpData.LR = indata;
indata = tmpData;



function velocity = calcVel(x,t)
%x and t are already in cm and sec at this point.
diffx = diff(x);
difft = diff(t);
pointRate = diffx./difft;
pointRate = [nan(1,7),pointRate,nan(1,7)];
velocity = arrayfun(@(x)nanmean(pointRate(x-7:x+7)),8:(length(diffx)+7));
velocity = [velocity(1),velocity];

function newInds = eliminateShortRuns(inds,cutoff)
ct = continuousRunsOfTrue(inds);
if ~exist('cutoff','var')
    cutoff = prctile(ct(:,2)-ct(:,1),10);
end
tooshort = arrayfun(@(x)diff(ct(x,:))<cutoff,1:size(ct,1));
ct(tooshort,:) = [];
newInds = false(size(inds));
for i=1:size(ct,1)
    newInds(ct(i,1):ct(i,2)) = 1;
end

function [pathData vel] = eliminateDeviatingPassesAdaptive(pathData,vel,maxDeviationFromZero,xBound)
bndInds = find(isnan(pathData.x));
numRuns = length(bndInds)-1;
x2 = nan;
y2 = nan;
t2 = nan;
v2 = nan;
for r = 1:numRuns
    x = pathData.x(bndInds(r)+1:bndInds(r+1)-1);
    y = pathData.y(bndInds(r)+1:bndInds(r+1)-1);
    t = pathData.t(bndInds(r)+1:bndInds(r+1)-1);
    v = vel(bndInds(r)+1:bndInds(r+1)-1);
    if abs(min(x)-max(x)) >= abs(diff(xBound)) %min(x)<=xBound(1) && max(x)>=xBound(2)
        x2 = cat(2,x2,[x nan]);
        y2 = cat(2,y2,[y nan]);
        t2 = cat(2,t2,[t,nan]);
        v2 = cat(2,v2,[v,nan]);
    end
end
pathData.x = x2;
pathData.y = y2;
pathData.t = t2;
vel = v2;

newY = pathData.y-nanmean(pathData.y);
%xRange = [min(pathData.x) max(pathData.x)];xDist = diff(xRange);
dev = abs(newY)>maxDeviationFromZero&~isnan(newY);
inInner = pathData.x>=xBound(1) & pathData.x<=xBound(2); %pathData.x>xRange(1)+.05*xDist&pathData.x<xRange(2)-.05*xDist;
devInInterior = dev&inInner;
runs = continuousRunsOfTrue(~isnan(newY));
discard = find(arrayfun(@(x)any(devInInterior(runs(x,1):runs(x,2))),1:size(runs,1)));
runs(:,2) = runs(:,2)+1; %this includes the nan at the end so that it can be eliminated if we're eliminating a run
if runs(end,2)>length(newY)
    runs(end,2) = runs(end,2)-1;
end
for i=length(discard):-1:1
    pathData.x(runs(discard(i),1):runs(discard(i),2)) = [];
    pathData.y(runs(discard(i),1):runs(discard(i),2)) = [];
    pathData.t(runs(discard(i),1):runs(discard(i),2)) = [];
    vel(runs(discard(i),1):runs(discard(i),2)) = [];
end
inOuter = pathData.x<xBound(1) | pathData.x>xBound(2);
pathData.x = pathData.x(~inOuter);
pathData.y = pathData.y(~inOuter);
pathData.t = pathData.t(~inOuter);
vel = vel(~inOuter);
pathData.x = removeExcessNans(pathData.x);
pathData.y = removeExcessNans(pathData.y);
pathData.t = removeExcessNans(pathData.t);
vel = removeExcessNans(vel);

function [pathData vel] = eliminateDeviatingPasses(pathData,vel,maxDeviationFromZero)
newY = pathData.y-nanmean(pathData.y);
xRange = [min(pathData.x) max(pathData.x)];xDist = diff(xRange);
dev = abs(newY)>maxDeviationFromZero&~isnan(newY);
inInner = pathData.x>xRange(1)+.05*xDist&pathData.x<xRange(2)-.05*xDist;
devInInterior = dev&inInner;
runs = continuousRunsOfTrue(~isnan(newY));
discard = find(arrayfun(@(x)any(devInInterior(runs(x,1):runs(x,2))),1:size(runs,1)));
runs(:,2) = runs(:,2)+1; %this includes the nan at the end so that it can be eliminated if we're eliminating a run
if runs(end,2)>length(newY)
    runs(end,2) = runs(end,2)-1;
end
for i=length(discard):-1:1
    pathData.x(runs(discard(i),1):runs(discard(i),2)) = [];
    pathData.y(runs(discard(i),1):runs(discard(i),2)) = [];
    pathData.t(runs(discard(i),1):runs(discard(i),2)) = [];
    vel(runs(discard(i),1):runs(discard(i),2)) = [];
end

function v = removeExcessNans(v)
ct = continuousRunsOfTrue(isnan(v));
ct(:,1) = ct(:,1)+1;
inds = [];
for i=1:size(ct,1)
    inds = [inds,ct(i,1):ct(i,2)];
end
v(inds) = [];
