function SpatialTuningMeasures = p___computeTuningMeasures(Map, occup, fieldInfo)

[si_bithz, si_bitspike] = dataanalyzer.routines.spatial.information_skaggs96(Map, occup);
si.persecond = si_bithz;
si.perspike = si_bitspike;

spa = dataanalyzer.routines.spatial.sparsity_skaggs96(Map, occup);

sel = dataanalyzer.routines.spatial.selectivity_skaggs96(Map, occup);

sel83 = NaN;
fieldBins = cat(1, fieldInfo.bins);
if ~isempty(fieldBins)
    sel83 = dataanalyzer.routines.spatial.selectivity_barnes83(Map, occup, fieldBins);
end


SpatialTuningMeasures.information_per_sec = si.persecond;
SpatialTuningMeasures.information_per_spike = si.perspike;
SpatialTuningMeasures.selectivity = sel;
SpatialTuningMeasures.sparsity = spa;
SpatialTuningMeasures.selectivity_barnes83 = sel83;