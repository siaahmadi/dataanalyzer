function computeTrialMaps(obj)


X = obj.parentTrial.positionData.getX();
Y = obj.parentTrial.positionData.getY();
T = obj.parentTrial.positionData.getTS();
S = obj.getSpikeTrain('unrestr');

dft_opt = dataanalyzer.internal.p___loadConstantsDB('phaprecTakuya');
