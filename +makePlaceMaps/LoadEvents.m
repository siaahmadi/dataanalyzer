
function S = LoadEvents(tfilelist, path, NaFile)

assert(isa(tfilelist, 'cell'),'LoadSpikes: tfilelist should be a cell array.');

nFiles = length(tfilelist); % Number of file names in tfilelist
anFiles = nFiles - length(NaFile); % Actual number of files to be loaded

fprintf(2, 'Reading %d files.', anFiles);

S = cell(nFiles, 1);
for iF = 1:nFiles
    tfn = tfilelist{iF};
    % Check if file exist
    if ~isempty(strmatch(char(tfn),NaFile,'exact'))
        S{iF} = -1; % Set this as default for each file that doesn't exist
    else
        tfn = strrep(strcat(strcat(path,'\'),tfn),'\\','\'); % Path to file + file name
        if ~isempty(tfn)
            events = load(tfn);
            fn = fieldnames(events);
            assert(length(fn)==1, 'each event file must contain only one variable')
            S{iF} = ts(events.(fn{1}));
        end 	% if tfn valid
    end
end		% for all files
fprintf(2,'\n');
