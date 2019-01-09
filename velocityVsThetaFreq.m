function [Vel_Bins, Freq_avg, Specg_avg, f] = velocityVsThetaFreq(pathToSession, tt, numBins, maxVelPlot)


dsrate = 32;
if ~exist('numBins', 'var') || isempty(numBins)
	numBins = 24;
end
if ~exist('maxVelPlot', 'var') || isempty(maxVelPlot)
	maxVelPlot = 30; % cm/s
end

[videoTS, videoX, videoY] = Nlx2MatVT(fullfile(pathToSession, 'VT1.nvt'), [1 1 1 0 0 0], 0, 1, 1);

x = videoX; x(x==0) = NaN;
y = videoY; y(y==0) = NaN;

idx = find(isnan(x));
x(idx) = interp1(find(~isnan(x)), x(~isnan(x)), idx, 'spline');
y(idx) = interp1(find(~isnan(y)), y(~isnan(y)), idx, 'spline');

x = smooth(x, 10);
y = smooth(y, 10);

x = x - (max(x) + min(x))/2;
y = y - (max(y) + min(y))/2;

[x, y] = rotatePoints(x, y, deg2rad(3.5));

x = x * .45;
y = y * .45;


[t,~,~,vx,vy,~,~] = dataanalyzer.trajectory_kalman_filter(x,y,videoTS*1e-6,1);
velocity = [t' sqrt(vx.*vx + vy.*vy)];
v = velocity(:, 2);

[eeg, Fs] = readCRTsd(fullfile(pathToSession, ['CSC' num2str(tt), '.ncs']));
eeg = downsample(Data(eeg), dsrate);
[S, ~, f] = specgramwwd(eeg, Fs/dsrate, 6, 14);
[~, I] = max(S);
Freq = f(I);

v_ds = downsample(v, floor(length(v)/length(Freq)));
v_ds = v_ds(ceil((length(v_ds)-length(Freq))/2):end-ceil((length(v_ds)-length(Freq))/2));

if length(v_ds) == length(Freq) + 1
	v_ds = v_ds(2:end);
end

idx_v = cell(1, numBins);
avg_Freq = nan(1, numBins);
avg_Specg = nan(length(f), numBins);
[~, edges, bins] = histcounts(v_ds, length(idx_v));

for i = 1:length(idx_v)
	idx_v{i} = find(bins==i);
	avg_Freq(i) = mean(Freq(idx_v{i}));
	avg_Specg(:, i) = mean(S(:, idx_v{i}), 2);
end

idx_max_vel = find(edges<maxVelPlot, 1, 'last')+1;
if idx_max_vel > length(edges)
	idx_max_vel = idx_max_vel - 1;
end
Vel_Bins = edges(1:idx_max_vel);
Vel_Bins = (Vel_Bins(1:end-1) + Vel_Bins(2:end)) / 2;
Freq_avg = avg_Freq(1:idx_max_vel-1);
Specg_avg = avg_Specg(:, 1:idx_max_vel-1);
figure;scatter(Vel_Bins, Freq_avg);
lsline;
xlabel('Velocity (cm/s)'); ylabel('Frequency (Hz)');
set(gca, 'FontName', 'Arial');

figure;imagesc(Vel_Bins, f, Specg_avg);
colormap jet; axis xy;
xlabel('Velocity (cm/s)'); ylabel('Frequency (Hz)');
set(gca, 'FontName', 'Arial');
