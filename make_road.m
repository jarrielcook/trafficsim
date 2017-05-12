function road = make_road

road.lanes(1) = make_lane('N', 100, 40);
road.lanes(2) = make_lane('S', 100, 30);
road.lanes(3) = make_lane('E', 100, 60);
road.lanes(4) = make_lane('W', 100, 70);

road.signals(1) = make_signal(1, 75, 'R');
road.signals(2) = make_signal(2, 55, 'R');
road.signals(3) = make_signal(3, 45, 'R');
road.signals(4) = make_signal(4, 25, 'R');
