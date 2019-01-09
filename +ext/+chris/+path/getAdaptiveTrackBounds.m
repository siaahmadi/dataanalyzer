
function [xBound yBound xNew yNew] = getAdaptiveTrackBounds(x,y,maxDev,params,subplotNum)
bndInds = find(isnan(x)==1);
% xTmp = mpR.pathData.x;
% yTmp = mpR.pathData.y;

numRuns = length(bndInds)-1;

xTmp = x;
yTmp = y;
xLens = zeros(numRuns,1);
x0 = zeros(numRuns,1);
xF = zeros(numRuns,1);
yMax = zeros(numRuns,1);
yMin = zeros(numRuns,1);
yMean = zeros(numRuns,1);
xNew = nan;
yNew = nan;
angToPath = zeros(numRuns,1);
if nargin<3
    [pAll, ~] = polyfit(xTmp(~isnan(xTmp) & xTmp<=.8*max(xTmp)),yTmp(~isnan(xTmp) & xTmp<=.8*max(xTmp)),1);
else
    pAll = params.p2;
end
xLensAll = max(xTmp)-min(xTmp);
if nargin == 4
    figure;
    sp = 0;
else
    sp = 1;
end
for r = 1:numRuns
    x = xTmp(bndInds(r)+1:bndInds(r+1)-1);
    y = yTmp(bndInds(r)+1:bndInds(r+1)-1);
    if max(x)-min(x)<=.6*xLensAll
        angToPath(r) = nan;
        xLens(r) = nan;
        x0(r) = nan;
        xF(r) = nan;
        yMax(r) = nan;
        yMin(r) = nan;
        yMean(r) = nan;
        if sp
            subplot(3,3,subplotNum)
        end
        plot(x,y,'m');
        
        hold on;
    else
        %     dRes = inf;
        %     res = inf;
        %
        %     p = 0;
        %     while (dRes>1 || res>10) && p<length(x)
        %         p = p+1;
        %         [pThis, s] = polyfit(x(p:end),y(p:end),1);
        %         res = s.normr;
        %         if p > 1
        %             dRes = abs(res-lastRes);
        %         end
        %         lastRes = res;
        %     end
        %     angToPath(r) = getRelativeAngle([x(p) x(end)],[x(p)*pThis(1)+pThis(2) x(end)*pThis(1)+pThis(2)],max(xTmp),max(xTmp)*pAll(1)+pAll(2),1);
        %     xLens(r) = abs(x(end)-x(p));
        %     lens(r) = norm([x(end)-x(p) y(end)-y(p)]);
        %     if angToPath(r)>0.2 || xLens(r)<= .60*xLensAll
        %         plot(x(p:end),y(p:end),'r-')
        %     else
        %         plot(x(p:end),y(p:end),'b-')
        %     end
        %     x0(r) = x(p);
        %     yMax(r) = max(y(p:end));
        %     yMin(r) = min(y(p:end));
        %     xNew = cat(2,xNew,[x(p:end) nan]);
        %     yNew = cat(2,yNew,[y(p:end) nan]);
        dRes0 = inf;
        res0 = inf;
        iMid = floor(length(x)*.8);
        p0 = 0;
        while (dRes0>1 || res0>10) && p0<iMid
            p0 = p0+1;
            [~, s] = polyfit(x(p0:iMid),y(p0:iMid),1);
            res0 = s.normr;
            if p0 > 1
                dRes0 = abs(res0-lastRes);
            end
            lastRes = res0;
        end
        resF = inf;
        dResF = inf;
        pF = length(x)+1;
        while (dResF>1 || resF>inf) && pF>p0+1
            pF = pF-1;
            [~, s] = polyfit(x(p0:pF),y(p0:pF),1);
            resF = s.normr;
            if pF < length(x)
                dResF = abs(resF-lastRes);
            end
            lastRes = resF;
        end
        yStand = y(p0:pF)-mean(y(p0:pF));
        if x(pF)-x(p0)<.5*xLensAll || max(abs(yStand))>maxDev
            angToPath(r) = nan;
            xLens(r) = nan;
            x0(r) = nan;
            xF(r) = nan;
            yMax(r) = nan;
            yMin(r) = nan;
            yMean(r) = nan;
            if sp
                subplot(3,3,subplotNum)
            end
            plot(x,y,'m');
            hold on;
        else
            [pThis,~] = polyfit(x(p0:pF),y(p0:pF),1);
            angToPath(r) = getRelativeAngle([x(p0) x(pF)],[x(p0) x(pF)]*pThis(1)+pThis(2),x(pF),x(pF)*pAll(1)+pAll(2),1);
            
            xLens(r) = abs(max(x)-min(x));
            if sp
                subplot(3,3,subplotNum)
            end
            plot(x,y,'k-')
            hold on
            
            if angToPath(r)>0.4 || xLens(r)<= .60*xLensAll
                plot(x(p0:pF),y(p0:pF),'r-')
            else
                plot(x(p0:pF),y(p0:pF),'b-')
            end
            
            x0(r) = x(p0);
            xF(r) = x(pF);
            
            yMax(r) = max(yStand);%max(y(p0:pF));
            yMin(r) = min(yStand);%min(y(p0:pF));
            yMean(r) = mean(y(p0:pF));
            
            %xNew = cat(2,xNew,[x(p0:pF) nan]);
        end
    end
    
    
end
toUse = ~isnan(angToPath);
% xBound = median(x0(toUse));
xBound = [median(x0(toUse)) median(xF(toUse))];
% yBound = max(abs(prctile(yMax,85)),abs(prctile(yMin,15)));
yBound = max(abs(max(yMax(toUse))),abs(min(yMin(toUse))));%max(abs(prctile(yMax(toUse),80)),abs(prctile(yMin(toUse),20))); %max(abs(max(yMax(toUse))),abs(min(yMin(toUse))));
% for r = 1:numRuns
%     x = xTmp(bndInds(r)+1:bndInds(r+1)-1);
%     y = yTmp(bndInds(r)+1:bndInds(r+1)-1);
%     if min(x)<=xBound(1) && max(x)>=xBound(2)
%         xNew = cat(2,xNew,[x nan]);
%         yNew = cat(2,yNew,[y nan]);
%     end
% end
% plot([xBound xBound],[-yBound yBound],'k-');
% plot([xBound nanmax(xNew)],[-yBound -yBound],'k-');
% plot([xBound nanmax(xNew)],[yBound yBound],'k-');
% plot([nanmax(xNew) nanmax(xNew)],[-yBound yBound],'k-');
plot([xBound(1) xBound(1)],[-yBound yBound]+mean(yMean(toUse)),'k-');
plot([xBound(1) xBound(2)],[-yBound -yBound]+mean(yMean(toUse)),'k-');
plot([xBound(1) xBound(2)],[yBound yBound]+mean(yMean(toUse)),'k-');
plot([xBound(2) xBound(2)],[-yBound yBound]+mean(yMean(toUse)),'k-');
set(gca,'ylim',[-75 75],'xlim',[-75 75])
hold off;