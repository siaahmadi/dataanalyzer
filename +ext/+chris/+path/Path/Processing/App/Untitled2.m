path = 4;
c = 12;
nTrials = size(trialInfo(path).inds,1);
xMax = max(template.L.d);
pad = 50;
bgc = {[0.9 0.9 0.9],[0.95 0.95 0.95]};
h = figure;
regions = fields(locBnds);

for c = [6:8 19:25]
    clf;
    for path = 1:4
        subplot(4,1,path)
        hold on;
        for r = 1:length(regions)
            if mod(r,2) == 0
                iC = 2;
            else
                iC = 1;
            end
            [xR yR] = rectcoords(diff(locBnds.(regions{r})),nTrials+2,locBnds.(regions{r})(1),-1);
            fill(xR,yR,bgc{iC},'EdgeColor','none');
            fill(xR+xMax+pad,yR,bgc{iC},'EdgeColor','none');
        end
        for tr = 1:nTrials
            direction = trialInfo(path).direction{tr};
            switch direction
                case 'L'
                    x0 = 0;
                case 'R'
                    x0 = xMax+pad;
            end
            inds = trialInfo(path).inds(tr,1):trialInfo(path).inds(tr,2);
            spInds = in(tSp{path,c},minmax(pathData(path).t(inds)),[],1);
           	
            xSp = eventpos(tSp{path,c}(spInds),pathDataLin(path).x(inds),pathDataLin(path).y(inds),pathData(path).t(inds),40);
            [xSp ySp] = data2tick(xSp,tr,0.8);
            plot(pathDataLin(path).x(inds)+x0,tr*ones(size(pathDataLin(path).x(inds))),'Color',[0.5 0.5 0.5]);
%             plot(template.(direction).d+x0,tr*ones(size(template.(direction).d)),'Color',[0.5 0.5 0.5]);
            hold on;
            plot(xSp+x0,ySp,'r')
            
            correct = trialInfo(path).success(tr);
            if correct
                mark = 'bp';               
            else
                mark = 'rx';
            end
            plot(xMax+pad/2,tr,mark,'MarkerSize',5);
        end
        title([sessDirs{path} ' - ' TList{c}]);
        ylabel('Trial')
        xlim([0 2*xMax+pad])
        ylim([-1 nTrials+1]);
    end
    
    pdfpage(h,'Fig8RasterTest2',0);
end
pdfpage(h,'Fig8RasterTest2',1,0);

