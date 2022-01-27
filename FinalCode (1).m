%% Load Data (Plot Voltage Output)

clear all; close all; clc


disp('Started')
app_data = demo_class;
app_data.app_running = true;

app_data.UI_figure = uifigure('Name','Raw Data From Stethoscope',...
    'CloseRequestFcn',{@app_close,app_data});

% Create a gridded layout
fig_grid = uigridlayout(app_data.UI_figure,[2,2]);
fig_grid.RowHeight = {'fit','1x'};
fig_grid.ColumnWidth = {'fit','1x'};

% Create a panel to hold graph axes
graph_panel = uipanel(fig_grid);
graph_panel.Layout.Row = [1 2]; % span rows 1 through 2
graph_panel.Layout.Column = 2;

% Create an axes to hold the graph
graph_ax = axes(graph_panel);

 
% Create a plot
time = linspace(0,1000,1000);
my_graph = plot(graph_ax,time,app_data.buffer);

% Create a ui button 
quit_btn = uibutton(fig_grid,'push','Text','Stop and Quit',...
    'ButtonPushedFcn', {@quit_func,app_data});
quit_btn.Layout.Row = 1; quit_btn.Layout.Column = 1;

% Pause for the figure to appear
pause(2)



div_count = 0;

a = arduino();
data_in = zeros(1,1000);

while app_data.app_running == true

    
   data5 = zeros(1,5);
    for i=1:5
        data = readVoltage(a,'A0');
        data5(i)= data;
    end
    
    data_in = [data_in(6: end) data5];
    app_data.buffer = data_in;

    if app_data.app_running == true
       my_graph.YData = data_in;
    end

    drawnow;
end

disp('End')


%% Load Data (Plot Frequency)

clear all; close all; clc

disp('Started')
app_data = demo_class;
app_data.app_running = true;

app_data.UI_figure = uifigure('Name','Frequency Output From Stethoscope',...
    'CloseRequestFcn',{@app_close,app_data});

% Create a gridded layout
fig_grid = uigridlayout(app_data.UI_figure,[2,2]);
fig_grid.RowHeight = {'fit','1x'};
fig_grid.ColumnWidth = {'fit','1x'};

% Create a panel to hold graph axes
graph_panel = uipanel(fig_grid);
graph_panel.Layout.Row = [1 2]; % span rows 1 through 2
graph_panel.Layout.Column = 2;

% Create an axes to hold the graph
graph_ax = axes(graph_panel);


% Create a plot
time = linspace(0,1000,1000);
my_graph = line(graph_ax,time,app_data.buffer);

% Create a ui button 
quit_btn = uibutton(fig_grid,'push','Text','Stop and Quit',...
    'ButtonPushedFcn', {@quit_func,app_data});
quit_btn.Layout.Row = 1; quit_btn.Layout.Column = 1;

RespRatetext = uilabel(fig_grid,'text',...
    ['Frequency: '],...
    'fontsize', 12,...
    'position', [80, 10, 100, 20]);
RespRatetext.Layout.Row = 2; RespRatetext.Layout.Column = 1;
drawnow;

% Pause for the figure to appear
pause(2)



div_count = 0;

a = arduino();
data_in = zeros(1,1000);
fs = 2000;


while app_data.app_running == true

    
   data5 = zeros(1,5);
    for i=1:5
        data = readVoltage(a,'A0');
        data5(i)= data;
    end
    
    data_in = [data_in(6: end) data5];
    [freq,t] = instfreq(data_in,fs);
    app_data.buffer = freq;
    RespRatetext.Text = ['Frequency: ', num2str(freq(30))];
    
    pause(0.001);
 
    if app_data.app_running == true
       my_graph.XData = t;
       my_graph.YData = freq;
    end

    drawnow;
end

disp('End')


%% Filter/Amplify Heart Signal and Plot in Real Time


clear all; close all; clc


disp('Started')
app_data = demo_class;
app_data.app_running = true;

app_data.UI_figure = uifigure('Name','Filtered Heart Signal',...
    'CloseRequestFcn',{@app_close,app_data});

% Create a gridded layout
fig_grid = uigridlayout(app_data.UI_figure,[2,2]);
fig_grid.RowHeight = {'fit','1x'};
fig_grid.ColumnWidth = {'fit','1x'};
% Create a panel to hold graph axes

graph_panel = uipanel(fig_grid);
graph_panel.Layout.Row = [1 3]; % span rows 1 through 2
graph_panel.Layout.Column = 2;

% Create an axes to hold the graph
graph_ax = axes(graph_panel);


% Create a plot
time = linspace(0,1000,1000);
my_graph = plot(graph_ax,time,app_data.buffer,'-k');


% Create a ui button 
quit_btn = uibutton(fig_grid,'push','Text','Stop and Quit',...
    'ButtonPushedFcn', {@quit_func,app_data});
quit_btn.Layout.Row = 1; quit_btn.Layout.Column = 1;

HeartRateText = uilabel(fig_grid,'text',...
    ['BPM: '],...
    'fontsize', 12,...
    'position', [80, 10, 100, 20]);
HeartRateText.Layout.Row = 2; HeartRateText.Layout.Column = 1;
drawnow;


% Pause for the figure to appear
pause(2)



div_count = 0;

a = arduino();

data_in = zeros(1,1000);

fs = 500;
fn = fs/2;
Wp = [20 150]/fn;
Ws = [10 175]/fn;
Rp = 0.5;
Rs = 40;

while app_data.app_running == true

    
   data5 = zeros(1,5);
   
    for i=1:5
        data = readVoltage(a,'A1');
        data5(i)= data;
    end
    
    data_in = [data_in(6: end) data5];

    [n,Wn] = buttord(Wp,Ws,Rp,Rs);
    [B,A] = butter(n,Wn,'bandpass');
    out1 = filtfilt(B,A,data_in);
    
    [X,Y] = butter(10,0.2);
    output = filtfilt(X,Y,out1)*1000;
    
    app_data.buffer = output;


    
    [Pks, Locs] = findpeaks(output,'MinPeakDistance',5,....
        'MinPeakHeight',5);
    numWave = numel(Locs);
    beat = 60*(((numWave*fs)/10)/length(output));
    HeartRateText.Text = ['BPM: ', num2str(beat)];
    
    pause(0.001);
 
    if app_data.app_running == true
       my_graph.YData = output;
    end

    drawnow;
end

disp('End')


%% Filter/Amplify Lungs Signal and Plot in Real Time

clear all; close all; clc

disp('Started')
app_data = demo_class;
app_data.app_running = true;

app_data.UI_figure = uifigure('Name','Filtered Lungs Signal',...
    'CloseRequestFcn',{@app_close,app_data});

% Create a gridded layout
fig_grid = uigridlayout(app_data.UI_figure,[2,2]);
fig_grid.RowHeight = {'fit','1x'};
fig_grid.ColumnWidth = {'fit','1x'};

% Create a panel to hold graph axes
graph_panel = uipanel(fig_grid);
graph_panel.Layout.Row = [1 3]; % span rows 1 through 2
graph_panel.Layout.Column = 2;

% Create an axes to hold the graph
graph_ax = axes(graph_panel);


% Create a plot
time = linspace(0,1000,1000);
my_graph = plot(graph_ax,time,app_data.buffer,'-k');

% Create a ui button 
quit_btn = uibutton(fig_grid,'push','Text','Stop and Quit',...
    'ButtonPushedFcn', {@quit_func,app_data});
quit_btn.Layout.Row = 1; quit_btn.Layout.Column = 1;

RespRatetext = uilabel(fig_grid,'text',...
    ['Respiratory Rate: '],...
    'fontsize', 12,...
    'position', [80, 10, 100, 20]);
RespRatetext.Layout.Row = 2; RespRatetext.Layout.Column = 1;
drawnow;

IEtext = uilabel(fig_grid,'text',...
    ['I:E Ratio: '],...
    'fontsize', 12,...
    'position', [80, 10, 100, 20]);
IEtext.Layout.Row = 3; IEtext.Layout.Column = 1;
drawnow;

% Pause for the figure to appear
pause(2)



div_count = 0;

a = arduino();
data_in = zeros(1,1000);


fs = 2110;
fn = fs/2;
Wp = [100 1000]/fn;
Ws = [50 1050]/fn;
Rp = 3;
Rs = 75;

while app_data.app_running == true

    
   data5 = zeros(1,5);
   
    for i=1:5
        data = readVoltage(a,'A1');
        data5(i)= data;
    end
    
    data_in = [data_in(6: end) data5];
    
    [n,Wp] = cheb1ord(Wp,Ws,Rp,Rs);
    [B,A] = cheby1(n,Rp,Wp,'bandpass');
    out1 = filtfilt(B,A,data_in);
    
    [X,Y] = butter(10,0.2);
    output = filtfilt(X,Y,out1)*1000;
    
    app_data.buffer = output;

    
    % FIX THIS CALCULATION
    [Pks, Locs] = findpeaks(output,'MinPeakDistance',5,....
        'MinPeakHeight',10);
    numWave = numel(Locs);
    respRate = (numWave*60)/100;
    RespRatetext.Text = ['Respiratory Rate: ', num2str(respRate)];
    
    
    % FIX THIS CALCULATION
    %IER =
    %IEtextText = ['I:E Ratio: ', num2str(IER)];
    
    
    pause(0.001);
 
    if app_data.app_running == true
       my_graph.YData = output;
    end

    drawnow;
end

disp('End')

%% Plot EKG of Heart Signal in Real Time

clear all; close all; clc

disp('Started')
app_data = demo_class;
app_data.app_running = true;

app_data.UI_figure = uifigure('Name','Filtered Electrocardiogram Signal',...
    'CloseRequestFcn',{@app_close,app_data});

% Create a gridded layout
fig_grid = uigridlayout(app_data.UI_figure,[2,2]);
fig_grid.RowHeight = {'fit','1x'};
fig_grid.ColumnWidth = {'fit','1x'};

% Create a panel to hold graph axes
graph_panel = uipanel(fig_grid);
graph_panel.Layout.Row = [1 3]; % span rows 1 through 2
graph_panel.Layout.Column = 2;

% Create an axes to hold the graph
graph_ax = axes(graph_panel);

% Create a plot
time = linspace(0,1000,1000);
my_graph = plot(graph_ax,time,app_data.buffer,'-k');
   
% Create a ui button 
quit_btn = uibutton(fig_grid,'push','Text','Stop and Quit',...
    'ButtonPushedFcn', {@quit_func,app_data});
quit_btn.Layout.Row = 1; quit_btn.Layout.Column = 1;

% Pause for the figure to appear
pause(2)

div_count = 0;
a = arduino();
data_in = zeros(1,1000);
fs = 600;

while app_data.app_running == true

   data5 = zeros(1,5);
   
    for i=1:5
        data = readVoltage(a,'A0');
        data5(i)= data;
    end
    
    data_in = [data_in(6: end) data5];
    
    % Scale the signal per the specifications of the ECG sensor
    ECG_adj = ((((data_in./((2.^10)-1))-0.0016) .* 3.3)) .* 1000;
    
    % Filter the scaled signal using a Savitzky-Golay filter
    ECG_Data = sgolayfilt(ECG_adj,7,21);
    
    app_data.buffer = ECG_Data;
    
    pause(0.001);
 
    if app_data.app_running == true
       my_graph.YData = ECG_Data;
    end

    drawnow;
end

disp('End')

%% EKG Plot (3 Seconds)

clear all; close all; clc;

div_count = 0;
a = arduino();
time_up = 5;
time_passed = 0;
start_time = tic;
times = [];
voltages = [];


while(time_passed<time_up)
    disp('Detecting');
    time_passed = toc(start_time);
    
    v = readVoltage(a,'A0');
    
    voltages = [voltages v];
    times = [times time_passed];
end

% Scale the signal per the specifications of the ECG sensor
ECG_adj = ((((voltages/((2.^10)-1))-0.0016) .* 3.3)) .* 1000;

% Filter the scaled signal using a Savitzky-Golay filter
ECG_Data = sgolayfilt(ECG_adj,7,21);


[R,TR1] = findpeaks(ECG_Data,times,'MinPeakHeight',0.5,...
    'MinPeakDistance', 0.5,'MaxPeakWidth',0.05,'MinPeakProminence',1);
[S,TR2] = findpeaks(-ECG_Data,times,'MinPeakHeight',-1.25,...
    'MinPeakDistance',0.5,'MaxPeakWidth',0.1,'MinPeakProminence',1);
[T,TR3] = findpeaks(ECG_Data,times,'MinPeakHeight',0.5,...
    'MinPeakDistance',0.5,'MinPeakWidth',0.1,'MinPeakProminence',0.5);
[Q,TR4] = findpeaks(-ECG_Data,times,'MinPeakHeight',-0.3,...
    'MinPeakDistance',0.5,'MinPeakWidth',0.1,'MinPeakProminence',0.5);
[P,TR5] = findpeaks(ECG_Data,times,'MinPeakHeight',0.01,... 
    'MinPeakDistance',0.5,'MaxPeakWidth',0.1,'MinPeakWidth',0.05);


plot(times,ECG_Data,'-k','DisplayName','EKG Signal');
xlabel('Time (s)')
ylabel('Voltage (mV)')
xlim([0 5]);
hold on;
plot(TR1,R,'.r','MarkerSize',20,'DisplayName','R Wave');
plot(TR2,-S,'.b','MarkerSize',20,'DisplayName','S Wave');
plot(TR3,T,'.c','MarkerSize',20,'DisplayName','T Wave');
plot(TR4,-Q,'.g','MarkerSize',20,'DisplayName','Q Wave');
plot(TR5,P,'.y','MarkerSize',20,'DisplayName','P Wave');
title('Electrocardiogram (EKG) Signal');
hold off;
legend

%% Plot Contour of Heart Signal








%% Plot Contour of Lungs Signal







%% Functions

function app_close(src,~,app_data)
app_data.app_running = false;
delete(src)
end 

function quit_func(~,~,app_data)
app_data.app_running = false;
delete(app_data.UI_figure)
end
