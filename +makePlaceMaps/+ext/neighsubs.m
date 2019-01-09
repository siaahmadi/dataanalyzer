function [i, j] = neighsubs(siz,i0,j0,varargin)
k = 1;
method = 'all';
nArgIn = length(varargin);
for i = 1:nArgIn
   input = varargin{i};
   if ischar(input) && ismember(lower(input),{'all','adj','diag'})
       method = lower(input);
   elseif ismember(size(input),[1 1;1 2],'rows') && isequal(input,int64(input))
       
       k = input;
       if isscalar(k)
           k = [k k];
       end
   else
       error('Invalid input argument');
   end
end

M = siz(1);
N = siz(2);

i = i0+[-sort(1:k(1),'descend') 0 1:k(1)];
j = j0+[-sort(1:k(2),'descend') 0 1:k(2)];
[iMesh, jMesh] = meshgrid(i,j);

keep = (iMesh>0 & jMesh>0 & iMesh<=M & jMesh<=N) & ~(iMesh==i0 & jMesh==j0);
switch method
    case 'adj'
        keep = keep & (jMesh==j0 | iMesh ==i0);
    case 'diag'
        d = diag(diag(keep));
        keep = keep & (d | fliplr(d));
end

i = iMesh(keep);
j = jMesh(keep);

if nargout==1
    i = sub2ind(siz,i,j);
end
