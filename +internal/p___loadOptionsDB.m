function db = p___loadOptionsDB()

phaprecTakuya.rad8pd_update.xCenter = 369;
phaprecTakuya.rad8pd_update.yCenter = 224;
phaprecTakuya.rad8pd_update.rotation = deg2rad(.5);
phaprecTakuya.rad8pd_update.xScale = .425;
phaprecTakuya.rad8pd_update.yScale = .46;
phaprecTakuya.rad8pd_update.prjType = 'orthogonal';
phaprecTakuya.rad8pd_update.rewardRadiusThreshold = 70; % cm
phaprecTakuya.rad8pd_update.revisitRadiusThreshold = 35; % cm
phaprecTakuya.rad8pd_update.stem_radius = 20; % cm
phaprecTakuya.rad8pd_update.rewardfirst = false;
phaprecTakuya.rad8pd_update.rewardImmobilityThreshold = 1;
phaprecTakuya.rad8pd_update.pathMSEtolerance = 0.05;
phaprecTakuya.rad8pd_update.armBisector = pi/8;
phaprecTakuya.rad8pd_update.ctrXCorrPeakFinderMethod = 'peak'; %%%%%%%%%%%% not sure if should be here
phaprecTakuya.expSession_loadSessionPD = phaprecTakuya.rad8pd_update;

phaprecTakuya.fig8_update = phaprecTakuya.rad8pd_update;

phaprecTakuya.expSession_loadSessionPD.xCenter = phaprecTakuya.rad8pd_update.xCenter;
phaprecTakuya.expSession_loadSessionPD.yCenter = phaprecTakuya.rad8pd_update.yCenter;
phaprecTakuya.expSession_loadSessionPD.rotation = deg2rad(.8);
phaprecTakuya.expSession_loadSessionPD.xScale = .39;
phaprecTakuya.expSession_loadSessionPD.yScale = .41;
phaprecTakuya.expSession_loadSessionPD.res = 1e3;

phaprecTakuya.expSession_preprocess = phaprecTakuya.expSession_loadSessionPD;

phaprecTakuya.positiondata_load.tsConversionFactor = 1e-6;
phaprecTakuya.expSession_loadSessionPD.tsConversionFactor = phaprecTakuya.positiondata_load.tsConversionFactor;

phaprecTakuya.placemap_p___MakeMap.spatialRange.left = -100;
phaprecTakuya.placemap_p___MakeMap.spatialRange.right = 100;
phaprecTakuya.placemap_p___MakeMap.spatialRange.bottom = -100;
phaprecTakuya.placemap_p___MakeMap.spatialRange.top = 100;
phaprecTakuya.placemap_p___MakeMap.nBins.x = 50;
phaprecTakuya.placemap_p___MakeMap.nBins.y = 50;
phaprecTakuya.placemap_p___MakeMap.filtVel = true;
phaprecTakuya.placemap_p___MakeMap.velRange = [2, Inf];

phaprecTakuya.makePlaceMaps_extractpf.minArea = 60; % cm^2
phaprecTakuya.makePlaceMaps_extractpf.mapInterpFactor = 5;
phaprecTakuya.makePlaceMaps_extractpf.minPeakHeight = 2;
phaprecTakuya.makePlaceMaps_extractpf.mergePeaksSeparatedByLessThan = 20;
phaprecTakuya.makePlaceMaps_extractpf.positiveFiringThreshold = 2;
phaprecTakuya.makePlaceMaps_extractpf.minLength = 10;

phaprecTakuya.expSession_writeLFPThetaPwrRatioToDirectory.ratio_measure = 'peaktobase';  % 'peaktobase' --> peak(theta)/avg(wideband \ theta) ('\' --> setdiff)
phaprecTakuya.expSession_writeLFPThetaPwrRatioToDirectory.thetaBnd = [6, 10];
phaprecTakuya.expSession_writeLFPThetaPwrRatioToDirectory.widebandLwr = .5;
phaprecTakuya.expSession_writeLFPThetaPwrRatioToDirectory.widebandHgh = 20;
phaprecTakuya.expSession_writeLFPThetaPwrRatioToDirectory.cscNamingConvention = '(?<=^CSC)\d+(?=.ncs$)'; % name starts with CSC followed by at least one digit followed by .ncs and ends
phaprecTakuya.expSession_writeLFPThetaPwrRatioToDirectory.saveFileName = 'eeg_theta_pwr_ratios.mat';
phaprecTakuya.expSession_writeLFPThetaPwrRatioToDirectory.ttExcluded = [13, 15:16];

phaprecTakuya.expSession_expSession.theta_pwr_ratio_filename = 'eeg_theta_pwr_ratios.mat';

phaprecTakuya.utils_ttpos.ttdbfile = 'V:\Sia\PhD\LabProjects\phasePrecessionTakuya\MetaFiles\ttpos.txt';
phaprecTakuya.routines_anatomy_load.ttdbfile = 'V:\Sia\PhD\LabProjects\phasePrecessionTakuya\MetaFiles\ttpos.txt';
phaprecTakuya.expSession_loadSessionNeurons.ttdbfile = 'V:\Sia\PhD\LabProjects\phasePrecessionTakuya\MetaFiles\ttpos.txt';

% ---
% additional defs go here
% ---

elapsedTime.rad8pd_update = phaprecTakuya.rad8pd_update;
elapsedTime.placemap_p___MakeMap = phaprecTakuya.placemap_p___MakeMap;
elapsedTime.expSession_loadSessionPD = phaprecTakuya.expSession_loadSessionPD;
elapsedTime.positiondata_load = phaprecTakuya.positiondata_load;
elapsedTime.expSession_expSession = phaprecTakuya.expSession_expSession;
elapsedTime.expSession_preprocess = phaprecTakuya.rad8pd_update;
elapsedTime.expSession_preprocess.rotation = -elapsedTime.expSession_preprocess.rotation;

% DO NOT CHANGE:
db.positionData_parseOptions = phaprecTakuya.rad8pd_update;
db.phaprecTakuya = phaprecTakuya; % this specification was defined on 11/18/2015. scripts written prior to this date shoud be updated. Specifically rad8pd_update.
db.elapsedTime = elapsedTime;

