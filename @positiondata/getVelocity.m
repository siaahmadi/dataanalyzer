function [v, vBar] = getVelocity(obj, restriction)
%v = getVelocity(obj, mask) Compute and return velocity of position data
%
%
% If Velocity has been computed it will only be returned. If not, it will
% be computed first and then the masked velocity will be returned.
%
% INPUT:
%
%	mask (OPTIONAL)
%		A dataanalyzer.mask object.
%
%		If skipped, current position data's restriction will be used. Pass
%		an empty array or mask object to override this.
%
% OUTPUT:
%
%	v
%		The velocity array.
%
%		If discontiguous intervals have been provided, this will be a cell
%		array of double arrays, each containing the velocity profile of the
%		corresponding contiguous bouts.

% Siavash Ahmadi
% 10/28/2015 Initial set up
% 11/09/2015 Functional -- restriction worked out


if ~exist('restriction', 'var') || isempty(restriction)
	restriction = 'unrestr';
end


if strncmpi(restriction, 'restr', 5)
	[V, vBar] = obj.getVelocity('unrestr');
	nMasks = length(obj.Mask);
	v = cell(nMasks, 1);
	for maskInd = 1:nMasks
		idx = obj.Mask(maskInd).mask2idx;
		if ~iscell(idx) % for when current mask is composed of a single interval
			idx = {idx};
		end
		v{maskInd} = cellfun(@(x) V(x), idx, 'UniformOutput', false);
		if length(v{maskInd}) == 1 % if the current mask is just a single interval don't put it in a cell
			v{maskInd} = v{maskInd}{1};
		end
	end
else
	if isempty(obj.V)
		pathData.x = obj.getX(restriction);
		pathData.y = obj.getY(restriction);
		pathData.t = obj.getTS(restriction);
		[v, vBar] = velocity(pathData.x,pathData.y,pathData.t,'kalman');
		obj.V = v;
	else
		v = obj.V;
		vBar = mean(v(:));
	end
end

function [v, vBar] = velocity(x,y,t,method)

switch method
    case 'kalman'
        v = nan(size(t));
        iNan = isnan(x) | isnan(y) | isnan(t);
        [tk,~,~,vx,vy,~,~] = dataanalyzer.routines.kalman.trajectory_kalman_filter(x(~iNan),y(~iNan),t(~iNan),1);        
        v(ismember(t,tk)) = sqrt(vx.*vx + vy.*vy);
    case 'simple'
        dyt = deriv(y,t);
        dxt = deriv(x,t);
        v = arrayfun(@(u,v)norm([u v]),dyt,dxt);
    otherwise
        error('DataAnalyzer:PositionData:InvalidVelcityComputeMethod', 'Invalid method. Valid methods: kalman, simple');
end

vBar = mean(v(:));