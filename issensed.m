function sensed = issensed(car, signal, sensor)

sensed = (car >= sensor) && (car <= signal);
