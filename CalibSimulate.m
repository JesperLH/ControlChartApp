function [YTrue, SoftSens] = CalibSimulate(Ncal, target, target_sd, reference_sd, sensor_sd, show_plot)
%% CALIBSIMULATE simulates calibration data from a univariate stochastic process
%
% MIT License
% Copyright (c) <2023> <Jesper Løve Hinrich>


if nargin < 1
    Ncal = 30; % Number of samples
end
if nargin < 4
    target = 3.3; % Target value of fat we aim for
    target_sd = .2; % Process variation, so the real variation of fat
    reference_sd = .1; % Variation in reference measurements
    sensor_sd = .1; % Variation in sensor measurements
    show_plot = true;
end


[YTrue, SoftSens]=makedat(target,target_sd,Ncal,reference_sd,sensor_sd);

if show_plot
    subplot(2,1,1)
    plot([YTrue SoftSens],'o','linewidth',3)
    axis([0 Ncal 0+target/2 max(max(YTrue),max(SoftSens))*1.03])
    legend({'Ref Lab';'Our sensor'})

    subplot(2,1,2)
    j=plot([YTrue-SoftSens],'o','linewidth',3,'Color',[.4 .9 .4],'MarkerFaceColor',[.2 .8 .2],'MarkerSize',10)
    legend({'Difference'})

    shg
end

data = YTrue-SoftSens;


%% 


function [YTrue, SoftSens]=makedat(target,ProcStd,Ncal,NoisRef,NoisSens)
% disp(target);
    
YTrue = target + randn(Ncal,1)*ProcStd;
SoftSens = YTrue;
YTrue = YTrue + randn(Ncal,1)*NoisRef;
SoftSens = SoftSens + randn(Ncal,1)*NoisSens;

end

end