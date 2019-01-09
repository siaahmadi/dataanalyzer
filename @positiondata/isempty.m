function I = isempty(obj)

% Siavash Ahmadi
% 12/11/2014 01:29 PM
% 11/09/2015 12:51 PM

% I = isempty(obj.getX());
I = arrayfun(@(obj) numel(obj.X)==0, obj);