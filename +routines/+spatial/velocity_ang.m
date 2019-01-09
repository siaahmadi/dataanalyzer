function [v_theta, v_rho] = velocity_ang(x,y,t)

[theta, rho] = cart2pol(x,y);
diffs = diff(theta);
jumps = find(abs(diffs)>5)+1;
for i = 1:length(jumps)
	if diffs(jumps(i)-1) > 0
		theta(jumps(i):end) = theta(jumps(i):end) - 2*pi;
	else
		theta(jumps(i):end) = theta(jumps(i):end) + 2*pi;
	end
end

[t,~,~,v_theta,v_rho,~,~] = trajectory_kalman_filter(theta, rho, t, 1);