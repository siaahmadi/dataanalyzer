function [runs, x, y, t, idx] = getRun(obj, N, superCompN)

[runs, x, y, t, idx] = obj.getParsedComp('runs', N, superCompN);