function varargout = MainForm(varargin)
% vers 4
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MainForm_OpeningFcn, ...
                   'gui_OutputFcn',  @MainForm_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
    
function MainForm_OpeningFcn(hObject, ~, handles, varargin)
    handles.output = hObject;

    try 
        handles.DefaultSettings = LoadDefaultSettings();
    catch exc
        errordlg('Не удаётся загрузить начальные настройки программы.', ...
            'Ошибка загрузки настройек');
        guidata(hObject, handles);
        delete(hObject);
        error('%s: %s',exc.identifier, exc.message);
    end

    handles.SignalData.WorkingFrequencyBand = handles.DefaultSettings.WorkingFrequencyBand;
    handles.SignalData.TransmissionFactor =  handles.DefaultSettings.TransmissionFactor;
    handles.SignalData.ModulPermissibleMaxDeviation = handles.DefaultSettings.ModulPermissibleMaxDeviation;
    handles.SignalData.ProjectionPermissibleMaxDeviation = handles.DefaultSettings.ProjectionPermissibleMaxDeviation;
    
    handles.UIConst.ProgrammStateValue.ReadyLabelProperties.Text = 'Готов к работе';
    handles.UIConst.ProgrammStateValue.ReadyLabelProperties.ForegroundColor = 'green';
    
    handles.UIConst.ProgrammStateValue.BusyLabelProperties.Text = 'Занят';
    handles.UIConst.ProgrammStateValue.BusyLabelProperties.ForegroundColor = [0.8500 0.3250 0.0980];
    
    handles.UIConst.ProgrammStateValue.ClosingLabelProperties.Text = 'Завершение работы';
    handles.UIConst.ProgrammStateValue.ClosingLabelProperties.ForegroundColor = 'red';

    handles.UIConst.RelativeDeviationStateValue.SuccessText = 'В допуске';
    handles.UIConst.RelativeDeviationStateValue.ErrorText = 'Вне допуска';
    handles.UIConst.RelativeDeviationStateValue.NAText = 'Не определяется';

    handles.UIConst.AccelerometerStateValue.SuccessText = 'Исправен';
    handles.UIConst.AccelerometerStateValue.ErrorText = 'Имеется неисправность';

    handles.UIConst.SuccessColor = 'green';
    handles.UIConst.ErrorColor = 'red';
    handles.UIConst.NAColor = 'black';

    handles.UIConst.DefaultLabelProperties.Text = char.empty;
    handles.UIConst.DefaultLabelProperties.ForegroundColor = 'black';

    SetLabelProperties(handles.ProgrammStateValue, handles.UIConst.ProgrammStateValue.ReadyLabelProperties);

    setappdata(handles.MainForm,'waiting',1)

    guidata(hObject, handles);

    uiwait(handles.MainForm);

function varargout = MainForm_OutputFcn(hObject, ~, handles) 
    if isfield(handles,'SignalStatistic')
        varargout{1} = handles.SignalStatistic;
    else
        varargout{1} = struct([]);
    end
    
	delete(hObject);


function OpenPreferencesDlg_ClickedCallback(hObject, ~, handles)
    current_preferences.WorkingFrequencyBand = handles.SignalData.WorkingFrequencyBand;
    current_preferences.TransmissionFactor = handles.SignalData.TransmissionFactor;
    current_preferences.ModulPermissibleMaxDeviation = handles.SignalData.ModulPermissibleMaxDeviation;
    current_preferences.ProjectionPermissibleMaxDeviation = handles.SignalData.ProjectionPermissibleMaxDeviation;
    
    new_preferences = PreferencesDialog('Owner', handles.MainForm, 'CurrentPreferences', current_preferences);
    if isequal(new_preferences,current_preferences)
        return;
    end
    
    set(hObject,'Enable','off');
    set(handles.OpenFile,'Enable','off');
    set(handles.StartMeasurement,'Enable','off');
    set(handles.SaveFile,'Enable','off');
    set(handles.StopMeasurement,'Enable','off');
    
    SetLabelProperties(handles.ProgrammStateValue, handles.UIConst.ProgrammStateValue.BusyLabelProperties);
    
    guidata(hObject, handles);
    
    ClearUI(hObject, struct([]), handles);

    drawnow
    
    handles = guidata(hObject);
    
    handles.SignalData.WorkingFrequencyBand = new_preferences.WorkingFrequencyBand;
    handles.SignalData.TransmissionFactor = new_preferences.TransmissionFactor;
    handles.SignalData.ModulPermissibleMaxDeviation = new_preferences.ModulPermissibleMaxDeviation;
    handles.SignalData.ProjectionPermissibleMaxDeviation = new_preferences.ProjectionPermissibleMaxDeviation;
    
    if isfield(handles.SignalData, 'Signal') && isfield(handles.SignalData.Signal, 'K') ...
            && ~isempty(handles.SignalData.Signal.K)
    
        event_data = struct([]);
        UpdateSignalStatistic(hObject, event_data, handles);
        handles = guidata(gcf);

        ShowSignalStatistic(hObject, event_data, handles);

        set(handles.NewOriginalSignalPlot,'Enable','on');
        set(handles.NewSpectrumSignalPlot,'Enable','on');
        % из меню настроек
        set(handles.NewAccelerationVectorPlot,'Enable','on');
        set(handles.NewAccelerationModulPlot,'Enable','on');
        set(handles.NewPhaseSignalPlot,'Enable','on ');
        
        set(handles.SaveFile,'Enable','on');
    end
  
    SetLabelProperties(handles.ProgrammStateValue, handles.UIConst.ProgrammStateValue.ReadyLabelProperties);
    
    set(hObject,'Enable','on');
    set(handles.OpenFile,'Enable','on');
    set(handles.StartMeasurement,'Enable','on');
    
    guidata(hObject, handles);

function MainForm_CloseRequestFcn(hObject, ~, handles)
    SetLabelProperties(handles.ProgrammStateValue, handles.UIConst.ProgrammStateValue.ClosingLabelProperties);
    drawnow
    
    if getappdata(handles.MainForm,'waiting')
        uiresume(hObject);
        setappdata(handles.MainForm,'waiting',0);
    else
        StopMeasurement_ClickedCallback(hObject,struct([]),handles);
        delete(hObject);
    end

function StartMeasurement_ClickedCallback(hObject, ~, handles)
    set(handles.OpenFile,'Enable','off');
    set(hObject,'Enable','off');
    set(handles.OpenPreferencesDlg,'Enable','off');
    set(handles.StopMeasurement,'Enable','on');
    
    SetLabelProperties(handles.ProgrammStateValue, handles.UIConst.ProgrammStateValue.BusyLabelProperties);
    
    ClearUI(hObject, struct([]), handles);
    ClearData(hObject, struct([]), handles);

    drawnow
    
    handles = guidata(hObject);
    
    try
        handles.DeviceSessionData.Session = CreateSession(handles.DefaultSettings.Device, true);
    catch exc
        errordlg('Не удаётся подключиться к АЦП./n Обратитесь к системному администратору','Ошибка подключения к АЦП');

        SetLabelProperties(handles.ProgrammStateValue, handles.UIConst.ProgrammStateValue.ReadyLabelProperties);
        
        set(handles.StopMeasurement,'Enable','off ');
        set(handles.OpenPreferencesDlg,'Enable','on');
        set(handles.OpenFile,'Enable','on');
        set(hObject,'Enable','on');
       
        guidata(hObject, handles);
        error('%s: %s',exc.identifier, exc.message);
    end

    handles.SignalData.SamplingFrequency = handles.DeviceSessionData.Session.Rate;

    handles.DeviceSessionData.Listener = addlistener(handles.DeviceSessionData.Session, ...
        'DataAvailable', @DataAvailableCallback); 
    
    try
       handles.DeviceSessionData.Session.startBackground();
    catch exc
        errordlg('Не удаётся запустить чтение данных при помощи АЦП. /n Обратитесь к системному администратору', ...
                 'Ошибка запуска АЦП');
        
        delete(handles.DeviceSessionData.Listener);
        delete(handles.DeviceSessionData.Session);
        handles = rmfield(handles,'DeviceSessionData');
        
        SetLabelProperties(handles.ProgrammStateValue, handles.UIConst.ProgrammStateValue.ReadyLabelProperties);
        
        set(handles.StopMeasurement,'Enable','off ');
        set(handles.OpenPreferencesDlg,'Enable','on');
        set(handles.OpenFile,'Enable','on');
        set(hObject,'Enable','on');
        
        guidata(hObject, handles);
        
        error('%s: %s',exc.identifier, exc.message);
    end
    
    guidata(hObject, handles);

function StopMeasurement_ClickedCallback(hObject, ~, handles)
    if isfield(handles,'DeviceSessionData')
        handles.DeviceSessionData.Session.stop();
        
        delete(handles.DeviceSessionData.Listener);
        delete(handles.DeviceSessionData.Session);
        
        handles = rmfield(handles,'DeviceSessionData');
    end
    
    if isfield(handles,'SignalData') && isfield(handles.SignalData, 'Signal') && ...
        isfield(handles.SignalData.Signal, 'K') && ~isempty(handles.SignalData.Signal.K)
            set(handles.SaveFile,'Enable','on');
    end
    
    if isfield(handles,'SignalStatistic') && ~isempty(handles.SignalStatistic)
        set(handles.NewOriginalSignalPlot,'Enable','on');
        set(handles.NewSpectrumSignalPlot,'Enable','on');
        % при остановке
        set(handles.NewAccelerationVectorPlot,'Enable','on');
        set(handles.NewAccelerationModulPlot,'Enable','on');
        set(handles.NewPhaseSignalPlot,'Enable','on ');
    end
    
    SetLabelProperties(handles.ProgrammStateValue, handles.UIConst.ProgrammStateValue.ReadyLabelProperties);
    
    set(hObject,'Enable','off');
    set(handles.OpenPreferencesDlg,'Enable','on');
    set(handles.OpenFile,'Enable','on');
    set(handles.StartMeasurement,'Enable','on');
    
    guidata(hObject, handles);
   
function DataAvailableCallback(~,eventdata)
    new_data_column_length = numel(eventdata.TimeStamps);
    
    handles = guidata(gcf);

%   % Раскомментировать при обработке даных фрагментами (без накопления)
%     ClearData(gcf, struct([]), handles);
%     handles = guidata(gcf);

     
    new_data_start_idx = numel(handles.SignalData.Signal.Time) + 1;
    new_data_end_idx = new_data_start_idx + new_data_column_length - 1;
     
    handles.SignalData.Signal.Time(new_data_start_idx:new_data_end_idx) = eventdata.TimeStamps;
    
%% Программная генерация сигналов
%      
%     x_amplitude_offset = 0;
%     y_amplitude_offset = 0;
%     z_amplitude_offset = 0;
%     k_amplitude_offset = 0;
%     
% %     % Амплитуды сигналов при исправных каналах  
% %     x_amplitude_value = 0.01125;
% %     y_amplitude_value = -0.0154;
% %     z_amplitude_value = 0.021303;
% %     k_amplitude_value = 0.01436018507;
% %     
% %     %  Амплитуды сигналов при неисправном канале X 
% %     x_amplitude_value = 0.009;
% %     y_amplitude_value = -0.0154;
% %     z_amplitude_value = 0.021303;
% %     k_amplitude_value = 0.01436018507;
% %     
% %     %  Амплитуды сигналов при неисправном канале Y 
% %     x_amplitude_value = 0.01125;
% %     y_amplitude_value = -0.01204;
% %     z_amplitude_value = 0.021303;
% %     k_amplitude_value = 0.01436018507;
% %     
% %     %  Амплитуды сигналов при неисправном канале Z
% %     x_amplitude_value = 0.01125;
% %     y_amplitude_value = -0.0154;
% %     z_amplitude_value = 0.017253;
% %     k_amplitude_value = 0.01436018507;
% %     
%     %  Амплитуды сигналов при неисправном канале K
% %     x_amplitude_value = 0.01125;
% %     y_amplitude_value = -0.0154;
% %     z_amplitude_value = 0.021303;
% %     k_amplitude_value = 0.01188429109241379;
%     
%     x_amplitude_value = -0.0149678;
%     y_amplitude_value = -0.0164646;
%     z_amplitude_value = 0.0222684;
%     k_amplitude_value = 0.0335421;
% 
%     signal_frequency = 40;
%     
%     signal_frequency = 2*pi*signal_frequency;
%     
%     x_phase_offset = 0;
%     y_phase_offset = 0;
%     z_phase_offset = 0;
%     k_phase_offset = 0;
%     
%     handles.SignalData.Signal.X(new_data_start_idx:new_data_end_idx) = x_amplitude_offset + x_amplitude_value * sin(signal_frequency*handles.SignalData.Signal.Time(new_data_start_idx:new_data_end_idx) + x_phase_offset);
%     handles.SignalData.Signal.Y(new_data_start_idx:new_data_end_idx) = y_amplitude_offset + y_amplitude_value * sin(signal_frequency*handles.SignalData.Signal.Time(new_data_start_idx:new_data_end_idx) + y_phase_offset);
%     handles.SignalData.Signal.Z(new_data_start_idx:new_data_end_idx) = z_amplitude_offset + z_amplitude_value * sin(signal_frequency*handles.SignalData.Signal.Time(new_data_start_idx:new_data_end_idx) + z_phase_offset);
%     handles.SignalData.Signal.K(new_data_start_idx:new_data_end_idx) = k_amplitude_offset + k_amplitude_value * sin(signal_frequency*handles.SignalData.Signal.Time(new_data_start_idx:new_data_end_idx) + k_phase_offset);
    
%%    
    handles.SignalData.Signal.X(new_data_start_idx:new_data_end_idx) = eventdata.Data(:,1)';
    handles.SignalData.Signal.Y(new_data_start_idx:new_data_end_idx) = eventdata.Data(:,2)';
    handles.SignalData.Signal.Z(new_data_start_idx:new_data_end_idx) = eventdata.Data(:,3)';
    handles.SignalData.Signal.K(new_data_start_idx:new_data_end_idx) = eventdata.Data(:,4)';
    
    event_data = struct([]);
    UpdateSignalStatistic(gcf, event_data, handles);
    handles = guidata(gcf);
    
    ShowSignalStatistic(gcf, event_data, handles);
    
function UpdateSignalStatistic(hObject, ~, handles)
    handles.SignalStatistic = SignalStatistic(handles.SignalData);
    
    guidata(hObject, handles);
   
function ShowSignalStatistic(hObject, ~, handles)
    event_data = struct([]);
    PlotSignals(handles.OriginalSignalPlot,event_data,handles);
    PlotSpectrums(handles.SpectrumSignalPlot,event_data,handles);
    PlotPhases(handles.PhaseSignalPlot,event_data,handles);
    PlotAccelerationModules(handles.AccelerationModulPlot,event_data,handles);
    % вывод в окно 
    PlotAccelerationVector(handles.AccelerationVectorPlot,event_data,handles);
    
    event_data = struct('IsDeviationPermissible', handles.SignalStatistic.AccelerationVector.Actual.IsDeviationPermissible);
    SetIsModRDPermissibleValue(handles.IsActualModRDPermissibleValue, event_data, handles);
    
    event_data.IsDeviationPermissible = handles.SignalStatistic.AccelerationVector.XProjection.IsDeviationPermissible;
    SetIsModRDPermissibleValue(handles.IsXProjectionModRDPermissibleValue, event_data, handles);
    
    event_data.IsDeviationPermissible = handles.SignalStatistic.AccelerationVector.YProjection.IsDeviationPermissible;
    SetIsModRDPermissibleValue(handles.IsYProjectionModRDPermissibleValue, event_data, handles);
    
    event_data.IsDeviationPermissible = handles.SignalStatistic.AccelerationVector.ZProjection.IsDeviationPermissible;
    SetIsModRDPermissibleValue(handles.IsZProjectionModRDPermissibleValue, event_data, handles);
    
    event_data = struct('IsSignificance', handles.SignalStatistic.X.Acceleration.IsRMSSignificance, ...
        'IsDeviationPermissible', handles.SignalStatistic.X.Acceleration.IsDeviationPermissible);
    SetIsP_RDPermissibleValue(handles.IsXP_RDPermissibleValue, event_data, handles);
    
    event_data.IsSignificance = handles.SignalStatistic.Y.Acceleration.IsRMSSignificance;
    event_data.IsDeviationPermissible = handles.SignalStatistic.Y.Acceleration.IsDeviationPermissible;
    SetIsP_RDPermissibleValue(handles.IsYP_RDPermissibleValue, event_data, handles);
    
    event_data.IsSignificance = handles.SignalStatistic.Z.Acceleration.IsRMSSignificance;
    event_data.IsDeviationPermissible = handles.SignalStatistic.Z.Acceleration.IsDeviationPermissible;
    SetIsP_RDPermissibleValue(handles.IsZP_RDPermissibleValue, event_data, handles);
    
    event_data.IsSignificance = handles.SignalStatistic.K.Acceleration.IsRMSSignificance;
    event_data.IsDeviationPermissible = handles.SignalStatistic.K.Acceleration.IsDeviationPermissible;
    SetIsP_RDPermissibleValue(handles.IsKP_RDPermissibleValue, event_data, handles);
    
    event_data = struct('IsAccelerometerEfficient', handles.SignalStatistic.IsAccelerometerEfficient);
    SetIsAccelerometerEfficientValue(handles.IsAccelerometerEfficientValue, event_data, handles);  
    
    guidata(hObject, handles);
    % построение исходного сигнала 
 function PlotSignals(hObject, ~, handles)
   plotting_data.Time = decimate(handles.SignalStatistic.Time, handles.SignalData.Decimator);
    plotting_data.X = decimate(handles.SignalStatistic.X.RawSignal, handles.SignalData.Decimator);
    plotting_data.Y = decimate(handles.SignalStatistic.Y.RawSignal, handles.SignalData.Decimator);
    plotting_data.Z = decimate(handles.SignalStatistic.Z.RawSignal, handles.SignalData.Decimator);
    plotting_data.K = decimate(handles.SignalStatistic.K.RawSignal, handles.SignalData.Decimator);
      
    if ~isempty(hObject)
        plot(hObject, plotting_data.Time, plotting_data.X, ...
            plotting_data.Time, plotting_data.Y, plotting_data.Time, plotting_data.Z, ...
            plotting_data.Time, plotting_data.K);

        set(hObject,'xgrid','on');
        set(hObject,'ygrid','on');
        set(hObject,'zgrid','on');

        legend(hObject, 'Канал X','Канал Y','Канал Z', 'Канал K', ...
            'Location','NorthOutside', 'Orientation', 'Horizontal');   

        xlabel(hObject ,'T, c');
        ylabel(hObject,'A, В');
    else
        plot(plotting_data.Time, plotting_data.X, ...
            plotting_data.Time, plotting_data.Y, ...
            plotting_data.Time, plotting_data.Z, ...
            plotting_data.Time, plotting_data.K);

        grid on;

        legend('Канал X','Канал Y','Канал Z', 'Канал K', ...
            'Location','NorthOutside', 'Orientation', 'Horizontal');   

        xlabel('T, c');
        ylabel('A, В');
    end
    % построение спектра сигнала
function PlotSpectrums(hObject, ~, handles) 
    if ~isempty(hObject)
         plot(hObject, ...
            handles.SignalStatistic.Frequency, handles.SignalStatistic.X.Spectrum, ...
            handles.SignalStatistic.Frequency, handles.SignalStatistic.Y.Spectrum, ...
            handles.SignalStatistic.Frequency, handles.SignalStatistic.Z.Spectrum, ...
            handles.SignalStatistic.Frequency, handles.SignalStatistic.K.Spectrum);

        set(hObject,'xgrid','on');
        set(hObject,'ygrid','on');
        set(hObject,'zgrid','on');

        legend(hObject,'Канал X','Канал Y','Канал Z', 'Канал K',...
            'Location','NorthOutside', 'Orientation', 'Horizontal'); 

        xlabel(hObject,'f, Гц');
        ylabel(hObject,'a, м/c^2');
    else
        plot(handles.SignalStatistic.Frequency, handles.SignalStatistic.X.Spectrum, ...
             handles.SignalStatistic.Frequency, handles.SignalStatistic.Y.Spectrum, ...
             handles.SignalStatistic.Frequency, handles.SignalStatistic.Z.Spectrum, ...
             handles.SignalStatistic.Frequency, handles.SignalStatistic.K.Spectrum);

        grid on;

        legend('Канал X','Канал Y','Канал Z', 'Канал K',...
            'Location','NorthOutside', 'Orientation', 'Horizontal'); 

        xlabel('f, Гц');
        ylabel('a, м/c^2');
    end
    % построение фазы сигнала
function PlotPhases(hObject, ~, handles)
    if ~isempty(hObject)
        plot(hObject, ...
            handles.SignalStatistic.Frequency, handles.SignalStatistic.X.Phase, ...
            handles.SignalStatistic.Frequency, handles.SignalStatistic.Y.Phase, ...
            handles.SignalStatistic.Frequency, handles.SignalStatistic.Z.Phase, ...
            handles.SignalStatistic.Frequency, handles.SignalStatistic.K.Phase);

        set(hObject,'xgrid','on');
        set(hObject,'ygrid','on');
        set(hObject,'zgrid','on');

        legend(hObject,'Канал X','Канал Y','Канал Z', 'Канал K',...
            'Location','NorthOutside', 'Orientation', 'Horizontal');

        xlabel(hObject,'f, Гц');
        ylabel(hObject,'Ф, град');
    else
        plot(handles.SignalStatistic.Frequency, handles.SignalStatistic.X.Phase, ...
            handles.SignalStatistic.Frequency, handles.SignalStatistic.Y.Phase, ...
            handles.SignalStatistic.Frequency, handles.SignalStatistic.Z.Phase, ...
            handles.SignalStatistic.Frequency, handles.SignalStatistic.K.Phase);

        grid on;

        legend('Канал X','Канал Y','Канал Z', 'Канал K',...
            'Location','NorthOutside', 'Orientation', 'Horizontal'); 

        xlabel('f, Гц');
        ylabel('Ф, град');
    end
   
   % построение модуля вектора вибрации
function PlotAccelerationModules(hObject, ~, handles)
    if ~isempty(hObject)
         plot(hObject, ...
            handles.SignalStatistic.Frequency, handles.SignalStatistic.AccelerationVector.Actual.Modul, ...
            handles.SignalStatistic.Frequency, handles.SignalStatistic.AccelerationVector.XProjection.Modul, ...
            handles.SignalStatistic.Frequency, handles.SignalStatistic.AccelerationVector.YProjection.Modul, ...
            handles.SignalStatistic.Frequency, handles.SignalStatistic.AccelerationVector.ZProjection.Modul);

        set(hObject,'xgrid','on');
        set(hObject,'ygrid','on');
        set(hObject,'zgrid','on');

        legend(hObject,'Действительное значение', ...
            'Значение с проекцией на ось X','Значение с проекцией на ось Y', ...
            'Значение с проекцией на ось Z', 'Location','NorthOutside');     

        xlabel(hObject,'f, Гц');
        ylabel(hObject,'a, м/c^2');
    else
        plot(handles.SignalStatistic.Frequency, handles.SignalStatistic.AccelerationVector.Actual.Modul, ...
            handles.SignalStatistic.Frequency, handles.SignalStatistic.AccelerationVector.XProjection.Modul, ...
            handles.SignalStatistic.Frequency, handles.SignalStatistic.AccelerationVector.YProjection.Modul, ...
            handles.SignalStatistic.Frequency, handles.SignalStatistic.AccelerationVector.ZProjection.Modul);
        
        grid on;
        
        legend('Действительное значение', 'Значение с проекцией на ось X', ...
            'Значение с проекцией на ось Y', 'Значение с проекцией на ось Z', ...
            'Location','NorthOutside');     

        xlabel('f, Гц');
        ylabel('a, м/c^2');
    end
    % построение вектора вибрации
function PlotAccelerationVector(hObject, ~, handles)
    start_vector = handles.SignalStatistic.AccelerationVector.Position.Start;
    end_vector = handles.SignalStatistic.AccelerationVector.Position.End;
    
    min_abs_start_projection = min(abs([start_vector.X start_vector.Y start_vector.Z]));
    max_abs_end_projection = max(abs([end_vector.X end_vector.Y end_vector.Z]));
    
    x_axis = VectorAxis(start_vector.X, end_vector.X, min_abs_start_projection,... 
                max_abs_end_projection);
    y_axis = VectorAxis(start_vector.Y, end_vector.Y, min_abs_start_projection,... 
                max_abs_end_projection);
    z_axis = VectorAxis(start_vector.Z, end_vector.Z, min_abs_start_projection,... 
                max_abs_end_projection);
   
    empty_projection = zeros(1,2);
    if ~isempty(hObject)
        plot3(hObject, ...
            start_vector.X, start_vector.Y, start_vector.Z, 'or', ...
            [x_axis.Start x_axis.End], empty_projection, empty_projection, '-red', ...
            empty_projection, [y_axis.Start y_axis.End], empty_projection, '-yellow', ...
            empty_projection, empty_projection, [z_axis.Start z_axis.End], '-g', ...
            [start_vector.X end_vector.X], [start_vector.Y end_vector.Y], ...
            [start_vector.Z end_vector.Z],'-black');
        
           % вывод начала и конца значения
             disp('x');
             disp(x_axis);
             disp('y');                         
             disp(y_axis);
             disp('z');
             disp(z_axis);
             
        set(hObject,'xgrid','on');
        set(hObject,'ygrid','on');
        set(hObject,'zgrid','on');

        xlabel(hObject,'X, м/c^2','color','red');
        ylabel(hObject,'Y, м/c^2','color','yellow');
        zlabel(hObject,'Z, м/c^2','color','green');

        axis(hObject,[x_axis.Start x_axis.End y_axis.Start y_axis.End ...
           z_axis.Start z_axis.End]);
       % начало и конец вектора
       % start_x_str = [start_vector.X; end_vector.X];
       % перевод в строку для вывода 
       % string_x = num2str(start_x_str); str_start_x = num2str(start_vector.X); str_end_x = num2str (end_vector.X);
       %   ось
       % t = 'X: ';
       % объединение строк 
       % test_str = strcat (t, str_start_x,  t, str_end_x);
 %             set (handles.list_xyz, 'String', test_str);
               % значение помещаем в list_xyz 
       start_end_x=[start_vector.X; end_vector.X; start_vector.Y; end_vector.Y; start_vector.Z; end_vector.Z]';
         set (handles.list_xyz, 'String', num2str(start_end_x));
         plus = 'Положительная'; 
         minus = 'Отрицательная';
         if start_vector.X < end_vector.X
             set (handles.X_more_zero, 'String', plus );
         else 
             set (handles.X_more_zero, 'String', minus );
         end
           if start_vector.Y < end_vector.Y
             set (handles.Y_more_zero, 'String', plus);
         else 
             set (handles.Y_more_zero, 'String', minus );
           end
         if start_vector.Z < end_vector.Z
             set (handles.Z_more_zero, 'String', plus );
         else 
             set (handles.Z_more_zero, 'String', minus );
         end
 
        
    else
        plot3(start_vector.X, start_vector.Y, start_vector.Z, 'or', ...
            [x_axis.Start x_axis.End], empty_projection, empty_projection, '-g', ...
            empty_projection, [y_axis.Start y_axis.End], empty_projection, '-g', ...
            empty_projection, empty_projection, [z_axis.Start z_axis.End], '-g', ...
            [start_vector.X end_vector.X], [start_vector.Y end_vector.Y], [start_vector.Z end_vector.Z],'-b');
             
         
        grid on;

        xlabel('X, м/c^2','color','r');
        ylabel('Y, м/c^2','color','r');
        zlabel('Z, м/c^2','color','r');

        axis([x_axis.Start x_axis.End y_axis.Start y_axis.End z_axis.Start z_axis.End]);
    end
    
function SetIsModRDPermissibleValue(hObject, eventdata, handles)
    event_data.IsSuccess = eventdata.IsDeviationPermissible;
         
    event_data.SuccessLabelProperties.Text = handles.UIConst.RelativeDeviationStateValue.SuccessText;
    event_data.SuccessLabelProperties.ForegroundColor = handles.UIConst.SuccessColor;
         
    event_data.ErrorLabelProperties.Text = handles.UIConst.RelativeDeviationStateValue.ErrorText;
    event_data.ErrorLabelProperties.ForegroundColor = handles.UIConst.ErrorColor;
         
    SetLabelPropertiesIfSuccess(hObject, event_data);
         
function SetIsAccelerometerEfficientValue(hObject, eventdata, handles)
    event_data.IsSuccess = eventdata.IsAccelerometerEfficient;
         
    event_data.SuccessLabelProperties.Text = handles.UIConst.AccelerometerStateValue.SuccessText;
    event_data.SuccessLabelProperties.ForegroundColor = handles.UIConst.SuccessColor;
         
    event_data.ErrorLabelProperties.Text = handles.UIConst.AccelerometerStateValue.ErrorText;
    event_data.ErrorLabelProperties.ForegroundColor = handles.UIConst.ErrorColor;
         
    SetLabelPropertiesIfSuccess(hObject, event_data);
        
function SetLabelPropertiesIfSuccess(hObject, eventdata)
    if (eventdata.IsSuccess)
        SetLabelProperties(hObject, eventdata.SuccessLabelProperties)
    else
        SetLabelProperties(hObject, eventdata.ErrorLabelProperties)
    end

function SetIsP_RDPermissibleValue(hObject, eventdata, handles)
    if (eventdata.IsSignificance)
        event_data.Text = handles.UIConst.RelativeDeviationStateValue.NAText;
        event_data.ForegroundColor = handles.UIConst.NAColor;
    else
        if (eventdata.IsDeviationPermissible)
            event_data.Text = handles.UIConst.RelativeDeviationStateValue.SuccessText;
            event_data.ForegroundColor = handles.UIConst.SuccessColor;
        else
            event_data.Text = handles.UIConst.RelativeDeviationStateValue.ErrorText;
            event_data.ForegroundColor = handles.UIConst.ErrorColor;
        end
    end
         
    SetLabelProperties(hObject, event_data);

function SetLabelProperties(hObject, labelProperties)
    if isfield(labelProperties, 'Text')
        set(hObject, 'String', labelProperties.Text);
    end
    
    if isfield(labelProperties, 'ForegroundColor')
        set(hObject,'ForegroundColor', labelProperties.ForegroundColor);
    end

function ClearData(hObject, ~, handles)
    handles.SignalData.Signal.Time = [];
    handles.SignalData.Signal.X = [];
    handles.SignalData.Signal.Y = [];
    handles.SignalData.Signal.Z = [];
    handles.SignalData.Signal.K = [];
    
    handles.SignalData.SamplingFrequency = handles.DefaultSettings.Device.SamplingFrequency;
    handles.SignalData.Filter = handles.DefaultSettings.Filter;
    handles.SignalData.AxisAngle = handles.DefaultSettings.AxisAngle;
    handles.SignalData.Decimator = handles.DefaultSettings.Decimator;
    handles.SignalData.FrequencyDelta = handles.DefaultSettings.FrequencyDelta;
    handles.SignalData.SignificanceThreshold = handles.DefaultSettings.SignificanceThreshold;
    
    handles.SignalStatistic = struct([]);
    
    guidata(hObject, handles);
     
 function ClearUI(hObject, ~, handles)
    set(handles.SaveFile,'Enable','off ');
    
    set(handles.NewOriginalSignalPlot,'Enable','off ');
    cla(handles.OriginalSignalPlot,'reset')
    %очистка 
    set(handles.NewAccelerationVectorPlot,'Enable','off ');
    cla(handles.AccelerationVectorPlot,'reset')
    
    SetLabelProperties(handles.IsActualModRDPermissibleValue, handles.UIConst.DefaultLabelProperties);
    SetLabelProperties(handles.IsXProjectionModRDPermissibleValue, handles.UIConst.DefaultLabelProperties);
    SetLabelProperties(handles.IsYProjectionModRDPermissibleValue, handles.UIConst.DefaultLabelProperties);
    SetLabelProperties(handles.IsZProjectionModRDPermissibleValue, handles.UIConst.DefaultLabelProperties);
    
    SetLabelProperties(handles.IsXP_RDPermissibleValue, handles.UIConst.DefaultLabelProperties);
    SetLabelProperties(handles.IsYP_RDPermissibleValue, handles.UIConst.DefaultLabelProperties);
    SetLabelProperties(handles.IsZP_RDPermissibleValue, handles.UIConst.DefaultLabelProperties);
    SetLabelProperties(handles.IsKP_RDPermissibleValue, handles.UIConst.DefaultLabelProperties);
    
    SetLabelProperties(handles.IsAccelerometerEfficientValue, handles.UIConst.DefaultLabelProperties);
    
    set(handles.NewSpectrumSignalPlot,'Enable','off ');
    cla(handles.SpectrumSignalPlot,'reset')
    
    set(handles.NewPhaseSignalPlot,'Enable','off ');
    cla(handles.PhaseSignalPlot,'reset')
     
    set(handles.NewAccelerationModulPlot,'Enable','off ');
    cla(handles.AccelerationModulPlot,'reset')
    
    guidata(hObject, handles);
    
function VectorAxis = VectorAxis(vectorStart,vectorEnd,minAbsStartProjection,maxAbsEndProjection)
    start_sign = sign(vectorStart);
    end_sign = sign(vectorEnd);
    
    sign_summ = start_sign + end_sign;

    % Если vectorStart и vectorEnd имеют одинаковые знаки или только 
    % один из них имеет значение ноль   
    if sign_summ ~= 0
        % Если vectorStart или vectorEnd - положительное число
        if sign_summ > 0
            VectorAxis.Start = minAbsStartProjection;
            VectorAxis.End = maxAbsEndProjection;
        else
            % Если vectorStart или vectorEnd - отрицательное число
            VectorAxis.Start = -maxAbsEndProjection;
            VectorAxis.End = -minAbsStartProjection;
        end
    elseif start_sign == 0
           % Если vectorStart и vectorEnd имеют значение ноль
            VectorAxis.Start = -eps;
            VectorAxis.End = eps;
        else
           % Если vectorStart и vectorEnd имеют разные знаки 
           VectorAxis.Start = -maxAbsEndProjection;
           VectorAxis.End = maxAbsEndProjection;
    end

function NewOriginalSignalPlot_Callback(~, ~, handles)
    figure('Name', 'Исходный сигнал','NumberTitle','off');
    PlotSignals(matlab.graphics.axis.Axes.empty, struct([]), handles);

function NewSpectrumSignalPlot_Callback(~, ~, handles)
    figure('Name', 'Спектр сигнала','NumberTitle','off');
    PlotSpectrums(matlab.graphics.axis.Axes.empty, struct([]), handles);
% не важно
function NewAccelerationVectorPlot_Callback(~, ~, handles)
    figure('Name', 'Вектор вибрации','NumberTitle','off');
    PlotAccelerationVector(matlab.graphics.axis.Axes.empty, struct([]), handles);
function NewAccelerationModulPlot_Callback(~, ~, handles)
    figure('Name', 'Модуль вектора вибрации','NumberTitle','off');
    PlotAccelerationModules(matlab.graphics.axis.Axes.empty, struct([]), handles);

function NewPhaseSignalPlot_Callback(~, ~, handles)
    figure('Name', 'Фаза сигнала','NumberTitle','off');
    PlotPhases(matlab.graphics.axis.Axes.empty, struct([]), handles);
    
function SaveFile_ClickedCallback(hObject, ~, handles)
    [file_name, folder_name] = uiputfile('*.xlsx','Сохранить');
    if file_name==0
        return;
    end
    
    set(hObject,'Enable','off');
    set(handles.StartMeasurement,'Enable','off');
    set(handles.OpenFile,'Enable','off');
    set(handles.OpenPreferencesDlg,'Enable','off');
    set(handles.StopMeasurement,'Enable','off');
    
    SetLabelProperties(handles.ProgrammStateValue, handles.UIConst.ProgrammStateValue.BusyLabelProperties);
    
    guidata(hObject, handles);
    
    drawnow
    
    file_path = [folder_name file_name];
    data_file = SignalDataFile(file_path);
    
    try
        data_file.WriteData(handles.SignalData);
    catch exc
        errordlg('Не удаётся сохранить данные сигнала.','Ошибка записи даных');
        
        delete(data_file);
        
        SetLabelProperties(handles.ProgrammStateValue, handles.UIConst.ProgrammStateValue.ReadyLabelProperties);
        
        set(handles.OpenPreferencesDlg,'Enable','on');
        set(hObject,'Enable','on');
        set(handles.OpenFile,'Enable','on');
        set(handles.StartMeasurement,'Enable','on');
        
        guidata(hObject, handles);
        
        error('%s: %s',exc.identifier, exc.message);
    end
     
    delete(data_file);
    
    SetLabelProperties(handles.ProgrammStateValue, handles.UIConst.ProgrammStateValue.ReadyLabelProperties);
        
    set(handles.OpenPreferencesDlg,'Enable','on');
    set(hObject,'Enable','on');
    set(handles.OpenFile,'Enable','on');
    set(handles.StartMeasurement,'Enable','on');
    
    guidata(hObject, handles);
    
function OpenFile_ClickedCallback(hObject, ~, handles)
    [file_name, folder_name] = uigetfile('*.xlsx','Открыть');
    if file_name==0
        return;
    end
    
    set(hObject,'Enable','off');
    set(handles.StartMeasurement,'Enable','off');
    set(handles.SaveFile,'Enable','off');
    set(handles.OpenPreferencesDlg,'Enable','off');
    set(handles.StopMeasurement,'Enable','off');
    
    SetLabelProperties(handles.ProgrammStateValue, handles.UIConst.ProgrammStateValue.BusyLabelProperties);
    
    guidata(hObject, handles);
    
    ClearUI(hObject, struct([]), handles);
    ClearData(hObject, struct([]), handles);

    drawnow
    
    handles = guidata(hObject);
    
    file_path = [folder_name file_name];
    data_file = SignalDataFile(file_path);
    
    try
        handles.SignalData = data_file.ReadData();
    catch exc
        errordlg('Не удаётся загрузить данные сигнала.','Ошибка загрузки даных');
        
        delete(data_file);
        
        SetLabelProperties(handles.ProgrammStateValue, handles.UIConst.ProgrammStateValue.ReadyLabelProperties);
        
        set(handles.OpenPreferencesDlg,'Enable','on');
        set(hObject,'Enable','on');
        set(handles.StartMeasurement,'Enable','on');
        
        guidata(hObject, handles);
        
        error('%s: %s',exc.identifier, exc.message);
    end
    
    delete(data_file);
    
    event_data = struct([]);
    UpdateSignalStatistic(gcf, event_data, handles);
    handles = guidata(gcf);
    
    ShowSignalStatistic(gcf, event_data, handles);
    
    set(handles.NewOriginalSignalPlot,'Enable','on');
    set(handles.NewSpectrumSignalPlot,'Enable','on');
    % из файла
    set(handles.NewAccelerationVectorPlot,'Enable','on');
    set(handles.NewAccelerationModulPlot,'Enable','on');
    set(handles.NewPhaseSignalPlot,'Enable','on ');
    
    SetLabelProperties(handles.ProgrammStateValue, handles.UIConst.ProgrammStateValue.ReadyLabelProperties);
    
    set(handles.OpenPreferencesDlg,'Enable','on');
    set(handles.SaveFile,'Enable','on');
    set(hObject,'Enable','on');
    set(handles.StartMeasurement,'Enable','on');
    
    guidata(hObject, handles);
 
% --- Executes on selection change in list_xyz.
function list_xyz_Callback(~, ~, ~)
% hObject    handle to list_xyz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns list_xyz contents as cell array
%        contents{get(hObject,'Value')} returns selected item from list_xyz


% --- Executes during object creation, after setting all properties.
function list_xyz_CreateFcn(hObject, ~, ~)
% hObject    handle to list_xyz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(~, ~, ~)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, ~, ~)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(~, ~, ~)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, ~, ~)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(~, ~, ~)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, ~, ~)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
