function [l, beginTS, endTS] = getDuration(obj)

if isempty(obj.duration)
	rPath = obj.residencePath;
	[TimeStamps, EventStrings] = Nlx2MatEV([rPath '\Events.nev'], [1 0 0 0 1 0], 0, 1, 1);
	tIndex = strcmp(EventStrings, obj.namestring); % trial begin index in TimeStamps
% 	if regexp(obj.namestring, 'sleep') > 0 % if sleep trial
% 		eIndex = strcmp(EventStrings, ['end' obj.namestring]);
% 	else
% 		eIndex = strcmp(EventStrings, ['end' num2str(obj.trialSeqInd)]); % trial end index TimeStamps
% 	end
	if dataanalyzer.trial.issleep(obj) % if sleep trial
		eIndex = strcmp(EventStrings, ['end' obj.namestring]);
	elseif dataanalyzer.trial.isbegin(obj)
		eIndex = strcmp(EventStrings, ['end' num2str(obj.trialSeqInd)]) ...
			| strcmp(EventStrings, ['end' obj.namestring]); % trial end index TimeStamps
	else
		error('Undefined')
	end
	% Sanity check:
	if sum(tIndex) == 0
		error('Mismatch between trial identity/namestring and recorded namestrings in the .nev event file.');
	end
	if sum(eIndex) == 0
		warning('Mismatch in namestring and records in .nev file. Attempting to resolve by lookahead.')
		if find(tIndex) == length(tIndex)
			error('Mismatch between trial identity/namestring and recorded namestrings in the .nev event file.');
		else
			fprintf(2, '\nSuccessfully resolved.\n\n');
			eIndex = circshift(tIndex, [1, 0]); % [1, 0] and not 1, due to MATLAB release notes and default behavior of |circshift|
		end
	end
	
	tIndex = find(tIndex, 1, 'last');
	eIndex = find(eIndex, 1, 'last');
	if TimeStamps(eIndex) < TimeStamps(tIndex)
		eIndex = strcmp(EventStrings, ['end' obj.namestring]); % trial end index TimeStamps
	end
	l = (TimeStamps(eIndex) - TimeStamps(tIndex)) / 1e6; % /1e6 converts us to s
	obj.duration = l;
	obj.beginTS = TimeStamps(tIndex) / 1e6;
	obj.endTS = TimeStamps(eIndex) / 1e6;
else
	beginTS = obj.beginTS;
	endTS = obj.endTS;
	l = obj.duration;
end