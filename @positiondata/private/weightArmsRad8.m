function mzTemplate = weightArms(mzTemplate)
pxi = regionprops(mzTemplate, 'PixelIdxList');
buffer = double(mzTemplate);
for i = [1:3 5:9] % for radial 8 maze, the 4-th element is the stem
	buffer(pxi(i).PixelIdxList) = buffer(pxi(i).PixelIdxList) + 1e3;
end
buffer(pxi(4).PixelIdxList) = -1;
mzTemplate = buffer;