function [t, x, y, angle,n_samples] = ProcessVideoData(file,diode)
%diode: 0 - luminance, 1 - doublediode (processed by a separate function),
%2 - red, 3 - green

handles = readVideoData(file); %displays number of records
[dTargets,trackingColour] = decodeTargets(handles.targets);

if ~exist('diode','var')||isempty(diode)
    diode = 0;
end
switch diode
    case 1 % double diode, process with a separate function
        [t, x, y, angle, n_samples] = ProcessVideoData_double(file);
        return
    case 2 % Use red signal
        [x,y,targets,exFlag] = extractPosition(dTargets,[0 1000],[0 1000],2);
        x = x'; y = y'; t = handles.post;
    case 3 % Use Green Signal
        [x,y,targets,exFlag] = extractPosition(dTargets,[0 1000],[0 1000],3);
        x = x'; y = y'; t = handles.post;
    otherwise % Use luminance
        [x,y,targets,exFlag] = extractPosition(dTargets,[0 1000],[0 1000],1);
        x = x'; y = y'; t = handles.post;
end
   

n_samples = length(x);
% Suppress postions at [0,0] because this is caused by bad tracking
%[x,y,t] = suppressZeros(x,y,t);
    
ind = x==0;
%t(ind) = NaN; %[];
x(ind) = NaN; %[];
y(ind) = NaN; %[];

[x,y] = meanpath(x,y);

angle(1:15) = NaN;
for i = 16:(length(x)-15)
    %disp(i);
    if (x(i+15) == x(i-15)) && (y(i+15) == y(i-15))
        angle = NaN;
    else
        [a, d] = cart2pol(x(i+15)-x(i-15),y(i+15)-y(i-15));
        angle(i) = a;
    end
end 
angle((length(x)-14):length(x)) = NaN;

% if exist('save_dir','var')&&~isempty(save_dir)
% fh = figure(); 
% plot(x,y,'b'); 
% saveas(fh,strcat(save_dir,'_Tracking.bmp')); 
% saveas(fh,strcat(save_dir,'_Tracking.ai'),'epsc');
% hold on
% close(fh);
% end
%figure(2); for i=1:100:length(gx)-100 hold off; plot(gx(i:i+100),gy(i:i+100),'g.'); hold on; plot(rx(i:i+100),ry(i:i+100),'r.'); plot(posx(i:i+100),posy(i:i+100),'b.'); axis([300 700 0 400]); pause; end

function [x,y] = meanpath(x,y)

temp_x = NaN(size(x));
temp_y = NaN(size(y));
for cc=8:length(x)-7
  x_window = x(cc-7:cc+7); y_window = y(cc-7:cc+7);
  temp_x(cc) = nanmean(x_window); temp_y(cc) = nanmean(y_window);
end

x = temp_x;
y = temp_y;