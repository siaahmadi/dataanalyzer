function ptempl = parsingtemplate(pmode)
%PARSINGTEMPLATE Define zones used to assign zone index to path data
%
% ptempl = PARSINGTEMPLATE(pmode)
%    pmode can be 'fig8:rdscr' (return-delay-stem-choice-reward)
%                 'fig8mouse:rdscr' (return-delay-stem-choice-reward)

% split = strsplit(pmode, ':');
% mazetype = split{1};
% pmode = split{2};

mazetype = 'fig8';
if ~exist('pmode', 'var')
	pmode = 'rldspw';
else
	matches = strsplit(pmode, ':');
	mazetype = matches{1};
	pmode = matches{2};
end

switch mazetype
	case {'fig8', 'fig8rat', 'fig8mouse'}
		if strcmpi(pmode, 'rldspw') % return-delay-stem-prereward-reward
			i = 0;
			
			i = i + 1;
			ptempl(i).x = [-70 -70 -25 -25 -10 -10 -70 NaN -[-70 -70 -25 -25 -10 -10 -70]];    % return left and right
			ptempl(i).y = [-90 60 60 -55 -55 -90 -90 NaN [-90 60 60 -55 -55 -90 -90]]; % return left and right
			ptempl(i).zone = 'return';
			
			i = i + 1;
			ptempl(i).x = [-10 -10 10 10 -10]; % pre-delay
			ptempl(i).y = -[90 62.5 62.5 90 90];   % pre-delay
			ptempl(i).zone = 'predelay';
			
			i = i + 1;
			ptempl(i).x = [-10 -10 10 10 -10]; % delay
			ptempl(i).y = -[62.5 45 45 62.5 62.5];   % delay
			ptempl(i).zone = 'delay';
			
			i = i + 1;
			ptempl(i).x = [-20 -20 20 20 -20]; % stem
			ptempl(i).y = [-45 60 60 -45 -45]; % stem
			ptempl(i).zone = 'stem';
			
			i = i + 1;
			ptempl(i).x = [-30 -30 30 30 -30]; % pre-reward
			ptempl(i).y = [60 90 90 60 60];    % pre-reward
			ptempl(i).zone = 'prereward';
			
			i = i + 1;
			ptempl(i).x = [-70 -70 -30 -30 -70 NaN 30 30 70 70 30]; % reward
			ptempl(i).y = [60 90 90 60 60 NaN 60 90 90 60 60];      % reward
			ptempl(i).zone = 'reward';
			
		elseif strcmpi(pmode, 'rdscr') % return-delay-stem-choice-reward
			ptempl(1).x = [-70 -70 -25 -25 -70 NaN 25 25 70 70 25];    % return left and right
			ptempl(1).y = [-90 60 60 -90 -90 NaN -90 60 60 -90 -90]; % return left and right
			ptempl(1).zone = 'return';
			
			ptempl(2).x = [-10 -10 10 10 -10]; % delay
			ptempl(2).y = -[90 45 45 90 90];   % delay
			ptempl(2).zone = 'delay';
			
			ptempl(3).x = [-20 -20 20 20 -20]; % stem
			ptempl(3).y = [-45 60 60 -45 -45]; % stem
			ptempl(3).zone = 'stem';
			
			ptempl(4).x = [-10 -10 10 10 -10]; % choice
			ptempl(4).y = [30 90 90 30 30];    % choice
			ptempl(4).zone = 'choice';
			
			ptempl(5).x = [-60 -60 -10 -10 -60 NaN 10 10 60 60 10]; % reward
			ptempl(5).y = [60 90 90 60 60 NaN 60 90 90 60 60];      % reward
			ptempl(5).zone = 'reward';
		else
			error('Unknown or unspecified parsing template.');
		end
		
		for i = 1:length(ptempl)
			[ptempl(i).x, ptempl(i).y] = poly2cw(ptempl(i).x, ptempl(i).y);
		end
		
end

switch mazetype
	case 'fig8mouse'
		for i = 1:length(ptempl)
			[ptempl(i).x, ptempl(i).y] = deal(ptempl(i).x*.5, ptempl(i).y*.5);
		end
end