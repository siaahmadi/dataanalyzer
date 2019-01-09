function [start, stop] = start_stop(logical_array, target, mode)
%start_stop takes a logical array of zeros and ones and returns the indices
%at which the ones start and stop. If 'target' is changed to 0, finds where
%0s start and stop. 1s are the default.
%
% MODE determines what happens when the array starts or stops mid window
%(ie with a 1). 'all' mode returns the stars and stops
%as is, so if it starts or ends with a 1, there will be a stop or a start
%without a patner at the beginning or end (respectively) of the list.
%'natural', the default, only returns the complete widows, ignoring 1s at
%the beggining or end.


if (nargin<2);
    target = 1;
end

if (nargin<3);
    mode = 'natural';
end

%% define as logical and a vector, else throw error

sz = size(logical_array);

if (min(sz) ~= 1);
    error('EEK! the input array is not a vector');
elseif (sum(unique(logical_array)) ~= 1);
    error('ZOUNDS! the input array must be logical!');
end

%% set target
if (target == 0);
    logical_array = logical_array==0;
end
    
%% take diff
logical_array_diff = diff(logical_array);

%% find 1s (starts) and -1s (stops)
start = find(logical_array_diff==1);
stop = find(logical_array_diff==-1);

%% if mode == natural, remove necessary starts and stops

if (strcmp(mode,'natural'));
    if (stop(1) < start(1));
        stop(1) = [];
    end
    
    if (start(end) > stop(end));
        start(end) = [];
    end
end


end

