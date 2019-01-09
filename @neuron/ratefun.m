function rf = ratefun(obj, forceStock, kernel, params)
% based on pp 8-14 Dayan and Abbott 2001

if ~exist('kernel', 'var')
	kernel = 'causal';
end
alpha = 1/.25; % 1/second
mu = 0; Sigma = .25; % second
dt = 0.01; % second

if exist('params', 'var') && isfield(params, 'alpha')
	alpha = params.alpha;
end
if exist('params', 'var')
	if isfield(params, 'mu')
		mu = params.mu;
	end
	if isfield(params, 'mu')
		Sigma = params.sigma;
	end
end
if exist('params', 'var') && isfield(params, 'dt')
	dt = params.dt;
end

if isempty(obj.rtfun)
	s = obj.getSpikeTrain();
	obj.rtfun = computeRateFun(s, kernel, alpha, mu, Sigma, dt, obj.parentTrial.beginTS, obj.parentTrial.endTS);
end

if exist('forceStock', 'var') && forceStock
	s = obj.spikeTrain;
	rf = computeRateFun(s, kernel, alpha, mu, Sigma, dt, obj.parentTrial.beginTS, obj.parentTrial.endTS);
else
	rf = obj.rtfun;
end