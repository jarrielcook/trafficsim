clear

%% Init Fuzzy System
x = 0:50;

% Input MFs
almost_mf = Ltriangle(x, 0, 0, 2);
almost = containers.Map(x, almost_mf);
few_mf = Ctriangle(x, 0, 2, 4);
few = containers.Map(x, few_mf);
many_mf = Ctriangle(x, 2, 4, 6);
many = containers.Map(x, many_mf);
toomany_mf = Rtriangle(x, 4, 6, 6);
toomany = containers.Map(x, toomany_mf);

verysmall_mf = Ltriangle(x, 0, 0, 2);
verysmall = containers.Map(x, verysmall_mf);
small_mf = Ctriangle(x, 0, 2, 4);
small = containers.Map(x, small_mf);
medium_mf = Ctriangle(x, 2, 4, 6);
medium = containers.Map(x, medium_mf);
large_mf = Rtriangle(x, 4, 6, 6);
large = containers.Map(x, large_mf);

y = -6:26;
% Output MFs
zero_mf = Ltriangle(y, 0, 0, 2);
zero = containers.Map(y, zero_mf);
zero_center = -2;
short_mf = Ctriangle(y, 0, 2, 4);
short = containers.Map(y, short_mf);
short_center = 2;
long_mf = Ctriangle(y, 2, 4, 6);
long = containers.Map(y, long_mf);
long_center = 4;
longer_mf = Rtriangle(y, 4, 6, 6);
longer = containers.Map(y, longer_mf);
longer_center = 8;

antecedents = {...
    {almost, verysmall},...
    {almost, small},...
    {almost, medium},...
    {almost, large},...
    {few, verysmall},...
    {few, small},...
    {few, medium},...
    {few, large},...
    {many, verysmall},...
    {many, small},...
    {many, medium},...
    {many, large},...
    {toomany, verysmall},...
    {toomany, small},...
    {toomany, medium},...
    {toomany, large}};
conclusions = {...
    zero_mf, zero_mf, zero_mf, zero_mf,...
    short_mf, short_mf, zero_mf, zero_mf,...
    long_mf, long_mf, short_mf, zero_mf,...
    longer_mf, long_mf, long_mf, short_mf};

[X,Y] = meshgrid(x,x);
for i=1:length(x)
    for j=1:length(x)
        Z(i,j) = clamp(smie_coa([x(i) x(j)], antecedents, conclusions, y),-10,8);
        Z(i,j) = smie_coa([x(i) x(j)], antecedents, conclusions, y);
    end
end
mesh(X,Y,Z)
title('Traffic Controller Rule Surface');
xlabel('Queued');
ylabel('Arrivals');
zlabel('Extension');
view(30,15);
