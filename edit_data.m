function [ref_data, sensor_data] = edit_data(ref_data, sensor_data, fig_handle)
%%EDIT_DATA handles if the user wants to add or remove outliers from the
%%data.
%
% MIT License
% Copyright (c) <2023> <Jesper Løve Hinrich>
if nargin < 1
    ref_data=randn(10,1);
    sensor_data = randn(10,1);
end

if nargin < 3
    fig_handle = figure;
end



uit = uitable(fig_handle);
if length(ref_data)==length(sensor_data)
    uit.Data =[ref_data,sensor_data, ref_data-sensor_data];
    uit.ColumnName = {'Reference Data', 'Sensor Data', 'Difference'};
else
    uit.Data =[sensor_data];
    uit.ColumnName = {'Sensor Data'};
end
set(fig_handle,'CloseRequestFcn',@MyReturnData);

uit.ColumnEditable = true;

set(fig_handle,'Tag','editFig')
set(uit,'Tag','editTable')

set(uit,'Position',[10,10,uit.Parent.Position(3:4).*[0.7, 0.9] ])
figure(fig_handle)

newData =[];
txt_title = uicontrol('Style', 'text', 'Position', [10 uit.Parent.Position(4)*0.92 uit.Parent.Position(3)*0.8 30], 'String', 'Edit the current dataset by changing the value of the cells.');
txt_title.FontSize=14;
waitfor(fig_handle);
% end
% Return edited data
if length(ref_data)==length(sensor_data)
ref_data = newData(:,1);
sensor_data = newData(:,2);
else
    sensor_data = newData(:,1);
end

% end

function MyReturnData(~,~)
    myfigure=findobj('Tag','editFig');
    newData=get(findobj(myfigure,'Tag','editTable'),'Data');
%     ref_data = uit.Data(:,1);
%     sensor_data = uit.Data(:,2);
    delete(myfigure);
end

end
%% Highlight outliers
% 
% styleIndices = ismissing(tdata);
% [row,col] = find(styleIndices);
% 
% s = uistyle('BackgroundColor','yellow');
% addStyle(uit,s,'cell',[row,col]);