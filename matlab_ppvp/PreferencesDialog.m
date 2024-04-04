function varargout = PreferencesDialog(varargin)
 
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PreferencesDialog_OpeningFcn, ...
                   'gui_OutputFcn',  @PreferencesDialog_OutputFcn, ...
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

function PreferencesDialog_OpeningFcn(hObject, ~, handles, varargin)
    owner_arg_name_idx = find(strcmp(varargin, 'Owner'),1,'last');
    if ~isempty(owner_arg_name_idx) ...
        && length(varargin) > owner_arg_name_idx ...
        && ishandle(varargin{owner_arg_name_idx+1})

        handles.Owner = varargin{owner_arg_name_idx+1};

        temp_dlg_units = get(hObject,'Units');
        set(hObject,'Units','Pixels');

        owner_position = getpixelposition(handles.Owner);
        dlg_position = get(hObject, 'Position');  

        % ”становка X и Y так, чтобы данное окно находилось посередине окна-владельца
        new_dlg_x = owner_position(1) + (owner_position(3)/2 - dlg_position(3)/2);
        new_dlg_y = owner_position(2) + (owner_position(4)/2 - dlg_position(4)/2);

        set(hObject, 'Position', [new_dlg_x, new_dlg_y, dlg_position(3), dlg_position(4)]);
        
        set(hObject,'Units', temp_dlg_units);
    end
    
    cur_preferences_arg_name_idx = find(strcmp(varargin, 'CurrentPreferences'),1,'last');
    if isempty(cur_preferences_arg_name_idx) ...
        || length(varargin) <= cur_preferences_arg_name_idx ...
        || ~IsPreferences(varargin{cur_preferences_arg_name_idx+1})
   
 %~IsPreferences(varargin{cur_preferences_arg_name_idx+1})
  
        handles.CurrentPreferences.TransmissionFactor.X = 0.001;
        handles.CurrentPreferences.TransmissionFactor.Y = 0.001;
        handles.CurrentPreferences.TransmissionFactor.Z = 0.001;
        handles.CurrentPreferences.TransmissionFactor.K = 0.001;
        
        handles.CurrentPreferences.WorkingFrequencyBand.Center = 160;
        handles.CurrentPreferences.WorkingFrequencyBand.Radius = 5;
        
        handles.CurrentPreferences.ModulPermissibleMaxDeviation = 0.03;
        handles.CurrentPreferences.ProjectionPermissibleMaxDeviation = 0.05;
        
        warning('“екущие настройки программы установлены из кода (использована компенсаци€)!');
    else
        handles.CurrentPreferences = varargin{cur_preferences_arg_name_idx+1};
        
        varargin{cur_preferences_arg_name_idx+1};
        
    end

    handles.NewPreferences = handles.CurrentPreferences;
    
    set(handles.TransmissionFactorXValue, 'String', handles.NewPreferences.TransmissionFactor.X*1000);
    set(handles.TransmissionFactorYValue, 'String', handles.NewPreferences.TransmissionFactor.Y*1000);
    set(handles.TransmissionFactorZValue, 'String', handles.NewPreferences.TransmissionFactor.Z*1000);
    set(handles.TransmissionFactorKValue, 'String', handles.NewPreferences.TransmissionFactor.K*1000);
    
    set(handles.WorkingFrequencyCenterValue, 'String', handles.NewPreferences.WorkingFrequencyBand.Center);
    set(handles.WorkingFrequencyBandwidthValue, 'String', handles.NewPreferences.WorkingFrequencyBand.Radius * 2);
    
    set(handles.ModulPermissibleMaxDeviationValue, 'String', handles.NewPreferences.ModulPermissibleMaxDeviation * 100);
    set(handles.ProjectionPermissibleMaxDeviationValue, 'String', handles.NewPreferences.ProjectionPermissibleMaxDeviation * 100);
    
    guidata(hObject, handles);
     
    uiwait(handles.PreferencesDialog);

function varargout = PreferencesDialog_OutputFcn(hObject, ~, handles) 
    varargout{1} = handles.NewPreferences;
    delete(hObject);

function TransmissionFactorXValue_Callback(hObject, ~, handles)
    value = str2double(get(hObject, 'String'));
    
    if isnan(value)
        set(hObject, 'String', handles.CurrentPreferences.TransmissionFactor.X*1000);
        errordlg('¬ведЄнное значение должно быть числом.','ќшибка ввода данных');
        return;
    end
    
    if value < 0
        set(hObject, 'String', handles.CurrentPreferences.TransmissionFactor.X*1000);
        errordlg('¬ведЄнное значение должно быть положительным числом, либо нулЄм.','ќшибка ввода данных');
        return;
    end
    
    handles.NewPreferences.TransmissionFactor.X = value/1000;
    
    guidata(hObject, handles);

function TransmissionFactorXValue_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function TransmissionFactorYValue_Callback(hObject, ~, handles)
    value = str2double(get(hObject, 'String'));
    
    if isnan(value)
        set(hObject, 'String', handles.CurrentPreferences.TransmissionFactor.Y*1000);
        errordlg('¬ведЄнное значение должно быть числом.','ќшибка ввода данных');
        return;
    end
    
    if value < 0
        set(hObject, 'String', handles.CurrentPreferences.TransmissionFactor.Y*1000);
        errordlg('¬ведЄнное значение должно быть положительным числом, либо нулЄм.','ќшибка ввода данных');
        return;
    end
    
    handles.NewPreferences.TransmissionFactor.Y = value/1000;
    
    guidata(hObject, handles);
    
function TransmissionFactorYValue_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function TransmissionFactorZValue_Callback(hObject, ~, handles)
    value = str2double(get(hObject, 'String'));
    
    if isnan(value)
        set(hObject, 'String', handles.CurrentPreferences.TransmissionFactor.Z*1000);
        errordlg('¬ведЄнное значение должно быть числом.','ќшибка ввода данных');
        return;
    end
    
    if value < 0
        set(hObject, 'String', handles.CurrentPreferences.TransmissionFactor.Z*1000);
        errordlg('¬ведЄнное значение должно быть положительным числом, либо нулЄм.','ќшибка ввода данных');
        return;
    end
    
    handles.NewPreferences.TransmissionFactor.Z = value/1000;
    
    guidata(hObject, handles);
    
function TransmissionFactorZValue_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function TransmissionFactorKValue_Callback(hObject, ~, handles)
    value = str2double(get(hObject, 'String'));
    
    if isnan(value)
        set(hObject, 'String', handles.CurrentPreferences.TransmissionFactor.K*1000);
        errordlg('¬ведЄнное значение должно быть числом.','ќшибка ввода данных');
        return;
    end
    
    if value < 0
        set(hObject, 'String', handles.CurrentPreferences.TransmissionFactor.K*1000);
        errordlg('¬ведЄнное значение должно быть положительным числом, либо нулЄм.','ќшибка ввода данных');
        return;
    end
    
    handles.NewPreferences.TransmissionFactor.K = value/1000;
    
    guidata(hObject, handles);
    
function TransmissionFactorKValue_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function WorkingFrequencyCenterValue_Callback(hObject, ~, handles)
     value = str2double(get(hObject, 'String'));
    
    if isnan(value)
        set(hObject, 'String', handles.CurrentPreferences.WorkingFrequencyBand.Center);
        errordlg('¬ведЄнное значение должно быть числом.','ќшибка ввода данных');
        return;
    end
    
    if value < 0
        set(hObject, 'String', handles.CurrentPreferences.WorkingFrequencyBand.Center);
        errordlg('¬ведЄнное значение должно быть положительным числом, либо нулЄм.','ќшибка ввода данных');
        return;
    end
    
    handles.NewPreferences.WorkingFrequencyBand.Center = value;
    
    guidata(hObject, handles);

function WorkingFrequencyCenterValue_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function WorkingFrequencyBandwidthValue_Callback(hObject, ~, handles)
     value = str2double(get(hObject, 'String'));
    
    if isnan(value)
        set(hObject, 'String', handles.CurrentPreferences.WorkingFrequencyBand.Radius * 2);
        errordlg('¬ведЄнное значение должно быть числом.','ќшибка ввода данных');
        return;
    end
    
    if value < 0
        set(hObject, 'String', handles.CurrentPreferences.WorkingFrequencyBand.Radius * 2);
        errordlg('¬ведЄнное значение должно быть положительным числом, либо нулЄм.','ќшибка ввода данных');
        return;
    end
    
    handles.NewPreferences.WorkingFrequencyBand.Radius = value / 2;
    
    guidata(hObject, handles);

function WorkingFrequencyBandwidthValue_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function ModulPermissibleMaxDeviationValue_Callback(hObject, ~, handles)
    value = str2double(get(hObject, 'String'));

    if isnan(value)
        set(hObject, 'String', handles.CurrentPreferences.ModulPermissibleMaxDeviation * 100);
        errordlg('¬ведЄнное значение должно быть числом.','ќшибка ввода данных');
        return;
    end
    
    if  0 > value || value > 100
        set(hObject, 'String', handles.CurrentPreferences.ModulPermissibleMaxDeviation * 100);
        errordlg('¬ведЄнное значение должно быть в пределах от 0 до 100 процентов.','ќшибка ввода данных');
        return;
    end
    
    handles.NewPreferences.ModulPermissibleMaxDeviation = value / 100;
    
    guidata(hObject, handles);

function ModulPermissibleMaxDeviationValue_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
function ProjectionPermissibleMaxDeviationValue_Callback(hObject, ~, handles)
    value = str2double(get(hObject, 'String'));

    if isnan(value)
        set(hObject, 'String', handles.CurrentPreferences.ProjectionPermissibleMaxDeviation * 100);
        errordlg('¬ведЄнное значение должно быть числом.','ќшибка ввода данных');
        return;
    end
    
    if  0 > value || value > 100
        set(hObject, 'String', handles.CurrentPreferences.ProjectionPermissibleMaxDeviation * 100);
        errordlg('¬ведЄнное значение должно быть в пределах от 0 до 100 процентов.','ќшибка ввода данных');
        return;
    end
    
    handles.NewPreferences.ProjectionPermissibleMaxDeviation = value / 100;
    
    guidata(hObject, handles);

function ProjectionPermissibleMaxDeviationValue_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function CancelButton_Callback(hObject, ~, handles)
    handles.NewPreferences = handles.CurrentPreferences;
    
    guidata(hObject, handles);
    
    uiresume(handles.PreferencesDialog);

function OkButton_Callback(~, ~, handles)
    uiresume(handles.PreferencesDialog);

function PreferencesDialog_CloseRequestFcn(hObject, ~, handles)
    handles.NewPreferences = handles.CurrentPreferences;
    
    guidata(hObject, handles);
    
    uiresume(handles.PreferencesDialog);
    
function IsPreferences = IsPreferences(preferences)

    if ~isstruct(preferences)
       IsPreferences = false;
       return;
    end
    
    if ~isfield(preferences,'WorkingFrequencyBand')
       IsPreferences = false;
       return;
    end    
    working_frequency_band = preferences.WorkingFrequencyBand;
    
    if ~(isfield(working_frequency_band,'Radius') ...
            && isa(working_frequency_band.Radius, 'double'))
       IsPreferences = false;
       return;
    end
    
    if ~(isfield(working_frequency_band,'Center') ...
            && isa(working_frequency_band.Center, 'double'))
       IsPreferences = false;
       return;
    end
    
    if ~isfield(preferences,'TransmissionFactor')
       IsPreferences = false;
       return;
    end    
    transmission_factors = preferences.TransmissionFactor;
    
    if ~(isfield(transmission_factors,'X') ...
            && isa(transmission_factors.X, 'double'))
       IsPreferences = false;
       return;
    end
    
    if ~(isfield(transmission_factors,'Y') ...
            && isa(transmission_factors.Y, 'double'))
       IsPreferences = false;
       return;
    end
    
    if ~(isfield(transmission_factors,'Z') ...
            && isa(transmission_factors.Z, 'double'))
       IsPreferences = false;
       return;
    end
    
    if ~(isfield(transmission_factors,'K') ...
            && isa(transmission_factors.K, 'double'))
       IsPreferences = false;
       return;
    end
    
     if ~(isfield(preferences,'ModulPermissibleMaxDeviation') ...
            && isa(preferences.ModulPermissibleMaxDeviation, 'double'))
       IsPreferences = false;
       return;
     end
 
%      ????????????????????????????????????????????????????????????????????
%      if ~(isfield(preferences,'SignificanceThreshold') ...
%             && isa(preferences.SignificanceThreshold, 'double'))
%        IsPreferences = false;
%        return;
%      end
     
     if ~(isfield(preferences,'ProjectionPermissibleMaxDeviation') ...
            && isa(preferences.ProjectionPermissibleMaxDeviation, 'double'))
       IsPreferences = false;
       return;
     end

    IsPreferences = true;