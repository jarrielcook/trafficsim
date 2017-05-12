function lane = make_lane(direction, len, pos, width)

if(direction ~= 'N' && ...
    direction ~= 'E' && ...
    direction ~= 'S' && ...
    direction ~= 'W')
    disp('Invalid direction: must be one of N,E,S,W');
else
    lane.direction = direction;
end

lane.length = len;
lane.position = pos;

if(nargin == 3)
    width = 10;
end
lane.width = width;
