function roads = make_roads(roadlen)

roads(1).lanes(1) = make_lane('N', roadlen, roadlen/2+10);
roads(1).lanes(2) = make_lane('S', roadlen, roadlen/2);
roads(2).lanes(1) = make_lane('E', roadlen, roadlen/2-10);
roads(2).lanes(2) = make_lane('W', roadlen, roadlen/2);

roads(1).lanes(1).signals(1) = make_signal(roadlen/2-15, 'R');
roads(1).lanes(2).signals(1) = make_signal(roadlen/2-5, 'R');
roads(2).lanes(1).signals(1) = make_signal(roadlen/2-5, 'G');
roads(2).lanes(2).signals(1) = make_signal(roadlen/2-15, 'G');

