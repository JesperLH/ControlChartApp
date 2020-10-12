function [mu_target, in_control] = ct_cusum(x_range, data, n_ref, mu_target, cusum_param, t_vmasks, fig_handle)
%%CT_CUSUM calculates and plots the CUSUM control chart
%
% INPUT:
%   x_range:    x-axis.
%   data:       Measured data (y-axis).
%   mu_target:  Control target.
%   cusum_param:    Parameters [h,k] or [alpha, beta, delta] for the
%                   CUSUM-chart.
%   t_vmasks:   One or more value which indexes observations in x_range
%               where the V-mask should be plotted.
%   fig_handle: Handle to figure (default=> gca)
%
% OUTPUT:
%   in_control: boolean value indicating whether all observations are in
%               control (true) or not (false).

if nargin < 1 || isempty(data)
    % NIST example
    % See https://www.itl.nist.gov/div898/handbook/pmc/section3/pmc323.htm
    data = [324.93, 324.68, 324.73, 324.35 , 325.35 , 325.23 , 324.13 , 324.53 ...
    ,325.23 , 324.60 , 324.63 , 325.15 , 328.33 , 327.25 , 327.83 , 328.50...
    ,326.68 , 327.78, 326.88, 328.35];
    mu_target = 325;
    h_decision_limit = 4.1959;
    k_slop = 0.3175;
    % Cusum
    cusum_data = cumsum(data-mu_target);
    x_range=(1:length(data));
    t_vmasks=14;
else
    % Get parameters for the CUSUM
    % Cusum
    if isempty(mu_target)
        mu_target = mean(data(1:n_ref));
    else
        n_ref=0;
    end
    
    calib_data = data(1:n_ref);
    cusum_data = cumsum(data(n_ref+1:end)-mu_target);

    if length(cusum_param)== 2 % [h,k]
        % h_decision_limit is the allowed change at timepoint t.
        % k is the slope of the V-mask line, e.g. how much more variation is
        %   allowed per additional timestep.
        h_decision_limit = cusum_param(1);
        k_slop = cusum_param(2);

    elseif length(cusum_param) == 3 % [alpha, beta, delta]
        % α: The probability of a false alarm, i.e., concluding that a shift in the
        %    process has occurred, while in fact it did not. 
        % β: The probability of not detecting that a shift in the process mean has,
        %    in fact, occurred.
        % δ (delta): The amount of shift in the process mean that we wish to
        %   detect, expressed as a multiple of the standard deviation of the data
        %   points (which are the sample means).  
        alpha = cusum_param(1); beta = cusum_param(2); delta = cusum_param(3);
        sigma_data = sqrt(var(data(1:n_ref)-mu_target));%/sqrt(length(data));
        warning('Sigma_data is not calculated correctly.. WIP.')
        
        k_slop = delta*sigma_data / 2;
        d = 2/delta^2*log( (1-beta)/alpha);
        h_decision_limit = d*k_slop;

    end
end

if nargin < 6
    fig_handle = gca;
end
color_high = [0.2,0.2,0.8];
color_low = [0.8,0.2,0.2];

% average run length (High ARL when in control, low when out of control)
% Calculate CUSUM upper and lower limits
[s_high,s_low] = iterative_cusum(data(n_ref+1:end), mu_target,k_slop);

%% Visualize control chart
% In control area
% fh_incontrol = fill(fig_handle, [x_range(1)-1,x_range(end)+1,x_range(end)+1,x_range(1)-1],...
%     [h_decision_limit,h_decision_limit,-h_decision_limit,-h_decision_limit],...
%     [0.4, 0.7, 0.2],'FaceAlpha',1,'EdgeColor',[0.4, 0.7, 0.2]);
hold(fig_handle,'on')

% Upper and lower limit for change
% fh_shigh = plot(fig_handle, x_range,s_high,'--','Color',color_high,'LineWidth',2);
% fh_slow = plot(fig_handle, x_range, s_low,'--','Color',color_low,'LineWidth',2);

% Determine in and out of control points
% If at time i, d_i>h or e_r > h, the process is out of control
in_control = ~(s_high > h_decision_limit | s_low > h_decision_limit);

% Reset CUSUM to zero after a series of uncontrolled points
if false
    idx_oic = find(~in_control(1:end-1) & in_control(2:end))+1;
    for i = 1:length(idx_oic)-1
        cusum_data(idx_oic(i):idx_oic(i)-1)=...
            cusum_data(idx_oic(i):idx_oic(i)-1)-cusum_data(idx_oic(i)-1);
        
    end
end
fh_calibr = plot(fig_handle, x_range(1:n_ref), calib_data, 'ok','markersize',8);
x_range_cusum=x_range(n_ref+1:end);
fh_cusum_control = plot(fig_handle, x_range_cusum(in_control), cusum_data(in_control), 'ob','markerfacecolor',[.7 .9 .7],'markersize',8);
fh_cusum_outcontrol= plot(fig_handle, x_range_cusum(~in_control), cusum_data(~in_control), '^r','markeredgecolor',.2*[1 1 1],'markerfacecolor',[.9 .6 .6],'markersize',10);

% plots_legend = {'In control','S(high)','S(low)','CUSUM (in control)','CUSUM (out of control)'};
if n_ref ~= 0
    plots_legend = {'Calibration','In control','Out of control'};
else
    plots_legend = {'In control','Out of control'};
end
if isempty(fh_cusum_control)
    plots_legend(length(plots_legend)-1) = [];
end

%legend([fh_incontrol, fh_shigh, fh_slow, fh_cusum_control, fh_cusum_outcontrol],...
legend([fh_calibr, fh_cusum_control, fh_cusum_outcontrol],...
    plots_legend, 'Location','eastoutside','FontSize',13)

% Plot V-mask at desired timestep
total_data = [calib_data; cusum_data(:)];
if ~isempty(t_vmasks)
    plotVmask(total_data(t_vmasks(1)),x_range(t_vmasks(1)),h_decision_limit,k_slop,fig_handle);
    for t = t_vmasks(2:end)
        plotVmask(total_data(t),x_range(t),h_decision_limit,k_slop,fig_handle);
        fig_handle.Legend.String(end) = [];
    end
end

xlim(fig_handle,[x_range(1), x_range(end)]);
ylim(fig_handle,[min(min(total_data(:)),-2*h_decision_limit), max(max(total_data(:)*1.2,2*h_decision_limit))]);
xlabel(fig_handle,'Observations');
ylabel(fig_handle,'CUSUM value');
title(fig_handle,'Control Chart (CUSUM)');


in_control = all(in_control);
end


function [d,e] = iterative_cusum(x,x_target,k)
    d = zeros(length(x)+1, 1);
    e = zeros(length(x)+1, 1);
    
    for i = 1:length(x)
        d(i+1) = max(0, d(i) + (x(i)-(x_target+k)));
        e(i+1) = max(0, e(i) - (x(i)-(x_target-k)));
    end
    
    d(1)=[];
    e(1)=[];
end

function plotVmask(xt,t,h,k,fig_handle,mask_color)
    
    if nargin <6
        mask_color = [0.2,0.2,0.2];
    end
    
    if nargin < 5 || isempty(fig_handle)
        fig_handle = gca;
    end
    

    d= h/k;
    
    lup = xt+h+k*(t:-1:1);
    ldown = xt-h-k*(t:-1:1);
    
    plot(fig_handle, [1:t,t:-1:1],[lup,ldown(end:-1:1)],'-','Color',mask_color,'LineWidth',1.5);
    fig_handle.Legend.String{end} = 'V-mask';
end

