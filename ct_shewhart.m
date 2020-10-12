function [mu, sd, sig_limits, status_rules] = ct_shewhart(...
    data,n_ref, apply_rules, fig_handle, mu, sd, sig_limits)

if nargin < 4 || isempty(fig_handle)
    fig_handle=gca;
end

n_obs = length(data);
if nargin < 3
    apply_rules=true(4,1);
end

if nargin < 2
    n_ref = ceil(n_obs*0.8);
else
    n_ref = max(n_ref,2);
    if round(n_ref)==n_ref
        % pass
    else
        n_ref = ceil(n_obs*n_ref);
    end
        
end

if nargin <5
    sig_limits = [2, 3];
    mu = mean(data(1:n_ref));
    sd = sqrt(1/(n_ref-1)*sum((data(1:n_ref)-mu).^2));
end
if length(sig_limits) > 2
%     warning('Only warning limit and control should be passed')
    sig_limits=sig_limits(2:3);
end


sig_color = {'g','y','r'};
sig_color = {[0.4, 0.7, 0.2], [0.9, 0.9, 0.1],[0.8, 0.1, 0.1]};
sig_color = sig_color(1:2);

for n_sig = length(sig_limits):-1:1
    fill(fig_handle, [0,0,n_obs+1,n_obs+1],[-sd*sig_limits(n_sig),sd*sig_limits(n_sig), ...
        sd*sig_limits(n_sig), -sd*sig_limits(n_sig)]+mu,...
        sig_color{n_sig}, 'FaceAlpha',1);
    hold(fig_handle, 'on')
end
plot(fig_handle, 0:n_obs+1, ones(1,n_obs+2)*mu,'k','LineWidth',2.5)
hold(fig_handle,'on')
for n_sig = 1:length(sig_limits)
    if n_sig == length(sig_limits)
        l_style='-.';
    else
        l_style='--';
    end
    plot(fig_handle, 0:n_obs+1, ones(1,n_obs+2)*(mu+sig_limits(n_sig)*sd), l_style,'Color',[1,1,1]*(0.8-(n_sig/length(sig_limits))/2),'LineWidth',2)
    plot(fig_handle, 0:n_obs+1, ones(1,n_obs+2)*(mu-sig_limits(n_sig)*sd), l_style,'Color',[1,1,1]*(0.8-(n_sig/length(sig_limits))/2),'LineWidth',2)
end

plot(fig_handle, 1:n_ref, data(1:n_ref), 'ok','markersize',8,'linewidth',1)
xlim(fig_handle, [0,n_obs+1])

ymax = max(max(abs(data(:))), sd*max(sig_limits))*1.3;
if ymax==0
    ymax= 0.1;
    warning('There was no variation in the data.')
end
ylim(fig_handle, [min(-ymax+mu,min(data(:))), max(ymax+mu,max(data))])
xlabel(fig_handle,'Observations')
ylabel(fig_handle,'Difference')
title(fig_handle,'Control Chart (Shewhart)')
%%
idx_new = n_ref+1:n_obs;
outofcontrol = false(length(idx_new),length(apply_rules));

% 1 outside upper or lower CL (UCL/LCL: control limit = 3 sd)
outofcontrol(:,1) = abs(data(idx_new)-mu) > max(sig_limits)*sd;

% 2 outside the same WL in a row (warning limit = 2sd)
tup = (data(idx_new)-mu) > sig_limits(2)*sd;
tlow = (data(idx_new)-mu) < -sig_limits(2)*sd;
fail_idx = (tlow(1:end-1)+tlow(2:end) == 2) | (tup(1:end-1)+tup(2:end) == 2);

% or 2 outside either WL in a row
% t = tup | tlow;
% fail_idx = (t(1:end-1)+t(2:end) == 2);
outofcontrol(unique([find(fail_idx); find(fail_idx)+1]),2) = true;

% 7 points increasing or decreasing (trend)
n_samesign=7;
t = diff(data(idx_new));
idx = ((1:length(idx_new)-n_samesign)+(0:n_samesign-1)')';
fail_idx = idx(abs(sum(sign(t(idx)),2))==n_samesign,:);
outofcontrol(unique(fail_idx),3) = true;


% 8 points on the same side of CL (centerline (confusing notation)) Bias
n_sameside = 8;
t = data(idx_new)>=mu;
idx = ((1:length(idx_new)-n_sameside)+(0:n_sameside-1)')';
fail_idx = idx(sum(t(idx),2) == n_sameside,:);
outofcontrol(unique(fail_idx),4) = true;
t = data(idx_new)<mu;
idx = ((1:length(idx_new)-n_sameside)+(0:n_sameside-1)')';
fail_idx = idx(sum(t(idx),2) == n_sameside,:);
outofcontrol(unique(fail_idx),4) = true;

% Which observations are under control?
% - Only done for rules that are applied
in_control = ~any(outofcontrol .* apply_rules(:)' ,2); 

% Plot in and out of control
plot(fig_handle, idx_new(in_control), data(idx_new(in_control)), 'ob','markerfacecolor',[.7 .9 .7],'markersize',8)
plot(fig_handle, idx_new(~in_control), data(idx_new(~in_control)), '^r','markeredgecolor',.2*[1 1 1],'markerfacecolor',[.9 .6 .6],'markersize',10)

status_rules = ~any(outofcontrol,1); % true => in control, false not in control

%%
% leg = legend(fig_handle);
if isempty(idx_new(~in_control))
 legend(fig_handle.Children([7,6,5,2,1]), {'CL', '2 \sigma', '3\sigma', 'Calibration','Obs. (in control)'},...
     'Location','northeastoutside','FontSize',13)
else
    legend(fig_handle.Children([[7,6,5,2,1]+1, 1]), {'CL', '2 \sigma', '3\sigma', 'Calibration','Obs. (in control)', 'Obs. (not in control)'},...
     'Location','northeastoutside','FontSize',13)
end

% This is because the app expect sig_limits to be [1sd, 2sd, 3sd] %
% TODO: Improve this...
if length(sig_limits) == 2
    sig_limits = [nan, sig_limits];
end

