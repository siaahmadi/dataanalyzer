function [significantCoactivations, raftBndrIdxQ, isolatedEvents, participationCDF] = findSignificantCoactivations(x, eventLength, eventSeparation, alpha)
% x: a cell array of spiketrains
% eventLength: the desired duration of candidate events
% alpha: at what prevalence should an event be considered significant?

%
% @Version 1.05
% @Date 04/04/2015
% @changes: definition of |t|: changed -numBins to -floor(numBins/2)
% This was due to my misbelief that |addDummyHeadAndTail| added a full
% numBins to both ends, while it in fact added floor(numBins/2) to each end

% 
% @Version 1.04
% @Date 04/02/2015
% @changes: "retain only if not too long" --> the |else| statment added
% (continue)

% @Version 1.03
% @Date 03/27/2015
% @changes: First two output arguments changed from |sigIntervals,
% spikeInfo| to |significantCoactivations, raftBndrIdxQ|

% @Version 1.01
% @Data 03/26/2015
% @Note First fully functional, fully featured version

NLX_SPIKE_TS_PRECISION = 4e-4; % seconds
MAX_EVENT_LENGTH = 0.5; % seconds
% ^ cannot be shorter than |eventLength|
MAX_EVENT_N = floor(MAX_EVENT_LENGTH / NLX_SPIKE_TS_PRECISION);

numBins = round(eventLength / NLX_SPIKE_TS_PRECISION); numBins = numBins - ~mod(numBins, 2); % make numBins odd
numBinsSep = round(eventSeparation / NLX_SPIKE_TS_PRECISION); numBinsSep = numBinsSep - ~mod(numBinsSep, 2); % make numBins odd
%                                 ^ this does not need to be multiplied by
%                                   two because slider adds 1's from left and
%                                   right (once for the leading spike, and
%                                   once for the lagging one)

ss = dataanalyzer.wip.mksparse(x);
if isempty(x)
	significantCoactivations = [];
	return;
end
t0 = x{find(ss, 1, 'first')}(1); % find(ss, 1, 'first') == first neuron to fire
ss = addDummyHeadAndTail(ss, numBins);

numParticipNeur = sparse([],[],[],1,size(ss,2));
numParticipNeurSep = sparse([],[],[],1,size(ss,2));
hwb = waitbar(0, 'Initializing...');
for rowInd = 1:size(ss,1) % apply filter row by row
	buffer = full(ss(rowInd,:));
	numParticipNeur = numParticipNeur + sparse(double(smooth(buffer, numBins)' * numBins > 0)); % NOTE: thought dilation needed: but no; invervals (sliders) are identified by their center, not their entire span
	numParticipNeurSep = numParticipNeurSep + sparse(double(smooth(buffer, numBinsSep)' * numBinsSep > 0));
	
	waitbar(rowInd/size(ss,1), hwb, 'Computing...');
end
waitbar(rowInd/size(ss,1), hwb, 'Finishing up...');
close(hwb);

raftBoundaries = getRaftBoundaries(numParticipNeurSep, numParticipNeur, numBins);
% --- get isolated events, with erosion
buffer = int2intset(raftBoundaries, false, 1, numel(numParticipNeur));
isolatedEvents = lau.raftidx(lau.erode(full(sparse(1,buffer,true,1,buffer(end))), floor(numBinsSep/2)));
isolatedEventsQ = dataanalyzer.wip.raftarray(isolatedEvents);
% ---
[raftBoundaries, crossOverRafts] = erodeRaftBoundaries(raftBoundaries, numBins, numBinsSep);
raftBoundaries = removeInvalidRaftBoundaries(raftBoundaries);
raftBndrIdxQ = dataanalyzer.wip.raftarray(raftBoundaries);

validationMask = sparse(1,unique(int2intset(raftBoundaries, false, 1, numel(numParticipNeur))), true, 1,numel(numParticipNeur));
numParticipNeur_Validated = numParticipNeur .* validationMask; % &-ing the two
% NOTE: difference between |raftBoundaries| and |numParticipNeur_Validated|
% |raftBoundaries| contains this indices of the boundaries within which
% numParticipNeur is valid. |numParticipNeur_Validated| is just
% numParticipNeur restricted to |raftBoundaries|

t = t0+(NLX_SPIKE_TS_PRECISION/2:NLX_SPIKE_TS_PRECISION:(numel(numParticipNeur)-floor(numBins/2)+1)*NLX_SPIKE_TS_PRECISION); % timestamps

[numCellsNeededToBeSignificant, participationCDF] = getSignificanceThreshold(numParticipNeur, alpha);
sigIdx = numParticipNeur_Validated >= numCellsNeededToBeSignificant;
sigIdx = lau.close(full(sigIdx),floor(numBinsSep/2)); % close short gaps (typically <50ms)
sigIdx = sparse(sigIdx & ~lau.open(sigIdx,floor(MAX_EVENT_N/2))); % subtract significant events longer than MAX_EVENT_N

% -- Get tight events
% here I can't use |numParticipNeurSep| because I want to have an adaptable
% slider window size. So the strategy here is to take Little Rafts in
% succession and make a window as wide as the raft under consideration and
% count the number of cells active in that window. (I could've done this
% for every event rather than divide the labour in two parts, right?)
sigIntvlTight = getTightSigIntervals(crossOverRafts, numCellsNeededToBeSignificant, ss, MAX_EVENT_N);
% -- END

allSigIntervalsQ = dataanalyzer.wip.raftarray(sort([sigIntvlTight; lau.raftidx(full(sigIdx))]));
sigIntervals = zeros(2,0);
spikeInfo = cell(numel(allSigIntervalsQ), 1);
j = 0;
while ~allSigIntervalsQ.eof()
	[bInd, ~] = allSigIntervalsQ.next(); % don't need the eInd except for info --> sigIdx by definition is robust against fluctuations in the number of active cells within an event

	currInterval = isolatedEventsQ.next();
	while currInterval(2) < bInd
		currInterval = isolatedEventsQ.next();
	end
	
	currInterval(1) = currInterval(1) - 1;
	currInterval(2) = currInterval(2) + 1;
	if diff(currInterval) < MAX_EVENT_N % retain only if not too long
		sigIntervals(:, size(sigIntervals, 2)+1) = currInterval(:);
	else
		continue;
	end
	
	j = j + 1;
	bInd = currInterval(1); % ------ NOTE: notice the change of purpose of bInd and eInd ------ %
	eInd = currInterval(2);
	sInfo = getSpikeInfo(ss, bInd, eInd);
	sInfo.firstIdx = sInfo.firstIdx + bInd - 1;
	sInfo.firstTS = t(sInfo.firstIdx);
	sInfo.medianTS = interp1(1:eInd-bInd+1, t(bInd:eInd), sInfo.medianIdx);	% order-senstive with next line
	sInfo.medianIdx = sInfo.medianIdx + bInd - 1;							% order-senstive with prev line
	spikeInfo{j} = sInfo;	% ------    NOTE: END change of purpose of bInd and eInd     ------ %
	
	try
		bNe = t(sigIntervals(:,j) - floor(numBins/2));
	catch
		1;
	end
	significantCoactivations(j) = dataanalyzer.wip.neuralevents.sigcoac(bNe,sInfo); %#ok<AGROW>
end

spikeInfo = [spikeInfo{:}]';
sigIntervals = t(sigIntervals - floor(numBins/2)); % NOTE: @Ver1.01 I believe this is actually the correct line. The reason the above line worked was I was including an Interneuron and then, for display purposes, not accounting for the fact that the interneuron spiked before every other neuron in the beginning



function raftBoundaries = getRaftBoundaries(numParticipNeurSep, numParticipNeur, numBinsBig)
raftBoundaries = find(lau.rt(full(numParticipNeurSep)>0));
ddBegin = 2*find(raftBoundaries(1:2:end) > floor(numBinsBig/2), 1, 'first')-1;
ddEnd = 2*find(raftBoundaries(2:2:end) <= length(numParticipNeur) - floor(numBinsBig/2), 1, 'last');
if raftBoundaries(ddEnd+1) < length(numParticipNeur) - floor(numBinsBig/2)
	raftBoundaries(ddEnd+2) = length(numParticipNeur) - floor(numBinsBig/2);
	ddEnd = ddEnd + 2;
end
if raftBoundaries(ddBegin-1) > floor(numBinsBig/2)
	raftBoundaries(ddBegin-2) = floor(numBinsBig/2) + 1;
	ddBegin = ddBegin - 2;
end

raftBoundaries = raftBoundaries(ddBegin:ddEnd);

function [raftBoundaries, crossOverRafts] = erodeRaftBoundaries(raftBoundaries, BigSpan, LittleSpan)

littleWing = floor(LittleSpan/2);
bigWing = floor(BigSpan/2);

erodeBy = littleWing + bigWing - LittleSpan;

crossOverIdx = false(size(raftBoundaries));
crossOverIdx(:) = repmat(diff(reshape(raftBoundaries, 2,numel(raftBoundaries)/2))<erodeBy*2, 2,1); % erodeBy*2 --> b/c erosion is two-ended
crossOverRafts = raftBoundaries(crossOverIdx);

if raftBoundaries(1) == bigWing + 1
	raftBoundaries(3:2:end) = raftBoundaries(3:2:end) + erodeBy;
else
	raftBoundaries(1:2:end) = raftBoundaries(1:2:end) + erodeBy;
end
if raftBoundaries(end) == bigWing
	raftBoundaries(2:2:end-2) = raftBoundaries(2:2:end-2) - erodeBy;
else
	raftBoundaries(2:2:end) = raftBoundaries(2:2:end) - erodeBy;
end

function raftBoundaries = removeInvalidRaftBoundaries(raftBoundaries)

raftBoundaries = reshape(raftBoundaries, 2,numel(raftBoundaries)/2);
d = diff(raftBoundaries);
raftBoundaries = raftBoundaries(:, d >= 0);
raftBoundaries = raftBoundaries(:)';


function ss = addDummyHeadAndTail(ss, numBins)
ss = [sparse([],[],[],size(ss,1),floor(numBins/2)), ss, sparse([],[],[],size(ss,1),floor(numBins/2))];

function [numCellsNeededToBeSignificant, participationCDF] = getSignificanceThreshold(numParticipNeur, alpha)
binCenters = unique(numParticipNeur);
N = histcounts(numParticipNeur);
particCDF = cumsum(N / sum(N));
% numCellsNeededToBeSignificant = binCenters(find(participationCDF>1-alpha, 1, 'first')); % old way --> fine for very large sets, but wrong for small ones
cdfMap = cumsum(fliplr(diff(particCDF)));
numCellsNeededToBeSignificant = binCenters(end-find(cdfMap < alpha, 1, 'last') + 1);
if isempty(numCellsNeededToBeSignificant) % nothing is significant at provided |alpha|
	numCellsNeededToBeSignificant = binCenters(end) + 1;
end
participationCDF.y = particCDF;
participationCDF.x = binCenters;

function sigIntvlTight = getTightSigIntervals(crossOverRafts, numCellsNeededToBeSignificant, ss, MAX_EVENT_N)
crvrQ = dataanalyzer.wip.raftarray(crossOverRafts);
sigIntvlTight = zeros(2,crvrQ.numel);
j = 0;
while ~crvrQ.eof()
	[bI, eI] = crvrQ.next();
	if bI - eI + 1 > MAX_EVENT_N % ingore events that are too long
		continue;
	end
	
	numParticNeurTight = getNumActiveCellsW(ss, bI, eI, 1);

	if numParticNeurTight > numCellsNeededToBeSignificant
		j = j + 1;
		sigIntvlTight(:, j) = [bI;eI];
	end
end
sigIntvlTight(:,j+1:end) = [];
sigIntvlTight = sigIntvlTight(:);

function numActiveNeur = getNumActiveCellsW(ss, bI, eI, method1or2)

w = ss(:, bI:eI);

if method1or2 == 1
	numActiveNeur = nnz(sum(w, 2)); % method 1
elseif method1or2 == 2
	numActiveNeur = sum(cellfun(@(x) nnz(x)>0, mat2cell(w, ones(1,size(w,1)), eI-bI+1))); % method 2
else
	error('select a valid method (1 or 2)');
end

function sInfo = getSpikeInfo(ss, bI, eI)

w = ss(:, bI:eI);

activeRows = find(sum(w,2));
[firstIdx, medianIdx, spikeCounts] = cellfun(@infoFunc, mat2cell(w(activeRows, :), ones(1,numel(activeRows)), size(w,2)));

sInfo.numActiveCells = numel(activeRows);
sInfo.activeCells = activeRows;
sInfo.firstIdx = firstIdx;
sInfo.medianIdx = medianIdx;
[~, Im] = sort(medianIdx);
[~, If] = sort(firstIdx);
sInfo.sortedCellsFirst  = activeRows(If);
sInfo.sortedCellsMedian = activeRows(Im);
sInfo.spikeCounts = spikeCounts;

function [y1,y2,y3] = infoFunc(x)
y1 = find(x>0,1,'first');
y2 = median(find(x));
y3 = full(sum(x>0));

function intervals = intset2int(inArray, mergeOffset, inverse, firstVal, lastVal)
% intervals = intset2int(inArray, mergeOffset, inverse, firstVal, lastVal)
%
% Convert an array of integers (type intervalset) into an array of pairs of
% integers denoting the boundaries of the intervals (type intervals)
% 
% This is the inverse function of @int2intset
% 
% inArray       input array
% mergeOffset   number of integers to ignore between subsequent intervals
% inverse       output intervals complementing inArray (true/false)
% firstVal      if inverse is true, this determines the lower bound of the
%               bigger interval in which inArray should be complemented
% lastVal       if inverse is true, the upper bound for the bigger interval
%
% a := [0 1 2 3 9 10 11 12 15 18 20 22 28 29 30];
% EXAMPLE       intset2int(a)
%               output:     0     3     9    12    15    15    18    18    20    20    22    22    28    30
%
% EXAMPLE       intset2int(a, 1)
%               output:     0     3     9    12    15    15    18    22    28    30
%
% EXAMPLE       intset2int(a, 1, true)
%               output:     4     8    13    17    23    27
%
% EXAMPLE       intset2int(a, 1, true, -10, 60)
%               output:     -10    -1     4     8    13    17    23    27    31    60

if isempty(inArray)
	intervals = [];
	return;
end
T = false;
if size(inArray, 2) == 1 && ~numel(inArray == 1)
	inArray = inArray';
	T = true;
end

if nargin == 1
	mergeOffset = 0;
	inverse = false;
elseif nargin == 4
	error('firstVal and lastVal must be simultaneously present or absent')
elseif nargin > 1 && mergeOffset == Inf
	mergeOffset = inArray(end)-inArray(1);
end
if nargin == 3
	firstVal = inArray(1);
	lastVal = inArray(end);
end
if (nargin==3 || nargin==5) && inverse
	if ~size(inArray, 1) == 1 && ~size(inArray, 2) == 1
		error('inArray must be a vector')
	end
	intervals = intset2int(...
					int2intset(...
						intset2int(inArray, mergeOffset, ~inverse, firstVal, lastVal),...
					inverse, firstVal, lastVal)...
				, mergeOffset, ~inverse, firstVal, lastVal);
	return
end

% detect singletons
diffArray = [mergeOffset+1 diff(inArray)-1 mergeOffset+1];
singletons = find((diffArray(1:end-1)>mergeOffset & diffArray(2:end)>mergeOffset)==true);
% now add duplicates of singletons to inArray
if ~isempty(singletons)
	inArray2 = [];
	prevInd = 1;
	for i = 1:length(singletons)
		try
		inArray2 = [inArray2 inArray(prevInd:singletons(i)) inArray(singletons(i))];
		prevInd = singletons(i)+1;
		catch
			continue;
		end
	end
	if singletons(end)~=length(inArray)  % last entry is not a singleton
		inArray2 = [inArray2 inArray(prevInd:end)];
	end
	inArray = inArray2;
	clear inArray2
end

% final stage
diffArray = abs(diff(inArray))>(mergeOffset+1);
diffArray = [1 find(diffArray==true) length(inArray)];
diffArray = union(diffArray(2:end), diffArray(2:end)+1);
intervals = [inArray(1) inArray(diffArray(1:end-1))];
if T
	intervals = intervals';
end

function intervalSet = int2intset(inArray, inverse, firstVal, lastVal)
% convert an array of integer pairs (called intervals) into a list of
% integers which fill the gap between the two ends of the intervals (called
% interval sets)
%
% This is the inverse function of @intset2int
%
% EXAMPLE: int2intset([2 3 7 11])
%          output: 2 3 7 8 9 10 11
%
% EXAMPLE: int2intset([2 3 7 11 13 15 20 22], true)
%          output: 4 5 6 12 16 17 18 19
%
% EXAMPLE: int2intset([2 3 7 11 13 15 20 22], true, -1, 25)
%          output: -1 0 1 4 5 6 12 16 17 18 19 23 24 25
%
% EXAMPLE: int2intset([2 3 7 11], false, -1, 13)
%          output: 2 3 7 8 9 10 11

if mod(inArray, 2)==1
	error('the input inArray must be of even length (because it is assumed to be in pairs).')
end
if size(inArray, 1)>1
	intervalSet = zeros(sum(inArray(2:2:end)-inArray(1:2:end))+length(inArray)/2, 1);
else
	intervalSet = zeros(1, sum(inArray(2:2:end)-inArray(1:2:end))+length(inArray)/2);
end
j = 1;
for i = 1:2:length(inArray)
	intervalSet(j:inArray(i+1)-inArray(i)+j) = (inArray(i):inArray(i+1))';
	j = inArray(i+1)-inArray(i)+j+1;
end
if nargin == 2
	if inverse == true
		intervalSet = setdiff(intervalSet(1):intervalSet(end), intervalSet);
	end
elseif nargin == 3
	error('firstVal and lastVal must be simultaneously present or absent')
elseif nargin > 3
	if inverse == true
		intervalSet = setdiff(firstVal:lastVal, intervalSet);
	end
end
if (size(inArray, 1) == 1 && size(intervalSet, 1)~=1) || (size(inArray, 2) == 1 && size(intervalSet, 2) ~= 1)
	intervalSet = intervalSet';
end