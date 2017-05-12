plot(results.NScongestion(1:2:end), results.total_cost(1:2:end))
hold on
plot(results.NScongestion(2:2:end), results.total_cost(2:2:end))
legend('Fixed System', 'Fuzzy System')
xlabel('NS Congestion')
ylabel('Cost Function')
title('Cost vs Congestion')