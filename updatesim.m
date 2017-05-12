function [roads,cars,stats] = updatesim(t, roads, cars, stats, speed, gridsize, use_controller, antecedents, conclusions, universe)

light_just_changed = 0;
for r=1:length(roads)
    for l=1:length(roads(r).lanes)
        for s=1:length(roads(r).lanes(l).signals)
            sig = roads(r).lanes(l).signals(s);
            sig.sim.counter = sig.sim.counter + 1;
            if(sig.color == 'R')
                if(sig.sim.counter >= clamp(sig.sim.redperiod + sig.sim.extension, 2 + sig.sim.yelperiod, 20 + sig.sim.yelperiod))
                    sig.color = 'G';
                    sig.sim.counter = 0;
                    light_just_changed = 1;
                end
            elseif(sig.color == 'Y')
                if(sig.sim.counter >= (sig.sim.yelperiod))
                    sig.color = 'R';
                    sig.sim.counter = 0;
                end
            elseif(sig.color == 'G')
                if(sig.sim.counter >= clamp(sig.sim.grnperiod + sig.sim.extension, 2, 20))
                    sig.color = 'Y';
                    sig.sim.counter = 0;
                end
            end
            roads(r).lanes(l).signals(s) = sig;
        end
    end
end

grid = zeros(gridsize);
dead = zeros(1,length(cars));
for c=1:length(cars)
    if(cars(c).sim.dead ~= 1)
        r = cars(c).road;
        l = cars(c).lane;
        o = cars(c).offset;
        e = roads(r).lanes(l).length;

        cars(c).sim.moving = 1;
        cars(c).sim.counter = cars(c).sim.counter + 1;
        for s=1:length(roads(r).lanes(l).signals)
            ro = roads(r).lanes(l).signals(s).offset;
            so = roads(r).lanes(l).signals(s).sensor_offset;

            if(isnear(o, ro, speed) && ...
                    (roads(r).lanes(l).signals(s).color == 'R' || ...
                    roads(r).lanes(l).signals(s).color == 'Y'))
                cars(c).sim.moving = 0;
            end
            
            if(issensed(o, ro, so))
                if(cars(c).sim.sensed == 0)
                    cars(c).sim.sensed = 1;
                    roads(r).lanes(l).signals(s).sim.cars_in = ...
                        roads(r).lanes(l).signals(s).sim.cars_in + 1;
                    
                    cars(c).sim.entry_time = t;
                end
        elseif(cars(c).sim.sensed == 1)
                cars(c).sim.sensed = 0;
                roads(r).lanes(l).signals(s).sim.cars_out = ...
                    roads(r).lanes(l).signals(s).sim.cars_out + 1;
                
                time_in = t - cars(c).sim.entry_time;
                drive_time = 15 / speed;
                roads(r).lanes(l).signals(s).sim.drive_time= ...
                    roads(r).lanes(l).signals(s).sim.drive_time + ...
                    drive_time;
                roads(r).lanes(l).signals(s).sim.wait_time = ...
                    roads(r).lanes(l).signals(s).sim.wait_time + ...
                    (time_in - drive_time);
                
            end
        end

        if(cars(c).sim.moving)
            ahead = grid(r, l, cars(c).offset+1:cars(c).offset+speed);
            car_ahead = length(find(ahead));
            if(car_ahead == 0)
                cars(c).offset = cars(c).offset + speed;
                %{
                if(r == 1 && l == 1)
                    disp(num2str([r l t cars(c).offset]));
                end
                %}
            else
                cars(c).sim.waitcounter = cars(c).sim.waitcounter + 1;
            end

            if(cars(c).offset > e)
                dead(c) = 1;
            end
        else
            cars(c).sim.waitcounter = cars(c).sim.waitcounter + 1;
        end
        
        % Mark this location
        %[r l cars(c).offset]
        if(grid(r, l, cars(c).offset) == 1)
            dead(c) = 1;
            %disp('Double car');
        else
            grid(r, l, cars(c).offset) = 1;
        end
    else
        dead(c) = 1;
    end
end

forstats = cars(dead==1);
numcars = zeros(gridsize(1), gridsize(2));
thrutimes = zeros(gridsize(1), gridsize(2));
for f=1:length(forstats)
    if(forstats(f).sim.counter > 0)
        r = forstats(f).road;
        l = forstats(f).lane;
        stats.waittimes(r,l,t) = stats.waittimes(r,l,t) + forstats(f).sim.waitcounter;
        
        numcars(r,l) = numcars(r,l) + 1;
        thrutimes(r,l) = thrutimes(r,l) + forstats(f).sim.counter;
    end
end
%{
for r=1:length(roads)
    for l=1:length(roads(r).lanes)
        if(numcars(r,l) > 0)
            stats.flowrate(r,l,t) = thrutimes(r,l) / numcars(r,l);
        elseif(t > 1)
            stats.flowrate(r,l,t) = stats.flowrate(r,l,t-1);
        end
    end
end
%}
cars(dead==1) = [];

arrivals = 0;
queues = 0;
for r=1:length(roads)
    for l=1:length(roads(r).lanes)
        for s=1:length(roads(r).lanes(l).signals)
            sig = roads(r).lanes(l).signals(s);
            if(sig.sim.cars_out > 0 && sig.sim.drive_time > 0)
                stats.cost(r,l,t) = (sig.sim.cars_in * sig.sim.wait_time) / ...
                    (sig.sim.cars_out * sig.sim.drive_time);
            else
                stats.cost(r,l,t) = 0;
            end
            
            if(sig.color == 'G')
                arrivals = arrivals + sig.sim.cars_in - sig.sim.cars_out;
            else
                queues = queues + sig.sim.cars_in - sig.sim.cars_out;
            end
        end
    end
end

[inference,wgts]=smie_coa([arrivals queues], ...
        antecedents, conclusions, universe);   

% Extract signal states
sigstate = [];
for r=1:length(roads)
    for l=1:length(roads(r).lanes)
        for s=1:length(roads(r).lanes(l).signals)
            sigstate = [sigstate roads(r).lanes(l).signals(s).color];
        end
    end
end

% Only update signal extension if no lights are yellow
if(light_just_changed)
    for r=1:length(roads)
        for l=1:length(roads(r).lanes)
            for s=1:length(roads(r).lanes(l).signals)
                if(use_controller)
                    roads(r).lanes(l).signals(s).sim.extension = inference;
                end
            end
        end
    end
    %%{
    disp(['inference: ', num2str(inference),' arrivals: ', num2str(arrivals), ...
        ' queues: ', num2str(queues), ' state: ', num2str(sigstate)]);
    %%}
end
