function db = p___loadConstantsDB()

lineartrackABBA.ttLocDB_path = 'H:\Y\Sia\PhD Projects\Recordings\LinearTrackABBA\ttPosition.txt';
phaprecTakuya.ttLocDB_path = 'H:\X\PhD\LabProjects\phasePrecessionTakuya\MetaFiles\ttPosition.txt';
phaprecTakuya.fig8_adjfile = 'V:\Sia\PhD\LabProjects\phasePrecessionTakuya\MetaFiles\fig8rat.adj';
db.ttLocDB_path_lineartrackABBA = lineartrackABBA.ttLocDB_path;
db.ttLocDB_path_phaprecTakuya = phaprecTakuya.ttLocDB_path;
db.fig8adjfile = phaprecTakuya.fig8_adjfile;
db.expSession_contextFile = 'contextorder.txt';
db.FileName_PathData_Session = 'pathdata.mat';
db.FileName_PathDataLinearized_Session = 'pathdatalin.mat';
db.FileName_SpikeData_Session = 'spikedata.mat';
db.FileName_LfpData_Session = 'lfpdata.mat';
db.FileName_ParseData_Session = 'parseinfo.mat';
db.FileName_SubtrialData_Session = 'subtrials.mat';
db.neuralynxVideoTsConversionFactor = 1e-6;

db.fieldDetectionContours = {'c20'};% used by @extractpf to compute place fields at these contours
db.cpropsContours = {'c20', 'c50'}; % used by cprops to compute properties of these contours; if not available in fieldInfo (i.e. if fields not extracted for a particular contour on this list) it will be skipped without warning

bandNames = {'theta', 'sgamma', 'fgamma'};
bandLows = {6, 30, 80}; bandHighs = {10, 49.99, 130};
db.dflt_freqBands = cellfun(@dataanalyzer.lfp.defineFreqBand, bandNames, bandLows, bandHighs)';

db.lfp_MAXTT = 2^10;

db.makeMapLinear.spatialRange.left = 0;
db.makeMapLinear.spatialRange.right = 360;
db.makeMapLinear.spatialRange.bottom = -2.5;
db.makeMapLinear.spatialRange.top = 2.5;
db.makeMapLinear.nBins.x = 120; % width of 3 cm
db.makeMapLinear.nBins.y = 1;
db.makeMapLinear.filtVel = true;
db.makeMapLinear.velRange = [2, Inf];
db.makeMapLinear.minValidLength = .3;
db.makeMapLinear.dimensionality = 1;
db.makeMap1D = db.makeMapLinear;

db.makeMap2D.spatialRange.left = -100;
db.makeMap2D.spatialRange.right = 100;
db.makeMap2D.spatialRange.bottom = -100;
db.makeMap2D.spatialRange.top = 100;
db.makeMap2D.nBins.x = round(200/3); % width of 3 cm
db.makeMap2D.nBins.y = round(200/3);
db.makeMap2D.filtVel = true;
db.makeMap2D.velRange = [2, Inf];
db.makeMap2D.minValidLength = .3;
db.makeMap2D.dimensionality = 2;