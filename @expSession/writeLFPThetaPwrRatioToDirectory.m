function writeLFPThetaPwrRatioToDirectory(obj)

if numel(obj) > 1
	arrayfun(@(x) x.writeLFPThetaPwrRatioToDirectory, obj);
	return;
end

opt = dataanalyzer.options(obj.projectname);

[eegFilesIdx, eegList, fullpath] = getEEGind(obj);

eegList = {eegList(eegFilesIdx).name}'; % File names of all .ncs files
ttNo = cellfun(@str2double, regexp(eegList, opt.cscNamingConvention, 'match', 'once'));
if any(isnan(ttNo(:)))
	warning('DataAnalyzer:expSession:BadNCSName', 'Some .ncs files were not named according to convention\nin %s. Ignoring these...', fullpath);
	ttNo = ttNo(isfinite(ttNo));
end

ttNo = setdiff(ttNo, opt.ttExcluded);

eeg = cell(max(ttNo), 1);
if isscalar(ttNo)
	eeg{ttNo} = dataanalyzer.routines.EEG.readEEG(fullpath, ttNo, false);
else
	eeg(ttNo) = dataanalyzer.routines.EEG.readEEG(fullpath, ttNo, false);
end

tooShortEEG = find(cellfun(@length, eeg)<1e4);

ttNo = setdiff(ttNo, tooShortEEG);

theta = opt.thetaBnd;
measure = opt.ratio_measure;
ratios = repmat(struct('ttNo', [], measure, []), size(ttNo));

ttInd = 0;
for tt = ttNo(:)'
	ttInd = ttInd + 1;
	[S, f] = EEG.psd(eeg{tt});
	sc = EEG.depink(S, f);
	wideband = f>opt.widebandLwr & f<opt.widebandHgh; % restrict the ratio to (peak(theta)/avg(wideband-theta)), because if wideband is taken to be the entire range, its average will be so small pretty much any theta power would be much bigger than it
	ratios(ttInd).(measure) = EEG.bandpower(f(wideband), sc(wideband), theta, measure);
	ratios(ttInd).ttNo = ttNo(ttInd);
end

save(fullfile(obj.fullPath, opt.saveFileName), 'ratios', '-v7.3');
obj.thetaRatiosFileName = opt.saveFileName;

function [eegFilesIdx, eegList, fullpath] = getEEGind(obj)

eegFilesIdx = false;
bgnIdx = cellfun(@(x) isa(x, 'dataanalyzer.begintrial'), obj.trials);
bgnTr = extractcell(obj.trials(bgnIdx));
paths = [obj.fullPath; arrayfun(@(b) b.fullPath, bgnTr(:), 'un', 0)];
c = 0;
while ~any(eegFilesIdx)
	c = c + 1;
	eegList = fastdir(paths{c});
	eegFilesIdx = cellfun(@(x) ~isempty(x), regexp({eegList.name}, '.ncs$', 'match', 'once'));
end

fullpath = paths{c};