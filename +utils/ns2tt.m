function ttNo = ns2tt(neurNameString)

token = regexp(neurNameString, '(?<=^TT)\d{1,2}(?=\_.*\.t$)', 'match', 'once');

ttNo = str2double(token);