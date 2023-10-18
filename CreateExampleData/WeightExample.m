% Example
close all
rng(2021)
W =   [79 82        78    78    78    79    79    80    80    81]';
W = [W;(randn(10,1)*.9+80)];
size(W)
W = [W;(randn(30,1)*.7+80+linspace(0,2,30)')];
figure
plot(W,'o')
xlabel('Day','fontsize',30)
ylabel('Weight [kg]','fontsize',30)


