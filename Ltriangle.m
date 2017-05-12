function [t] = Ltriangle(x, a, b, c)

t = max(min(1, (c-x)/(c-b)), 0);
