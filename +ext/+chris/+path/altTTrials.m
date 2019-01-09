function trialInfo = altTTrials(locInfo)
trialInfo = struct([]);

nPaths = length(locInfo);
for path = 1:nPaths
    locInds = locInfo(path).inds;
    locInts = locInfo(path).tInt;
    locLabels = locInfo(path).labelSeq;
    nLocs = size(locInds,1);
    labelSeq = fillSeqHole(locInfo(path).labelSeq);
    startVisits = find(ismember(labelSeq,'A25'));
    rewardVisits = find(ismember(labelSeq,{'N4','N6'}));
    
    nextStart = startVisits(1);
    trialInds = [];
    trialInts = [];
    trialDirs = [];
    trialLocs = [];
    iDegen = zeros(0,2);
    degenIDs = [];
    iTrial = 0;
    while ~isempty(nextStart)
        iTrial = iTrial+1;
        thisStart = nextStart;
        thisReward = rewardVisits(find(rewardVisits>thisStart,1));
        if isempty(thisReward)
            break;
        end
        rewardLoc = labelSeq(thisReward);
        if strcmp(rewardLoc,'N4')
            direction = 'R';
            returnArm = 'A23';
            rewardArm = 'A45';
        else
            direction = 'L';
            returnArm = 'A12';
            rewardArm = 'A56';
        end
        
        if isempty(trialDirs)
            trialSuccess = true;
        else
            trialSuccess = cat(1,trialSuccess,~strcmp(trialDirs(end),direction));
        end
        trialDirs = cat(1,trialDirs,{direction});
        nextStart = startVisits(find(startVisits>thisReward,1));
        if isempty(nextStart)
            thisEnd = thisReward;
        else
            thisEnd = nextStart-1;
        end
        trialInds = cat(1,trialInds,{locInds(thisStart:thisEnd,:)});
        trialInts = cat(1,trialInts,{locInts(thisStart:thisEnd,:)});
        trialLocs = cat(1,trialLocs,{locLabels(thisStart:thisEnd)});
        iExitStem = find(strcmp(labelSeq,'N5') & in([1:nLocs]',thisStart,thisEnd,1),1);
        iExitChoice = find(strcmp(labelSeq,'N5') & in([1:nLocs]',iExitStem,thisEnd,1),1,'last');
        if ~all(ismember(labelSeq(iExitStem:iExitChoice),{'A25','N5'})) % the rat is only allowed to leave the N5 node to go a little back into the stem arm (A25); this behavior may happend as many times as the rat wishes without labeling the trial a degenerate trial
            iDegen = cat(1,iDegen,[locInds(iExitStem,1) locInds(iExitChoice,2)]);
            degenIDs = cat(1,degenIDs,iTrial);
        end
        iExitChoice = find(~strcmp(labelSeq,'N5') & ~strcmp(labelSeq,'A25') & in([1:nLocs]',iExitStem,thisEnd,1),1);
        if ~strcmp(rewardArm,labelSeq(iExitChoice)) % this will never be true (last 'if' block ensures this fact)
            iEnterArm = find(strcmp(labelSeq,rewardArm) & in([1:nLocs]',iExitChoice+1,thisEnd,1),1);
% 			try
				iDegen = cat(1,iDegen,[locInds(iExitStem,1) locInds(iEnterArm-1,2)]);
% 			catch
% 				1;
% 			end
            degenIDs = cat(1,degenIDs,iTrial);
        end
        iEnterChoice = find(strcmp(labelSeq,'N2') & in([1:nLocs]',thisStart,thisEnd,1),1);
        if ~isempty(iEnterChoice)
            iExitChoice = find(~strcmp(labelSeq,'N2') & ~strcmp(labelSeq,returnArm) & in([1:nLocs]',iEnterChoice,thisEnd,1),1);
            if ~isempty(iExitChoice)
                iDegen = cat(1,iDegen,[locInds(iEnterChoice,1) locInds(thisEnd,2)]);
                degenIDs = cat(1,degenIDs,iTrial);
            end
        end
    end
    degen = false(size(trialInds,1),1);
    degen(unique(degenIDs)) = true;
    nTrials = length(trialDirs);
    trialNums = [1:nTrials]';
    trialInfo(path,1).trial = trialNums;
    trialInfo(path,1).inds = trialInds;
    trialInfo(path,1).tInt = trialInts;
    trialInfo(path,1).direction = trialDirs;
    trialInfo(path,1).loc = trialLocs;
    trialInfo(path,1).success = trialSuccess;
    trialInfo(path,1).degen = degen;
    trialInfo(path,1).degenInds = iDegen;
    trialInfo(path,1).degenIDs = degenIDs;
    trialInfo(path,1).mazeType = 'fig8';
end

end

function lblSeq = fillSeqHole(lblSeq)
	idx = strcmpi(lblSeq, '');
	idx(1) = false; idx(end) = false; % for the first and last indices we can never be sure what the previous location of the animal has been (unless we look at the videoData)
	
	for i = find(idx(:)')
		lblSeq{i} = ['N', setdiff(intersect(lblSeq{i-1}, lblSeq{i+1}), 'A')];
	end
end