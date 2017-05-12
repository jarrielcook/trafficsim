%% Simulation Configuration
use_controller = 0;
roadlen = 200;
NScongestion = 0.30;
EWcongestion = 0.25;
% Initialize random number generator
rng(42491);
% Create roads and initialize cars
roads = make_roads(roadlen);
cars = [generate_traffic(NScongestion, 1, 2) generate_traffic(EWcongestion, 2, 2)];
stats = stats_init(2,2,roadlen + 200);

%% Init Fuzzy System
x = 0:16;
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

% Rules
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
    zero_mf,...
    zero_mf,...
    zero_mf,...
    zero_mf,...
    short_mf,...
    short_mf,...
    zero_mf,...
    zero_mf,...
    long_mf,...
    long_mf,...
    short_mf,...
    zero_mf,...
    longer_mf,...
    long_mf,...
    long_mf,...
    short_mf};


%% Run simulation
last_car = zeros(2,2);
for i=1:roadlen+100
    % Draw current state of simulation
    draw(1, i, roads, cars);

    % Annotate plot
    figure(1);
    cong = sprintf('NS Congestion: %d EW Congestion: %d', ...
        (NScongestion*100), (EWcongestion*100));
    text(10, 15, cong);
    fuzzy = sprintf('Use Controller: %d', use_controller);
    text(10, 20, fuzzy);

    % Grab video frame
    F(i) = getframe;
    pause(0.001)

    % Update simulation
    [roads,cars,stats] = updatesim(i, roads,cars,stats,4, [2 2 roadlen+1], use_controller, antecedents, conclusions, y);

    % Generate more traffic
    newcars = [generate_traffic(NScongestion, 1, 2) generate_traffic(EWcongestion, 2, 2)];
    for c=1:length(newcars)
        r = newcars(c).road;
        l = newcars(c).lane;
        if(r > 0)
            stats.flowrate(r, i) = stats.flowrate(r, i) + 1 / (i-last_car(r,l));
            last_car(r,l) = i;
        end
    end
    cars = [cars newcars];

    % Display statistics
    dispstats(2, stats);
end

%% Flush simulation
for i=roadlen+101:roadlen+200
    % Draw current state of simulation
    draw(1, i, roads, cars);

    % Grab video frame
    F(i) = getframe;
    pause(0.001)
    
    % Update simulation
    [roads,cars,stats] = updatesim(i, roads,cars,stats,4, [2 2 roadlen+1], use_controller, antecedents, conclusions, y);

    % Display statistics
    dispstats(2, stats);
end

%% Display Wait Time summary
wait_1_1 = stats.waittimes(1,1,:);
wait_1_2 = stats.waittimes(1,2,:);
wait_2_1 = stats.waittimes(2,1,:);
wait_2_2 = stats.waittimes(2,2,:);
wait_all_lanes = stats.waittimes(:);
disp(['ave wait: ', num2str(mean(wait_all_lanes)),...
    ' ave wait when stopped: ', num2str(mean(wait_all_lanes(wait_all_lanes>0)))]);

%% Display Cost Summary
cars_in = 0;
cars_out = 0;
wait_time = 0;
drive_time = 0;
for r=1:length(roads)
    for l=1:length(roads(r).lanes)
        for s=1:length(roads(r).lanes(l).signals)
            cars_in = cars_in + roads(r).lanes(l).signals(s).sim.cars_in;
            cars_out = cars_out + roads(r).lanes(l).signals(s).sim.cars_out;
            wait_time = wait_time + roads(r).lanes(l).signals(s).sim.wait_time;
            drive_time = drive_time + roads(r).lanes(l).signals(s).sim.drive_time;
        end
    end
end
total_cost = (cars_in * wait_time) / (cars_out * drive_time);
disp(['Total Cost: ', num2str(total_cost)]);

%% Display Cost and Flow Density
figure(2);
subplot(211);
title(['NS Congestion: ', num2str(NScongestion), ...
    ' EW Congestion: ', num2str(EWcongestion), ...
    ' Total Cost: ', num2str(total_cost)]);
subplot(212);
title(['Flow Density  NS Congestion: ', num2str(NScongestion), ...
    ' EW Congestion: ', num2str(EWcongestion)]);

%% Store video
moviename = sprintf('simulation_%d_%d', ...
    floor(NScongestion*100), floor(EWcongestion*100));
simvid = VideoWriter(moviename);
set(simvid, 'FrameRate', 5);
open(simvid);
writeVideo(simvid, F);
close(simvid);

