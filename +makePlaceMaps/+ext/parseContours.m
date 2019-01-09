function contourStruct = parseContours(C, plotContours)
% SYNTAX: contourStruct = parseContours(C, plotContours)
% This is an inner-workings function you are unlikely to call directly.
% It takes contours in the form created by Matlab and reformats them into a
% form usable by the Locating Place Fields software.
% C: contours created by Matlab's contour function
% plotContours: true or false, if true, a plot is made of the contours.
%
% Written by Emily Mankin, (c) 2012

counter = 1;
while size(C,2)>0
    value = C(1,1);
    nPoints = C(2,1);
    xdata = C(1,2:nPoints+1);
    ydata = C(2,2:nPoints+1);
    C(:,1:nPoints+1) = [];
    contourStruct(counter) = struct('value',value,'xdata',xdata,'ydata',ydata);
    counter = counter+1;
end

if exist('plotContours','var') && plotContours
    figure; hold on
    for i=1:length(contourStruct)
        plot(contourStruct(i).xdata,contourStruct(i).ydata,'Color',rand(1,3))
    end
end