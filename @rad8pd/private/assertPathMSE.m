function s = assertPathMSE(X, Y, tolerance)
% updated on 5/8/2018: the smoothing used the @smooth function which for
% some reason is many times slower than @conv

smoothing_kernel = 5;
winspan = floor(smoothing_kernel/2);

X = [X(1:winspan); X(:); X(end-winspan+1:end)];
Y = [Y(1:winspan); Y(:); Y(end-winspan+1:end)];

smooth_x = conv(X(:), ones(1, smoothing_kernel) / smoothing_kernel, 'same');
smooth_y = conv(Y(:), ones(1, smoothing_kernel) / smoothing_kernel, 'same');

X = X(winspan+1:end-winspan);
Y = Y(winspan+1:end-winspan);
smooth_x = smooth_x(winspan+1:end-winspan);
smooth_y = smooth_y(winspan+1:end-winspan);

err = (eucldist(0, 0, diff(X(:)), diff(Y(:)))-eucldist(0, 0, diff(smooth_x), diff(smooth_y))).^2;

s = nanmean(err) < tolerance;

if ~s
	error('Radial8MazeParser:PathSamplingError:PathMSEExceedsTolerance', 'Path not smooth enough. Either smooth path further or increase error tolerance.');
end