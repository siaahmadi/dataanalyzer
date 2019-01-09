
function S = LoadSpikes(tfilelist, path, NaFile)

if ~isa(tfilelist, 'cell')
    error('LoadSpikes: tfilelist should be a cell array.');
end


% Number of file names in tfilelist
nFiles = length(tfilelist);
% Actual number of files to be loaded
anFiles = nFiles - length(NaFile);

fprintf(2, 'Reading %d files.', anFiles);

S = cell(nFiles, 1);
for iF = 1:nFiles
    tfn = tfilelist{iF};
    % Check if file exist
    if length(strmatch(char(tfn),NaFile,'exact'))>0
        S{iF} = -1; % Set this as default for each file that doesn't exist
    else
        tfn = strrep(strcat(strcat(path,'\'),tfn),'\\','\'); % Path to file + file name
        if ~isempty(tfn)
            tfp = fopen(tfn, 'rb','b');
            if (tfp == -1)
                warning([ 'Could not open tfile ' tfn]);
            end
            
            ReadHeader(tfp);
            S{iF} = fread(tfp,inf,'uint32');	%read as 32 bit ints
            S{iF} = ts(S{iF});
            fclose(tfp);
        end 	% if tfn valid
    end
end		% for all files
fprintf(2,'\n');


function H = ReadHeader(fp)
% H = ReadHeader(fp)
%  Reads NSMA header, leaves file-read-location at end of header
%  INPUT:

%      fid -- file-pointer (i.e. not filename)
%  OUTPUT:
%      H -- cell array.  Each entry is one line from the NSMA header
% Now works for files with no header.
% ADR 1997
% version L4.1
% status: PROMOTED
% v4.1 17 nov 98 now works for files sans header
%
% May 2010, modified by Emily to work with new Matlab
%---------------

% Get keys
beginheader = '%%BEGINHEADER';
endheader = '%%ENDHEADER';

iH = 1; H = {};
curfpos = ftell(fp);

% look for beginheader
headerLine = my_fgetl(fp);
if strcmp(headerLine, beginheader)
    H{1} = headerLine;
    while ~feof(fp) & ~strcmp(headerLine, endheader)
        headerLine = my_fgetl(fp);
        iH = iH+1;
        H{iH} = headerLine;
    end
else % no header
    fseek(fp, curfpos, 'bof');
end

function tline = my_fgetl(fid)

try
    [tline,lt] = fgets(fid);
    tline = tline(1:end-length(lt));
    fseek(fid, -(length(lt)-1), 'cof');
    
    if isempty(tline)
        tline = '';
    end
    
catch exception
    if nargin ~= 1
        error (nargchk(1,1,nargin,'struct'))
    end
    throw(exception);
end