function [x,y] = interppos(x,y,timeThreshold,sampRate)

sampThreshold = floor(timeThreshold * sampRate);

index_isvalid = find(~isnan(x) & ~isnan(y));
count_NaNs = 0;
for i = index_isvalid(1):index_isvalid(end)
    if isnan(x(i)) || isnan(y(i)) 
        count_NaNs = count_NaNs+1;
    else
        if count_NaNs > 0 && count_NaNs < sampThreshold
            for j = last_valid+1:i-1
                x(j) = (x(i)*(j-last_valid)+x(last_valid)*(i-j))/(i-last_valid);
                y(j) = (y(i)*(j-last_valid)+y(last_valid)*(i-j))/(i-last_valid);
            end
        end
    last_valid = i;
    count_NaNs = 0;
    end
end