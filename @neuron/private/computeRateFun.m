function rf = computeRateFun(s, kernel, alpha, mu, Sigma, dt, t_low, t_high)

spSrate = 1e4; %spike sample rate

switch kernel
	case 'causal'
		w = @(tau) alpha.^2.*tau.*exp(-alpha.*tau).*heaviside(alpha.^2.*tau.*exp(-alpha.*tau));
		param = 1/alpha;
	case 'gaussian'
		w = @(tau) 1/(sqrt(2*pi)*Sigma)*exp(-(tau-mu)^2/(2*Sigma^2));
		param = Sigma;
	case 'rectangular'
		w = @(t) (1/dt)*(t>=-dt/2 & t<dt/2);
		param = dt;
	case 'linear'
		% TODO
end

% rho = @(t) any(t == s); % neural response function

ss = sparse(ones(size(round((s-t_low)*spSrate))), round((s-t_low)*spSrate),1,1,length(t_low:1/spSrate:t_high));
rf = @(t) myrf(t, ss, w, spSrate, t_low, param);



function rf = myrf(t, s, w, spSrate, t_low, param)

if numel(t) > 1
	rf = zeros(length(t), 1);
	for i = 1:length(rf)
		rf(i) = myrf(t(i), s, w, spSrate, t_low, param);
	end
	return
elseif isempty(t)
	rf = conv(w(-10*param:1/spSrate:10*param),full(s));
	x = length(-10*param:1/spSrate:10*param);
	if mod(x,2)==1
		rf = rf(ceil(x/2):end-floor(x/2));
	else
		rf = rf(x/2+1:end-x/2);
	end
	return
end

ind = ceil((t-t_low) * spSrate);
if ind < 1 || ind > length(s)
	rf = NaN; % timestamp requested outside trial bounds
	return
end

ind_l = max(ind - spSrate * 10*param, 1); % 10 alpha before
ind_u = min(ind + spSrate * 10*param, length(s)); % 10 alpha after


rf = conv(w(-10*param:1/spSrate:10*param),full(s(ind_l:ind_u)));
if mod(length(rf), 2) == 1
	rf = rf(ceil(length(rf)/2));
else
	rf = mean([rf(length(rf)/2), rf(length(rf)/2+1)]);
end