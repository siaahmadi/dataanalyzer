function map = ratemap(ts,spkx,spky,posx,posy,post,h,mapAxis)
%I'm just removing nans here, but NaNs come from dividing linear track data
%by direction, and hence mark discontinuities in the data
%over which edges really shouldn't be smoothed.  This needs to be taken
%care of properly! But I'm hoping this will do for now.
naninds = isnan(posx+posy+post);
posx(naninds)=[];posy(naninds)=[];post(naninds) = [];

invh = 1/h;
map = zeros(length(mapAxis),length(mapAxis));
yy = 0;
for y = mapAxis
    yy = yy + 1;
    xx = 0;
    for x = mapAxis
        xx = xx + 1;
        map(yy,xx) = dataanalyzer.makePlaceMaps.rate_estimator(ts,spkx,spky,x,y,invh,posx,posy,post);
    end
end