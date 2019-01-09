demoPath = 'X:\Sia\PhD\LabProjects\phasePrecessionTakuya\Recordings\DGLesion\rat633\2013-10-02_19-25-51\begin3';

[videoTS, videoX, videoY] = Nlx2MatVT(fullfile(demoPath, 'VT1.nvt'), [1 1 1 0 0 0], 0, 1, 1);
[X, Y] = tidyPositionData(videoX, videoY,[364, 227], 1/.4, 1/.47);
parsed = phaprec.parsemz.rad8.parse(smooth(X), smooth(Y), videoTS);

figure;
for i = 1:length(parsed.visits.runs)-1
	if i > 1
		plot(parsed.path.orig.x(1:parsed.visits.runs(i)-1), parsed.path.orig.y(1:parsed.visits.runs(i)-1), '.', 'Color', ones(1,3)*.8, 'MarkerSize', 15)
	end
	
	hold on
	plot(parsed.path.orig.x(parsed.visits.runs(i):parsed.visits.runs(i+1)), parsed.path.orig.y(parsed.visits.runs(i):parsed.visits.runs(i+1)), 'k.', 'MarkerSize', 15)
	hold off
	
	xlim([-100 100]); ylim([-100 100]); axis square
	
	waitforbuttonpress
end