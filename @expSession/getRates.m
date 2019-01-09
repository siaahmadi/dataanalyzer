function all_rates = getRates(obj, order, varargin) % varargin should be used for obj.getNeurons --> the return value of obj.getNeurons can be converted to cell, with unreturned neurons as empty

allN = obj.getNeurons;
all_rates = cellfun(@auxFunc, allN);

temporalOrder = {'sleep0'
    'begin1'
    'sleep1'
    'begin2'
    'sleep2'
    'begin3'
    'sleep3'
    'begin4'
    'sleep4'
    'begin5'
    'sleep5'
    'begin6'
    'sleep6'
    'begin7'
    'sleep7'
    'begin8'
    'sleep8'
    'begin9'
    'sleep9'};

if ~exist('order', 'var') || isempty(order) || strcmpi(order, 'object')
	% pass
elseif strcmpi(order, 'temporal')
	f_idx = firstone(cellfun(@length,allN'));
	
	trialNameStringsInOrder = cellfun(@(x) x.Parent.namestring, allN(sub2ind(size(allN), f_idx', 1:size(f_idx, 1))), 'UniformOutput', false);
	
	[~, idx_inv] = parentTrialIndex(trialNameStringsInOrder, temporalOrder);
	
	all_rates = all_rates(:, idx_inv);
end


function r = auxFunc(x)

if isempty(x)
	r = 0;
else
	r = x.meanRate();
end

function [trIdx, trIdx_inv, trsIncluded] = parentTrialIndex(trialNameStringsInOrder, temporalOrder)

idx = cell2mat(cellfun(@(x) matchstr(temporalOrder, x), trialNameStringsInOrder, 'UniformOutput', false));
idx_inv = cell2mat(cellfun(@(x) matchstr(temporalOrder, x), trialNameStringsInOrder, 'UniformOutput', false));
trsIncluded = sum(idx, 2)==1;
idx = mat2cell(idx, size(idx, 1), ones(size(idx, 2), 1));
idx_inv = mat2cell(idx_inv, ones(size(idx_inv, 1), 1), size(idx_inv, 2));
idx = cellfun(@(x) find(x,1,'first'), idx, 'UniformOutput', false);
idx_inv = cellfun(@(x) find(x,1,'first'), idx_inv, 'UniformOutput', false);
idx = [idx{:}];
idx_inv = [idx_inv{:}];
trIdx = idx(:);
trIdx_inv = idx_inv(:);