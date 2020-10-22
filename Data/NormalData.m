%%
clf
rng(1)
ms = 30;
col1 = [.4 .4 .7];
col2 = [.2 .2 .4];
fs = 30;
x = randn(100,1);
plot(x,'o','color',col2,'markerfacecolor',col1,'markersize',ms,'linewidth',4)
set(gca,'fontsize',20)
xlabel('Time','fontsize',fs)
ylabel('Deviation from ref','fontsize',fs)
axis([0 100 -6 +6])
shg


%%
clf
nexttile
pp=plot(x,'o','color',col2,'markerfacecolor',col1,'markersize',ms,'linewidth',4)
set(gca,'fontsize',20)
xlabel('Time','fontsize',fs)
ylabel('Deviation from ref','fontsize',fs)
axis([0 100 -6 +6])
shg

nexttile
h=histogram(x);
h.BinWidth=.2;
h.FaceColor = col1;
h.EdgeColor = col2;


%%
m = mean(x);
sd = std(x);
title(['Mean ',num2str(round(m*100)/100),' std ',num2str(round(sd*100)/100)],'fontsize',fs)
y = -3:0.1:3;
hold on
f = exp(-(y-m).^2./(2*sd^2))./(sd*sqrt(2*pi));
plot(y,20*f,'LineWidth',5)
shg


%%
nexttile(1)
yline(m,'linewidth',10)
text
yline(m+2*sd,'linewidth',10,'color',[0 1 0],'linewidth',5)
yline(m-2*sd,'linewidth',10,'color',[0 1 0],'linewidth',5)
yline(m+3*sd,'linewidth',10,'color',[1 0 0],'linewidth',5)
yline(m-3*sd,'linewidth',10,'color',[1 0 0],'linewidth',5)

nexttile(2)
xline(m,'linewidth',10)
text
xline(m+2*sd,'linewidth',10,'color',[0 1 0],'linewidth',5)
xline(m-2*sd,'linewidth',10,'color',[0 1 0],'linewidth',5)
xline(m+3*sd,'linewidth',10,'color',[1 0 0],'linewidth',5)
xline(m-3*sd,'linewidth',10,'color',[1 0 0],'linewidth',5)
title('')

shg