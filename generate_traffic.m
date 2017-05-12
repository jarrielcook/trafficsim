function cars = generate_traffic(congestion, roadnum, nlanes)

newcars = (rand(1, nlanes) <= congestion);

cars(1) = deadcar;
c = 1;
for i=1:nlanes
    if(newcars(i))
        cars(c).road = roadnum;
        cars(c).lane = i;
        cars(c).offset = 1;
        cars(c).sim.moving = 1;
        cars(c).sim.dead = 0;
        cars(c).sim.waitcounter = 0;
        cars(c).sim.counter = 0;
        cars(c).sim.sensed = 0;
        c = c + 1;
    end
end
