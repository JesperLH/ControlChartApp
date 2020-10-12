%demo
%[x_ref, x_sensor] = CalibSimulate();%Ncal, target, target_sd, reference_sd, sensor_sd, show_plot)

data = xlsread('./example-sugar1.xlsx');

x_ref = data(:,1);
x_sensor = data(:,2);

[x_ref, x_sensor] = CalibSimulate(...
                 100, 0.5, 1, 1.2, 1, false);

%% nist example
figure;
ct_cusum()
%% Control Chart Shewhat
figure
ct_shewhart(x_ref-x_sensor,50)

figure
ct_shewhart(x_sensor,50)
%%


%% Control Chart CUMSUM
% ct_cusum(x_sensor, [], mean(x_ref), 5, 0.5);
mu_target =  mean(x_ref(1:50));
cusum_param = [1/2*sqrt(var(x_ref(1:50))), 1]; % [h,k]
% cusum_param = [0.5, 0.05, 2]; % [alpha, beta, delta]

t_vmasks = [34,49,75,80];

figure;
ct_cusum(1:length(x_sensor), x_sensor, 20, mu_target, cusum_param,t_vmasks,gca);
figure
ct_cusum(1:length(x_sensor), x_sensor, 20, [], cusum_param,t_vmasks,gca);