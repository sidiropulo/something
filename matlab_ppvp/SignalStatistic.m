function SignalStatistic = SignalStatistic(signalData)
    SignalStatistic.Time =  signalData.Signal.Time;
    
    SignalStatistic.X.RawSignal =  signalData.Signal.X;
    SignalStatistic.Y.RawSignal =  signalData.Signal.Y;
    SignalStatistic.Z.RawSignal =  signalData.Signal.Z;
    SignalStatistic.K.RawSignal =  signalData.Signal.K;
    
    SignalStatistic.SamplingFrequency = signalData.SamplingFrequency;
    SignalStatistic.Filter = signalData.Filter;
    
    SignalStatistic.X.FilteredSignal =  FilteredSignal(SignalStatistic.X.RawSignal, ...
        SignalStatistic.SamplingFrequency, SignalStatistic.Filter);
    SignalStatistic.Y.FilteredSignal =  FilteredSignal(SignalStatistic.Y.RawSignal, ...
        SignalStatistic.SamplingFrequency, SignalStatistic.Filter);
    SignalStatistic.Z.FilteredSignal =  FilteredSignal(SignalStatistic.Z.RawSignal, ...
        SignalStatistic.SamplingFrequency, SignalStatistic.Filter);
    SignalStatistic.K.FilteredSignal =  FilteredSignal(SignalStatistic.K.RawSignal, ...
       SignalStatistic.SamplingFrequency, SignalStatistic.Filter);
    
    SignalStatistic.X.TransmissionFactor =  signalData.TransmissionFactor.X;
    SignalStatistic.Y.TransmissionFactor =  signalData.TransmissionFactor.Y;
    SignalStatistic.Z.TransmissionFactor =  signalData.TransmissionFactor.Z;
    SignalStatistic.K.TransmissionFactor =  signalData.TransmissionFactor.K;
    
    SignalStatistic.X.Acceleration.Amplitude  = Acceleration(SignalStatistic.X.FilteredSignal, ...
        SignalStatistic.X.TransmissionFactor);
    SignalStatistic.Y.Acceleration.Amplitude = Acceleration(SignalStatistic.Y.FilteredSignal, ...
        SignalStatistic.Y.TransmissionFactor);
    SignalStatistic.Z.Acceleration.Amplitude = Acceleration(SignalStatistic.Z.FilteredSignal, ...
        SignalStatistic.Z.TransmissionFactor);
    SignalStatistic.K.Acceleration.Amplitude = Acceleration(SignalStatistic.K.FilteredSignal, ...
        SignalStatistic.K.TransmissionFactor);
    
    target_spectrum_length = 2^nextpow2(SignalStatistic.SamplingFrequency / signalData.FrequencyDelta);
    data_length = max([numel(SignalStatistic.X.RawSignal) numel(SignalStatistic.Y.RawSignal) ...
        numel(SignalStatistic.Z.RawSignal) numel(SignalStatistic.K.RawSignal)]);
    
    if (data_length >= target_spectrum_length)
        spectrum_length = target_spectrum_length;
    else
        spectrum_length = data_length;
    end
    
    frequency_start = 0;    
    SignalStatistic.FrequencyDelta = SignalStatistic.SamplingFrequency / spectrum_length;
    frequency_end = SignalStatistic.SamplingFrequency - SignalStatistic.FrequencyDelta;
    SignalStatistic.Frequency = frequency_start:SignalStatistic.FrequencyDelta:frequency_end;
    
    SignalStatistic.X.Spectrum = SignalSpectrum(SignalStatistic.X.Acceleration.Amplitude, spectrum_length);
    SignalStatistic.Y.Spectrum = SignalSpectrum(SignalStatistic.Y.Acceleration.Amplitude, spectrum_length);
    SignalStatistic.Z.Spectrum = SignalSpectrum(SignalStatistic.Z.Acceleration.Amplitude, spectrum_length);
    SignalStatistic.K.Spectrum = SignalSpectrum(SignalStatistic.K.Acceleration.Amplitude, spectrum_length);
   
    SignalStatistic.X.Phase = SignalPhase(SignalStatistic.X.Acceleration.Amplitude, spectrum_length);
    SignalStatistic.Y.Phase = SignalPhase(SignalStatistic.Y.Acceleration.Amplitude, spectrum_length);
    SignalStatistic.Z.Phase = SignalPhase(SignalStatistic.Z.Acceleration.Amplitude, spectrum_length);
    SignalStatistic.K.Phase = SignalPhase(SignalStatistic.K.Acceleration.Amplitude, spectrum_length);
    
    lower_frequency_idx = find(SignalStatistic.Filter.LowerCutoffFrequency <= SignalStatistic.Frequency, 1);    
    upper_frequency_idx = find(SignalStatistic.Frequency <= SignalStatistic.Filter.UpperCutoffFrequency, 1, 'last');
    
    SignalStatistic.Frequency =  SignalStatistic.Frequency(lower_frequency_idx:upper_frequency_idx);
    
    SignalStatistic.X.Spectrum = SignalStatistic.X.Spectrum(lower_frequency_idx:upper_frequency_idx);
    SignalStatistic.Y.Spectrum = SignalStatistic.Y.Spectrum(lower_frequency_idx:upper_frequency_idx);
    SignalStatistic.Z.Spectrum = SignalStatistic.Z.Spectrum(lower_frequency_idx:upper_frequency_idx);
    SignalStatistic.K.Spectrum = SignalStatistic.K.Spectrum(lower_frequency_idx:upper_frequency_idx);
    
    SignalStatistic.X.Phase = SignalStatistic.X.Phase(lower_frequency_idx:upper_frequency_idx);
    SignalStatistic.Y.Phase = SignalStatistic.Y.Phase(lower_frequency_idx:upper_frequency_idx);
    SignalStatistic.Z.Phase = SignalStatistic.Z.Phase(lower_frequency_idx:upper_frequency_idx);
    SignalStatistic.K.Phase = SignalStatistic.K.Phase(lower_frequency_idx:upper_frequency_idx);
    
    SignalStatistic.X.Spectrum = times(SignalStatistic.X.Spectrum, ...
        CorrectSpectrumPhase(SignalStatistic.X.Phase, SignalStatistic.Z.Phase));
    SignalStatistic.Y.Spectrum = times(SignalStatistic.Y.Spectrum, ...
        CorrectSpectrumPhase(SignalStatistic.Y.Phase, SignalStatistic.Z.Phase));
    SignalStatistic.K.Spectrum = times(SignalStatistic.K.Spectrum, ...
        CorrectSpectrumPhase(SignalStatistic.K.Phase, SignalStatistic.Z.Phase));
    
    acceleration_vector_x_projection =  VectorXProjection(signalData.AxisAngle.Beta, ...
        signalData.AxisAngle.Gamma, SignalStatistic.K.Spectrum, ...
        SignalStatistic.Y.Spectrum, SignalStatistic.Z.Spectrum);
    
    acceleration_vector_y_projection =  VectorYProjection(signalData.AxisAngle.Beta, ...
        signalData.AxisAngle.Gamma, SignalStatistic.K.Spectrum, ...
        SignalStatistic.X.Spectrum, SignalStatistic.Z.Spectrum);
    
    acceleration_vector_z_projection =  VectorZProjection(signalData.AxisAngle.Beta, ...
        signalData.AxisAngle.Gamma, SignalStatistic.K.Spectrum, ...
        SignalStatistic.X.Spectrum,SignalStatistic.Y.Spectrum);
    
    SignalStatistic.AccelerationVector.Actual.Modul = Norm(SignalStatistic.X.Spectrum, ...
        SignalStatistic.Y.Spectrum, SignalStatistic.Z.Spectrum);
    SignalStatistic.AccelerationVector.XProjection.Modul = Norm(acceleration_vector_x_projection, ...
        SignalStatistic.Y.Spectrum, SignalStatistic.Z.Spectrum);
    SignalStatistic.AccelerationVector.YProjection.Modul = Norm(SignalStatistic.X.Spectrum, ...
        acceleration_vector_y_projection, SignalStatistic.Z.Spectrum);
    SignalStatistic.AccelerationVector.ZProjection.Modul = Norm(SignalStatistic.X.Spectrum, ...
        SignalStatistic.Y.Spectrum, acceleration_vector_z_projection);
    
    SignalStatistic.WorkingFrequencyBand = signalData.WorkingFrequencyBand;
    
    lower_working_frequency = SignalStatistic.WorkingFrequencyBand.Center - SignalStatistic.WorkingFrequencyBand.Radius;
    lower_working_frequency_idx = find(lower_working_frequency <= SignalStatistic.Frequency, 1); 
    upper_working_frequency = SignalStatistic.WorkingFrequencyBand.Center + SignalStatistic.WorkingFrequencyBand.Radius;
    upper_working_frequency_idx = find(SignalStatistic.Frequency <= upper_working_frequency, 1, 'last');
    
    SignalStatistic.AccelerationVector.Actual.ModulRMS = rms(SignalStatistic.AccelerationVector.Actual.Modul(lower_working_frequency_idx:upper_working_frequency_idx));
    SignalStatistic.AccelerationVector.XProjection.ModulRMS = rms(SignalStatistic.AccelerationVector.XProjection.Modul(lower_working_frequency_idx:upper_working_frequency_idx));
    SignalStatistic.AccelerationVector.YProjection.ModulRMS = rms(SignalStatistic.AccelerationVector.YProjection.Modul(lower_working_frequency_idx:upper_working_frequency_idx));
    SignalStatistic.AccelerationVector.ZProjection.ModulRMS = rms(SignalStatistic.AccelerationVector.ZProjection.Modul(lower_working_frequency_idx:upper_working_frequency_idx));
     
    SignalStatistic.AccelerationVector.AverageModul = mean([SignalStatistic.AccelerationVector.Actual.ModulRMS; SignalStatistic.AccelerationVector.XProjection.ModulRMS; ...
        SignalStatistic.AccelerationVector.YProjection.ModulRMS; SignalStatistic.AccelerationVector.ZProjection.ModulRMS]);
    
    SignalStatistic.AccelerationVector.Actual.RelativeDeviation = RelativeDeviation(SignalStatistic.AccelerationVector.Actual.ModulRMS, ...
        SignalStatistic.AccelerationVector.AverageModul);
    SignalStatistic.AccelerationVector.XProjection.RelativeDeviation = RelativeDeviation(SignalStatistic.AccelerationVector.XProjection.ModulRMS, ...
        SignalStatistic.AccelerationVector.AverageModul);
    SignalStatistic.AccelerationVector.YProjection.RelativeDeviation = RelativeDeviation(SignalStatistic.AccelerationVector.YProjection.ModulRMS, ...
        SignalStatistic.AccelerationVector.AverageModul);
    SignalStatistic.AccelerationVector.ZProjection.RelativeDeviation = RelativeDeviation(SignalStatistic.AccelerationVector.ZProjection.ModulRMS, ...
        SignalStatistic.AccelerationVector.AverageModul);
    
    SignalStatistic.AccelerationVector.PermissibleMaxDeviation = signalData.ModulPermissibleMaxDeviation;
    
    abs_modul_permissible_max_deviation = abs(SignalStatistic.AccelerationVector.PermissibleMaxDeviation);
    SignalStatistic.AccelerationVector.Actual.IsDeviationPermissible = abs(SignalStatistic.AccelerationVector.Actual.RelativeDeviation) - abs_modul_permissible_max_deviation <= eps;
    SignalStatistic.AccelerationVector.XProjection.IsDeviationPermissible = abs(SignalStatistic.AccelerationVector.XProjection.RelativeDeviation) - abs_modul_permissible_max_deviation <= eps;
    SignalStatistic.AccelerationVector.YProjection.IsDeviationPermissible = abs(SignalStatistic.AccelerationVector.YProjection.RelativeDeviation) - abs_modul_permissible_max_deviation <= eps;
    SignalStatistic.AccelerationVector.ZProjection.IsDeviationPermissible = abs(SignalStatistic.AccelerationVector.ZProjection.RelativeDeviation) - abs_modul_permissible_max_deviation <= eps;
    
    SignalStatistic.AccelerationVector.IsDeviationPermissible = SignalStatistic.AccelerationVector.Actual.IsDeviationPermissible && ...
        SignalStatistic.AccelerationVector.XProjection.IsDeviationPermissible && SignalStatistic.AccelerationVector.YProjection.IsDeviationPermissible && ...
        SignalStatistic.AccelerationVector.ZProjection.IsDeviationPermissible;
    
    SignalStatistic.X.Acceleration.RMS = rms(SignalStatistic.X.Spectrum(lower_working_frequency_idx:upper_working_frequency_idx));
    SignalStatistic.Y.Acceleration.RMS = rms(SignalStatistic.Y.Spectrum(lower_working_frequency_idx:upper_working_frequency_idx));
    SignalStatistic.Z.Acceleration.RMS = rms(SignalStatistic.Z.Spectrum(lower_working_frequency_idx:upper_working_frequency_idx));
    SignalStatistic.K.Acceleration.RMS = rms(SignalStatistic.K.Spectrum(lower_working_frequency_idx:upper_working_frequency_idx));
    
    SignalStatistic.Acceleration.AverageRMS = mean([SignalStatistic.X.Acceleration.RMS; SignalStatistic.Y.Acceleration.RMS; ...
        SignalStatistic.Z.Acceleration.RMS; SignalStatistic.K.Acceleration.RMS]);
    
    SignalStatistic.X.Acceleration.RMSRelativeDeviation =  RelativeDeviation(SignalStatistic.X.Acceleration.RMS, ...
        SignalStatistic.Acceleration.AverageRMS);
    SignalStatistic.Y.Acceleration.RMSRelativeDeviation =  RelativeDeviation(SignalStatistic.Y.Acceleration.RMS, ...
        SignalStatistic.Acceleration.AverageRMS);
    SignalStatistic.Z.Acceleration.RMSRelativeDeviation =  RelativeDeviation(SignalStatistic.Z.Acceleration.RMS, ...
        SignalStatistic.Acceleration.AverageRMS);
    SignalStatistic.K.Acceleration.RMSRelativeDeviation =  RelativeDeviation(SignalStatistic.K.Acceleration.RMS, ...
        SignalStatistic.Acceleration.AverageRMS);
    
    SignalStatistic.X.Acceleration.RMSSignificanceFactor = 1 - abs(SignalStatistic.X.Acceleration.RMSRelativeDeviation);
    SignalStatistic.Y.Acceleration.RMSSignificanceFactor = 1 - abs(SignalStatistic.Y.Acceleration.RMSRelativeDeviation);
    SignalStatistic.Z.Acceleration.RMSSignificanceFactor = 1 - abs(SignalStatistic.Z.Acceleration.RMSRelativeDeviation);
    SignalStatistic.K.Acceleration.RMSSignificanceFactor = 1 - abs(SignalStatistic.K.Acceleration.RMSRelativeDeviation);
    
    SignalStatistic.Acceleration.SignificanceThreshold = signalData.SignificanceThreshold;
    
    abs_significance_threshold = abs(SignalStatistic.Acceleration.SignificanceThreshold);
    SignalStatistic.X.Acceleration.IsRMSSignificance = SignalStatistic.X.Acceleration.RMSSignificanceFactor - abs_significance_threshold >= -eps;
    SignalStatistic.Y.Acceleration.IsRMSSignificance = SignalStatistic.Y.Acceleration.RMSSignificanceFactor - abs_significance_threshold >= -eps;
    SignalStatistic.Z.Acceleration.IsRMSSignificance = SignalStatistic.Z.Acceleration.RMSSignificanceFactor - abs_significance_threshold >= -eps;
    SignalStatistic.K.Acceleration.IsRMSSignificance = SignalStatistic.K.Acceleration.RMSSignificanceFactor - abs_significance_threshold >= -eps;
    
    x_projection_rms =  VectorXProjection(signalData.AxisAngle.Beta, ...
        signalData.AxisAngle.Gamma, SignalStatistic.K.Acceleration.RMS, ...
        SignalStatistic.Y.Acceleration.RMS, SignalStatistic.Z.Acceleration.RMS);
    
    y_projection_rms =  VectorYProjection(signalData.AxisAngle.Beta, ...
        signalData.AxisAngle.Gamma, SignalStatistic.K.Acceleration.RMS, ...
        SignalStatistic.X.Acceleration.RMS, SignalStatistic.Z.Acceleration.RMS);
    
    z_projection_rms =  VectorZProjection(signalData.AxisAngle.Beta, ...
        signalData.AxisAngle.Gamma, SignalStatistic.K.Acceleration.RMS, ...
        SignalStatistic.X.Acceleration.RMS,SignalStatistic.Y.Acceleration.RMS);
    
    k_projection_rms =  VectorKProjection(signalData.AxisAngle.Beta, ...
        signalData.AxisAngle.Gamma, SignalStatistic.X.Acceleration.RMS, ...
        SignalStatistic.Y.Acceleration.RMS,SignalStatistic.Z.Acceleration.RMS);
    
    SignalStatistic.X.Acceleration.RMSProjectionRelativeDeviation =  RelativeDeviation(SignalStatistic.X.Acceleration.RMS, ...
        x_projection_rms);
    SignalStatistic.Y.Acceleration.RMSProjectionRelativeDeviation =  RelativeDeviation(SignalStatistic.Y.Acceleration.RMS, ...
        y_projection_rms);
    SignalStatistic.Z.Acceleration.RMSProjectionRelativeDeviation =  RelativeDeviation(SignalStatistic.Z.Acceleration.RMS, ...
        z_projection_rms);
    SignalStatistic.K.Acceleration.RMSProjectionRelativeDeviation =  RelativeDeviation(SignalStatistic.K.Acceleration.RMS, ...
        k_projection_rms);
    
    SignalStatistic.Acceleration.ProjectionPermissibleMaxDeviation = signalData.ProjectionPermissibleMaxDeviation;
    
    abs_projection_permissible_max_deviation = abs(SignalStatistic.Acceleration.ProjectionPermissibleMaxDeviation);
    SignalStatistic.X.Acceleration.IsDeviationPermissible = SignalStatistic.X.Acceleration.IsRMSSignificance || ...
        abs(SignalStatistic.X.Acceleration.RMSProjectionRelativeDeviation) - abs_projection_permissible_max_deviation <= eps;
    SignalStatistic.Y.Acceleration.IsDeviationPermissible = SignalStatistic.Y.Acceleration.IsRMSSignificance || ...
        abs(SignalStatistic.Y.Acceleration.RMSProjectionRelativeDeviation) - abs_projection_permissible_max_deviation <= eps;
    SignalStatistic.Z.Acceleration.IsDeviationPermissible = SignalStatistic.Z.Acceleration.IsRMSSignificance || ...
        abs(SignalStatistic.Z.Acceleration.RMSProjectionRelativeDeviation) - abs_projection_permissible_max_deviation <= eps;
    SignalStatistic.K.Acceleration.IsDeviationPermissible = SignalStatistic.K.Acceleration.IsRMSSignificance || ...
        abs(SignalStatistic.K.Acceleration.RMSProjectionRelativeDeviation) - abs_projection_permissible_max_deviation <= eps;
    
    SignalStatistic.Acceleration.IsDeviationPermissible = SignalStatistic.X.Acceleration.IsDeviationPermissible && ...
       SignalStatistic.Y.Acceleration.IsDeviationPermissible && SignalStatistic.Z.Acceleration.IsDeviationPermissible && ...
       SignalStatistic.K.Acceleration.IsDeviationPermissible;
   
   SignalStatistic.IsAccelerometerEfficient = SignalStatistic.AccelerationVector.IsDeviationPermissible && SignalStatistic.Acceleration.IsDeviationPermissible;
    
    SignalStatistic.AccelerationVector.Position.Start.X  = 0;
    SignalStatistic.AccelerationVector.Position.Start.Y  = 0;
    SignalStatistic.AccelerationVector.Position.Start.Z  = 0;
    
    [~, max_acceleration_vector_modul_idx] = max(SignalStatistic.AccelerationVector.Actual.Modul(lower_working_frequency_idx:upper_working_frequency_idx));
    % функция max() возвращает индекс в указанной полосе частот (локальный
    % - от lower_working_frequency до upper_working_frequency).
    % Поэтому необходимо выполнить пересчёт max_acceleration_vector_modul_idx 
    % на индекс во всём спектре (глобальный - от LowerCutoffFrequency до
    % UpperCutoffFrequency).
    max_acceleration_vector_modul_idx = lower_working_frequency_idx + max_acceleration_vector_modul_idx - 1;
    SignalStatistic.AccelerationVector.Position.End.X  = SignalStatistic.X.Spectrum(max_acceleration_vector_modul_idx);
    SignalStatistic.AccelerationVector.Position.End.Y  = SignalStatistic.Y.Spectrum(max_acceleration_vector_modul_idx);
    SignalStatistic.AccelerationVector.Position.End.Z  = SignalStatistic.Z.Spectrum(max_acceleration_vector_modul_idx);
end

