function l = isbegin(sth)

l = regexp(sth, '^begin\d{0,2}$|^b\d{0,2}$') == 1;