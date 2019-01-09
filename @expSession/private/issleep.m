function l = issleep(sth)

l = regexp(sth, '^sleep\d{0,2}$|^s\d{0,2}$') == 1;