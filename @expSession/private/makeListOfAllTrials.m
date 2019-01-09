function [listOfAllTrials, trialTypes] = makeListOfAllTrials(fullPath, bgnStr, slpStr)

dirList = dir(fullPath);
subdirList = dirList(cat(1, dirList.isdir));
subdirList = {subdirList.name}';

listOfAllTrials = subdirList(matchstr(subdirList, ['^' bgnStr '\d{0,2}$|^' slpStr '\d{0,2}$'], 'contains'));

trialTypes = matchstr(listOfAllTrials, bgnStr);