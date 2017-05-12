function near = isnear(car, signal, speed)

near = (car >= (signal-speed)) && (car <= signal);
