function [ REMStart REMStop1 REMStop2 REMDur] = startREM(path,bestCh,figON,prevREMStarts,varargin)
if nargin>4
extract_varargin;
varargin{:};
end
%secStart tsStart duration]
if ~exist('LFPSignal');
cd(path)
L = readCSC(['CSC',num2str(bestCh),'.ncs']);
else
    L = LFPSignal;
    L.samp = L.dat{1};
end
tapers = [5 9];
pad = 0;
err = [2, .05];
fpass = [1,20];
winsize = 10;
winstep = 1;

params.tapers = tapers; 
%1st parameter time-bandwidth product, e.g, 5 sec window, 1 Hz bandwidth; 10 sec window, 0.5 Hz bandwidth
%2nd parameter number of tapers; max should be 2*time*bandwidth-1
params.pad = pad;
params.err = err;
params.fpass = fpass;
movingwin = [winsize winstep];
params.Fs = L.sampFreq(1);

[S,t,f,Serr]=mtspecgramc(L.samp,movingwin,params);

% for each second, find theta/delta ratio
[r p1 p2] = REM_start.bbratio(S,f,[6 10],[2 4],'avg');

if figON
REMFigure = figure;
subplot(2,1,1);
imagesc(t,f,S');
set(gca,'ydir','norm','clim',[0 max(S(f>6 & f<8))]); hold on;
subplot(2,1,2);
plot(smooth(r,9),'k')
hold on; 
plot(r,'color',[.5 .5 .5]);
plot([1 length(r)],[2 2],'r')
axis tight;
title(path);
end


%find starts and stops
logicalTheta = logical(r>2);
if sum(logicalTheta)>0;
[start, stop] = REM_start.start_stopForSeizure(logicalTheta);

else
    clear r
    for i = 1:size(S,1)
    delta(i)= mean(S(i,f>2 & f<4));
    theta(i) = mean(S(i,f>6 & f<8));
    
    r(i)=theta(i)/delta(i);
    end
   logicalTheta = logical(r>1.5);
[start, stop] = REM_start.start_stopForSeizure(logicalTheta); 
end
% -- merge events within 25 seconds of each other 

interval_threshold = 60;
logical_interval = zeros(numel(start)-1,1);

for k = 1:numel(start)-1;
    
    logical_interval(k) = (start(k+1)-stop(k)) < interval_threshold;
    
end

logical_interval = logical(logical_interval);

start([false ; logical_interval]) = [];
stop([logical_interval ; false]) = [];

%events must be at least 10 seconds long;
dur = stop-start;
logical_dur = dur < 10;

start(logical_dur) = [];
stop(logical_dur) = [];
dur = stop-start;



% %test = find(smooth(tdRatio,9)>2);
% test = find(tdRatio>2);
% if length(test)<10;
%     test = find(tdRatio>1.5); disp('Not a great singal, ratio > than 1.5')
% end

% test2=test(find(diff(test)>25)+1)
% test2 = max(test2);
% if isempty(test2)
%     test2 = test(1);
% end
% 
% plot([test2 test2],[0 15],'m');

%  % put this in for the case when we put together preSez and seiz.
%  if nargin<5
%  keepInd = stop<295; start = start(keepInd); 
%  end
 
 if prevREMStarts
     
     [a b] = min(abs(start-oldREMStart));
     REMStart = start(b)+5;
     
    REMStop1 = stop(b)+5;
    REMDur=dur(b);
     
 end
 
 if ~prevREMStarts
 REMStart = start(end)+5;
stop = stop(end); 
 REMStop = stop(end)+5;
 REMStop1 = REMStop;
 dur =dur(end); 
 REMDur = dur;
 end

if exist('seizureStart');
   
    if REMStop> seizureStart
        REMStop1 = REMStop;
        REMStop2 = seizureStart;
    end
end
 
 if ~exist('REMStop2')
     REMStop2= REMStop1;
 end
 
 
 
 if figON
     if prevREMStarts
 plot([start(b)';start(b)'],[0;20],'m');
 plot([stop(b)';stop(b)'], [0;20], 'k');
     end
     if ~prevREMStarts
 plot([start(end)';start(end)'],[0;20],'m');
 plot([stop(end)';stop(end)'], [0;20], 'k'); 
     end

end


end

