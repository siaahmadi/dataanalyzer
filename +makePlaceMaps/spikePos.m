% Finds the position of the spikes
% If spikeToPositionMode is 'bin', it assigns each spike to the nearest
% (x,y) coordinate that is recorded in (posx,posy).  If
% spikeToPoisitionMode is 'interpolate', it uses linear interpolation to
% assign a position between those recorded in (posx,posy).
% As of 9/5/10 this function is called from NlxBinFinder5 - EM

function [spkx,spky] = spikePos(ts,posx,posy,post,spikeToPositionMode,samplingThreshold_sec,samplingThreshold_cm)
if ~exist('spikeToPositionMode','var')
    spikeToPositionMode = 'interpolate';
end
if ~exist('samplingThreshold_sec','var')
    samplingThreshold_sec = .5;
end
if ~exist('samplingThreshold_cm','var')
    samplingThreshold_cm = 2;
end
nSpikes = length(ts);
nPos = length(post);
spkx = nan(nSpikes,1);
spky = nan(nSpikes,1);

nanInds = isnan(posx+posy+post);
posx(nanInds) = [];
posy(nanInds) = [];
post(nanInds) = [];

ts = sort(ts);
[post inds] = sort(post);
posx = posx(inds);
posy = posy(inds);

[n, bin] = histc(ts,post);
bins = unique(bin);
bins = bins(bins>0);
for i=1:length(bins)
    [spkx(bin==bins(i)) returnedNAN] = calculatePosition(ts(bin==bins(i)),[posx(bins(i)),posx(bins(i)+1)],[post(bins(i)),post(bins(i)+1)],spikeToPositionMode,samplingThreshold_sec,samplingThreshold_cm);
    if ~returnedNAN
        [spky(bin==bins(i)) returnedNAN] = calculatePosition(ts(bin==bins(i)),[posy(bins(i)),posy(bins(i)+1)],[post(bins(i)),post(bins(i)+1)],spikeToPositionMode,samplingThreshold_sec,samplingThreshold_cm);
        if returnedNAN
            spkx(bin==bins(i)) = NaN;
        end
    else
        spky(bin==bins(i)) = NaN;
    end
end
disp(['Of ',num2str(length(ts)),' spikes, ',num2str(sum(isnan(spkx))),' spikes were not assigned to positions.'])
if sum(isnan(spkx))~=sum(isnan(spky))
    error('Should never have gotten here.  This is a coding error!!')
end

% Calculates the (single dimensional) location of a spike (thus spkx and
% spky are computed separately above).  If too many sampling points have
% been dropped (due to bad tracking, for example), we don't want to claim
% to know where the spike was.  If the time between samples is greater than
% samplingThreshold_sec, we will still keep the spike if the distance
% between samples is less than samplingThresh_cm.  Otherwise, we return
% NaN.
function [position returnedNAN] = calculatePosition(spikeTimes,pos,posTimes,mode,samplingThreshold_sec,samplingThreshold_cm)
position = nan(size(spikeTimes));
if diff(posTimes)<samplingThreshold_sec | abs(diff(pos))<samplingThreshold_cm
    returnedNAN = 0;
    switch mode
    case 'bin'
        halfway = mean(posTimes);
        position(spikeTimes<=halfway) = posTimes(1);
        position(spikeTimes>halfway) = posTimes(2);
    case 'interpolate'
        T = (spikeTimes - posTimes(1))/(posTimes(2)-posTimes(1));
        position = pos(1)+T*diff(pos);
    end
else
    returnedNAN = 1;
end


