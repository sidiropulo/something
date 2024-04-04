classdef SignalDataFile < handle
    properties (Access=private)
        fileName
    end
    properties (Hidden)
        cleanup
    end
    methods
        function obj = SignalDataFile(fileName)
            obj.fileName = fileName;
            obj.cleanup = onCleanup(@()delete(obj));
        end
       
        function SignalData = ReadData(obj)
           try
                [numbers,header] = xlsread(obj.fileName);
           catch exc
               throw(MException('SignalDataFile:ReadingDataError',...
                    'Невозможно прочитать данные из файла %s. Причина: %s',obj.fileName,exc.message));
           end
           
           if ~isrow(header)
               throw(MException('SignalDataFile:ReadingDataError',...
                    'Невозможно прочитать данные из файла %s. Причина: заголовок даных в файле отсутствует или занимает более одной строки.', ...
                    obj.fileName));
           end
           
           row_size = numel(header);
           if row_size < 15
               throw(MException('SignalDataFile:ReadingDataError',...
                    'Невозможно прочитать данные из файла %s. Причина: в файле отсутствуют необходимые даные (меньшее количество столбцов).', ...
                    obj.fileName));
           end
           
           numbers_size = size(numbers);
           
           if numbers_size(2) < row_size
               throw(MException('SignalDataFile:ReadingDataError',...
                    'Невозможно прочитать данные из файла %s. Причина: в файле отсутствуют необходимые даные (меньшее количество столбцов).', ...
                    obj.fileName));
           end
           
           % Размер колонки не может быть меньше 4, т.к. необходимо хранить коэффициенты передачи в одном столбце
           if numbers_size(1) < 4
               throw(MException('SignalDataFile:ReadingDataError',...
                    'Невозможно прочитать данные из файла %s. Причина: в файле отсутствуют необходимые даные (меньшее количество строк).', ...
                    obj.fileName));
           end
           
           for column_index=1:row_size
               switch (header{column_index})
                   case 't'
                        SignalData.Signal.Time = numbers(:,column_index)';
                   case 'X'
                        SignalData.Signal.X = numbers(:,column_index)';
                   case 'Y'
                        SignalData.Signal.Y = numbers(:,column_index)';
                   case 'Z'
                        SignalData.Signal.Z = numbers(:,column_index)';
                   case 'K'
                        SignalData.Signal.K = numbers(:,column_index)';
                   case 'Fs'
                       SignalData.SamplingFrequency = numbers(1,column_index);
                   case 'Fc'
                       SignalData.Filter.LowerCutoffFrequency = numbers(1,column_index);
                       SignalData.Filter.UpperCutoffFrequency = numbers(2,column_index);
                   case 'Kпр'
                       SignalData.TransmissionFactor.X = numbers(1,column_index);
                       SignalData.TransmissionFactor.Y = numbers(2,column_index);
                       SignalData.TransmissionFactor.Z = numbers(3,column_index);
                       SignalData.TransmissionFactor.K = numbers(4,column_index);
                   case 'dF'
                       SignalData.FrequencyDelta = numbers(1,column_index);
                   case 'Angle'
                       SignalData.AxisAngle.Beta = numbers(1,column_index);
                       SignalData.AxisAngle.Gamma = numbers(2,column_index);
                   case 'Fw'
                       SignalData.WorkingFrequencyBand.Center = numbers(1,column_index);
                       SignalData.WorkingFrequencyBand.Radius = numbers(2,column_index)/2;
                   case 'Maxd|a|'
                       SignalData.ModulPermissibleMaxDeviation = numbers(1,column_index)/100;
                   case 'R'
                       SignalData.Decimator = numbers(1,column_index);
                   case 'a'
                       SignalData.SignificanceThreshold = numbers(1,column_index)/100;
                   case 'MaxdM'
                       SignalData.ProjectionPermissibleMaxDeviation = numbers(1,column_index)/100;
               end
           end
           
           if ~exist('SignalData','var')
               throw(MException('SignalDataFile:ReadingDataError',...
                    'Невозможно прочитать данные из файла %s. Причина: в файле отсутствуют необходимые даные (нет искомых параметров).', ...
                    obj.fileName));
           end
           
           try
               obj.CheckSignalData(SignalData);
           catch exc
               throw(MException('SignalDataFile:ReadingDataError',...
                    'Невозможно прочитать данные из файла %s. Причина: в файле отсутствуют необходимые даные. Подробнее: %s',obj.fileName,exc.message));
           end
               
        end
        
        function WriteData(obj,signalData)
           try
              obj.CheckSignalData(signalData);
           catch exc
               throw(MException('SignalDataFile:WritingDataError',...
                    'Невозможно сохранить данные в файл %s. Причина: %s',obj.fileName,exc.message));
           end
           
           writing_data = obj.CreateWritingData(signalData);
           
           [writing_status,writing_message] = xlswrite(obj.fileName,writing_data);
           if ~writing_status
               throw(MException('SignalDataFile:WritingDataError',...
                    'Невозможно сохранить данные в файл %s. Причина: %s',obj.fileName,writing_message)); 
           end
        end
       
        function obj = delete(obj)
        end
    end
    
    methods (Access=private)
        function CheckSignalData(obj,signalData)
            if ~isstruct(signalData)
                throw(MException('SignalDataFile:InvalidSignalData', ...
                    'Даные сигнала не являются структурой.'));
            end
            
            if ~(isfield(signalData, 'Signal') && isstruct(signalData.Signal)) 
                throw(MException('SignalDataFile:InvalidSignalData',...
                    'Даные сигнала не содержат сам сигнал (поле Signal).'));
            end
            signal = signalData.Signal;
            
            if ~(isfield(signal, 'Time') && obj.IsDoubleVector(signal.Time) && all(~isnan(signal.Time))) 
               throw(MException('SignalDataFile:InvalidSignalData',...
                    'Даные сигнала не содержат вектор времени (поле Time).'));
            end
            
            if ~(isfield(signal, 'X') && obj.IsDoubleVector(signal.X) && all(~isnan(signal.X))) 
               throw(MException('SignalDataFile:InvalidSignalData',...
                    'Даные сигнала не содержат сигнал с оси X (поле X).'));
            end
            
            if ~(isfield(signal, 'Y') && obj.IsDoubleVector(signal.Y) && all(~isnan(signal.Y))) 
               throw(MException('SignalDataFile:InvalidSignalData',...
                    'Даные сигнала не содержат сигнал с оси Y (поле Y).'));
            end 
            
            if ~(isfield(signal, 'Z') && obj.IsDoubleVector(signal.Z) && all(~isnan(signal.Z))) 
               throw(MException('SignalDataFile:InvalidSignalData',...
                    'Даные сигнала не содержат сигнал с оси Z (поле Z).'));
            end 
            
            if ~(isfield(signal, 'K') && obj.IsDoubleVector(signal.K) && all(~isnan(signal.K))) 
               throw(MException('SignalDataFile:InvalidSignalData',...
                    'Даные сигнала не содержат сигнал с оси K (поле K).'));
            end 
            
            if ~(isfield(signalData, 'SamplingFrequency') ...
                    && obj.IsDoublePrimitive(signalData.SamplingFrequency)...
                    &&  signalData.SamplingFrequency > 0) 
               throw(MException('SignalDataFile:InvalidSignalData',...
                    'Даные сигнала не содержат корректную частоту дискретизации (поле SamplingFrequency).'));
            end 
            
            if ~(isfield(signalData, 'Filter') && isstruct(signalData.Filter)) 
               throw(MException('SignalDataFile:InvalidSignalData',...
                    'Даные сигнала не содержат настройки фильтров (поле Filter).'));
            end
            filter = signalData.Filter;
            
            if ~(isfield(filter, 'UpperCutoffFrequency') ...
                    && obj.IsDoublePrimitive(filter.UpperCutoffFrequency)...
                    && filter.UpperCutoffFrequency > 0 ...
                    && filter.UpperCutoffFrequency < signalData.SamplingFrequency/2) 
               throw(MException('SignalDataFile:InvalidSignalData',...
                    'Даные сигнала не содержат корректную верхнюю частотату среза (поле Filter.UpperCutoffFrequency).'));
            end 
            
            if ~(isfield(filter, 'LowerCutoffFrequency') ...
                    && obj.IsDoublePrimitive(filter.LowerCutoffFrequency)...
                    && 0 < filter.LowerCutoffFrequency ...
                    && filter.LowerCutoffFrequency <= filter.UpperCutoffFrequency) 
               throw(MException('SignalDataFile:InvalidSignalData',...
                    'Даные сигнала не содержат корректную нижнюю частотату среза (поле Filter.LowerCutoffFrequency).'));
            end 
            
            if ~(isfield(signalData, 'TransmissionFactor')...
                    && isstruct(signalData.TransmissionFactor)) 
               throw(MException('SignalDataFile:InvalidSignalData',...
                    'Даные сигнала не содержат коэффициенты преобразования (поле TransmissionFactor).'));
            end
            transmission_factor = signalData.TransmissionFactor;
            
            if ~(isfield(transmission_factor, 'X') ...
                    && obj.IsDoublePrimitive(transmission_factor.X)...
                    &&  transmission_factor.X > 0) 
               throw(MException('SignalDataFile:InvalidSignalData',...
                    'Даные сигнала не содержат корректный коэффициент преобразования для оси X (поле TransmissionFactor.X)'));
            end 
            
            if ~(isfield(transmission_factor, 'Y') ...
                    && obj.IsDoublePrimitive(transmission_factor.Y)...
                    &&  transmission_factor.Y > 0) 
               throw(MException('SignalDataFile:InvalidSignalData',...
                    'Даные сигнала не содержат корректный коэффициент преобразования для оси Y (поле TransmissionFactor.Y).'));
            end 
            
            if ~(isfield(transmission_factor, 'Z') ...
                    && obj.IsDoublePrimitive(transmission_factor.Z)...
                    &&  transmission_factor.Z > 0) 
               throw(MException('SignalDataFile:InvalidSignalData',...
                    'Даные сигнала не содержат корректный коэффициент преобразования для оси Z (поле TransmissionFactor.Z).'));
            end 
            
            if ~(isfield(transmission_factor, 'K') ...
                    && obj.IsDoublePrimitive(transmission_factor.K)...
                    &&  transmission_factor.K > 0) 
               throw(MException('SignalDataFile:InvalidSignalData',...
                    'Даные сигнала не содержат корректный коэффициент преобразования для оси K (поле TransmissionFactor.K).'));
            end 
            
            if ~(isfield(signalData, 'FrequencyDelta') ...
                    && obj.IsDoublePrimitive(signalData.FrequencyDelta)...
                    &&  signalData.FrequencyDelta > 0) 
               throw(MException('SignalDataFile:InvalidSignalData',...
                    'Даные сигнала не содержат корректную величину шага по частоте (поле FrequencyDelta).'));
            end 
            
            if ~(isfield(signalData, 'AxisAngle')...
                    && isstruct(signalData.AxisAngle)) 
               throw(MException('SignalDataFile:InvalidSignalData',...
                    'Даные сигнала не содержат углы оси K (поле AxisAngle).'));
            end
            axis_angle = signalData.AxisAngle;
            
            if ~(isfield(axis_angle, 'Beta') ...
                    && obj.IsDoublePrimitive(axis_angle.Beta)) 
               throw(MException('SignalDataFile:InvalidSignalData',...
                    'Даные сигнала не содержат угол Бета оси K (поле AxisAngle.Beta).'));
            end 
            
            if ~(isfield(axis_angle, 'Gamma') ...
                    && obj.IsDoublePrimitive(axis_angle.Gamma)) 
               throw(MException('SignalDataFile:InvalidSignalData',...
                    'Даные сигнала не содержат угол Гамма оси K (поле AxisAngle.Gamma).'));
            end 
            
            if ~(isfield(signalData, 'WorkingFrequencyBand')...
                    && isstruct(signalData.WorkingFrequencyBand)) 
               throw(MException('SignalDataFile:InvalidSignalData',...
                    'Даные сигнала не содержат параметры рабочей полосы частот (поле WorkingFrequencyBand).'));
            end
            working_frequency_band = signalData.WorkingFrequencyBand;
            
            if ~(isfield(working_frequency_band, 'Center') ...
                    && obj.IsDoublePrimitive(working_frequency_band.Center)...
                    &&  working_frequency_band.Center >= 0) 
               throw(MException('SignalDataFile:InvalidSignalData',...
                    'Даные сигнала не содержат корректную величину центра рабочей полосы частот (поле WorkingFrequencyBand.Center).'));
            end 
            
            if ~(isfield(working_frequency_band, 'Radius') ...
                    && obj.IsDoublePrimitive(working_frequency_band.Radius)...
                    &&  working_frequency_band.Radius >= 0) 
               throw(MException('SignalDataFile:InvalidSignalData',...
                    'Даные сигнала не содержат корректную величину радиуса рабочей полосы частот (поле WorkingFrequencyBand.Radius).'));
            end 
            
            if ~(isfield(signalData, 'ModulPermissibleMaxDeviation') ...
                    && obj.IsDoublePrimitive(signalData.ModulPermissibleMaxDeviation)...
                    &&  0 <= signalData.ModulPermissibleMaxDeviation  ...
                    && signalData.ModulPermissibleMaxDeviation <= 1) 
               throw(MException('SignalDataFile:InvalidSignalData',...
                    'Даные сигнала не содержат корректную максимальную величину отклонения модулей виброускорения (поле ModulPermissibleMaxDeviation).'));
            end 
            
            if ~(isfield(signalData, 'Decimator') && obj.IsDoublePrimitive(signalData.Decimator)...
                    &&  signalData.Decimator > 0 && round(signalData.Decimator) == signalData.Decimator) 
               throw(MException('SignalDataFile:InvalidSignalData',...
                    'Даные сигнала не содержат корректную величину дециматора (поле Decimator).'));
            end 
            
            if ~(isfield(signalData, 'SignificanceThreshold') ...
                    && obj.IsDoublePrimitive(signalData.SignificanceThreshold)...
                    &&  0 <= signalData.SignificanceThreshold  ...
                    && signalData.SignificanceThreshold <= 1) 
               throw(MException('SignalDataFile:InvalidSignalData',...
                    'Даные сигнала не содержат корректную величину порога значимости (поле SignificanceThreshold).'));
            end 
            
            if ~(isfield(signalData, 'ProjectionPermissibleMaxDeviation') ...
                    && obj.IsDoublePrimitive(signalData.ProjectionPermissibleMaxDeviation)...
                    &&  0 <= signalData.ProjectionPermissibleMaxDeviation  ...
                    && signalData.ProjectionPermissibleMaxDeviation <= 1) 
               throw(MException('SignalDataFile:InvalidSignalData',...
                    'Даные сигнала не содержат корректную максимальную величину отклонения расчётных и измеренных значений ортогональных проекций (поле ProjectionPermissibleMaxDeviation).'));
            end 
        end
        
        
        function IsDoubleVector = IsDoubleVector(~, doubleVector)
            if ~isempty(doubleVector) && isvector(doubleVector) ...
                    && isa(doubleVector, 'double')
                IsDoubleVector = true;
            else
                IsDoubleVector = false;
            end
        end
        
        function IsDoublePrimitive = IsDoublePrimitive(~, doublePrimitive)
            if numel(doublePrimitive)==1 && isa(doublePrimitive, 'double')
                IsDoublePrimitive = true;
            else
                IsDoublePrimitive = false;
            end
        end
        
        function WritingData = CreateWritingData(obj,signalData)
             % Длина колонки не может быть меньше 4, т.к. необходимо хранить коэффициенты передачи в одном столбце
             data_column_length = max([numel(signalData.Signal.Time) numel(signalData.Signal.X) numel(signalData.Signal.Y) ...
                 numel(signalData.Signal.Z) numel(signalData.Signal.K) 4]);
             
             header = string.empty;
             numbers = [];
             
             [header, numbers] = obj.AddWritingData(header,numbers,'t', signalData.Signal.Time, data_column_length);
             [header, numbers] = obj.AddWritingData(header,numbers,'X', signalData.Signal.X, data_column_length);   
             [header, numbers] = obj.AddWritingData(header,numbers,'Y', signalData.Signal.Y, data_column_length);   
             [header, numbers] = obj.AddWritingData(header,numbers,'Z', signalData.Signal.Z, data_column_length);   
             [header, numbers] = obj.AddWritingData(header,numbers,'K', signalData.Signal.K, data_column_length);  
             
             [header, numbers] = obj.AddWritingData(header,numbers,'Fs', signalData.SamplingFrequency, data_column_length); 
             
             [header, numbers] = obj.AddWritingData(header,numbers,'Fc', [signalData.Filter.LowerCutoffFrequency ...
                 signalData.Filter.UpperCutoffFrequency], data_column_length);
             
             [header, numbers] = obj.AddWritingData(header,numbers,'Kпр', [signalData.TransmissionFactor.X ...
                 signalData.TransmissionFactor.Y signalData.TransmissionFactor.Z signalData.TransmissionFactor.K], ...
                 data_column_length);
             
             [header, numbers] = obj.AddWritingData(header,numbers,'dF', signalData.FrequencyDelta, data_column_length);
             
             [header, numbers] = obj.AddWritingData(header,numbers,'Angle', [signalData.AxisAngle.Beta ...
                 signalData.AxisAngle.Gamma], data_column_length);
             
             [header, numbers] = obj.AddWritingData(header,numbers,'Fw', [signalData.WorkingFrequencyBand.Center ...
                 signalData.WorkingFrequencyBand.Radius*2], data_column_length);
             
             [header, numbers] = obj.AddWritingData(header,numbers,'Maxd|a|', signalData.ModulPermissibleMaxDeviation*100, data_column_length); 
             
             [header, numbers] = obj.AddWritingData(header,numbers,'R', signalData.Decimator, data_column_length);
             
             [header, numbers] = obj.AddWritingData(header,numbers,'a', signalData.SignificanceThreshold*100, data_column_length); 
             
             [header, numbers] = obj.AddWritingData(header,numbers,'MaxdM', signalData.ProjectionPermissibleMaxDeviation*100, data_column_length); 
             
             WritingData = [convertStringsToChars(header); num2cell(numbers)];
         end
         
        function [Header, Numbers] = AddWritingData(~,currentHeader, currentNumber, ...
                newColumnName, newDataColumn, dataColumnLength)
            
             Header = [currentHeader newColumnName];
                       
             if numel(newDataColumn) < dataColumnLength
                if isrow(newDataColumn)
                    newDataColumn(end+1:dataColumnLength) = 0;
                else
                    newDataColumn(end+1:dataColumnLength,1) = 0;
                end
             end
             
             if isrow(newDataColumn)
                Numbers = [currentNumber newDataColumn'];
             else
                Numbers = [currentNumber newDataColumn];
             end
        end
    end
end

