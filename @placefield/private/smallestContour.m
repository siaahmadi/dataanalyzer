function contour = smallestContour(obj)

contours = fieldnames(obj.fieldInfo.boundary;

clevels = str2double(regexp(contours, '(?<=^c)\d{2}', 'match', 'once'));
contour = num2str(['c', min(clevels)]);