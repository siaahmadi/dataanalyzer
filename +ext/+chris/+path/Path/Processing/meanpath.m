function [x,y] = meanpath(x,y)
% smoothes path
% @cmtAuthor: Sia @date 9/15/15 12:57 PM

temp_x = NaN(size(x));
temp_y = NaN(size(y));
for cc=8:length(x)-7
    x_window = x(cc-7:cc+7); y_window = y(cc-7:cc+7);
    temp_x(cc) = nanmean(x_window); temp_y(cc) = nanmean(y_window);
end

x = temp_x;
y = temp_y;