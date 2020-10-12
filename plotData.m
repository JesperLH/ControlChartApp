function plotData(x_ref, x_sensor, fig_handle)

if isempty(x_ref)

    plot(fig_handle, x_sensor, 'or')
    title(fig_handle,'Observed Data')
    legend(fig_handle,{'Data'},...
                        'Location','northeastoutside', 'Fontsize',13)
    
else
    plot(fig_handle, x_ref, 'ob')
    hold(fig_handle,'on')
    plot(fig_handle, x_sensor, 'or')
    
    title(fig_handle,'Reference and Sensor Data')
    legend(fig_handle,{'Reference', 'Soft Sensor'},...
                        'Location','northeastoutside', 'Fontsize',13)
end

xlim(fig_handle,[0,length(x_sensor)])
xlabel(fig_handle,'Observations')
ylabel(fig_handle,'Value')

                    
                    