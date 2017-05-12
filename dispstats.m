function dispstats(fig, stats)

figure(fig);clf;subplot(211);hold on;subplot(212);hold on;
%figure(fig);clf;hold on;
%axis([1 500 0 2])

dims = size(stats.waittimes);
labels = cell(dims(1),1);
label_iter = 1;
for r=1:dims(1)
    for l=1:dims(2)
        %{
        rg = squeeze(stats.waittimes(r,l,:));
        subplot(211);
        plot(rg);
        %}
        subplot(211);
        rg1 = squeeze(stats.cost(r,l,:));
        plot(filter(ones(15,1),1,rg1)/15);
        title('Cost');
        
        subplot(212);
        rg2 = squeeze(stats.flowrate(r,:));
        plot(filter(ones(60,1),1,rg2)/60);
        title('Flow Rate');
        %hist(rg(rg~=0),1:50);
    end
        
    labels(label_iter) = {sprintf('Road: %d', r)};
    label_iter = label_iter + 1;
end
subplot(212);
legend(labels)

subplot(211);
a=axis;
a(4)=7;
axis(a);
