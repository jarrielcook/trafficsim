function draw(fig, t, roads, cars)

figure(fig); clf; hold on;xticks([]);yticks([]);
status = sprintf('Simulation Count: %d', t);
text(10, 10, status);

for c=1:length(cars)
    if(cars(c).sim.dead ~= 1)
        r = cars(c).road;
        l = cars(c).lane;
        p = roads(r).lanes(l).position;
        o = cars(c).offset;
        d = roads(r).lanes(l).direction;
        e = roads(r).lanes(l).length;

        if(d =='N')
            x = p;
            y = o;
            plot(x, y, 'b^', 'MarkerFaceColor', 'b', 'MarkerSize', 8);
        elseif(d == 'S')
            x = p;
            y = e - o;
            plot(x, y, 'rv', 'MarkerFaceColor', 'r', 'MarkerSize', 8);
        elseif(d == 'E')
            x = o;
            y = p;
            plot(x, y, 'k>', 'MarkerFaceColor', 'y', 'MarkerSize', 8);
        elseif(d == 'W')
            x = e - o;
            y = p;
            plot(x, y, 'm<', 'MarkerFaceColor', 'm', 'MarkerSize', 8);
        end
        
        %{
        if(cars(c).sim.waitcounter > 20)
            plot(x, y, 'r*', 'MarkerSize', 8);
        end
        if(cars(c).sim.sensed)
            plot(x, y, 'r+', 'MarkerSize', 8);
        end
        %}
    end
end

for r=1:length(roads)
    for l=1:length(roads(r).lanes)
        w = roads(r).lanes(l).width;
        p = roads(r).lanes(l).position;
        e = roads(r).lanes(l).length;
        d = roads(r).lanes(l).direction;
        if(d == 'N' || d == 'S')
            x1 = [(p-w/2) (p-w/2)];
            x2 = [(p+w/2) (p+w/2)];
            y = [0 e];
            plot(x1, y, 'k--');
            plot(x2, y, 'k--');
        elseif(d == 'E' || d == 'W')
            x = [0 e];
            y1 = [(p-w/2) (p-w/2)];
            y2 = [(p+w/2) (p+w/2)];
            plot(x, y1, 'k--');
            plot(x, y2, 'k--');
        end
    
        for s=1:length(roads(r).lanes(l).signals)
            o = roads(r).lanes(l).signals(s).offset;
            so = roads(r).lanes(l).signals(s).sensor_offset;
            sig = roads(r).lanes(l).signals(s);

            redface = 'none';
            yelface = 'none';
            grnface = 'none';
            if(roads(r).lanes(l).signals(s).color == 'R')
                redface = 'r';
                textcolor = 'r';
                target_count = clamp(sig.sim.redperiod + ceil(sig.sim.extension), 2, 20);
            elseif(roads(r).lanes(l).signals(s).color == 'Y')
                yelface = 'y';
                textcolor = 'k';
                target_count = sig.sim.yelperiod;
            elseif(roads(r).lanes(l).signals(s).color == 'G')
                grnface = 'g';
                textcolor = 'g';
                target_count = clamp(sig.sim.grnperiod + ceil(sig.sim.extension), 2, 20);
            end

            if(d == 'N')
                x = [p p]+w/2;
                y1 = [o o];
                y2 = [o o]-4;
                y3 = [o o]-8;
                xs = [p-w/2 p+w/2];
                ys = [so so];
                plot(x, y1, 'ko', 'MarkerFaceColor', redface, 'MarkerSize', 10);
                plot(x, y2, 'ko', 'MarkerFaceColor', yelface, 'MarkerSize', 10);
                plot(x, y3, 'ko', 'MarkerFaceColor', grnface, 'MarkerSize', 10);
                plot(xs, ys, 'k-.');
                
                count = sprintf('Count: %d/%d', sig.sim.counter, target_count);
                th=text(x + 10, y1 - 10, count);
            elseif(d == 'S')
                x = [p p]-w/2;
                y1 = e-[o o];
                y2 = e-[o o]+4;
                y3 = e-[o o]+8;
                xs = [p-w/2 p+w/2];
                ys = e-[so so];
                plot(x, y1, 'ko', 'MarkerFaceColor', redface, 'MarkerSize', 10);
                plot(x, y2, 'ko', 'MarkerFaceColor', yelface, 'MarkerSize', 10);
                plot(x, y3, 'ko', 'MarkerFaceColor', grnface, 'MarkerSize', 10);
                plot(xs, ys, 'k-.');
                
                count = sprintf('Count: %d/%d', sig.sim.counter, target_count);
                th=text(x - 35, y1 + 10, count);
            elseif(d == 'E')
                x1 = [o o];
                x2 = [o o]-4;
                x3 = [o o]-8;
                y = [p p]-w/2;
                xs = [so so];
                ys = [p-w/2 p+w/2];
                plot(x1, y, 'ko', 'MarkerFaceColor', redface, 'MarkerSize', 10);
                plot(x2, y, 'ko', 'MarkerFaceColor', yelface, 'MarkerSize', 10);
                plot(x3, y, 'ko', 'MarkerFaceColor', grnface, 'MarkerSize', 10);
                plot(xs, ys, 'k-.');
                
                count = sprintf('Count: %d/%d', sig.sim.counter, target_count);
                th=text(x1 - 35, y-10, count);
            elseif(d == 'W')
                x1 = e-[o o];
                x2 = e-[o o]+4;
                x3 = e-[o o]+8;
                y = [p p]+w/2;
                xs = e-[so so];
                ys = [p-w/2 p+w/2];
                plot(x1, y, 'ko', 'MarkerFaceColor', redface, 'MarkerSize', 10);
                plot(x2, y, 'ko', 'MarkerFaceColor', yelface, 'MarkerSize', 10);
                plot(x3, y, 'ko', 'MarkerFaceColor', grnface, 'MarkerSize', 10);
                plot(xs, ys, 'k-.');
                
                count = sprintf('Count: %d/%d', sig.sim.counter, target_count);
                th=text(x3, y+10, count);
            end
            set(th,'Color',textcolor);
        end
    end
end

    
