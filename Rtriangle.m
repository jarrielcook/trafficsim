function [t] = Rtriangle(x, a, b, c)

t = max(min((x-a)/(b-a), 1), 0);
