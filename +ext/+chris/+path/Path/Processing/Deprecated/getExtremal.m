%% Use boxedges
%estimates the borders of a square by setting the edge to coordinates that were visited
%less than 20% of the average coordinate, coordinates in cm, resolution 0.5 cm,
%assumes a maximum box size of 100 cm by 100 cm
function [xExt yExt] = getExtremal(x_squares,y_squares,cutoff)
if nargin<3 || isempty(cutoff)
   cutoff = 0.05; % reduced from 20% to 10 %, Sept 2010
end
range_min = min(min(x_squares),min(y_squares));
range_max = max(max(x_squares),max(y_squares));
range = [range_min:0.5:range_max];


x_hist = histc(x_squares(x_squares >= range_min & x_squares <= range_max),range);
y_hist = histc(y_squares(y_squares >= range_min & y_squares <= range_max),range);

x_index = find (x_hist > cutoff*mean(x_hist));
y_index = find (y_hist > cutoff*mean(y_hist));


% Put extremal values in an array
xExt = [range(min(x_index)) range(max(x_index))];
yExt = [range(min(y_index)) range(max(y_index))];