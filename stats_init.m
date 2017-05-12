function stats = stats_init(nroads,nlanes, simlen)

stats.waittimes = zeros(nroads, nlanes, simlen);
stats.cost = zeros(nroads, nlanes, simlen);
stats.flowrate = zeros(nroads, simlen);
