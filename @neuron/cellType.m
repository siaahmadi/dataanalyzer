function ctype = cellType(obj)

persistent bcix intx pyrx tfn sessionid % minimizes I/O reads

if isempty(sessionid) || ~strcmp(sessionid, dataanalyzer.ancestor(obj, 'expSession').namestring)
	sessionid = dataanalyzer.ancestor(obj, 'expSession').namestring;
	bcix = []; % this was missing; fixed on 03/30/2015
end

if ~isempty(obj.type)
	ctype = obj.type;
	return
end

wvFileToLoad = fullfile(obj.parentTrial.residencePath, ['rat' num2str(obj.parentTrial.ratNo) 'wv.mat']);

if ~exist(wvFileToLoad, 'file')
	error(['Cell type identification has not been completed or results not saved in the session directory. ' ...
		'Please run |alignAndScale.m| from directory Y:\Sia\PhD Projects\Analyses\LinearTrackABBA\spikeWaveforms for this rat to proceed.'])
elseif isempty(bcix)
	load(wvFileToLoad, 'badCellIdx', 'INTidx', 'pyrCellIdx', 'tFileNames');
	bcix = badCellIdx;	%#ok<NODEF>
	intx = INTidx;		%#ok<NODEF>
	pyrx = pyrCellIdx;	%#ok<NODEF>
	tfn = tFileNames;	%#ok<NODEF>
end
badCellIdx = bcix;
INTidx = intx;
pyrCellIdx = pyrx;
tFileNames = tfn;

myInd = matchstr(tFileNames, obj.namestring, 'exact');

switch true
	case badCellIdx(myInd)
		obj.type = 'bad';
	case INTidx(myInd)
		obj.type = 'INT';
	case pyrCellIdx(myInd)
		obj.type = 'pyr';
end

ctype = obj.type;