function FilteredSignal = HighpassButterworthFilter(Signal, samplingFrequency, cutoffFrequency)
    % Частота среза, нормированная по частоте Найквиста
    norm_cutoff_frequency = (2*cutoffFrequency)/samplingFrequency;
    if 0 >= norm_cutoff_frequency || norm_cutoff_frequency >=1 
        throw(MException('ButterworthFilter:CutoffFrequencyOutOfRange',...
                    'Частота среза %f вне предела (0 samplingFrequency(%f)).', ...
                    cutoffFrequency, samplingFrequency)); 
    end
    
    % Синтез фильтра верхних частот Баттерворта 1-го порядка
    % b и a - коэффициенты полиномов числителя и знаменателя функции 
    % передачи в порядке убывания степеней переменной z:
    [b,a] = butter(1,norm_cutoff_frequency,'high');
    
    % Фильтрация сигнала
    FilteredSignal = filter(b,a,Signal);
end

