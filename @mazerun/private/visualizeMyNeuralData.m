function h = visualizeMyNeuralData(obj, ttNo, all_my_spikes, opt, fig)

h = [];

if opt.lfp
	if isstruct(ttNo)
		lfp = ttNo;
	else
		lfp = getMyLFP(obj, ttNo); % rather time-consuming
	end
	if numel(lfp) > 1
		answer = 'Yes'; % if less than 10
		if numel(lfp) > 10
			answer = questdlg('There is going to be more than 10 figures popping up. Are you sure?', 'Too many figure windows', 'Yes', 'No', 'No');
		end
		if strcmp(answer, 'Yes')
			all_my_spikes = accFunc_groupByRun(all_my_spikes);
			cellfun(@(l, sp) visualizeMyNeuralData(obj, l, sp, opt, true), num2cell(lfp), all_my_spikes);
		end
		return;
	end

	if ~exist('fig', 'var') || fig
		dataanalyzer.figure(); hold on;
	end
	
	hg_spikelfp = hggroup('DisplayName', 'Spike LFP Raster');

	plot(lfp.t, lfp.raw-mean(lfp.raw), 'Color', ones(1,3)*.8, 'LineWidth', .75, 'Parent', hg_spikelfp, 'DisplayName', 'Run Raw LFP');
	plot(lfp.t, lfp.theta, 'Color', 'k', 'LineWidth', 1, 'Parent', hg_spikelfp, 'DisplayName', 'Run Theta');
	height_peakIndicator = max(abs(lfp.raw));
	ph0_ht = NaN(length(lfp.phase0)*3-1, 1);
	ph0_ts = NaN(length(lfp.phase0)*3-1, 1);
	ph0_ht(1:3:end) = -height_peakIndicator/2;
	ph0_ht(2:3:end) = height_peakIndicator/2;
	ph0_ts(1:3:end) = lfp.phase0;
	ph0_ts(2:3:end) = lfp.phase0;

	plot(ph0_ts, ph0_ht,'Color', 'k', 'LineWidth', 2);

	if opt.spikelfp
		sp_ts = NaN(numel(all_my_spikes) * 3 - 1, 1);
		sp_ht = NaN(numel(all_my_spikes) * 3 - 1, 1);
		height_spike = max(abs(lfp.theta));

		sp_ts(1:3:end) = cat(1,all_my_spikes.ts);
		sp_ts(2:3:end) = cat(1,all_my_spikes.ts);

		sp_ht(1:3:end) = height_spike/2;
		sp_ht(2:3:end) = -height_spike/2;
		sp_ht = sp_ht - height_peakIndicator/2;

		plot(sp_ts, sp_ht, 'r', 'LineWidth', 1.5, 'Parent', hg_spikelfp, 'DisplayName', 'Run Spike Rasters');
	end
	ax = gca;
	xlim([lfp.t(1)-.05*range(lfp.t), lfp.t(end)+.05*range(lfp.t)]);
	ylim([-max(ax.YLim), max(ax.YLim)]);
	figpretty;
	ax.XTick = [lfp.t(1), lfp.t(end)];
	
	if nargout > 0
		h = hg_spikelfp;
	end
end

function [all_my_spikes, parents] = accFunc_groupByRun(all_my_spikes)

parents = {all_my_spikes(1).Parent};
idx = {1};
numParents = length(parents);
for i = 2:numel(all_my_spikes)
	if all_my_spikes(i).Parent == parents{numParents}
		if numParents > length(idx)
			idx{numParents, 1} = i;
		else
			idx{numParents} = [idx{numParents}; i];
		end
		continue;
	else
		parents{numParents+1, 1} = all_my_spikes(i).Parent;
		numParents = numParents + 1;
	end
end

all_my_spikes = cellfun(@(ind) all_my_spikes(ind), idx, 'un', 0);