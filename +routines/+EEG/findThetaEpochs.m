function  Th  = findThetaEpochs( pathToData,bestCh,thetaDeltaThreshold,mergeThreshold)
%pathToData = 'pathToCSC'
%bestCh = [tetrode # with strong theta signal]
%thetaDeltaThreshold = [# that you think is a good threhold, usually 2]
%mergeThreshold = [two theta events that are this far apart in seconds will
%be merged]

    cd(pathToData);
    L = readCSC(['CSC',num2str(bestCh),'.ncs']);
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
   



REMFigure = figure;
subplot(2,1,1);
imagesc(t,f,S');
set(gca,'ydir','norm','clim',[0 mean(S(f>4 & f<12))*1.2]); hold on;
subplot(2,1,2);
plot(r,'k');
hold on; 
plot([1 length(r)],[2 2],'r'); axis tight;

%find starts and stops
logicalTheta = logical(r>thetaDeltaThreshold);
[start, stop] = REM_start.start_stop(logicalTheta);

% -- merge events within x (25 in past) seconds of each other 

interval_threshold = mergeThreshold;
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

 plot([start';start'],[0;20],'m');
 plot([stop';stop'], [0;20], 'k');


Th.S = S;
Th.t=t;
Th.f=f;
Th.Serr= Serr;
Th.Ch = bestCh;
Th.start = start;
Th.stop = stop;
Th.dur = dur;

saveas(gcf,'ThetaEpochs_2.5','fig');
save Th Th
close all
end


