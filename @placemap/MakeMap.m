function [rmap, binRangeX, binRangeY, occup, preRM, gaussFit] = MakeMap(projectname, x, y, t, s, validintervals, opt)

if nargin < 5
	error('Fix project name');
end

if ~exist('opt', 'var') || isempty(opt)
	dft_opt = dataanalyzer.options(projectname);
else
	dft_opt = opt;
end
dft_opt.validIvls = validintervals;

if ~isfield(dft_opt, 'dimensionality') || dft_opt.dimensionality == 2
	[rmap, binRangeX, binRangeY, occup, preRM, gaussFit] = dataanalyzer.makePlaceMaps. ...
			mymake2(s, x , y, t, [], dft_opt);
elseif dft_opt.dimensionality == 1
	binRangeY = 0;
	[rmap, binRangeX, occup, preRM, gaussFit] = dataanalyzer.makePlaceMaps. ...
			mymake1(s, x, t, [], dft_opt);
% 	rmap = rmap(:);
% 	binRangeX = binRangeX(:);
% 	occup = occup(:);
% 	preRM.spikemap = preRM.spikemap(:);
% 	preRM.occupmap = preRM.occupmap(:);
else
	error('Unhandled place map dimensionality.');
end