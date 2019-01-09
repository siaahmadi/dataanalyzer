function [t, x, y, angle, n_samples] = ProcessVideoData_double(file)

borderX = [0 1000];
borderY = [0 1000];
sampRate = 30;
timeThreshold = .5;
speedlimit = 100; %in pixels/sec 

handles = readVideoData(file) %displays number of records
[dTargets,trackingColour] = decodeTargets(handles.targets);

[rx,ry,rtargets,exFlag] = extractPosition(dTargets,[0 1000],[0 1000],2);
[gx,gy,gtargets,exFlag] = extractPosition(dTargets,[0 1000],[0 1000],3);

n_samples = length(rx);

ind = find(rx == 0);
rx(ind) = NaN; %[];
ry(ind) = NaN; %[];
ind = find(gx == 0);
gx(ind) = NaN; %[];
gy(ind) = NaN; %[];

[gx,gy] = meanpath(gx,gy);
[rx,ry] = meanpath(rx,ry);

%if red and greed or more than 1.5 std apart than the mean, one of the
%tracking points is wrong; exclude from calculating xy coordinate
grdist = sqrt((rx-gx).*(rx-gx)+(ry-gy).*(ry-gy));
gr_factor = 2; %number of std
ind = find(grdist > nanmean(grdist)+nanstd(grdist)*gr_factor);

rx(ind) = NaN; %[];
ry(ind) = NaN; %[];
gx(ind) = NaN; %[];
gy(ind) = NaN; %[];


%[rx,ry,rtargets,exFlag] = removeJumps_sl(rtargets,[0 1000],[0 1000],2,speedlimit);
%[gx,gy,gtargets,exFlag] = removeJumps_sl(gtargets,[0 1000],[0 1000],3,speedlimit);

[rx,ry] = interpolatePosition_sl(rx,ry,timeThreshold,sampRate);
[gx,gy] = interpolatePosition_sl(gx,gy,timeThreshold,sampRate);
%
rx = double(rx); ry = double(ry);
gx = double(gx); gy = double(gy);

t = handles.post; %t = t';
x = (rx+gx)/2; x = x';
y = (ry+gy)/2; y = y';

% fh = figure(); plot(gx,gy,'g'); hold on; plot(rx,ry,'r'); plot(x,y,'b'); 
% saveas(fh,strcat(save_dir,'_Tracking.bmp')); 
% saveas(fh,strcat(save_dir,'_Tracking.ai'),'epsc'); 
% close(fh);
%figure(2); for i=1:100:length(gx)-100 hold off; plot(gx(i:i+100),gy(i:i+100),'g.'); hold on; plot(rx(i:i+100),ry(i:i+100),'r.'); plot(posx(i:i+100),posy(i:i+100),'b.'); axis([300 700 0 400]); pause; end

%if red and greed are more or less than 1.5 std from the mean, angle is likely 
%inaccurate; exclude from calculating angle
ind = find(grdist > nanmean(grdist)+nanstd(grdist)*gr_factor | grdist < nanmean(grdist)-nanstd(grdist)*gr_factor);
rx(ind) = NaN; %[];
ry(ind) = NaN; %[];
gx(ind) = NaN; %[];
gy(ind) = NaN; %[];

angle = cart2pol(rx-gx,ry-gy); angle = angle'; 

function [x,y] = meanpath(x,y)

temp_x = NaN(size(x));
temp_y = NaN(size(y));
for cc=8:length(x)-7
  x_window = x(cc-7:cc+7); y_window = y(cc-7:cc+7);
  temp_x(cc) = nanmean(x_window); temp_y(cc) = nanmean(y_window);
end

x = temp_x;
y = temp_y;

function [x,y] = interpolatePosition_sl(x,y,timeThreshold,sampRate)

sampThreshold = floor(timeThreshold * sampRate);

index_isvalid = find(~isnan(x) & ~isnan(y));
count_NaNs = 0;
for i = index_isvalid(1):index_isvalid(end)
    if isnan(x(i)) || isnan(y(i)) 
        count_NaNs = count_NaNs+1;
    else
        if count_NaNs > 0 && count_NaNs < sampThreshold
            for j = last_valid+1:i-1
                x(j) = (x(i)*(j-last_valid)+x(last_valid)*(i-j))/(i-last_valid);
                y(j) = (y(i)*(j-last_valid)+y(last_valid)*(i-j))/(i-last_valid);
            end
        end
    last_valid = i;
    count_NaNs = 0;
    end
end

            
    


