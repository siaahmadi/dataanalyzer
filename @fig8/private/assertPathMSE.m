function s = assertPathMSE(X, Y, tolerance)

err = (eucldist(0, 0, diff(X(:)), diff(Y(:)))-eucldist(0, 0, diff(smooth(X(:))), diff(smooth(Y(:))))).^2;

s = mean(err) < tolerance;

if ~s
	error('Radial8MazeParser:PathSamplingError:PathMSEExceedsTolerance', 'Path not smooth enough. Either smooth path further or increase error tolerance.');
end