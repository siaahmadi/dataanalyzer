function mzTemplate = weightArms(mzTemplate, res)
pxi = regionprops(mzTemplate, 'PixelIdxList');
buffer = double(mzTemplate);
for i = [1:3 5:9] % for radial 8 maze, the 4-th element is the stem
	buffer(pxi(i).PixelIdxList) = buffer(pxi(i).PixelIdxList) + res;
end
buffer(pxi(4).PixelIdxList) = -1;
mzTemplate = buffer;