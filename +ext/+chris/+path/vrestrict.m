function varargout = vrestrict(varargin)
switch length(varargin)
    case 2
        if ispathdata(varargin{1});
            pathData = varargin{1};
            vRange = varargin{2};
            if any(vRange)>0
				if ~isfield(pathData, 'v') % if statement added by Sia on 2/25/16
					pathData = addvelocity(pathData);
				end
                nPaths = length(pathData);
                for p = 1:nPaths
                    [pathData(p).x pathData(p).y] = vrestrict(pathData(p).x, pathData(p).y,pathData(p).t,pathData(p).v,vRange);
                end
            end
            varargout{1} = pathData;
        else
            error('PATHDATA must be a structure with fields X,Y and T');
        end
    case {4,5}
        x = varargin{1};
        y = varargin{2};
        t = varargin{3};
        assert(isequal(length(x),length(y),length(t)),'X,Y and T must be the same length');
        if length(varargin)== 5
            v = varargin{4};
            vRange = varargin{5};
        else
            vRange = varargin{4};
            v = velocity(x,y,t);
        end
        
        if any(vRange>0)
            if isscalar(vRange)
                vRange = [vRange inf];
            end
            x = subdata(x,vRange,v,'restrict');
            y = subdata(y,vRange,v,'restrict');
        end
        varargout{1} = x;
        varargout{2} = y;
end
