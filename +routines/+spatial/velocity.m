function [v, vHat] = velocity(x,y,t,method)
if nargin<4
    method = 'kalman';
end

switch method
    case 'kalman'
        v = nan(size(t));
        iNan = isnan(x) | isnan(y) | isnan(t);
        [tk,~,~,vx,vy,~,~] = trajectory_kalman_filter(x(~iNan),y(~iNan),t(~iNan),1);
        v(ismember(t,tk)) = sqrt(vx.*vx + vy.*vy);
    case 'simple'
        dyt = deriv(y,t);
        dxt = deriv(x,t);
        v = arrayfun(@(u,v)norm([u v]),dyt,dxt);
    otherwise
        error('Invalid method');
end
%mean velocity
vHat = mean(v);