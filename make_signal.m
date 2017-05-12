function signal = make_signal(offset, color)

if(color ~= 'R' && ...
    color ~= 'Y' && ...
    color ~= 'G')
    disp('Invalid color: must be one of R,Y,G');
else
    signal.color = color;
end

signal.offset = offset;
signal.sensor_offset = offset - 15;
signal.sim.grnperiod = 4;
signal.sim.yelperiod = 4;
% redperiod = grnperiod + yelperiod
signal.sim.redperiod = signal.sim.grnperiod + signal.sim.yelperiod;
signal.sim.extension = 0;
signal.sim.counter = 0;
signal.sim.cars_in = 0;
signal.sim.cars_out = 0;
signal.sim.wait_time = 0;
signal.sim.drive_time = 0;

