index = 1;

%% Init Fuzzy System
x = 0:16;
% Input MFs
%figure(3); clf
%subplot(311); hold on; title('Arrival Input MFs');
almost_mf = Ltriangle(x, 0, 0, 2);
almost = containers.Map(x, almost_mf);
%plot(x, almost_mf);
few_mf = Ctriangle(x, 0, 2, 4);
few = containers.Map(x, few_mf);
%plot(x, few_mf);
many_mf = Ctriangle(x, 2, 4, 6);
many = containers.Map(x, many_mf);
%plot(x, many_mf);
toomany_mf = Rtriangle(x, 4, 6, 6);
toomany = containers.Map(x, toomany_mf);
%plot(x, toomany_mf);
%xlabel('Arrival');
%legend('Almost','Few','Many','Too Many');

%subplot(312); hold on; title('Queueing Input MFs');
verysmall_mf = Ltriangle(x, 0, 0, 2);
verysmall = containers.Map(x, verysmall_mf);
%plot(x, verysmall_mf);
small_mf = Ctriangle(x, 0, 2, 4);
small = containers.Map(x, small_mf);
%plot(x, small_mf);
medium_mf = Ctriangle(x, 2, 4, 6);
medium = containers.Map(x, medium_mf);
%plot(x, medium_mf);
large_mf = Rtriangle(x, 4, 6, 6);
large = containers.Map(x, large_mf);
%plot(x, large_mf);
%xlabel('Queueing');
%legend('Very Small','Small','Medium','Large');

y = -6:26;
% Output MFs
%subplot(313); hold on; title('Output MFs');
zero_mf = Ltriangle(y, 0, 0, 2);
zero = containers.Map(y, zero_mf);
zero_center = -2;
%plot(y, zero_mf);
short_mf = Ctriangle(y, 0, 2, 4);
short = containers.Map(y, short_mf);
short_center = 2;
%plot(y, short_mf);
long_mf = Ctriangle(y, 2, 4, 6);
long = containers.Map(y, long_mf);
long_center = 4;
%plot(y, long_mf);
longer_mf = Rtriangle(y, 4, 6, 6);
longer = containers.Map(y, longer_mf);
longer_center = 8;
%plot(y, longer_mf);
%xlabel('Extension')
%legend('Zero','Short','Medium','Longer');

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

for NScongestion=0.05:0.05:0.40
    for use_controller=0:1
        roadlen = 200;
        EWcongestion = 0.25;
        rng(42491);

        roads = make_roads(roadlen);
        cars = [generate_traffic(NScongestion, 1, 2) generate_traffic(EWcongestion, 2, 2)];
        stats = stats_init(2,2,roadlen + 200);


        %% Run simulation
        last_car = zeros(2,2);
        for i=1:roadlen+100
            [roads,cars,stats] = updatesim(i, roads,cars,stats,4, [2 2 roadlen+1], use_controller, antecedents, conclusions, y);

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
        end

        % Flush simulation
        for i=roadlen+101:roadlen+200
            [roads,cars,stats] = updatesim(i, roads,cars,stats,4, [2 2 roadlen+1], use_controller, antecedents, conclusions, y);
        end

	%% Compute Total Cost
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

	% Compile results
        results.EWcongestion(index) = EWcongestion;
        results.NScongestion(index) = NScongestion;
        results.use_controller(index) = use_controller;
        results.total_cost(index) = total_cost;
        index = index + 1;
    end
end
