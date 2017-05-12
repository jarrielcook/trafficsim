function [t] = Ctriangle(x, a, b, c)

t = max(min((x-a)/(b-a), (c-x)/(c-b)), 0);
