function [d, ph, h, regress_results] = phasedist(obj, varargin)

import dataanalyzer.figure

% default output:
d = [];
ph = [];
h = [];
regress_results = [];

[ax_h, args, nargs] = axescheck(varargin{:}); % stole from @compass
opt = p___parseInputArgs(varargin{:});

% Options to be implemented:
%
% 'plot' : 'on', 'off' PLOT THE RESULTS
% 'heat' : 'on', 'off' SHOW A HEAT MAP OF DENSITY OF SPIKES
% 'regress' : 'on', 'off' CIRCULAR REGRESSION
% 'duplicate' : 'on', 'off' SHOW IN RANGE [0, 4pi] (on) or [0, 2pi] (off)
% other options as accepted by MATLAB's @scatter function

% Siavash Ahmadi
% 11/29/2015 1:45 PM

LIN_REGR_COLOR = [184, 226, 179] / 255;

if opt.update
	obj.update();
end

% if any(~[obj.inField])
% 	warning('Some spike(s) not in field. Cannot continue.');
% 	d = [];
% 	ph = [];
% 	h = handle([]);
% 	return;
% end

freqBandName = 'theta'; % FOR NOW -- TO BE CHANGED 11/29/2015 2:51 PM

ph = arrayfun(@(x) x.(freqBandName), [obj.phase]);
d = arrayfun(@(x) x.fromField.retrospective.normalized, [obj.distance]);

if length(ph(isfinite(ph))) < 1
	warning('For some reason the phase of this spike is not computed properly. Skipping...');
	return;
end

if length(ph(isfinite(ph))) < 2
	warning('Not enough spikes to perform regression. Turning regression off.');
	opt.regress = false;
end

if opt.regress
	l = @(x, m, y0) y0+m*x;
	
	[b,~,~,~,stats_lin] = regress(ph(:),[ones(length(d), 1), d(:)]);
	y_lin = l([0, 1], b(2), b(1));
	
	regress_results.lin.sl = b(2);
	regress_results.lin.phi0 = b(1);
	regress_results.lin.rho = sign(b(2)) * sqrt(stats_lin(1));
	regress_results.lin.stats = stats_lin;
	regress_results.lin.x = [0, 1];
	regress_results.lin.y = y_lin;

	[sl, phi0, rho, stats_circ] = regresscl(d, ph, [-2, 2]);
	y_circ = l([0, 1], sl, phi0);
	
	regress_results.circ.sl = sl;
	regress_results.circ.phi0 = phi0;
	regress_results.circ.rho = rho;
	regress_results.circ.stats = stats_circ;
	regress_results.circ.x = [0, 1];
	regress_results.circ.y = y_circ;
else
	regress_results = [];
end

if opt.plot
	figure;
	h_phasedist_spikes = scatter(d, ph, 49, 'k', 'filled');
	xlim([0, 1]);
	ylim([0 2*pi]);
	ax = gca;
	ax.YTick = [0, pi, 2*pi];
	ax.YTickLabel = {'0', '\pi', '2\pi'};
	ax.XTick = [0, 1];
	xlabel('Position in Field');
	ylabel(['Phase of ' strcap(freqBandName)]);
	ax.FontName = 'Arial';
	ax.FontSize = 16;
	ax.Box = 'off';
	ax.TickDir = 'out';
	set(ax, 'xticklabel', {'Entry', 'Exit'}, 'xticklabelrotation', 335);

	if opt.regress
		hold on;
		r_lin = plot([0, 1], y_lin, '--', 'Color', LIN_REGR_COLOR, 'LineWidth', 2);
		r_circ = plot([0, 1], y_circ+2*pi*any(y_circ<0), 'm', 'LineWidth', 5);
		
		if opt.legend
			lgtxt_lin = ['Linear \rho = ' num2str(sign(b(2))*sqrt(stats_lin(1)), 2) ', {\it p}-value = ', num2str(stats_lin(3))];
			lgtxt_circ = ['Circular \rho = ' num2str(rho, 2) ', {\it p}-value = ', num2str(stats_circ.p)];

			txt = stralign({lgtxt_lin;lgtxt_circ}, 1, 'right');
			lgtxt_lin = txt{1};
			lgtxt_circ = txt{2};

			lg = legend([r_lin; r_circ], lgtxt_lin, lgtxt_circ);
			lg.FontName = 'Courier New';
			lg.FontSize = 12;
		end
	end

	hg_phasedist = hggroup('DisplayName', 'Phase Distance Plot Contents');
	if opt.duplicate
		hg_phasedist_scatter = hggroup('Parent', hg_phasedist);

		h_phasedist_spikes_dupl = copyobj(h_phasedist_spikes, hg_phasedist_scatter);
		h_phasedist_spikes.Parent = hg_phasedist_scatter;
		h_phasedist_spikes_dupl.YData = h_phasedist_spikes_dupl.YData + 2*pi;
		ax = ancestor(h_phasedist_spikes, 'Axes');
		ax.YLim(2) = ax.YLim(2) + 2*pi;
		ax.YTick = [0, 2*pi, 4*pi];
		ax.YTickLabel = {'0', '2\pi', '4\pi'};
	else
		h_phasedist_spikes.Parent = hg_phasedist;
	end

	figure;
	hg_hist = hggroup('DisplayName', 'Phase Locking Histogram');
	hist_h = histogram(ph, linspace(0,4*pi, 25), 'Normalization', 'Probability', 'Parent', hg_hist);
	hist_h.FaceColor = ones(1,3) * .15;
	hist_h.EdgeColor = ones(1,3) * .15;
	hist_h.FaceAlpha = 1;
	hist_dupl = copyobj(hist_h, hg_hist);
	hist_dupl.Data = hist_dupl.Data + 2*pi;
	ax = gca;
	ax.XTick = [0, 2*pi, 4*pi];
	ax.XTickLabel = {'0', '2\pi', '4\pi'};
	ax.FontName = 'Arial';
	ax.FontSize = 16;
	ax.Box = 'off';
	ax.XLim = [0 4*pi];
	ax.XLabel.String = ['Phase of ' strcap(freqBandName)];
	ax.YLabel.String = 'Probability of Firing';
	
	h = [hg_phasedist; hg_hist];
else
	h = [];
end